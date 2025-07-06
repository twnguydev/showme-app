// mobile/lib/features/auth/presentation/widgets/social_login_button.dart
import 'package:flutter/material.dart';
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
        return Container(
          width: 20,
          height: 20,
          child: Icon(
            Icons.apple,
            color: _getTextColor(),
            size: 20,
          ),
        );
      case SocialProvider.google:
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          child: CustomPaint(
            painter: GoogleLogoPainter(),
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

// Custom painter pour le logo Google
class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // G de Google (simplifié)
    // Bleu
    paint.color = const Color(0xFF4285F4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width * 0.5, size.height * 0.5),
        const Radius.circular(2),
      ),
      paint,
    );

    // Rouge
    paint.color = const Color(0xFFEA4335);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.5, 0, size.width * 0.5, size.height * 0.5),
        const Radius.circular(2),
      ),
      paint,
    );

    // Vert
    paint.color = const Color(0xFF34A853);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height * 0.5, size.width * 0.5, size.height * 0.5),
        const Radius.circular(2),
      ),
      paint,
    );

    // Jaune
    paint.color = const Color(0xFFFBBC04);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.5, size.height * 0.5, size.width * 0.5, size.height * 0.5),
        const Radius.circular(2),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}