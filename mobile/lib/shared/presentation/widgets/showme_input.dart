// mobile/lib/shared/presentation/widgets/showme_input.dart
import 'package:flutter/material.dart';
import '../../../core/design/showme_design_system.dart';

class ShowmeInput extends StatefulWidget {
  final String label;
  final String? hint;
  final String? value;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLines;
  final bool enabled;

  const ShowmeInput({
    super.key,
    required this.label,
    this.hint,
    this.value,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  State<ShowmeInput> createState() => _ShowmeInputState();
}

class _ShowmeInputState extends State<ShowmeInput>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<Color?> _borderColorAnimation;

  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    
    _animationController = AnimationController(
      duration: ShowmeDesign.normalDuration,
      vsync: this,
    );

    _borderColorAnimation = ColorTween(
      begin: ShowmeDesign.neutral300,
      end: ShowmeDesign.primaryPurple,
    ).animate(_animationController);

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        AnimatedContainer(
          duration: ShowmeDesign.fastDuration,
          margin: EdgeInsets.only(
            bottom: ShowmeDesign.spacingSm,
            left: ShowmeDesign.spacingXs,
          ),
          child: Text(
            widget.label,
            style: ShowmeDesign.bodyMedium.copyWith(
              color: _isFocused 
                  ? ShowmeDesign.primaryPurple 
                  : ShowmeDesign.neutral700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Input field
        AnimatedBuilder(
          animation: _borderColorAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                color: widget.enabled ? ShowmeDesign.white : ShowmeDesign.neutral50,
                borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
                border: Border.all(
                  color: _borderColorAnimation.value ?? ShowmeDesign.neutral300,
                  width: _isFocused ? 2 : 1,
                ),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: ShowmeDesign.primaryPurple.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: TextFormField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: widget.onChanged,
                validator: widget.validator,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                maxLines: widget.maxLines,
                enabled: widget.enabled,
                style: ShowmeDesign.bodyMedium.copyWith(
                  color: ShowmeDesign.neutral900,
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: ShowmeDesign.bodyMedium.copyWith(
                    color: ShowmeDesign.neutral500,
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: _isFocused 
                              ? ShowmeDesign.primaryPurple 
                              : ShowmeDesign.neutral500,
                        )
                      : null,
                  suffixIcon: widget.suffixIcon,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(ShowmeDesign.spacingMd),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}