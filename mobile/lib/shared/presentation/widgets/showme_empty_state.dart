// mobile/lib/shared/presentation/widgets/showme_empty_state.dart
import 'package:flutter/material.dart';
import '../../../core/design/showme_design_system.dart';
import 'showme_button.dart';

class ShowmeEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const ShowmeEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(ShowmeDesign.spacingXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: ShowmeDesign.neutral100,
              borderRadius: BorderRadius.circular(ShowmeDesign.radiusXl),
            ),
            child: Icon(
              icon,
              size: 40,
              color: ShowmeDesign.neutral400,
            ),
          ),
          
          SizedBox(height: ShowmeDesign.spacingLg),
          
          Text(
            title,
            style: ShowmeDesign.h3.copyWith(
              color: ShowmeDesign.neutral700,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: ShowmeDesign.spacingSm),
          
          Text(
            subtitle,
            style: ShowmeDesign.bodyMedium.copyWith(
              color: ShowmeDesign.neutral600,
            ),
            textAlign: TextAlign.center,
          ),
          
          if (actionText != null && onActionPressed != null) ...[
            SizedBox(height: ShowmeDesign.spacingXl),
            ShowmeButton(
              text: actionText!,
              onPressed: onActionPressed,
              style: ShowmeButtonStyle.primary,
            ),
          ],
        ],
      ),
    );
  }
}