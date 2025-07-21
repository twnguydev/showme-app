// mobile/lib/features/profile/presentation/widgets/profile_text_field.dart
import 'package:flutter/material.dart';
import '../../../../core/design/showme_design_system.dart';

class ProfileTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final TextInputType keyboardType;
  final bool obscureText;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final bool enabled;
  final String? helperText;

  const ProfileTextField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.enabled = true,
    this.helperText,
  });

  @override
  State<ProfileTextField> createState() => _ProfileTextFieldState();
}

class _ProfileTextFieldState extends State<ProfileTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          validator: widget.validator,
          enabled: widget.enabled,
          onTap: () => setState(() => _isFocused = true),
          onTapOutside: (_) => setState(() => _isFocused = false),
          style: ShowmeDesign.bodyMedium.copyWith(
            color: widget.enabled 
              ? ShowmeDesign.neutral900 
              : ShowmeDesign.neutral500,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: ShowmeDesign.bodyMedium.copyWith(
              color: _isFocused 
                ? ShowmeDesign.primaryBlue 
                : ShowmeDesign.neutral500,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _isFocused 
                      ? ShowmeDesign.primaryBlue 
                      : ShowmeDesign.neutral500,
                    size: 20,
                  )
                : null,
            suffixIcon: widget.suffixIcon != null
                ? GestureDetector(
                    onTap: widget.onSuffixTap,
                    child: Icon(
                      widget.suffixIcon,
                      color: ShowmeDesign.neutral500,
                      size: 20,
                    ),
                  )
                : null,
            filled: true,
            fillColor: widget.enabled 
              ? Colors.white 
              : ShowmeDesign.neutral100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
              borderSide: const BorderSide(
                color: ShowmeDesign.neutral200,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
              borderSide: const BorderSide(
                color: ShowmeDesign.neutral200,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
              borderSide: const BorderSide(
                color: ShowmeDesign.primaryBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
              borderSide: const BorderSide(
                color: ShowmeDesign.primaryRose,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
              borderSide: const BorderSide(
                color: ShowmeDesign.primaryRose,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ShowmeDesign.spacingMd,
              vertical: widget.maxLines > 1 
                ? ShowmeDesign.spacingMd 
                : ShowmeDesign.spacingSm,
            ),
            counterStyle: ShowmeDesign.caption.copyWith(
              color: ShowmeDesign.neutral500,
            ),
          ),
        ),
        if (widget.helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.helperText!,
            style: ShowmeDesign.caption.copyWith(
              color: ShowmeDesign.neutral500,
            ),
          ),
        ],
      ],
    );
  }
}