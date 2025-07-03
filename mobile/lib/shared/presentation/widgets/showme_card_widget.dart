// mobile/lib/shared/widgets/showme_card_widget.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/design/showme_design_system.dart';
import '../../models/card.dart' as CardModel;
import '../../models/card_theme.dart';

class ShowmeCardWidget extends StatefulWidget {
  final CardModel.Card card;
  final VoidCallback? onTap;
  final bool showActions;
  final bool showQR;
  final CardSize size;

  const ShowmeCardWidget({
    super.key,
    required this.card,
    this.onTap,
    this.showActions = true,
    this.showQR = false,
    this.size = CardSize.normal,
  });

  @override
  State<ShowmeCardWidget> createState() => _ShowmeCardWidgetState();
}

enum CardSize { compact, normal, large, hero }

class _ShowmeCardWidgetState extends State<ShowmeCardWidget>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _entryController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      duration: ShowmeDesign.normalDuration,
      vsync: this,
    );

    _entryController = AnimationController(
      duration: ShowmeDesign.extraSlowDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: ShowmeDesign.primaryCurve,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: ShowmeDesign.smoothCurve,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: ShowmeDesign.bouncyCurve,
    ));

    _entryController.forward();
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  double get _cardHeight {
    switch (widget.size) {
      case CardSize.compact:
        return 140;
      case CardSize.normal:
        return 200;
      case CardSize.large:
        return 260;
      case CardSize.hero:
        return 320;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: ShowmeDesign.spacingXl, // 32px de margin top
        left: 10, // Même marge que l'AppBar
        right: 10, // Même marge que l'AppBar
      ),
      child: SlideTransition(
        position: _slideAnimation,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: _buildCard(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard() {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: _cardHeight,
          decoration: _buildCardDecoration(),
          child: Stack(
            children: [
              _buildBackgroundEffects(),
              _buildCardContent(),
              if (widget.card.isPro) _buildProBadge(),
              if (widget.showQR) _buildQROverlay(),
            ],
          ),
        ),
      ),
    );
  }

  void _handleHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  BoxDecoration _buildCardDecoration() {
    final gradient = CardThemeHelper.getGradient(widget.card.theme);
    
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(ShowmeDesign.radiusXl),
      boxShadow: _isHovered ? CardThemeHelper.getShadows(widget.card.theme) : ShowmeDesign.cardShadow,
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1,
      ),
    );
  }

  Widget _buildBackgroundEffects() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ShowmeDesign.radiusXl),
      child: Stack(
        children: [
          // Effet holographique
          AnimatedBuilder(
            animation: _shimmerAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_shimmerAnimation.value * 100, 0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Motifs géométriques
          Positioned.fill(
            child: CustomPaint(
              painter: GeometricPatternPainter(
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          
          // Cercles décoratifs
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent() {
    return Padding(
      padding: EdgeInsets.all(ShowmeDesign.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Spacer(),
          _buildMainInfo(),
          if (widget.showActions) ...[
            SizedBox(height: ShowmeDesign.spacingMd),
            _buildActions(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Avatar avec animation
        TweenAnimationBuilder<double>(
          duration: ShowmeDesign.normalDuration,
          tween: Tween(begin: 0, end: 1),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                width: widget.size == CardSize.compact ? 40 : 56,
                height: widget.size == CardSize.compact ? 40 : 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: widget.size == CardSize.compact ? 18 : 26,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage: widget.card.profile.avatar != null
                      ? NetworkImage(widget.card.profile.avatar!.url)
                      : null,
                  child: widget.card.profile.avatar == null
                      ? Text(
                          _getInitials(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: widget.size == CardSize.compact ? 14 : 18,
                          ),
                        )
                      : null,
                ),
              ),
            );
          },
        ),
        
        const Spacer(),
        
        // Logo entreprise ou icône
        if (widget.card.profile.company != null)
          Container(
            padding: EdgeInsets.all(ShowmeDesign.spacingSm),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
            ),
            child: Icon(
              Icons.business,
              color: Colors.white.withOpacity(0.9),
              size: widget.size == CardSize.compact ? 16 : 20,
            ),
          ),
      ],
    );
  }

Widget _buildMainInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nom - Fixed null safety
        Text(
          _getFullName(),
          style: (widget.size == CardSize.compact 
              ? ShowmeDesign.bodyLarge 
              : ShowmeDesign.h3).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        SizedBox(height: ShowmeDesign.spacingXs),
        
        // Titre/Poste
        if (widget.card.profile.position != null)
          Text(
            widget.card.profile.position!,
            style: (widget.size == CardSize.compact 
                ? ShowmeDesign.bodySmall 
                : ShowmeDesign.bodyMedium).copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        
        // Entreprise
        if (widget.card.profile.company != null) ...[
          SizedBox(height: ShowmeDesign.spacingXs),
          Row(
            children: [
              Icon(
                Icons.business_outlined,
                color: Colors.white.withOpacity(0.8),
                size: 12,
              ),
              SizedBox(width: ShowmeDesign.spacingXs),
              Expanded(
                child: Text(
                  widget.card.profile.company!,
                  style: ShowmeDesign.caption.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
        
        // Stats pour les grandes cartes
        if (widget.size != CardSize.compact) ...[
          SizedBox(height: ShowmeDesign.spacingSm),
          Row(
            children: [
              _buildStatChip(Icons.visibility, '${widget.card.viewsCount}'),
              SizedBox(width: ShowmeDesign.spacingSm),
              _buildStatChip(Icons.share, '${widget.card.totalShared}'),
              if (widget.card.totalLeads > 0) ...[
                SizedBox(width: ShowmeDesign.spacingSm),
                _buildStatChip(Icons.person_add, '${widget.card.totalLeads}'),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String value) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ShowmeDesign.spacingSm,
        vertical: ShowmeDesign.spacingXs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(ShowmeDesign.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.9),
            size: 12,
          ),
          SizedBox(width: ShowmeDesign.spacingXs),
          Text(
            value,
            style: ShowmeDesign.caption.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        _buildActionButton(
          icon: Icons.share,
          label: 'Partager',
          onTap: () => _handleAction('share'),
        ),
        SizedBox(width: ShowmeDesign.spacingSm),
        _buildActionButton(
          icon: Icons.qr_code,
          label: 'QR',
          onTap: () => _handleAction('qr'),
        ),
        const Spacer(),
        _buildActionButton(
          icon: Icons.edit,
          label: 'Modifier',
          onTap: () => _handleAction('edit'),
        ),
      ],
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
              icon,
              color: Colors.white,
              size: 14,
            ),
            SizedBox(width: ShowmeDesign.spacingXs),
            Text(
              label,
              style: ShowmeDesign.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProBadge() {
    return Positioned(
      top: ShowmeDesign.spacingSm,
      right: ShowmeDesign.spacingSm,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ShowmeDesign.spacingSm,
          vertical: ShowmeDesign.spacingXs,
        ),
        decoration: BoxDecoration(
          gradient: ShowmeDesign.warmGradient,
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusSm),
          boxShadow: [
            BoxShadow(
              color: ShowmeDesign.primaryAmber.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              color: Colors.white,
              size: 12,
            ),
            SizedBox(width: ShowmeDesign.spacingXs),
            Text(
              'PRO',
              style: ShowmeDesign.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQROverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusXl),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(ShowmeDesign.spacingMd),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
              ),
              child: QrImageView(
                data: widget.card.publicUrl,
                version: QrVersions.auto,
                size: 120,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
            SizedBox(height: ShowmeDesign.spacingMd),
            Text(
              'Scannez pour voir ma carte',
              style: ShowmeDesign.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFullName() {
    final firstName = widget.card.profile.firstName ?? '';
    final lastName = widget.card.profile.lastName ?? '';
    final fullName = '$firstName $lastName'.trim();
    
    // If both are empty, fallback to email or a default
    if (fullName.isEmpty) {
      return widget.card.profile.email ?? 'Utilisateur';
    }
    
    return fullName;
  }

  String _getInitials() {
    final firstName = widget.card.profile.firstName ?? '';
    final lastName = widget.card.profile.lastName ?? '';
    
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    } else if (firstName.isNotEmpty) {
      return firstName.substring(0, firstName.length > 1 ? 2 : 1).toUpperCase();
    } else if (lastName.isNotEmpty) {
      return lastName.substring(0, lastName.length > 1 ? 2 : 1).toUpperCase();
    } else {
      // Fallback to email or default
      final email = widget.card.profile.email;
      if (email != null && email.isNotEmpty) {
        return email.substring(0, email.length > 1 ? 2 : 1).toUpperCase();
      }
      return 'US'; // Default initials
    }
  }

  void _handleAction(String action) {
    // TODO: Implémenter les actions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Action "$action" en cours de développement'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Painter pour les motifs géométriques
class GeometricPatternPainter extends CustomPainter {
  final Color color;

  GeometricPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Lignes diagonales
    for (int i = 0; i < 5; i++) {
      final path = Path();
      path.moveTo(i * 60.0, 0);
      path.lineTo(i * 60.0 + 40, size.height);
      canvas.drawPath(path, paint);
    }

    // Cercles décoratifs
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      8,
      paint,
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.8),
      12,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}