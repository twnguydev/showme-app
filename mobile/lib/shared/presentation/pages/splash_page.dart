// mobile/lib/shared/presentation/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/showme_design_system.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_event.dart';
import '../../../features/auth/bloc/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late AnimationController _backgroundController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    
    _setupAnimations();
    _startAnimationSequence();
    
    // Vérifier l'authentification après l'animation
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        context.read<AuthBloc>().add(AuthCheckRequested());
      }
    });
  }

  void _setupAnimations() {
    // Animation du logo principal
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Animation de pulsation continue
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Animation du background
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Logo scale avec courbe élastique
    _logoScaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
    ));

    // Logo fade in
    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    // Text fade in
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));

    // Pulsation continue
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Background gradient animation
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimationSequence() {
    // Démarrer l'animation du background
    _backgroundController.forward();
    
    // Démarrer l'animation du logo
    _logoController.forward();
    
    // Démarrer la pulsation en boucle après un délai
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _pulseController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/home');
          } else if (state is AuthUnauthenticated) {
            context.go('/login');
          }
        },
        child: AnimatedBuilder(
          animation: _backgroundController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(
                      ShowmeDesign.primaryPurple,
                      ShowmeDesign.primaryBlue,
                      _backgroundAnimation.value,
                    )!,
                    Color.lerp(
                      ShowmeDesign.primaryBlue,
                      ShowmeDesign.primaryTeal,
                      _backgroundAnimation.value,
                    )!,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Effets de background
                  _buildBackgroundEffects(),
                  
                  // Contenu principal
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLogo(),
                        SizedBox(height: ShowmeDesign.spacingXl),
                        _buildText(),
                        SizedBox(height: ShowmeDesign.spacing3xl),
                        _buildLoadingIndicator(),
                      ],
                    ),
                  ),
                  
                  // Version en bas
                  _buildVersionInfo(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBackgroundEffects() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Cercles animés
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return CustomPaint(
                painter: FloatingCirclesPainter(
                  animation: _backgroundAnimation.value,
                ),
                size: Size.infinite,
              );
            },
          ),
          
          // Motif géométrique
          Positioned.fill(
            child: CustomPaint(
              painter: GeometricBackgroundPainter(
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),
          
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoController, _pulseController]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _logoFadeAnimation,
          child: Transform.scale(
            scale: _logoScaleAnimation.value * _pulseAnimation.value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(ShowmeDesign.radius2xl),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, -5),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Fond gradient subtil
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(ShowmeDesign.radius2xl),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.grey.shade50,
                        ],
                      ),
                    ),
                  ),
                  
                  // Logo Showme
                  Center(
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: ShowmeDesign.primaryGradient,
                        borderRadius: BorderRadius.circular(ShowmeDesign.radiusLg),
                      ),
                      child: const Icon(
                        Icons.business_center_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildText() {
    return AnimatedBuilder(
      animation: _textFadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _textFadeAnimation,
          child: Column(
            children: [
              // Nom de l'app
              Text(
                'Showme',
                style: ShowmeDesign.h1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: ShowmeDesign.spacingSm),
              
              // Tagline
              Text(
                'Votre carte de visite digitale',
                style: ShowmeDesign.bodyLarge.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 1),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return AnimatedBuilder(
      animation: _textFadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _textFadeAnimation,
          child: Column(
            children: [
              // Indicateur de chargement custom
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(ShowmeDesign.radiusXs),
                ),
                child: Stack(
                  children: [
                    AnimatedBuilder(
                      animation: _backgroundController,
                      builder: (context, child) {
                        return Container(
                          width: 40 * _backgroundAnimation.value,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(ShowmeDesign.radiusXs),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: ShowmeDesign.spacingMd),
              
              // Texte de chargement
              Text(
                'Chargement...',
                style: ShowmeDesign.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVersionInfo() {
    return Positioned(
      bottom: ShowmeDesign.spacing2xl,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _textFadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _textFadeAnimation,
            child: Center(
              child: Text(
                'Version 1.0.0',
                style: ShowmeDesign.caption.copyWith(
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Painter pour les cercles flottants animés
class FloatingCirclesPainter extends CustomPainter {
  final double animation;

  FloatingCirclesPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Cercles avec opacité et mouvement
    final circles = [
      {
        'x': size.width * 0.2,
        'y': size.height * 0.3 + (animation * 30),
        'radius': 40.0,
        'opacity': 0.1,
      },
      {
        'x': size.width * 0.8,
        'y': size.height * 0.7 - (animation * 25),
        'radius': 60.0,
        'opacity': 0.08,
      },
      {
        'x': size.width * 0.1,
        'y': size.height * 0.8 + (animation * 20),
        'radius': 30.0,
        'opacity': 0.12,
      },
      {
        'x': size.width * 0.9,
        'y': size.height * 0.2 - (animation * 35),
        'radius': 50.0,
        'opacity': 0.09,
      },
    ];

    for (final circle in circles) {
      paint.color = Colors.white.withOpacity(circle['opacity'] as double);
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

// Painter pour le motif géométrique de fond
class GeometricBackgroundPainter extends CustomPainter {
  final Color color;

  GeometricBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Grille de lignes diagonales
    for (int i = 0; i < size.width / 60; i++) {
      final path = Path();
      path.moveTo(i * 60.0, 0);
      path.lineTo(i * 60.0 + 100, size.height);
      canvas.drawPath(path, paint);
    }

    // Lignes horizontales subtiles
    for (int i = 0; i < size.height / 80; i++) {
      canvas.drawLine(
        Offset(0, i * 80.0),
        Offset(size.width, i * 80.0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}