// mobile/lib/features/auth/presentation/widgets/auth_button.dart
import 'package:flutter/material.dart';
import '../../../../core/design/showme_design_system.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? color;
  final Color? textColor;

  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: onPressed != null ? ShowmeDesign.primaryGradient : null,
        color: onPressed == null ? ShowmeDesign.neutral300 : null,
        borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
        boxShadow: onPressed != null ? ShowmeDesign.buttonShadow : null,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: textColor ?? Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? Colors.white,
                  ),
                ),
              )
            : Text(
                text,
                style: ShowmeDesign.button.copyWith(
                  color: textColor ?? Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}