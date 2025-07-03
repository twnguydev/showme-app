// mobile/lib/shared/presentation/widgets/quick_actions_grid.dart
import 'package:flutter/material.dart';
import '../../../core/design/showme_design_system.dart';

class QuickActionsGrid extends StatelessWidget {
  final Function(String) onActionTap;

  const QuickActionsGrid({
    super.key,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'id': 'share_nfc',
        'icon': Icons.nfc_rounded,
        'title': 'NFC',
        'subtitle': 'Partage tactile',
        'color': ShowmeDesign.primaryBlue,
        'isPro': false,
      },
      {
        'id': 'share_qr',
        'icon': Icons.qr_code_rounded,
        'title': 'QR Code',
        'subtitle': 'Scan rapide',
        'color': ShowmeDesign.primaryTeal,
        'isPro': false,
      },
      {
        'id': 'view_contacts',
        'icon': Icons.people_rounded,
        'title': 'Contacts',
        'subtitle': 'Mini CRM',
        'color': ShowmeDesign.primaryEmerald,
        'isPro': false,
      },
      {
        'id': 'kiosk_mode',
        'icon': Icons.fullscreen_rounded,
        'title': 'Kiosque',
        'subtitle': 'Mode événement',
        'color': ShowmeDesign.primaryAmber,
        'isPro': true,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildActionCard(action);
      },
    );
  }

  Widget _buildActionCard(Map<String, dynamic> action) {
    return GestureDetector(
      onTap: () => onActionTap(action['id']),
      child: Container(
        decoration: BoxDecoration(
          color: ShowmeDesign.white,
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusLg),
          boxShadow: ShowmeDesign.cardShadow,
        ),
        child: Stack(
          children: [
            // Contenu principal
            Padding(
              padding: EdgeInsets.all(ShowmeDesign.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icône
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (action['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
                    ),
                    child: Icon(
                      action['icon'] as IconData,
                      color: action['color'] as Color,
                      size: 24,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Texte
                  Text(
                    action['title'],
                    style: ShowmeDesign.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ShowmeDesign.neutral900,
                    ),
                  ),
                  
                  SizedBox(height: ShowmeDesign.spacingXs),
                  
                  Text(
                    action['subtitle'],
                    style: ShowmeDesign.bodySmall.copyWith(
                      color: ShowmeDesign.neutral600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Badge Pro si nécessaire
            if (action['isPro'] == true)
              Positioned(
                top: ShowmeDesign.spacingSm,
                right: ShowmeDesign.spacingSm,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ShowmeDesign.spacingXs,
                    vertical: ShowmeDesign.spacingXs / 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: ShowmeDesign.warmGradient,
                    borderRadius: BorderRadius.circular(ShowmeDesign.radiusXs),
                  ),
                  child: Text(
                    'PRO',
                    style: ShowmeDesign.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: ShowmeDesign.text2xs,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}