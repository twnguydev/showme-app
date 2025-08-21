// mobile/lib/features/card/presentation/widgets/dynamic_card_preview.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/design/showme_design_system.dart';
import '../../../../shared/models/card_theme.dart' as CardTheme;

class DynamicCardPreview extends StatefulWidget {
  final CardTheme.CardTheme theme;
  final String title;
  final String position;
  final String company;
  // final String email;
  final String phone;
  final String website;

  const DynamicCardPreview({
    super.key,
    required this.theme,
    required this.title,
    required this.position,
    required this.company,
    // required this.email,
    required this.phone,
    required this.website
  });

  @override
  State<DynamicCardPreview> createState() => _DynamicCardPreviewState();
}

class _DynamicCardPreviewState extends State<DynamicCardPreview>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      duration: ShowmeDesign.normalDuration,
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: ShowmeDesign.primaryCurve,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildCard(),
          );
        },
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

  Widget _buildCard() {
    return Container(
      height: 220,
      decoration: _buildCardDecoration(),
      child: Stack(
        children: [
          _buildBackgroundEffects(),
          _buildCardContent(),
          _buildShimmerEffect(),
        ],
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    final gradient = CardTheme.CardThemeHelper.getGradient(widget.theme);

    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(ShowmeDesign.radiusXl),
      boxShadow: _isHovered
          ? CardTheme.CardThemeHelper.getShadows(widget.theme)
          : [
              BoxShadow(
                color: ShowmeDesign.neutral900.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
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
            top: -60,
            right: -60,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),

          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 100,
              height: 100,
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

  Widget _buildShimmerEffect() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ShowmeDesign.radiusXl),
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shimmerAnimation.value * 150, 0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.15),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardContent() {
    return Padding(
      padding: const EdgeInsets.all(ShowmeDesign.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Spacer(),
          _buildMainInfo(),
          const SizedBox(height: ShowmeDesign.spacingSm),
          _buildContactInfo(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Avatar avec initiales dynamiques
        Container(
          width: 56,
          height: 56,
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
            radius: 26,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              _getInitials(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),

        const Spacer(),

        // Logo entreprise ou QR code preview
        if (widget.company.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(ShowmeDesign.spacingSm),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
            ),
            child: const Icon(
              Icons.business,
              color: Colors.white,
              size: 20,
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(ShowmeDesign.spacingSm),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
            ),
            child: const Icon(
              Icons.qr_code,
              color: Colors.white,
              size: 20,
            ),
          ),
      ],
    );
  }

  Widget _buildMainInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nom complet
        Text(
          widget.title,
          style: ShowmeDesign.h3.copyWith(
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

        const SizedBox(height: ShowmeDesign.spacingXs),

        // Poste
        if (widget.position.isNotEmpty)
          Text(
            widget.position,
            style: ShowmeDesign.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

        // Entreprise
        if (widget.company.isNotEmpty) ...[
          const SizedBox(height: ShowmeDesign.spacingXs),
          Row(
            children: [
              Icon(
                Icons.business_outlined,
                color: Colors.white.withOpacity(0.8),
                size: 12,
              ),
              const SizedBox(width: ShowmeDesign.spacingXs),
              Expanded(
                child: Text(
                  widget.company,
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
      ],
    );
  }

  Widget _buildContactInfo() {
    final contacts = _getVisibleContacts();
    if (contacts.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: ShowmeDesign.spacingSm,
      runSpacing: ShowmeDesign.spacingXs,
      children: contacts.map((contact) => _buildContactChip(
        contact['icon'] as IconData,
        contact['label'] as String,
      )).toList(),
    );
  }

  Widget _buildContactChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ShowmeDesign.spacingSm,
        vertical: ShowmeDesign.spacingXs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(ShowmeDesign.radiusSm),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.9),
            size: 12,
          ),
          const SizedBox(width: ShowmeDesign.spacingXs),
          Text(
            label,
            style: ShowmeDesign.caption.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials() {
    final parts = widget.title.split(' ');
    if (parts.length < 3) return widget.title.isNotEmpty ? widget.title[0].toUpperCase() : 'C';

    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  List<Map<String, dynamic>> _getVisibleContacts() {
    final contacts = <Map<String, dynamic>>[];

    if (widget.phone.isNotEmpty) {
      contacts.add({
        'icon': Icons.phone,
        'label': 'Tel',
      });
    }

    // if (widget.email.isNotEmpty) {
    //   contacts.add({
    //     'icon': Icons.email,
    //     'label': 'Email',
    //   });
    // }

    if (widget.website.isNotEmpty) {
      contacts.add({
        'icon': Icons.language,
        'label': 'Site',
      });
    }

    // Limiter à 3 contacts pour l'aperçu
    return contacts.take(3).toList();
  }
}

// Painter pour les motifs géométriques (réutilisé)
class GeometricPatternPainter extends CustomPainter {
  final Color color;

  GeometricPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Lignes diagonales subtiles
    for (int i = 0; i < 4; i++) {
      final path = Path();
      path.moveTo(i * 80.0, 0);
      path.lineTo(i * 80.0 + 60, size.height);
      canvas.drawPath(path, paint);
    }

    // Cercles décoratifs
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      6,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.85),
      8,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}