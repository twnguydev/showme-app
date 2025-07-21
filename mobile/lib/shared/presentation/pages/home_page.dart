// mobile/lib/shared/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/showme_design_system.dart';
import '../../../features/card/bloc/card_bloc.dart';
import '../../../features/crm/bloc/crm_bloc.dart';
import '../widgets/showme_card_widget.dart';
import '../widgets/stats_overview.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/showme_app_bar.dart';
import '../../models/contact_exchange.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_state.dart';
import '../../../shared/models/profile.dart';
import '../../../shared/models/card.dart' as CardModel;
import '../../../shared/models/card_theme.dart' as CardTheme;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;
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
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                return ShowmeSliverAppBar(
                  title: authState is AuthAuthenticated 
                    ? 'Bonjour ${authState.user.firstName ?? 'Utilisateur'} !'
                    : 'Accueil',
                  showWelcomeSection: true,
                  showProfileIcon: true,
                  onProfilePressed: () => context.go('/profile'),
                  // Passer l'utilisateur pour afficher son avatar dans l'AppBar
                  user: authState is AuthAuthenticated ? authState.user : null,
                );
              },
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
                      const SizedBox(height: ShowmeDesign.spacing3xl),
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
                  builder: (context, cardState) {
                    return BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        if (cardState is CardLoaded && cardState.cards.isNotEmpty) {
                          final activeCard = cardState.cards.first;
                          return ShowmeCardWidget(
                            card: activeCard,
                            profile: authState is AuthAuthenticated ? authState.user.profileOrDefault : Profile.demo(),
                            size: CardSize.large,
                            onTap: () => context.go('/cards/${activeCard.id}'),
                          );
                        } else if (cardState is CardLoading) {
                          return _buildCardLoadingSkeleton();
                        } else {
                          // Créer une carte basée sur les infos utilisateur réelles
                          if (authState is AuthAuthenticated) {
                            return _buildDynamicCardFromUser(authState.user);
                          } else {
                            return _buildEmptyCardState();
                          }
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDynamicCardFromUser(dynamic user) {
    // Créer un slug basé sur le nom utilisateur
    String generateSlug() {
      final firstName = user.firstName ?? '';
      final lastName = user.lastName ?? '';
      if (firstName.isNotEmpty && lastName.isNotEmpty) {
        return '${firstName.toLowerCase()}-${lastName.toLowerCase()}';
      } else if (firstName.isNotEmpty) {
        return firstName.toLowerCase();
      } else if (user.email != null) {
        return user.email!.split('@').first.toLowerCase();
      }
      return 'utilisateur-${user.id}';
    }

    // Utiliser profileOrDefault qui gère automatiquement le cas null
    final profile = user.profileOrDefault;

    // Créer une carte temporaire basée sur le profile
    final dynamicCard = CardModel.Card(
      id: 0, // ID temporaire
      slug: generateSlug(),
      title: profile.company != null && profile.company!.isNotEmpty
          ? 'Carte ${profile.company}'
          : 'Ma carte de visite',
      bio: profile.position != null && profile.position!.isNotEmpty
          ? 'Découvrez mon parcours professionnel et connectons-nous !'
          : 'Créez votre première carte pour personnaliser cette description.',
      isPublic: true,
      viewsCount: 0,
      walletPassUrl: null,
      allowPayment: false,
      nfcEnabled: true,
      qrCodeUrl: null,
      totalShared: 0,
      totalLeads: 0,
      profile: profile,
      subscription: null,
      theme: CardTheme.CardTheme.purple,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return Container(
      margin: const EdgeInsets.only(
        top: ShowmeDesign.spacingMd,
        left: 10,
        right: 10,
      ),
      child: Stack(
        children: [
          ShowmeCardWidget(
            card: dynamicCard,
            profile: profile,
            size: CardSize.large,
            onTap: () => context.go('/cards/new'),
          ),
          // Overlay pour indiquer que c'est un aperçu
          Positioned(
            top: ShowmeDesign.spacingLg,
            left: ShowmeDesign.spacingLg,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ShowmeDesign.spacingSm,
                vertical: ShowmeDesign.spacingXs,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(ShowmeDesign.radiusSm),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.preview,
                    color: Colors.white,
                    size: 12,
                  ),
                  SizedBox(width: ShowmeDesign.spacingXs),
                  Text(
                    'Aperçu - Cliquez pour créer',
                    style: ShowmeDesign.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Badge encourageant à créer une vraie carte
          Positioned(
            bottom: ShowmeDesign.spacingLg,
            right: ShowmeDesign.spacingLg,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ShowmeDesign.spacingSm,
                vertical: ShowmeDesign.spacingXs,
              ),
              decoration: BoxDecoration(
                gradient: ShowmeDesign.primaryGradient,
                borderRadius: BorderRadius.circular(ShowmeDesign.radiusSm),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 12,
                  ),
                  SizedBox(width: ShowmeDesign.spacingXs),
                  Text(
                    'Créer ma carte',
                    style: ShowmeDesign.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return AnimatedBuilder(
      animation: _contentStaggerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: const Offset(0, -40),
          child: Opacity(
            opacity: _contentStaggerAnimation.value,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 0,
                left: 20,
                right: 20,
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
              padding: const EdgeInsets.only(
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
                        padding: const EdgeInsets.symmetric(
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
                  const SizedBox(height: ShowmeDesign.spacingMd),
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
              padding: const EdgeInsets.only(
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
                  const SizedBox(height: ShowmeDesign.spacingMd),
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
      height: 270,
      margin: const EdgeInsets.all(ShowmeDesign.spacingMd),
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
      margin: const EdgeInsets.all(ShowmeDesign.spacingMd),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
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
          const SizedBox(height: ShowmeDesign.spacingMd),
          Text(
            'Créez votre première carte',
            style: ShowmeDesign.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: ShowmeDesign.neutral700,
            ),
          ),
          const SizedBox(height: ShowmeDesign.spacingXs),
          Text(
            'Commencez à partager votre profil',
            style: ShowmeDesign.bodyMedium.copyWith(
              color: ShowmeDesign.neutral600,
            ),
          ),
          const SizedBox(height: ShowmeDesign.spacingLg),
          ElevatedButton(
            onPressed: () => context.go('/cards/new'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ShowmeDesign.primaryPurple,
              padding: const EdgeInsets.symmetric(
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
          margin: const EdgeInsets.only(bottom: ShowmeDesign.spacingSm),
          decoration: BoxDecoration(
            color: ShowmeDesign.white,
            borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
            boxShadow: ShowmeDesign.cardShadow,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(ShowmeDesign.spacingMd),
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
                  padding: const EdgeInsets.symmetric(
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
                const SizedBox(width: ShowmeDesign.spacingXs),
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
      padding: const EdgeInsets.all(ShowmeDesign.spacingXl),
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
            child: const Icon(
              Icons.timeline_rounded,
              color: ShowmeDesign.neutral400,
              size: 32,
            ),
          ),
          const SizedBox(height: ShowmeDesign.spacingMd),
          Text(
            'Aucune activité récente',
            style: ShowmeDesign.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: ShowmeDesign.neutral700,
            ),
          ),
          const SizedBox(height: ShowmeDesign.spacingXs),
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
    // Vérifier si l'action est PRO et si l'utilisateur n'a pas l'abonnement
    if (_isProAction(action) && !_hasProSubscription()) {
      _redirectToPaywall(action);
      return;
    }

    // Actions normales
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

  bool _isProAction(String action) {
    const proActions = {
      'kiosk_mode',
    };
    return proActions.contains(action);
  }

  bool _hasProSubscription() {
    // return context.read<SubscriptionBloc>().state.isPro;
    return false;
  }

  void _redirectToPaywall(String feature) {
    context.go('/paywall?feature=$feature&source=quick_actions');
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(ShowmeDesign.spacingLg),
        decoration: const BoxDecoration(
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
            const SizedBox(height: ShowmeDesign.spacingLg),
            Text(
              'Partager ma carte',
              style: ShowmeDesign.h3.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: ShowmeDesign.spacingLg),
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
            const SizedBox(height: ShowmeDesign.spacingXl),
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
          const SizedBox(height: ShowmeDesign.spacingSm),
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

  void _showNFCSharing() {
    context.go('/splash');
  }

  void _showQRCode() {
    context.go('/qr-share');
  }

  void _shareLink() {
    _showComingSoon('Partage de lien');
  }

  void _activateKioskMode() {
    context.go('/kiosk');
  }

  void _showPaymentOptions() {
    context.go('/payment');
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