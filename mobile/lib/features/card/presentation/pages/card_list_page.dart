// mobile/lib/features/card/presentation/pages/card_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:showme/features/card/bloc/card_bloc.dart';
import 'package:showme/features/card/bloc/card_event.dart';
import 'package:showme/features/card/bloc/card_state.dart';
import 'package:showme/shared/presentation/widgets/showme_app_bar.dart';

import '../../../../core/design/showme_design_system.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_state.dart';
import 'card_creation_page.dart';

class CardListPage extends StatefulWidget {
  const CardListPage({super.key});

  @override
  State<CardListPage> createState() => _CardListPageState();
}

class _CardListPageState extends State<CardListPage> with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _fabAnimationController = AnimationController(
      duration: ShowmeDesign.normalDuration,
      vsync: this,
    );
    
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: ShowmeDesign.bouncyCurve,
    );
    
    // Charger les cartes au démarrage
    context.read<CardBloc>().add(CardLoadRequested());
    
    // Animer le FAB
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CardBloc, CardState>(
          listener: (context, state) {
            if (state is CardCreateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Carte créée avec succès'),
                  backgroundColor: ShowmeDesign.primaryTeal,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is CardUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Carte mise à jour avec succès'),
                  backgroundColor: ShowmeDesign.primaryTeal,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is CardDeleteSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Carte supprimée avec succès'),
                  backgroundColor: ShowmeDesign.primaryTeal,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is CardOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: ShowmeDesign.primaryTeal,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is CardShareSuccess) {
              // Partager l'URL ou afficher le QR code
              _handleShareSuccess(state.shareUrl, state.message);
            } else if (state is CardImageUploadSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: ShowmeDesign.primaryTeal,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is CardError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: ShowmeDesign.primaryRose,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: ShowmeDesign.neutral50,
        body: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: ShowmeDesign.primaryPurple,
          child: CustomScrollView(
            slivers: [
              // AppBar avec statistiques et actions
              _buildAppBar(),

              // Statistiques rapides
              BlocBuilder<CardBloc, CardState>(
                builder: (context, state) {
                  final cards = _getCardsFromState(state);
                  if (cards != null && cards.isNotEmpty) {
                    return _buildStatsSection(cards);
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),

              // Liste des cartes
              BlocBuilder<CardBloc, CardState>(
                builder: (context, state) {
                  if (state is CardLoading || state is CardCreateLoading || 
                      state is CardUpdateLoading || state is CardDeleteLoading) {
                    return _buildLoadingState();
                  }

                  if (state is CardError) {
                    return _buildErrorState(state.message);
                  }

                  final cards = _getCardsFromState(state);
                  if (cards != null) {
                    if (cards.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildCardsList(cards);
                  }

                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),

              // Padding bottom
              const SliverToBoxAdapter(
                child: SizedBox(height: ShowmeDesign.spacingXl + 80), // Extra space for FAB
              ),
            ],
          ),
        ),
        
        // FAB pour créer une nouvelle carte
        floatingActionButton: ScaleTransition(
          scale: _fabAnimation,
          child: FloatingActionButton.extended(
            onPressed: _navigateToCardCreation,
            icon: const Icon(Icons.add),
            label: const Text('Nouvelle carte'),
            backgroundColor: ShowmeDesign.primaryPurple,
            foregroundColor: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ShowmeDesign.radiusLg),
            ),
          ),
        ),
      ),
    );
  }

  // Helper pour extraire les cartes de l'état
  List? _getCardsFromState(CardState state) {
    if (state is CardLoaded) return state.cards;
    if (state is CardCreateSuccess) return state.allCards;
    if (state is CardUpdateSuccess) return state.allCards;
    if (state is CardDeleteSuccess) return state.remainingCards;
    if (state is CardOperationSuccess) return state.cards;
    return null;
  }

  Widget _buildAppBar() {
    return ShowmeSliverAppBar(
      title: 'Mes cartes',
      showBackButton: true,
      onBackPressed: () => context.go('/profile'),
      actions: [
        // Bouton refresh
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: BlocBuilder<CardBloc, CardState>(
            builder: (context, state) {
              final isLoading = state is CardLoading || 
                              state is CardCreateLoading || 
                              state is CardUpdateLoading || 
                              state is CardDeleteLoading;
              
              return IconButton(
                onPressed: isLoading ? null : () {
                  context.read<CardBloc>().add(CardRefreshRequested());
                },
                icon: AnimatedRotation(
                  turns: isLoading ? 1 : 0,
                  duration: ShowmeDesign.normalDuration,
                  child: Icon(
                    Icons.refresh,
                    color: isLoading ? ShowmeDesign.neutral400 : ShowmeDesign.neutral700,
                  ),
                ),
              );
            },
          ),
        ),
        // Bouton création rapide
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: IconButton(
            onPressed: _navigateToCardCreation,
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: ShowmeDesign.primaryTeal,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(List cards) {
    final totalViews = cards.fold<int>(0, (sum, card) => sum + (card.viewsCount as int));
    final totalShares = cards.fold<int>(0, (sum, card) => sum + (card.totalShared as int));
    final publicCards = cards.where((card) => card.isPublic).length;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(ShowmeDesign.spacingMd),
        padding: const EdgeInsets.all(ShowmeDesign.spacingLg),
        decoration: BoxDecoration(
          color: ShowmeDesign.white,
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusLg),
          boxShadow: [
            BoxShadow(
              color: ShowmeDesign.neutral900.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                icon: Icons.visibility,
                value: totalViews.toString(),
                label: 'Vues',
                color: ShowmeDesign.primaryBlue,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: ShowmeDesign.neutral200,
            ),
            Expanded(
              child: _buildStatItem(
                icon: Icons.share,
                value: totalShares.toString(),
                label: 'Partages',
                color: ShowmeDesign.primaryTeal,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: ShowmeDesign.neutral200,
            ),
            Expanded(
              child: _buildStatItem(
                icon: Icons.public,
                value: publicCards.toString(),
                label: 'Publiques',
                color: ShowmeDesign.primaryPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: ShowmeDesign.spacingSm),
        Text(
          value,
          style: ShowmeDesign.h4.copyWith(
            color: ShowmeDesign.neutral900,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: ShowmeDesign.caption.copyWith(
            color: ShowmeDesign.neutral600,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: ShowmeDesign.primaryPurple,
            ),
            const SizedBox(height: ShowmeDesign.spacingMd),
            Text(
              'Chargement de vos cartes...',
              style: ShowmeDesign.bodyMedium.copyWith(
                color: ShowmeDesign.neutral600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(ShowmeDesign.spacingXl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: ShowmeDesign.primaryRose.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 40,
                  color: ShowmeDesign.primaryRose,
                ),
              ),
              const SizedBox(height: ShowmeDesign.spacingLg),
              Text(
                'Oups !',
                style: ShowmeDesign.h3.copyWith(
                  color: ShowmeDesign.neutral800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: ShowmeDesign.spacingSm),
              Text(
                message,
                style: ShowmeDesign.bodyMedium.copyWith(
                  color: ShowmeDesign.neutral600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ShowmeDesign.spacingLg),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<CardBloc>().add(CardLoadRequested());
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ShowmeDesign.primaryPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(ShowmeDesign.spacingXl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration avec animation
              TweenAnimationBuilder<double>(
                duration: const Duration(seconds: 2),
                tween: Tween(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (value * 0.2),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ShowmeDesign.primaryPurple.withOpacity(0.1),
                            ShowmeDesign.primaryTeal.withOpacity(0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.credit_card,
                        size: 60,
                        color: ShowmeDesign.primaryPurple,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: ShowmeDesign.spacingXl),
              
              Text(
                'Aucune carte pour le moment',
                style: ShowmeDesign.h3.copyWith(
                  color: ShowmeDesign.neutral800,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: ShowmeDesign.spacingMd),
              
              Text(
                'Créez votre première carte de visite digitale pour commencer à partager vos informations professionnelles de manière moderne et élégante.',
                style: ShowmeDesign.bodyMedium.copyWith(
                  color: ShowmeDesign.neutral600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: ShowmeDesign.spacingXl),
              
              ElevatedButton.icon(
                onPressed: _navigateToCardCreation,
                icon: const Icon(Icons.add),
                label: const Text('Créer ma première carte'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ShowmeDesign.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: ShowmeDesign.spacingXl,
                    vertical: ShowmeDesign.spacingMd,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ShowmeDesign.radiusLg),
                  ),
                  elevation: 4,
                ),
              ),
              
              const SizedBox(height: ShowmeDesign.spacingMd),
              
              TextButton(
                onPressed: () {
                  // Afficher un guide ou des exemples
                  _showCardExamples();
                },
                child: Text(
                  'Voir des exemples',
                  style: ShowmeDesign.bodyMedium.copyWith(
                    color: ShowmeDesign.primaryPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardsList(List cards) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final card = cards[index];
          
          return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is AuthAuthenticated) {
                return Container(
                  margin: const EdgeInsets.only(
                    left: ShowmeDesign.spacingMd,
                    right: ShowmeDesign.spacingMd,
                    bottom: ShowmeDesign.spacingSm,
                  ),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ShowmeDesign.radiusLg),
                    ),
                    child: InkWell(
                      onTap: () => _navigateToCardDetail(card.id.toString()),
                      borderRadius: BorderRadius.circular(ShowmeDesign.radiusLg),
                      child: Padding(
                        padding: const EdgeInsets.all(ShowmeDesign.spacingLg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header avec titre et actions
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        card.title,
                                        style: ShowmeDesign.h5.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (card.bio != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          card.bio!,
                                          style: ShowmeDesign.bodySmall.copyWith(
                                            color: ShowmeDesign.neutral600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                
                                // Menu d'actions
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert),
                                  onSelected: (String value) {
                                    switch (value) {
                                      case 'edit':
                                        _showEditCardDialog(context, card);
                                        break;
                                      case 'toggle_public':
                                        context.read<CardBloc>().add(
                                          CardTogglePublicRequested(card.id.toString(), !card.isPublic)
                                        );
                                        break;
                                      case 'share':
                                        context.read<CardBloc>().add(
                                          CardShareRequested(card.id.toString(), 'link')
                                        );
                                        break;
                                      case 'qr_code':
                                        context.read<CardBloc>().add(
                                          CardQRGenerateRequested(card.id.toString())
                                        );
                                        break;
                                      case 'delete':
                                        _confirmDeleteCard(context, card);
                                        break;
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                    const PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 20),
                                          SizedBox(width: 8),
                                          Text('Modifier'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'toggle_public',
                                      child: Row(
                                        children: [
                                          Icon(
                                            card.isPublic ? Icons.visibility_off : Icons.visibility,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(card.isPublic ? 'Rendre privée' : 'Rendre publique'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'share',
                                      child: Row(
                                        children: [
                                          Icon(Icons.share, size: 20),
                                          SizedBox(width: 8),
                                          Text('Partager'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'qr_code',
                                      child: Row(
                                        children: [
                                          Icon(Icons.qr_code, size: 20),
                                          SizedBox(width: 8),
                                          Text('QR Code'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuDivider(),
                                    const PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, size: 20, color: ShowmeDesign.primaryRose),
                                          SizedBox(width: 8),
                                          Text('Supprimer', style: TextStyle(color: ShowmeDesign.primaryRose)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: ShowmeDesign.spacingMd),
                            
                            // Statistiques
                            Row(
                              children: [
                                _buildStatChip(
                                  icon: Icons.visibility,
                                  value: card.viewsCount.toString(),
                                  color: ShowmeDesign.primaryBlue,
                                ),
                                const SizedBox(width: ShowmeDesign.spacingSm),
                                _buildStatChip(
                                  icon: Icons.share,
                                  value: card.totalShared.toString(),
                                  color: ShowmeDesign.primaryTeal,
                                ),
                                const SizedBox(width: ShowmeDesign.spacingSm),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: card.isPublic 
                                        ? ShowmeDesign.primaryPurple.withOpacity(0.1)
                                        : ShowmeDesign.neutral200,
                                    borderRadius: BorderRadius.circular(ShowmeDesign.radiusSm),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        card.isPublic ? Icons.public : Icons.lock,
                                        size: 12,
                                        color: card.isPublic 
                                            ? ShowmeDesign.primaryPurple
                                            : ShowmeDesign.neutral600,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        card.isPublic ? 'Public' : 'Privé',
                                        style: ShowmeDesign.caption.copyWith(
                                          color: card.isPublic 
                                              ? ShowmeDesign.primaryPurple
                                              : ShowmeDesign.neutral600,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          );
        },
        childCount: cards.length,
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ShowmeDesign.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: ShowmeDesign.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Méthodes d'action

  Future<void> _handleRefresh() async {
    context.read<CardBloc>().add(CardRefreshRequested());
    await Future.delayed(const Duration(milliseconds: 300));
  }

  void _navigateToCardCreation() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<CardBloc>(),
          child: const CardCreationPage(),
        ),
      ),
    );
  }

  void _navigateToCardDetail(String cardId) {
    context.go('/cards/$cardId');
  }

  void _handleShareSuccess(String shareUrl, String message) {
    if (message.contains('QR')) {
      // Afficher le QR code dans une boîte de dialogue
      _showQRCodeDialog(shareUrl);
    } else {
      // Partager l'URL directement avec share_plus v11.1.0
      Share.shareUri(
        Uri.parse(shareUrl),
      );
    }
  }

  void _showQRCodeDialog(String qrCodeUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ici vous pourriez afficher l'image du QR code
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: ShowmeDesign.neutral300),
                borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.qr_code,
                      size: 80,
                      color: ShowmeDesign.neutral600,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'QR Code généré',
                      style: ShowmeDesign.bodySmall.copyWith(
                        color: ShowmeDesign.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Partagez ce QR code pour que les autres puissent scanner votre carte',
              style: ShowmeDesign.bodySmall.copyWith(
                color: ShowmeDesign.neutral600,
              ),
              textAlign: TextAlign.center,
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
              Share.share(qrCodeUrl, subject: 'QR Code de ma carte');
            },
            child: const Text('Partager'),
          ),
        ],
      ),
    );
  }

  void _showEditCardDialog(BuildContext context, dynamic card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier la carte'),
        content: const Text('Cette fonctionnalité sera bientôt disponible. Vous pourrez modifier votre carte directement depuis cette interface.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigator vers la page d'édition
              // _navigateToCardEdit(card.id.toString());
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

void _confirmDeleteCard(BuildContext context, dynamic card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la carte'),
        content: RichText(
          text: TextSpan(
            style: ShowmeDesign.bodyMedium.copyWith(color: ShowmeDesign.neutral800),
            children: [
              const TextSpan(text: 'Êtes-vous sûr de vouloir supprimer '),
              TextSpan(
                text: '"${card.title}"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' ?\n\nCette action est irréversible.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CardBloc>().add(
                CardDeleteRequested(card.id.toString())
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ShowmeDesign.primaryRose,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showCardExamples() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: ShowmeDesign.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(ShowmeDesign.radiusXl),
            topRight: Radius.circular(ShowmeDesign.radiusXl),
          ),
        ),
        padding: const EdgeInsets.all(ShowmeDesign.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ShowmeDesign.neutral300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: ShowmeDesign.spacingLg),
            
            Text(
              'Exemples de cartes',
              style: ShowmeDesign.h4.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: ShowmeDesign.spacingMd),
            
            Text(
              'Découvrez différents styles de cartes que vous pouvez créer',
              style: ShowmeDesign.bodyMedium.copyWith(
                color: ShowmeDesign.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: ShowmeDesign.spacingLg),
            
            // Liste d'exemples
            ..._buildExamplesList(),
            
            const SizedBox(height: ShowmeDesign.spacingLg),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: ShowmeDesign.neutral300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
                      ),
                    ),
                    child: const Text('Fermer'),
                  ),
                ),
                const SizedBox(width: ShowmeDesign.spacingMd),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToCardCreation();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ShowmeDesign.primaryPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
                      ),
                    ),
                    child: const Text('Créer ma carte'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildExamplesList() {
    final examples = [
      {
        'title': 'Professionnelle',
        'subtitle': 'Idéale pour les environnements corporate',
        'icon': Icons.business_center,
        'color': ShowmeDesign.primaryBlue,
      },
      {
        'title': 'Créative',
        'subtitle': 'Pour les métiers artistiques et créatifs',
        'icon': Icons.palette,
        'color': ShowmeDesign.primaryPurple,
      },
      {
        'title': 'Minimaliste',
        'subtitle': 'Simple et élégante, pour tous les secteurs',
        'icon': Icons.minimize,
        'color': ShowmeDesign.primaryTeal,
      },
      {
        'title': 'Tech',
        'subtitle': 'Moderne et innovante pour les tech workers',
        'icon': Icons.code,
        'color': ShowmeDesign.primaryRose,
      },
    ];

    return examples.map((example) => Container(
      margin: const EdgeInsets.only(bottom: ShowmeDesign.spacingSm),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: (example['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
          ),
          child: Icon(
            example['icon'] as IconData,
            color: example['color'] as Color,
            size: 24,
          ),
        ),
        title: Text(
          'Carte ${example['title']}',
          style: ShowmeDesign.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          example['subtitle'] as String,
          style: ShowmeDesign.bodySmall.copyWith(
            color: ShowmeDesign.neutral600,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: ShowmeDesign.neutral400,
        ),
        onTap: () {
          Navigator.pop(context);
          _navigateToCardCreation();
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
        ),
        tileColor: ShowmeDesign.neutral50,
      ),
    )).toList();
  }
}