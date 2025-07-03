// mobile/lib/shared/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/showme_design_system.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_state.dart';
import '../../../features/card/bloc/card_bloc.dart';
import '../../../features/crm/bloc/crm_bloc.dart';
import '../widgets/showme_card_widget.dart';
import '../widgets/premium_action_card.dart';
import '../widgets/stats_overview.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/showme_app_bar.dart';
import '../../models/contact_exchange.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _contentStaggerAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadInitialData();
  }

  void _setupAnimations() {
    _headerController = AnimationController(
      duration: ShowmeDesign.slowDuration,
      vsync: this,
    );

    _contentController = AnimationController(
      duration: ShowmeDesign.extraSlowDuration,
      vsync: this,
    );

    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: ShowmeDesign.primaryCurve,
    ));

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: ShowmeDesign.primaryCurve,
    ));

    _contentStaggerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: ShowmeDesign.primaryCurve,
    ));

    // Démarrer les animations
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _contentController.forward();
    });
  }

  void _loadInitialData() {
    // Charger les données initiales
    context.read<CardBloc>().add(CardLoadRequested());
    context.read<CrmBloc>().add(CrmStatsRequested());
    context.read<CrmBloc>().add(CrmContactsRequested());
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: ShowmeDesign.primaryPurple,
        child: CustomScrollView(
          slivers: [
            ShowmeSliverAppBar(
              title: 'Accueil',
              showWelcomeSection: true,
              showProfileIcon: true,
              onProfilePressed: () => context.go('/profile'),
            ),
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _contentController,
                builder: (context, child) {
                  return Column(
                    children: [
                      _buildMyCardSection(),
                      _buildQuickActionsSection(),
                      _buildStatsSection(),
                      _buildRecentActivitySection(),
                      SizedBox(height: ShowmeDesign.spacing3xl),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildMyCardSection() {
    return AnimatedBuilder(
      animation: _contentStaggerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _contentStaggerAnimation.value) * 30),
          child: Opacity(
            opacity: _contentStaggerAnimation.value,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<CardBloc, CardState>(
                    builder: (context, state) {
                      if (state is CardLoaded && state.cards.isNotEmpty) {
                        final activeCard = state.cards.first;
                        return ShowmeCardWidget(
                          card: activeCard,
                          size: CardSize.large,
                          onTap: () => context.go('/cards/${activeCard.id}'),
                        );
                      } else if (state is CardLoading) {
                        return _buildCardLoadingSkeleton();
                      } else {
                        return _buildEmptyCardState();
                      }
                    },
                  ),
                ],
            ),
          ),
        );
      },
    );
  }

Widget _buildQuickActionsSection() {
    return AnimatedBuilder(
      animation: _contentStaggerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _contentStaggerAnimation.value) * 15), // Réduit de 40 à 15
          child: Opacity(
            opacity: _contentStaggerAnimation.value,
            child: Padding(
              padding: EdgeInsets.only(
                top: ShowmeDesign.spacingSm, // Réduit l'espace avec la carte
                left: 20, // Même marge que la carte
                right: 20, // Même marge que la carte
                bottom: ShowmeDesign.spacingLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  QuickActionsGrid(
                    onActionTap: _handleQuickAction,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return AnimatedBuilder(
      animation: _contentStaggerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _contentStaggerAnimation.value) * 20), // Réduit de 50 à 20
          child: Opacity(
            opacity: _contentStaggerAnimation.value,
            child: Padding(
              padding: EdgeInsets.only(
                left: 20, // Même marge que la carte
                right: 20, // Même marge que la carte
                bottom: ShowmeDesign.spacingLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cette semaine',
                        style: ShowmeDesign.h3.copyWith(
                          color: ShowmeDesign.neutral900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ShowmeDesign.spacingSm,
                          vertical: ShowmeDesign.spacingXs,
                        ),
                        decoration: BoxDecoration(
                          color: ShowmeDesign.primaryTeal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(ShowmeDesign.radiusSm),
                        ),
                        child: Text(
                          'Actif',
                          style: ShowmeDesign.caption.copyWith(
                            color: ShowmeDesign.primaryTeal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ShowmeDesign.spacingMd),
                  BlocBuilder<CrmBloc, CrmState>(
                    builder: (context, state) {
                      if (state is CrmStatsLoaded) {
                        return StatsOverview(stats: state.stats);
                      }
                      return _buildStatsLoadingSkeleton();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivitySection() {
    return AnimatedBuilder(
      animation: _contentStaggerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _contentStaggerAnimation.value) * 25), // Réduit de 60 à 25
          child: Opacity(
            opacity: _contentStaggerAnimation.value,
            child: Padding(
              padding: EdgeInsets.only(
                left: 20, // Même marge que la carte
                right: 20, // Même marge que la carte
                bottom: ShowmeDesign.spacingLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Activité récente',
                        style: ShowmeDesign.h3.copyWith(
                          color: ShowmeDesign.neutral900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/crm'),
                        child: Text(
                          'Voir tout',
                          style: ShowmeDesign.bodyMedium.copyWith(
                            color: ShowmeDesign.primaryPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ShowmeDesign.spacingMd),
                  BlocBuilder<CrmBloc, CrmState>(
                    builder: (context, state) {
                      if (state is CrmContactsLoaded && state.contacts.isNotEmpty) {
                        return _buildRecentContactsList(state.contacts.take(3).toList());
                      }
                      return _buildEmptyActivityState();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardLoadingSkeleton() {
    return Container(
      height: 200,
      margin: EdgeInsets.all(ShowmeDesign.spacingMd),
      decoration: BoxDecoration(
        color: ShowmeDesign.neutral100,
        borderRadius: BorderRadius.circular(ShowmeDesign.radiusXl),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyCardState() {
    return Container(
      height: 200,
      margin: EdgeInsets.all(ShowmeDesign.spacingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ShowmeDesign.neutral100,
            ShowmeDesign.neutral50,
          ],
        ),
        borderRadius: BorderRadius.circular(ShowmeDesign.radiusXl),
        border: Border.all(
          color: ShowmeDesign.neutral200,
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: ShowmeDesign.primaryGradient,
              borderRadius: BorderRadius.circular(ShowmeDesign.radiusLg),
            ),
            child: const Icon(
              Icons.add_business_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          SizedBox(height: ShowmeDesign.spacingMd),
          Text(
            'Créez votre première carte',
            style: ShowmeDesign.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: ShowmeDesign.neutral700,
            ),
          ),
          SizedBox(height: ShowmeDesign.spacingXs),
          Text(
            'Commencez à partager votre profil',
            style: ShowmeDesign.bodyMedium.copyWith(
              color: ShowmeDesign.neutral600,
            ),
          ),
          SizedBox(height: ShowmeDesign.spacingLg),
          ElevatedButton(
            onPressed: () => context.go('/cards/new'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ShowmeDesign.primaryPurple,
              padding: EdgeInsets.symmetric(
                horizontal: ShowmeDesign.spacingLg,
                vertical: ShowmeDesign.spacingSm,
              ),
            ),
            child: Text(
              'Créer ma carte',
              style: ShowmeDesign.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsLoadingSkeleton() {
    return Row(
      children: List.generate(3, (index) {
        return Expanded(
          child: Container(
            height: 80,
            margin: EdgeInsets.only(
              right: index < 2 ? ShowmeDesign.spacingSm : 0,
            ),
            decoration: BoxDecoration(
              color: ShowmeDesign.neutral100,
              borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRecentContactsList(List<dynamic> contacts) {
    return Column(
      children: contacts.map((contact) {
        return Container(
          margin: EdgeInsets.only(bottom: ShowmeDesign.spacingSm),
          decoration: BoxDecoration(
            color: ShowmeDesign.white,
            borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
            boxShadow: ShowmeDesign.cardShadow,
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(ShowmeDesign.spacingMd),
            leading: CircleAvatar(
              backgroundColor: ShowmeDesign.primaryPurple.withOpacity(0.1),
              child: Text(
                contact.visitor != null && contact.visitor.name != null
                    ? contact.visitor.name![0].toUpperCase()
                    : '?',
                style: ShowmeDesign.bodyMedium.copyWith(
                  color: ShowmeDesign.primaryPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              contact.visitor != null && contact.visitor.name != null
                  ? contact.visitor.name!
                  : 'Visiteur inconnu',
              style: ShowmeDesign.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ShowmeDesign.spacingXs,
                    vertical: ShowmeDesign.spacingXs / 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getMethodColor(contact.referrer).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ShowmeDesign.radiusXs),
                  ),
                  child: Text(
                    contact.displayMethod,
                    style: ShowmeDesign.caption.copyWith(
                      color: _getMethodColor(contact.referrer),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: ShowmeDesign.spacingXs),
                Text(
                  _formatTime(contact.createdAt),
                  style: ShowmeDesign.caption.copyWith(
                    color: ShowmeDesign.neutral500,
                  ),
                ),
              ],
            ),
            trailing: contact.isQualifiedLead
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: ShowmeDesign.primaryEmerald,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyActivityState() {
    return Container(
      padding: EdgeInsets.all(ShowmeDesign.spacingXl),
      decoration: BoxDecoration(
        color: ShowmeDesign.white,
        borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
        boxShadow: ShowmeDesign.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: ShowmeDesign.neutral100,
              borderRadius: BorderRadius.circular(ShowmeDesign.radiusLg),
            ),
            child: Icon(
              Icons.timeline_rounded,
              color: ShowmeDesign.neutral400,
              size: 32,
            ),
          ),
          SizedBox(height: ShowmeDesign.spacingMd),
          Text(
            'Aucune activité récente',
            style: ShowmeDesign.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: ShowmeDesign.neutral700,
            ),
          ),
          SizedBox(height: ShowmeDesign.spacingXs),
          Text(
            'Partagez votre carte pour voir l\'activité',
            style: ShowmeDesign.bodyMedium.copyWith(
              color: ShowmeDesign.neutral600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _showShareOptions(),
      backgroundColor: ShowmeDesign.primaryPurple,
      icon: const Icon(Icons.share_rounded, color: Colors.white),
      label: Text(
        'Partager',
        style: ShowmeDesign.bodyMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Méthodes utilitaires
  Color _getMethodColor(ExchangeMethod method) {
    switch (method.name.toLowerCase()) {
      case 'nfc':
        return ShowmeDesign.primaryBlue;
      case 'qr':
        return ShowmeDesign.primaryTeal;
      case 'link':
        return ShowmeDesign.primaryPurple;
      case 'kiosk':
        return ShowmeDesign.primaryAmber;
      default:
        return ShowmeDesign.neutral500;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}j';
    }
  }

  // Gestionnaires d'événements
  Future<void> _handleRefresh() async {
    // Updated to use CardBloc
    context.read<CardBloc>().add(CardRefreshRequested());
    context.read<CrmBloc>().add(CrmStatsRequested());
    context.read<CrmBloc>().add(CrmContactsRequested());
    
    // Attendre un peu pour l'effet visuel
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _handleQuickAction(String action) {
    switch (action) {
      case 'share_nfc':
        _showNFCSharing();
        break;
      case 'share_qr':
        _showQRCode();
        break;
      case 'view_contacts':
        context.go('/crm');
        break;
      case 'edit_card':
        context.go('/cards');
        break;
      case 'kiosk_mode':
        _activateKioskMode();
        break;
      case 'payment':
        _showPaymentOptions();
        break;
      default:
        _showComingSoon(action);
    }
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(ShowmeDesign.spacingLg),
        decoration: BoxDecoration(
          color: ShowmeDesign.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(ShowmeDesign.radiusXl),
            topRight: Radius.circular(ShowmeDesign.radiusXl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ShowmeDesign.neutral300,
                borderRadius: BorderRadius.circular(ShowmeDesign.radiusXs),
              ),
            ),
            SizedBox(height: ShowmeDesign.spacingLg),
            Text(
              'Partager ma carte',
              style: ShowmeDesign.h3.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ShowmeDesign.spacingLg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  icon: Icons.nfc_rounded,
                  label: 'NFC',
                  color: ShowmeDesign.primaryBlue,
                  onTap: _showNFCSharing,
                ),
                _buildShareOption(
                  icon: Icons.qr_code_rounded,
                  label: 'QR Code',
                  color: ShowmeDesign.primaryTeal,
                  onTap: _showQRCode,
                ),
                _buildShareOption(
                  icon: Icons.link_rounded,
                  label: 'Lien',
                  color: ShowmeDesign.primaryPurple,
                  onTap: _shareLink,
                ),
              ],
            ),
            SizedBox(height: ShowmeDesign.spacingXl),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ShowmeDesign.radiusLg),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          SizedBox(height: ShowmeDesign.spacingSm),
          Text(
            label,
            style: ShowmeDesign.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Fonctions de partage (stubs pour le moment)
  void _showNFCSharing() {
    _showComingSoon('Partage NFC');
  }

  void _showQRCode() {
    _showComingSoon('QR Code');
  }

  void _shareLink() {
    _showComingSoon('Partage de lien');
  }

  void _activateKioskMode() {
    _showComingSoon('Mode kiosque');
  }

  void _showPaymentOptions() {
    _showComingSoon('Options de paiement');
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature bientôt disponible !'),
        backgroundColor: ShowmeDesign.primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
        ),
      ),
    );
  }
}