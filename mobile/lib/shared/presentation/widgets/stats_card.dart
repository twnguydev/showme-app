// mobile/lib/shared/presentation/widgets/stats_card.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class StatsCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final String? trend;
  final Gradient? gradient;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.trend,
    this.gradient,
  });

  @override
  State<StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<StatsCard>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _counterController;
  late AnimationController _entranceController;
  late Animation<double> _glowAnimation;
  late Animation<int> _counterAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    _counterController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    final targetValue = int.tryParse(widget.value) ?? 0;
    _counterAnimation = IntTween(
      begin: 0,
      end: targetValue,
    ).animate(CurvedAnimation(
      parent: _counterController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeInOut,
    ));

    // Démarrer les animations
    _entranceController.forward();
    _glowController.repeat(reverse: true);
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && targetValue > 0) {
        _counterController.forward();
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _counterController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_slideAnimation, _fadeAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: widget.gradient ?? const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.gradient?.colors.first ?? const Color(0xFF667eea))
                        .withOpacity(0.3 * _glowAnimation.value),
                    blurRadius: 15 + (10 * _glowAnimation.value),
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Motifs de fond
                  _buildBackgroundPattern(),
                  
                  // Effet glassmorphique
                  _buildGlassEffect(),
                  
                  // Contenu principal
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header avec icône et trend
                        _buildHeader(),
                        
                        const SizedBox(height: 12),
                        
                        // Valeur principale avec animation
                        _buildAnimatedValue(),
                        
                        const SizedBox(height: 8),
                        
                        // Titre
                        _buildTitle(),
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

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Cercle décoratif animé
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return Positioned(
                  top: -15 + (5 * math.sin(_glowAnimation.value * math.pi)),
                  right: -15 + (3 * math.cos(_glowAnimation.value * math.pi)),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1 * _glowAnimation.value),
                    ),
                  ),
                );
              },
            ),
            
            // Lignes géométriques
            Positioned(
              bottom: 10,
              left: 16,
              right: 16,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.3 * _glowAnimation.value),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassEffect() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.1),
              Colors.transparent,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Icône avec effet 3D
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            );
          },
        ),
        
        // Trend badge avec animation
        if (widget.trend != null)
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1200),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTrendColor().withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _getTrendColor().withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.trend!.startsWith('+') 
                            ? Icons.trending_up 
                            : Icons.trending_down,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.trend!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildAnimatedValue() {
    final targetValue = int.tryParse(widget.value);
    
    if (targetValue != null) {
      return AnimatedBuilder(
        animation: _counterAnimation,
        builder: (context, child) {
          return Text(
            _counterAnimation.value.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          );
        },
      );
    }
    
    return Text(
      widget.value,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: -1,
        shadows: [
          Shadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.9),
        letterSpacing: 0.2,
      ),
    );
  }

  Color _getTrendColor() {
    if (widget.trend == null) return Colors.grey;
    return widget.trend!.startsWith('+') 
        ? const Color(0xFF00ff94)
        : const Color(0xFFff6b6b);
  }
}