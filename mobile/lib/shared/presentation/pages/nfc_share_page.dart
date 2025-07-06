// mobile/lib/shared/presentation/pages/nfc_share_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

import '../../../core/design/showme_design_system.dart';

class NFCSharePage extends StatefulWidget {
  const NFCSharePage({super.key});

  @override
  State<NFCSharePage> createState() => _NFCSharePageState();
}

class _NFCSharePageState extends State<NFCSharePage>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _cardController;
  late AnimationController _particleController;
  late AnimationController _successController;
  
  late Animation<double> _waveAnimation;
  late Animation<double> _cardScaleAnimation;
  late Animation<double> _cardSlideAnimation;
  late Animation<double> _particleAnimation;

  bool _isTransferring = false;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    
    _setupAnimations();
    _startNFCAnimation();
  }

  void _setupAnimations() {
    // Animation des ondes de transmission
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Animation de la carte
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Animation des particules
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    // Animation de succès
    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Ondes concentriques
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeOut,
    ));

    // Échelle de la carte
    _cardScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    // Glissement de la carte vers le haut
    _cardSlideAnimation = Tween<double>(
      begin: 100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));

    // Particules de données
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeInOut,
    ));
  }

  void _startNFCAnimation() {
    // Démarrer l'animation des ondes
    _waveController.repeat();
    
    // Démarrer l'animation de la carte
    _cardController.forward();
    
    // Simuler le début du transfert après 1 seconde
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isTransferring = true;
        });
        _particleController.forward();
      }
    });
    
    // Simuler la fin du transfert après 3 secondes
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        setState(() {
          _isTransferring = false;
          _isComplete = true;
        });
        _waveController.stop();
        _successController.forward();
        
        // Revenir à l'écran précédent après le succès
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            context.go('/home');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _cardController.dispose();
    _particleController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fond avec gradient subtil
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.3),
                radius: 1.5,
                colors: [
                  Color(0xFF1A1A1A),
                  Color(0xFF000000),
                ],
              ),
            ),
          ),
          
          // Animation des ondes NFC
          if (!_isComplete) _buildNFCWaves(),
          
          // Particules de données
          if (_isTransferring) _buildDataParticles(),
          
          // Contenu principal
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                
                // Icône NFC animée
                _buildNFCIcon(),
                
                const SizedBox(height: ShowmeDesign.spacing3xl),
                
                // Carte de visite
                _buildBusinessCard(),
                
                const SizedBox(height: ShowmeDesign.spacing3xl),
                
                // Texte de statut
                _buildStatusText(),
                
                const Spacer(),
                
                // Bouton d'annulation
                if (!_isComplete) _buildCancelButton(),
                
                const SizedBox(height: ShowmeDesign.spacing2xl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNFCWaves() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _waveAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: NFCWavesPainter(
              animation: _waveAnimation.value,
              isTransferring: _isTransferring,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildDataParticles() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _particleAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: DataParticlesPainter(
              animation: _particleAnimation.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildNFCIcon() {
    return AnimatedBuilder(
      animation: _cardController,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardScaleAnimation.value,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                // Effet de glow
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: ShowmeDesign.primaryBlue.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
                
                // Icône NFC
                const Center(
                  child: Icon(
                    Icons.nfc,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBusinessCard() {
    return AnimatedBuilder(
      animation: _cardController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _cardSlideAnimation.value),
          child: Transform.scale(
            scale: _cardScaleAnimation.value,
            child: Container(
              width: 300,
              height: 180,
              decoration: BoxDecoration(
                gradient: ShowmeDesign.primaryGradient,
                borderRadius: BorderRadius.circular(ShowmeDesign.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Motif de fond
                  Positioned.fill(
                    child: CustomPaint(
                      painter: CardPatternPainter(),
                    ),
                  ),
                  
                  // Contenu de la carte
                  Padding(
                    padding: const EdgeInsets.all(ShowmeDesign.spacingLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo et nom
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
                              ),
                              child: const Icon(
                                Icons.business_center_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: ShowmeDesign.spacingMd),
                            const Text(
                              'Showme',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        
                        const Spacer(),
                        
                        // Informations
                        const Text(
                          'Votre carte de visite digitale',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        
                        const SizedBox(height: ShowmeDesign.spacingSm),
                        
                        const Text(
                          'Partagez vos informations\ninstantanément',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
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

  Widget _buildStatusText() {
    String statusText = 'Approchez votre téléphone...';
    if (_isTransferring) {
      statusText = 'Transfert en cours...';
    } else if (_isComplete) {
      statusText = 'Transfert terminé !';
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        statusText,
        key: ValueKey(statusText),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCancelButton() {
    return TextButton(
      onPressed: () => context.go('/home'),
      child: const Text(
        'Annuler',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
      ),
    );
  }
}

// Painter pour les ondes NFC
class NFCWavesPainter extends CustomPainter {
  final double animation;
  final bool isTransferring;

  NFCWavesPainter({required this.animation, required this.isTransferring});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height * 0.25);
    final maxRadius = size.width * 0.8;

    // Dessiner 3 ondes concentriques
    for (int i = 0; i < 3; i++) {
      final delay = i * 0.3;
      final waveAnimation = ((animation + delay) % 1.0);
      final radius = maxRadius * waveAnimation;
      final opacity = (1.0 - waveAnimation) * 0.6;

      paint.color = (isTransferring ? Colors.green : Colors.blue)
          .withOpacity(opacity);

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Painter pour les particules de données
class DataParticlesPainter extends CustomPainter {
  final double animation;

  DataParticlesPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final startY = size.height * 0.25;
    final endY = size.height * 0.75;
    final centerX = size.width / 2;

    // Créer des particules qui descendent
    for (int i = 0; i < 20; i++) {
      final offset = (i * 0.1) % 1.0;
      final particleAnimation = ((animation + offset) % 1.0);
      
      final x = centerX + (math.sin(i * 0.5) * 50);
      final y = startY + (endY - startY) * particleAnimation;
      final opacity = math.sin(particleAnimation * math.pi);
      
      paint.color = Colors.white.withOpacity(opacity * 0.8);
      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Painter pour le motif de la carte
class CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Dessiner des lignes diagonales subtiles
    for (int i = 0; i < 10; i++) {
      final path = Path();
      path.moveTo(i * 30.0, 0);
      path.lineTo(i * 30.0 + 50, size.height);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}