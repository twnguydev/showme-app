// mobile/lib/shared/presentation/widgets/premium_action_card.dart
import 'package:flutter/material.dart';
import '../../../core/design/showme_design_system.dart';

class PremiumActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLocked;

  const PremiumActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ShowmeDesign.spacingLg),
        decoration: BoxDecoration(
          gradient: isLocked 
              ? LinearGradient(
                  colors: [
                    ShowmeDesign.neutral200,
                    ShowmeDesign.neutral100,
                  ],
                )
              : ShowmeDesign.primaryGradient,
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusLg),
          boxShadow: isLocked ? [] : ShowmeDesign.premiumShadow,
        ),
        child: Row(
          children: [
            // Icône
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(isLocked ? 0.5 : 0.2),
                borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
              ),
              child: Icon(
                isLocked ? Icons.lock_rounded : icon,
                color: isLocked ? ShowmeDesign.neutral500 : Colors.white,
                size: 24,
              ),
            ),
            
            SizedBox(width: ShowmeDesign.spacingMd),
            
            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ShowmeDesign.bodyLarge.copyWith(
                      color: isLocked ? ShowmeDesign.neutral600 : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: ShowmeDesign.spacingXs),
                  Text(
                    subtitle,
                    style: ShowmeDesign.bodySmall.copyWith(
                      color: isLocked 
                          ? ShowmeDesign.neutral500 
                          : Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            // Badge Pro ou flèche
            if (isLocked)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ShowmeDesign.spacingSm,
                  vertical: ShowmeDesign.spacingXs,
                ),
                decoration: BoxDecoration(
                  gradient: ShowmeDesign.warmGradient,
                  borderRadius: BorderRadius.circular(ShowmeDesign.radiusSm),
                ),
                child: Text(
                  'PRO',
                  style: ShowmeDesign.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}