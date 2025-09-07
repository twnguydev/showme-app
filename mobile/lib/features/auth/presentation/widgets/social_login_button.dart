// mobile/lib/features/auth/presentation/widgets/social_login_button.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/design/showme_design_system.dart';

enum SocialProvider { apple, google }

class SocialLoginButton extends StatefulWidget {
  final SocialProvider provider;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.provider,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  State<SocialLoginButton> createState() => _SocialLoginButtonState();
}

class _SocialLoginButtonState extends State<SocialLoginButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: ShowmeDesign.fastDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: widget.onPressed != null ? _onTapDown : null,
            onTapUp: widget.onPressed != null ? _onTapUp : null,
            onTapCancel: _onTapCancel,
            onTap: widget.onPressed,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
                border: Border.all(
                  color: _getBorderColor(),
                  width: 1.5,
                ),
                boxShadow: widget.onPressed != null
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getTextColor(),
                        ),
                      ),
                    )
                  else
                    _buildIcon(),
                  
                  SizedBox(width: ShowmeDesign.spacingMd),
                  
                  Text(
                    _getText(),
                    style: ShowmeDesign.bodyMedium.copyWith(
                      color: _getTextColor(),
                      fontWeight: FontWeight.w600,
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

  Widget _buildIcon() {
    switch (widget.provider) {
      case SocialProvider.apple:
        return const SizedBox(
          width: 20,
          height: 20,
          child: FaIcon(
            FontAwesomeIcons.apple,
            color: Colors.white,
            size: 20,
          ),
        );
      case SocialProvider.google:
        return const SizedBox(
          width: 20,
          height: 20,
          child: FaIcon(
            FontAwesomeIcons.google,
            color: Colors.black,
            size: 20,
          ),
        );
    }
  }

  Color _getBackgroundColor() {
    if (widget.onPressed == null) {
      return ShowmeDesign.neutral100;
    }
    
    switch (widget.provider) {
      case SocialProvider.apple:
        return Colors.black;
      case SocialProvider.google:
        return Colors.white;
    }
  }

  Color _getBorderColor() {
    if (widget.onPressed == null) {
      return ShowmeDesign.neutral200;
    }
    
    switch (widget.provider) {
      case SocialProvider.apple:
        return Colors.black;
      case SocialProvider.google:
        return ShowmeDesign.neutral300;
    }
  }

  Color _getTextColor() {
    if (widget.onPressed == null) {
      return ShowmeDesign.neutral400;
    }
    
    switch (widget.provider) {
      case SocialProvider.apple:
        return Colors.white;
      case SocialProvider.google:
        return ShowmeDesign.neutral700;
    }
  }

  String _getText() {
    switch (widget.provider) {
      case SocialProvider.apple:
        return 'Continuer avec Apple';
      case SocialProvider.google:
        return 'Continuer avec Google';
    }
  }
}

// Custom painter pour le vrai logo Google
class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    // Arc bleu (partie supérieure droite)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // -90 degrés
      pi / 2,  // 90 degrés
      false,
      paint,
    );

    // Arc rouge (partie supérieure gauche)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi, // -180 degrés
      pi / 2, // 90 degrés
      false,
      paint,
    );

    // Arc jaune (partie inférieure gauche)
    paint.color = const Color(0xFFFBBC04);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // -90 degrés (depuis le bas)
      -pi / 2, // -90 degrés
      false,
      paint,
    );

    // Arc vert (partie inférieure droite)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0, // 0 degrés
      pi / 2, // 90 degrés
      false,
      paint,
    );

    // Ligne horizontale bleue (caractéristique du G de Google)
    paint.color = const Color(0xFF4285F4);
    paint.style = PaintingStyle.fill;
    
    final lineRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        center.dx,
        center.dy - paint.strokeWidth / 2,
        radius * 0.6,
        paint.strokeWidth,
      ),
      Radius.circular(paint.strokeWidth / 2),
    );
    canvas.drawRRect(lineRect, paint);

    // Petite ligne verticale à la fin de la ligne horizontale
    final verticalLineRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        center.dx + radius * 0.6 - paint.strokeWidth / 2,
        center.dy - paint.strokeWidth / 2,
        paint.strokeWidth,
        radius * 0.3,
      ),
      Radius.circular(paint.strokeWidth / 2),
    );
    canvas.drawRRect(verticalLineRect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Alternative plus simple avec le "G" de Google
class SimpleGoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Fond blanc/transparent pour le centre
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width * 0.4;
    final innerRadius = size.width * 0.25;

    // Arc bleu (droite)
    paint.color = const Color(0xFF4285F4);
    final bluePath = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: outerRadius),
        -pi / 3, // Start angle
        2 * pi / 3, // Sweep angle
      )
      ..addArc(
        Rect.fromCircle(center: center, radius: innerRadius),
        pi / 3, // Start angle (reverse)
        -2 * pi / 3, // Sweep angle (reverse)
      );
    canvas.drawPath(bluePath, paint);

    // Arc rouge (haut gauche)
    paint.color = const Color(0xFFEA4335);
    final redPath = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: outerRadius),
        2 * pi / 3, // Start angle
        2 * pi / 3, // Sweep angle
      )
      ..addArc(
        Rect.fromCircle(center: center, radius: innerRadius),
        4 * pi / 3, // Start angle (reverse)
        -2 * pi / 3, // Sweep angle (reverse)
      );
    canvas.drawPath(redPath, paint);

    // Arc jaune (bas gauche)
    paint.color = const Color(0xFFFBBC04);
    final yellowPath = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: outerRadius),
        4 * pi / 3, // Start angle
        pi / 2, // Sweep angle
      )
      ..addArc(
        Rect.fromCircle(center: center, radius: innerRadius),
        11 * pi / 6, // Start angle (reverse)
        -pi / 2, // Sweep angle (reverse)
      );
    canvas.drawPath(yellowPath, paint);

    // Arc vert (bas droite)
    paint.color = const Color(0xFF34A853);
    final greenPath = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: outerRadius),
        11 * pi / 6, // Start angle
        pi / 2, // Sweep angle
      )
      ..addArc(
        Rect.fromCircle(center: center, radius: innerRadius),
        -pi / 3, // Start angle (reverse)
        -pi / 2, // Sweep angle (reverse)
      );
    canvas.drawPath(greenPath, paint);

    // Barre horizontale du G (caractéristique de Google)
    paint.color = const Color(0xFF4285F4);
    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        center.dx,
        center.dy - size.height * 0.03,
        size.width * 0.15,
        size.height * 0.06,
      ),
      Radius.circular(size.height * 0.03),
    );
    canvas.drawRRect(barRect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}