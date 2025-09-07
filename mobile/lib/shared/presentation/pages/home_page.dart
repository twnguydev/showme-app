// mobile/lib/shared/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qard/shared/models/user.dart';

import '../../../core/design/showme_design_system.dart';
import '../../../features/card/bloc/card_bloc.dart';
import '../../../features/card/bloc/card_event.dart';
import '../../../features/card/bloc/card_state.dart';
import '../../../features/crm/bloc/crm_bloc.dart';
import '../widgets/showme_card_widget.dart';
import '../widgets/stats_overview.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/showme_app_bar.dart';
import '../../models/contact_exchange.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_state.dart';
import '../../../shared/models/card.dart' as CardModel;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;
  late Animation<double> _contentStaggerAnimation;

  // Contrôleur pour le PageView des cartes
  late PageController _cardPageController;
  int _currentCardIndex = 0;
  List<CardModel.Card> _userCards = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupPageController();
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

    _contentStaggerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: ShowmeDesign.primaryCurve,
      ),
    );

    // Démarrer les animations
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _contentController.forward();
    });
  }

  void _setupPageController() {
    _cardPageController = PageController();
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
    _cardPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('home_scaffold'), // ✅ Ajouter cette clé
      body: RefreshIndicator(
        key: const ValueKey('home_refresh_indicator'), // ✅ Ajouter cette clé
        onRefresh: _handleRefresh,
        color: ShowmeDesign.primaryPurple,
        child: CustomScrollView(
          key: const ValueKey('home_scroll_view'), // ✅ Déjà présent, garder
          slivers: [
            BlocBuilder<AuthBloc, AuthState>(
              key: const ValueKey('home_auth_builder'), // ✅ Ajouter cette clé
              builder: (context, authState) {
                return ShowmeSliverAppBar(
                  key: const ValueKey('home_sliver_appbar'), // ✅ Déjà présent, garder
                  title: authState is AuthAuthenticated
                      ? 'Bonjour ${authState.user.firstName ?? 'Utilisateur'} !'
                      : 'Accueil',
                  showWelcomeSection: true,
                  showProfileIcon: true,
                  onProfilePressed: () => context.push('/profile'),
                  user: authState is AuthAuthenticated ? authState.user : null,
                );
              },
            ),
            SliverToBoxAdapter(
              key: const ValueKey('home_content'), // ✅ Déjà présent, garder
              child: Column(
                key: const ValueKey('home_content_column'), // ✅ Déjà présent, garder
                children: [
                  _buildMyCardSection(),
                  _buildQuickActionsSection(),
                  _buildStatsSection(),
                  _buildRecentActivitySection(),
                  const SizedBox(height: ShowmeDesign.spacing3xl),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildMyCardSection() {
    return Container(
      key: const ValueKey('my_card_section_container'), // ✅ Ajouter cette clé
      padding: const EdgeInsets.all(ShowmeDesign.spacingMd),
      child: BlocListener<CardBloc, CardState>(
        key: const ValueKey('card_bloc_listener'), // ✅ Ajouter cette clé
        listener: (context, state) {
          if (state is CardLoaded ||
              state is CardCreateSuccess ||
              state is CardUpdateSuccess ||
              state is CardOperationSuccess) {
            final cards = _getCardsFromState(state);
            if (cards != null) {
              setState(() {
                _userCards = cards;
                // Réinitialiser l'index si nécessaire
                if (_currentCardIndex >= cards.length && cards.isNotEmpty) {
                  _currentCardIndex = 0;
                }
              });
            }
          }
        },
        child: BlocBuilder<CardBloc, CardState>(
          key: const ValueKey('card_bloc_builder'), // ✅ Ajouter cette clé
          builder: (context, cardState) {
            return BlocBuilder<AuthBloc, AuthState>(
              key: const ValueKey('auth_bloc_builder_cards'), // ✅ Ajouter cette clé
              builder: (context, authState) {
                if (cardState is CardLoading) {
                  return _buildCardLoadingSkeleton();
                }

                final cards = _getCardsFromState(cardState);
                if (cards != null && cards.isNotEmpty) {
                  return _buildCardsSwiper(cards, authState);
                } else {
                  return _buildEmptyCardState();
                }
              },
            );
          },
        ),
      ),
    );
  }

  // 3. _buildCardsSwiper() - Ajouter des clés pour le PageView
  Widget _buildCardsSwiper(List<CardModel.Card> cards, AuthState authState) {
    return Column(
      key: const ValueKey('cards_swiper_column'), // ✅ Ajouter cette clé
      children: [
        // Swiper des cartes
        SizedBox(
          height: 280,
          child: PageView.builder(
            key: const ValueKey('cards_page_view'), // ✅ Ajouter cette clé
            controller: _cardPageController,
            onPageChanged: (index) {
              setState(() {
                _currentCardIndex = index;
              });
            },
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              return Container(
                key: ValueKey('card_container_${card.id}'), // ✅ Clé unique par carte
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: ShowmeCardWidget(
                  key: ValueKey('card_widget_${card.id}'), // ✅ Clé unique par carte
                  card: card,
                  user: authState is AuthAuthenticated ? authState.user : User.demo(),
                  size: CardSize.large,
                  onTap: () => context.go('/cards/${card.id}'),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: ShowmeDesign.spacingMd),

        // Indicateurs de pages + informations de la carte
        if (cards.length > 1) _buildCardIndicators(cards),

        // Informations de la carte actuelle
        _buildCurrentCardInfo(cards[_currentCardIndex]),
      ],
    );
  }

  List<CardModel.Card>? _getCardsFromState(CardState state) {
    if (state is CardLoaded) return state.cards;
    if (state is CardCreateSuccess) return state.allCards;
    if (state is CardUpdateSuccess) return state.allCards;
    if (state is CardOperationSuccess) return state.cards;
    return null;
  }

  Widget _buildCardIndicators(List<CardModel.Card> cards) {
    return Container(
      key: const ValueKey('card_indicators_container'), // ✅ Ajouter cette clé
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Indicateurs de points
          Row(
            key: const ValueKey('indicators_row'), // ✅ Ajouter cette clé
            children: cards.asMap().entries.map((entry) {
              final index = entry.key;
              final isActive = index == _currentCardIndex;

              return Container(
                key: ValueKey('indicator_$index'), // ✅ Clé unique par indicateur
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? ShowmeDesign.primaryPurple
                      : ShowmeDesign.neutral300,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }).toList(),
          ),

          const SizedBox(width: ShowmeDesign.spacingMd),

          // Compteur
          Container(
            key: const ValueKey('card_counter'), // ✅ Ajouter cette clé
            padding: const EdgeInsets.symmetric(
              horizontal: ShowmeDesign.spacingSm,
              vertical: ShowmeDesign.spacingXs,
            ),
            decoration: BoxDecoration(
              color: ShowmeDesign.neutral100,
              borderRadius: BorderRadius.circular(ShowmeDesign.radiusSm),
            ),
            child: Text(
              '${_currentCardIndex + 1}/${cards.length}',
              style: ShowmeDesign.caption.copyWith(
                color: ShowmeDesign.neutral600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentCardInfo(CardModel.Card card) {
    return Container(
      key: ValueKey('card_info_${card.id}'), // ✅ Clé unique par carte
      margin: const EdgeInsets.all(ShowmeDesign.spacingMd),
      padding: const EdgeInsets.all(ShowmeDesign.spacingMd),
      decoration: BoxDecoration(
        color: ShowmeDesign.white,
        borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
        boxShadow: ShowmeDesign.cardShadow,
      ),
      child: Row(
        children: [
          // Icône de statut
          Container(
            key: ValueKey('status_icon_${card.id}'), // ✅ Ajouter cette clé
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: card.isPublic
                  ? ShowmeDesign.primaryTeal.withOpacity(0.1)
                  : ShowmeDesign.neutral200,
              borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
            ),
            child: Icon(
              card.isPublic ? Icons.public : Icons.lock,
              color: card.isPublic
                  ? ShowmeDesign.primaryTeal
                  : ShowmeDesign.neutral500,
              size: 20,
            ),
          ),

          const SizedBox(width: ShowmeDesign.spacingMd),

          // Informations
          Expanded(
            child: Column(
              key: ValueKey('card_info_column_${card.id}'), // ✅ Ajouter cette clé
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: ShowmeDesign.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      card.isPublic ? 'Publique' : 'Privée',
                      style: ShowmeDesign.caption.copyWith(
                        color: card.isPublic
                            ? ShowmeDesign.primaryTeal
                            : ShowmeDesign.neutral500,
                      ),
                    ),
                    const SizedBox(width: ShowmeDesign.spacingSm),
                    Text(
                      '•',
                      style: ShowmeDesign.caption.copyWith(
                        color: ShowmeDesign.neutral400,
                      ),
                    ),
                    const SizedBox(width: ShowmeDesign.spacingSm),
                    Text(
                      '${card.viewsCount} vues',
                      style: ShowmeDesign.caption.copyWith(
                        color: ShowmeDesign.neutral500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions rapides
          Row(
            key: ValueKey('quick_actions_${card.id}'), // ✅ Ajouter cette clé
            children: [
              IconButton(
                key: ValueKey('share_button_${card.id}'), // ✅ Clé unique
                onPressed: () => _shareCurrentCard(),
                icon: const Icon(Icons.share, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: ShowmeDesign.primaryBlue.withOpacity(0.1),
                  foregroundColor: ShowmeDesign.primaryBlue,
                ),
              ),
              const SizedBox(width: ShowmeDesign.spacingXs),
              IconButton(
                key: ValueKey('qr_button_${card.id}'), // ✅ Clé unique
                onPressed: () => _showCurrentCardQR(),
                icon: const Icon(Icons.qr_code, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: ShowmeDesign.primaryTeal.withOpacity(0.1),
                  foregroundColor: ShowmeDesign.primaryTeal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Container(
      key: const ValueKey('quick_actions_section'), // ✅ Ajouter cette clé
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
            key: const ValueKey('quick_actions_grid'), // ✅ Ajouter cette clé
            onActionTap: _handleQuickAction,
            currentCard: _userCards.isNotEmpty ? _userCards[_currentCardIndex] : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      key: const ValueKey('stats_section'), // ✅ Ajouter cette clé
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
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
                key: const ValueKey('active_badge'), // ✅ Ajouter cette clé
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
            key: const ValueKey('crm_stats_builder'), // ✅ Ajouter cette clé
            builder: (context, state) {
              if (state is CrmStatsLoaded) {
                return StatsOverview(
                  key: const ValueKey('stats_overview'), // ✅ Ajouter cette clé
                  stats: state.stats,
                );
              }
              return _buildStatsLoadingSkeleton();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Container(
      key: const ValueKey('recent_activity_section'), // ✅ Ajouter cette clé
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
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
                key: const ValueKey('see_all_activity_button'), // ✅ Ajouter cette clé
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
            key: const ValueKey('crm_contacts_builder'), // ✅ Ajouter cette clé
            builder: (context, state) {
              if (state is CrmContactsLoaded && state.contacts.isNotEmpty) {
                return _buildRecentContactsList(
                  state.contacts.take(3).toList(),
                );
              }
              return _buildEmptyActivityState();
            },
          ),
        ],
      ),
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
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEmptyCardState() {
    return Container(
      key: const ValueKey('empty_card_state'), // ✅ Ajouter cette clé
      height: 200,
      margin: const EdgeInsets.all(ShowmeDesign.spacingMd),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ShowmeDesign.neutral100, ShowmeDesign.neutral50],
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
            key: const ValueKey('create_first_card_button'), // ✅ Ajouter cette clé
            onPressed: () => context.push('/cards/create'), // ✅ Corriger la route
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
      key: const ValueKey('recent_contacts_column'), // ✅ Ajouter cette clé
      children: contacts.asMap().entries.map((entry) {
        final index = entry.key;
        final contact = entry.value;
        
        return Container(
          key: ValueKey('contact_${contact.id ?? index}'), // ✅ Clé unique par contact
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
    context.read<CardBloc>().add(CardRefreshRequested());
    context.read<CrmBloc>().add(CrmStatsRequested());
    context.read<CrmBloc>().add(CrmContactsRequested());

    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _handleQuickAction(String action) {
    final currentCard =
        _userCards.isNotEmpty ? _userCards[_currentCardIndex] : null;

    if (_isProAction(action) && !_hasProSubscription()) {
      _redirectToPaywall(action);
      return;
    }

    switch (action) {
      case 'share_nfc':
        _showNFCSharing();
        break;
      case 'share_qr':
        _showCurrentCardQR();
        break;
      case 'view_contacts':
        context.push('/crm');
        break;
      case 'edit_card':
        if (currentCard != null) {
          context.push('/cards/${currentCard.id}/edit');
        } else {
          context.push('/cards');
        }
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
    const proActions = {'kiosk_mode'};
    return proActions.contains(action);
  }

  bool _hasProSubscription() {
    return false; // TODO: Implémenter la logique d'abonnement
  }

  void _redirectToPaywall(String feature) {
    context.go('/paywall?feature=$feature&source=quick_actions');
  }

  void _shareCurrentCard() {
    if (_userCards.isNotEmpty) {
      final currentCard = _userCards[_currentCardIndex];
      context.read<CardBloc>().add(
        CardShareRequested(currentCard.id.toString(), 'link'),
      );
    }
  }

  void _showCurrentCardQR() {
    if (_userCards.isNotEmpty) {
      final currentCard = _userCards[_currentCardIndex];
      context.read<CardBloc>().add(
        CardQRGenerateRequested(currentCard.id.toString()),
      );
    }
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
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
                  style: ShowmeDesign.h3.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: ShowmeDesign.spacingMd),
                if (_userCards.isNotEmpty) ...[
                  Text(
                    _userCards[_currentCardIndex].title,
                    style: ShowmeDesign.bodyMedium.copyWith(
                      color: ShowmeDesign.neutral600,
                    ),
                  ),
                  const SizedBox(height: ShowmeDesign.spacingLg),
                ],
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
                      onTap: _showCurrentCardQR,
                    ),
                    _buildShareOption(
                      icon: Icons.link_rounded,
                      label: 'Lien',
                      color: ShowmeDesign.primaryPurple,
                      onTap: _shareCurrentCard,
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
            child: Icon(icon, color: color, size: 28),
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
    if (_userCards.isEmpty) {
      _showComingSoon('NFC');
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Partage NFC'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: ShowmeDesign.primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.nfc,
                    size: 40,
                    color: ShowmeDesign.primaryBlue,
                  ),
                ),
                const SizedBox(height: ShowmeDesign.spacingMd),
                Text(
                  'Approchez votre téléphone d\'un autre appareil compatible NFC pour partager votre carte "${_userCards[_currentCardIndex].title}".',
                  textAlign: TextAlign.center,
                  style: ShowmeDesign.bodyMedium.copyWith(
                    color: ShowmeDesign.neutral600,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Activer le partage NFC
                  _showComingSoon('Partage NFC');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ShowmeDesign.primaryBlue,
                ),
                child: const Text('Activer NFC'),
              ),
            ],
          ),
    );
  }

  void _activateKioskMode() {
    if (_userCards.isEmpty) {
      _showComingSoon('Mode Kiosque');
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Mode Kiosque'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: ShowmeDesign.primaryAmber.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fullscreen,
                    size: 40,
                    color: ShowmeDesign.primaryAmber,
                  ),
                ),
                const SizedBox(height: ShowmeDesign.spacingMd),
                Text(
                  'Le mode kiosque affichera votre carte "${_userCards[_currentCardIndex].title}" en plein écran pour faciliter le partage lors d\'événements.',
                  textAlign: TextAlign.center,
                  style: ShowmeDesign.bodyMedium.copyWith(
                    color: ShowmeDesign.neutral600,
                  ),
                ),
                const SizedBox(height: ShowmeDesign.spacingMd),
                Container(
                  padding: const EdgeInsets.all(ShowmeDesign.spacingSm),
                  decoration: BoxDecoration(
                    color: ShowmeDesign.primaryAmber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ShowmeDesign.radiusSm),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: ShowmeDesign.primaryAmber,
                      ),
                      const SizedBox(width: ShowmeDesign.spacingXs),
                      Text(
                        'Fonctionnalité PRO',
                        style: ShowmeDesign.caption.copyWith(
                          color: ShowmeDesign.primaryAmber,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (_hasProSubscription()) {
                    context.go(
                      '/kiosk?cardId=${_userCards[_currentCardIndex].id}',
                    );
                  } else {
                    _redirectToPaywall('kiosk_mode');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ShowmeDesign.primaryAmber,
                ),
                child: const Text('Activer'),
              ),
            ],
          ),
    );
  }

  void _showPaymentOptions() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Options de paiement'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: ShowmeDesign.primaryEmerald.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.payment,
                    size: 40,
                    color: ShowmeDesign.primaryEmerald,
                  ),
                ),
                const SizedBox(height: ShowmeDesign.spacingMd),
                Text(
                  'Configurez les options de paiement pour permettre à vos contacts de vous payer directement via votre carte.',
                  textAlign: TextAlign.center,
                  style: ShowmeDesign.bodyMedium.copyWith(
                    color: ShowmeDesign.neutral600,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Plus tard'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/payment-setup');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ShowmeDesign.primaryEmerald,
                ),
                child: const Text('Configurer'),
              ),
            ],
          ),
    );
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
