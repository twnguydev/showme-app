// mobile/lib/shared/presentation/widgets/showme_button.dart
import 'package:flutter/material.dart';
import '../../../core/design/showme_design_system.dart';

enum ShowmeButtonStyle { primary, secondary, outline, ghost }
enum ShowmeButtonSize { small, medium, large }

class ShowmeButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ShowmeButtonStyle style;
  final ShowmeButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const ShowmeButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = ShowmeButtonStyle.primary,
    this.size = ShowmeButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  State<ShowmeButton> createState() => _ShowmeButtonState();
}

class _ShowmeButtonState extends State<ShowmeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: ShowmeDesign.fastDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildButton(),
          );
        },
      ),
    );
  }

  Widget _buildButton() {
    return Container(
      width: widget.isFullWidth ? double.infinity : null,
      height: _getHeight(),
      decoration: _getDecoration(),
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
          ),
        ),
        child: widget.isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: _getTextColor(),
                      size: _getIconSize(),
                    ),
                    SizedBox(width: ShowmeDesign.spacingSm),
                  ],
                  Text(
                    widget.text,
                    style: _getTextStyle(),
                  ),
                ],
              ),
      ),
    );
  }

  BoxDecoration _getDecoration() {
    switch (widget.style) {
      case ShowmeButtonStyle.primary:
        return BoxDecoration(
          gradient: ShowmeDesign.primaryGradient,
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
          boxShadow: ShowmeDesign.buttonShadow,
        );
      case ShowmeButtonStyle.secondary:
        return BoxDecoration(
          color: ShowmeDesign.neutral100,
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
        );
      case ShowmeButtonStyle.outline:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
          border: Border.all(
            color: ShowmeDesign.primaryPurple,
            width: 2,
          ),
        );
      case ShowmeButtonStyle.ghost:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
        );
    }
  }

  Color _getTextColor() {
    switch (widget.style) {
      case ShowmeButtonStyle.primary:
        return Colors.white;
      case ShowmeButtonStyle.secondary:
        return ShowmeDesign.neutral700;
      case ShowmeButtonStyle.outline:
        return ShowmeDesign.primaryPurple;
      case ShowmeButtonStyle.ghost:
        return ShowmeDesign.primaryPurple;
    }
  }

  TextStyle _getTextStyle() {
    final baseStyle = ShowmeDesign.button.copyWith(
      color: _getTextColor(),
      fontSize: _getFontSize(),
    );
    return baseStyle;
  }

  double _getHeight() {
    switch (widget.size) {
      case ShowmeButtonSize.small:
        return 36;
      case ShowmeButtonSize.medium:
        return 48;
      case ShowmeButtonSize.large:
        return 56;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case ShowmeButtonSize.small:
        return ShowmeDesign.textSm;
      case ShowmeButtonSize.medium:
        return ShowmeDesign.textBase;
      case ShowmeButtonSize.large:
        return ShowmeDesign.textLg;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ShowmeButtonSize.small:
        return 16;
      case ShowmeButtonSize.medium:
        return 18;
      case ShowmeButtonSize.large:
        return 20;
    }
  }
}