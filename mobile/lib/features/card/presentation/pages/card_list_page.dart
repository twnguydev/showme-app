// mobile/lib/features/card/presentation/pages/card_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:showme/features/card/bloc/card_bloc.dart';
import 'package:showme/shared/presentation/widgets/showme_app_bar.dart';
import 'package:showme/shared/presentation/widgets/showme_card_widget.dart';

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
    return BlocListener<CardBloc, CardState>(
      listener: (context, state) {
        if (state is CardOperationSuccess) {
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
                  if (state is CardLoaded || state is CardOperationSuccess) {
                    final cards = state is CardLoaded ? state.cards : (state as CardOperationSuccess).cards;
                    return _buildStatsSection(cards);
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),

              // Liste des cartes
              BlocBuilder<CardBloc, CardState>(
                builder: (context, state) {
                  if (state is CardLoading) {
                    return _buildLoadingState();
                  }

                  if (state is CardError) {
                    return _buildErrorState(state.message);
                  }

                  if (state is CardLoaded || state is CardOperationSuccess) {
                    final cards = state is CardLoaded ? state.cards : (state as CardOperationSuccess).cards;

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

  Widget _buildAppBar() {
    return ShowmeSliverAppBar(
      title: 'Mes cartes',
      showBackButton: true,
      actions: [
        // Bouton refresh
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: BlocBuilder<CardBloc, CardState>(
            builder: (context, state) {
              final isLoading = state is CardLoading;
              
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
                  margin: const EdgeInsets.only(bottom: ShowmeDesign.spacingSm),
                  child: ShowmeCardWidget(
                    card: card,
                    user: authState.user,
                    profile: card.profile,
                    onTap: () => _navigateToCardDetail(card.id.toString()),
                    showActions: true,
                    size: CardSize.normal,
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

  Future<void> _handleRefresh() async {
    context.read<CardBloc>().add(CardRefreshRequested());
    // Attendre que l'état change
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

  void _showCardExamples() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
            ...['Professionnelle', 'Créative', 'Minimaliste'].map((style) => 
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: ShowmeDesign.primaryPurple.withOpacity(0.1),
                  child: Icon(
                    Icons.credit_card,
                    color: ShowmeDesign.primaryPurple,
                    size: 20,
                  ),
                ),
                title: Text('Carte $style'),
                subtitle: Text('Style adapté aux $style.toLowerCase()s'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToCardCreation();
                },
              ),
            ),
            
            const SizedBox(height: ShowmeDesign.spacingLg),
            
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToCardCreation();
              },
              child: const Text('Créer ma carte'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ShowmeDesign.primaryPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}