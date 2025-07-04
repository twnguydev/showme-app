// mobile/lib/features/auth/presentation/widgets/auth_text_field.dart
import 'package:flutter/material.dart';
import '../../../../core/design/showme_design_system.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onChanged,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: AnimatedContainer(
        duration: ShowmeDesign.fastDuration,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
          boxShadow: _isFocused 
              ? [
                  BoxShadow(
                    color: ShowmeDesign.primaryPurple.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          validator: widget.validator,
          onChanged: widget.onChanged,
          style: ShowmeDesign.bodyMedium.copyWith(
            color: ShowmeDesign.neutral900,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hintText,
            labelStyle: ShowmeDesign.bodyMedium.copyWith(
              color: _isFocused 
                  ? ShowmeDesign.primaryPurple 
                  : ShowmeDesign.neutral500,
              fontWeight: FontWeight.w500,
            ),
            hintStyle: ShowmeDesign.bodyMedium.copyWith(
              color: ShowmeDesign.neutral400,
            ),
            prefixIcon: widget.prefixIcon != null 
                ? Icon(
                    widget.prefixIcon,
                    color: _isFocused 
                        ? ShowmeDesign.primaryPurple 
                        : ShowmeDesign.neutral500,
                    size: 20,
                  ) 
                : null,
            suffixIcon: widget.suffixIcon,
            filled: true,
            fillColor: ShowmeDesign.neutral50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
              borderSide: BorderSide(
                color: ShowmeDesign.neutral200,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
              borderSide: BorderSide(
                color: ShowmeDesign.neutral200,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
              borderSide: BorderSide(
                color: ShowmeDesign.primaryPurple,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
              borderSide: BorderSide(
                color: ShowmeDesign.primaryRose,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
              borderSide: BorderSide(
                color: ShowmeDesign.primaryRose,
                width: 2,
              ),
            ),
            errorStyle: ShowmeDesign.caption.copyWith(
              color: ShowmeDesign.primaryRose,
              fontWeight: FontWeight.w500,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ShowmeDesign.spacingMd,
              vertical: ShowmeDesign.spacingMd,
            ),
          ),
        ),
      ),
    );
  }
}