// mobile/lib/features/card/presentation/widgets/card_preview.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../shared/models/card.dart';
import '../../../../core/utils/app_theme.dart';

class CardPreview extends StatefulWidget {
  final Card card;
  final VoidCallback? onTap;
  final bool showActions;

  const CardPreview({
    super.key,
    required this.card,
    this.onTap,
    this.showActions = true,
  });

  @override
  State<CardPreview> createState() => _CardPreviewState();
}

class _CardPreviewState extends State<CardPreview>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _glowController;
  late AnimationController _entranceController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));

    // Démarrer les animations
    _entranceController.forward();
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _glowController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _rotationController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _rotationController.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _rotationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _slideAnimation,
        _rotationAnimation,
        _glowAnimation,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value * (_isPressed ? 0.98 : 1.0),
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: GestureDetector(
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getCardThemeColor(),
                        _getCardThemeColor().withOpacity(0.8),
                        _getCardThemeColor().withOpacity(0.6),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getCardThemeColor()
                            .withOpacity(0.4 * _glowAnimation.value),
                        blurRadius: 25 + (15 * _glowAnimation.value),
                        offset: const Offset(0, 12),
                        spreadRadius: 2,
                      ),
                      if (_isPressed)
                        BoxShadow(
                          color: _getCardThemeColor().withOpacity(0.6),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                          spreadRadius: 5,
                        ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Motifs de fond futuristes
                      _buildFuturisticBackground(),
                      
                      // Effet glassmorphique
                      _buildGlassmorphicEffect(),
                      
                      // Contenu principal
                      _buildContent(),
                      
                      // Badge actif (Pro badge)
                      if (widget.card.isPro) _buildProBadge(),
                      
                      // Reflets lumineux
                      _buildLightReflections(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getCardThemeColor() {
    // Use the helper class instead of extension
    return CardThemeHelper.getPrimaryColor(widget.card.theme);
  }

  Widget _buildFuturisticBackground() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Cercles animés
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return Positioned(
                  top: -40 + (10 * math.sin(_glowAnimation.value * math.pi)),
                  right: -40 + (8 * math.cos(_glowAnimation.value * math.pi)),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.15 * _glowAnimation.value),
                          Colors.white.withOpacity(0.05 * _glowAnimation.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Formes géométriques
            Positioned(
              bottom: -25,
              left: -25,
              child: Transform.rotate(
                angle: _glowAnimation.value * math.pi / 4,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
            ),
            
            // Lignes modernes
            Positioned(
              top: 40,
              left: -30,
              child: Transform.rotate(
                angle: 0.3,
                child: Container(
                  width: 120,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.3 * _glowAnimation.value),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
            
            // Grille de points futuriste
            ...List.generate(8, (index) {
              return Positioned(
                top: 20 + (index * 25.0),
                right: 20,
                child: Container(
                  width: 2,
                  height: 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassmorphicEffect() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.25),
              Colors.white.withOpacity(0.1),
              Colors.transparent,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec avatar et logo
          _buildHeader(),
          
          const Spacer(),
          
          // Informations principales
          _buildMainInfo(),
          
          if (widget.showActions) ...[
            const SizedBox(height: 20),
            _buildActions(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Avatar avec effet 3D
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1000),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.transparent,
                  backgroundImage: widget.card.profile.avatar?.url != null
                      ? NetworkImage(widget.card.profile.avatar!.url)
                      : null,
                  child: widget.card.profile.avatar?.url == null
                      ? Text(
                          _getInitials(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        )
                      : null,
                ),
              ),
            );
          },
        ),
        
        // Logo entreprise avec effet moderne
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1200),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(30 * (1 - value), 0),
              child: Opacity(
                opacity: value,
                child: widget.card.profile.companyLogo?.url != null
                    ? Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            widget.card.profile.companyLogo!.url,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.business_outlined,
                              color: Colors.grey[400],
                              size: 24,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.business_outlined,
                          color: Colors.white.withOpacity(0.9),
                          size: 24,
                        ),
                      ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _getInitials() {
    final firstName = widget.card.profile.firstName ?? '';
    final lastName = widget.card.profile.lastName ?? '';
    return '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();
  }

  Widget _buildMainInfo() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom avec effet futuriste
                Text(
                  _getFullName(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black38,
                        offset: Offset(0, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 6),
                
                // Titre/Poste
                Text(
                  widget.card.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Entreprise
                if (widget.card.profile.company != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.business_outlined,
                          color: Colors.white.withOpacity(0.9),
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.card.profile.company!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _getFullName() {
    final firstName = widget.card.profile.firstName ?? '';
    final lastName = widget.card.profile.lastName ?? '';
    return '$firstName $lastName'.trim();
  }

  Widget _buildActions() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Row(
              children: [
                // Partager
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: _handleShare,
                ),
                
                const SizedBox(width: 12),
                
                // QR Code
                _buildActionButton(
                  icon: Icons.qr_code_outlined,
                  label: 'QR',
                  onTap: _handleQRCode,
                ),
                
                const Spacer(),
                
                // Stats mini
                _buildStatsIndicator(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.25),
              Colors.white.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.trending_up,
            color: Colors.white.withOpacity(0.9),
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.card.viewsCount}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProBadge() {
    return Positioned(
      top: 20,
      right: 20,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 1800),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00ff94), Color(0xFF00d4aa)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00ff94).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'HELLO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLightReflections() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1.0 + (2.0 * _glowAnimation.value), -1.0),
                  end: Alignment(1.0 + (2.0 * _glowAnimation.value), 1.0),
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.1 * _glowAnimation.value),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleShare() {
    HapticFeedback.mediumImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: const Row(
            children: [
              Icon(Icons.share_outlined, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text(
                'Share feature coming soon',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF1a1a1a),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _handleQRCode() {
    HapticFeedback.mediumImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: const Row(
            children: [
              Icon(Icons.qr_code_outlined, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text(
                'QR Code coming soon',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF1a1a1a),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}