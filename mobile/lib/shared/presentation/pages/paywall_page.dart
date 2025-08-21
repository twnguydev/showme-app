// mobile/lib/features/subscription/presentation/pages/paywall_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

import '../../../../core/design/showme_design_system.dart';

class PaywallPage extends StatefulWidget {
  final String? feature;
  final String? source;

  const PaywallPage({
    super.key,
    this.feature,
    this.source,
  });

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _floatingController;
  
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _floatingAnimation;

  String _selectedPlan = 'yearly';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _slideController.forward();
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  String get _featureTitle {
    switch (widget.feature) {
      case 'kiosk_mode':
        return 'le mode Kiosque';
      default:
        return 'Qard Pro';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                // Background avec éléments flottants
                _buildFloatingBackground(),
                
                // Contenu scrollable
                Transform.translate(
                  offset: Offset(0, MediaQuery.of(context).size.height * _slideAnimation.value),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: _buildHeader(),
                      ),
                      // Contenu principal
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: ShowmeDesign.spacingLg),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // Hero section
                            _buildHeroSection(),
                            
                            const SizedBox(height: ShowmeDesign.spacingXl),
                            
                            // Badge promotion
                            _buildPromoBadge(),
                            
                            const SizedBox(height: ShowmeDesign.spacingLg),
                            
                            // Plans de tarification
                            _buildPricingPlans(),
                            
                            const SizedBox(height: ShowmeDesign.spacingLg),
                            
                            // Fonctionnalités
                            _buildFeaturesList(),
                            
                            const SizedBox(height: ShowmeDesign.spacingXl),
                            
                            // CTA
                            _buildCTAButton(),
                            
                            const SizedBox(height: ShowmeDesign.spacingMd),
                            
                            // Informations légales
                            _buildLegalInfo(),
                            
                            const SizedBox(height: ShowmeDesign.spacingMd),
                            
                            // Bouton restaurer
                            _buildRestoreButton(),
                            
                            const SizedBox(height: ShowmeDesign.spacingXl),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFloatingBackground() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _floatingAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: FloatingElementsPainter(
              animation: _floatingAnimation.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(ShowmeDesign.spacingMd),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40),
          IconButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go('/home');
              }
            },
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.close,
                color: ShowmeDesign.neutral700,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Icône avec effet premium
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: ShowmeDesign.primaryGradient,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: ShowmeDesign.primaryBlue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              _getFeatureIcon(),
              color: Colors.white,
              size: 40,
            ),
          ),
          
          const SizedBox(height: ShowmeDesign.spacingLg),
          
          // Titre
          Text(
            'Débloquez $_featureTitle',
            style: ShowmeDesign.h2.copyWith(
              color: ShowmeDesign.neutral900,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: ShowmeDesign.spacingSm),
          
          // Sous-titre
          Text(
            'Accédez à toutes les fonctionnalités premium de Qard',
            style: ShowmeDesign.bodyLarge.copyWith(
              color: ShowmeDesign.neutral600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBadge() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ShowmeDesign.spacingMd,
            vertical: ShowmeDesign.spacingSm,
          ),
          decoration: BoxDecoration(
            color: ShowmeDesign.primaryAmber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ShowmeDesign.radiusFull),
            border: Border.all(
              color: ShowmeDesign.primaryAmber.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_fire_department,
                color: ShowmeDesign.primaryAmber,
                size: 16,
              ),
              const SizedBox(width: ShowmeDesign.spacingXs),
              Text(
                '7 jours d\'essai gratuit',
                style: ShowmeDesign.bodySmall.copyWith(
                  color: ShowmeDesign.primaryAmber,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingPlans() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        children: [
          Expanded(
            child: _buildPlanCard(
              title: 'Mensuel',
              price: '9,99€',
              period: '/mois',
              planId: 'monthly',
              originalPrice: null,
            ),
          ),
          
          const SizedBox(width: ShowmeDesign.spacingMd),
          
          Expanded(
            child: _buildPlanCard(
              title: 'Annuel',
              price: '6,66€',
              period: '/mois',
              planId: 'yearly',
              originalPrice: '9,99€',
              savings: '33% d\'économie',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String period,
    required String planId,
    String? originalPrice,
    String? savings,
  }) {
    final isSelected = _selectedPlan == planId;
    final isPopular = planId == 'yearly';
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = planId;
        });
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(ShowmeDesign.spacingLg),
        decoration: BoxDecoration(
          color: isSelected ? ShowmeDesign.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusLg),
          border: Border.all(
            color: isSelected ? ShowmeDesign.primaryBlue : ShowmeDesign.neutral200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                ? ShowmeDesign.primaryBlue.withOpacity(0.2)
                : Colors.black.withOpacity(0.08),
              blurRadius: isSelected ? 20 : 10,
              offset: Offset(0, isSelected ? 8 : 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Badge populaire
            if (isPopular)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ShowmeDesign.spacingSm,
                  vertical: ShowmeDesign.spacingXs / 2,
                ),
                margin: const EdgeInsets.only(bottom: ShowmeDesign.spacingSm),
                decoration: BoxDecoration(
                  gradient: ShowmeDesign.warmGradient,
                  borderRadius: BorderRadius.circular(ShowmeDesign.radiusXs),
                ),
                child: Text(
                  'POPULAIRE',
                  style: ShowmeDesign.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            
            // Titre du plan
            Text(
              title,
              style: ShowmeDesign.bodyLarge.copyWith(
                color: isSelected ? Colors.white : ShowmeDesign.neutral700,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: ShowmeDesign.spacingSm),
            
            // Prix principal
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: price,
                    style: ShowmeDesign.h2.copyWith(
                      color: isSelected ? Colors.white : ShowmeDesign.neutral900,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  TextSpan(
                    text: period,
                    style: ShowmeDesign.bodySmall.copyWith(
                      color: isSelected ? Colors.white.withOpacity(0.8) : ShowmeDesign.neutral600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Prix barré et économies
            if (originalPrice != null) ...[
              const SizedBox(height: ShowmeDesign.spacingXs),
              Text(
                'au lieu de $originalPrice',
                style: ShowmeDesign.caption.copyWith(
                  color: isSelected ? Colors.white.withOpacity(0.7) : ShowmeDesign.neutral500,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
            
            if (savings != null) ...[
              const SizedBox(height: ShowmeDesign.spacingXs),
              Text(
                savings,
                style: ShowmeDesign.caption.copyWith(
                  color: isSelected ? Colors.white : ShowmeDesign.primaryTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      '✨ Partage NFC illimité',
      '📱 Mode Kiosque pour les événements',
      '📊 Analytics détaillées',
      '🎨 Thèmes de cartes personnalisés',
      '🗂️ CRM avancé'
    ];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(ShowmeDesign.spacingLg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusLg),
          border: Border.all(
            color: ShowmeDesign.neutral200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tout ce que vous obtenez :',
              style: ShowmeDesign.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: ShowmeDesign.neutral900,
              ),
            ),
            const SizedBox(height: ShowmeDesign.spacingMd),
            ...features.map((feature) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: ShowmeDesign.spacingXs),
                child: Row(
                  children: [
                    Text(
                      feature,
                      style: ShowmeDesign.bodyMedium.copyWith(
                        color: ShowmeDesign.neutral700,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCTAButton() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _handleSubscribe,
          style: ElevatedButton.styleFrom(
            backgroundColor: ShowmeDesign.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: ShowmeDesign.primaryBlue.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ShowmeDesign.radiusLg),
            ),
          ),
          child: Text(
            'Démarrer l\'essai gratuit',
            style: ShowmeDesign.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegalInfo() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Text(
        'Annulation possible à tout moment. Facturation automatique après l\'essai.',
        style: ShowmeDesign.caption.copyWith(
          color: ShowmeDesign.neutral500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildRestoreButton() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: TextButton(
        onPressed: _handleRestore,
        child: Text(
          'Restaurer les achats',
          style: ShowmeDesign.bodySmall.copyWith(
            color: ShowmeDesign.neutral600,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  IconData _getFeatureIcon() {
    switch (widget.feature) {
      case 'kiosk_mode':
        return Icons.fullscreen_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  void _handleSubscribe() {
    HapticFeedback.mediumImpact();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusLg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(ShowmeDesign.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: ShowmeDesign.primaryBlue,
              ),
              const SizedBox(height: ShowmeDesign.spacingLg),
              Text(
                'Activation en cours...',
                style: ShowmeDesign.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop(); // Fermer le dialog
        
        // Vérifier si on peut pop avant de le faire
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(); // Fermer le paywall
        } else {
          // Si on ne peut pas pop, aller à la home
          context.go('/home');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✨ Showme Pro activé !'),
            backgroundColor: ShowmeDesign.primaryTeal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
            ),
          ),
        );
      }
    });
  }

  void _handleRestore() {
    HapticFeedback.lightImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Aucun achat à restaurer'),
        backgroundColor: ShowmeDesign.neutral600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
        ),
      ),
    );
  }
}

// Painter pour les éléments flottants en arrière-plan
class FloatingElementsPainter extends CustomPainter {
  final double animation;

  FloatingElementsPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Cercles flottants subtils
    final circles = [
      {
        'x': size.width * 0.1,
        'y': size.height * 0.2 + (animation * 20),
        'radius': 60.0,
        'color': Colors.blue.withOpacity(0.05),
      },
      {
        'x': size.width * 0.9,
        'y': size.height * 0.7 - (animation * 25),
        'radius': 80.0,
        'color': Colors.purple.withOpacity(0.03),
      },
      {
        'x': size.width * 0.8,
        'y': size.height * 0.3 + (animation * 15),
        'radius': 40.0,
        'color': Colors.teal.withOpacity(0.04),
      },
    ];

    for (final circle in circles) {
      paint.color = circle['color'] as Color;
      canvas.drawCircle(
        Offset(circle['x'] as double, circle['y'] as double),
        circle['radius'] as double,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}