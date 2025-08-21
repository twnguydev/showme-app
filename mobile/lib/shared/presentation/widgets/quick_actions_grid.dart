// mobile/lib/shared/presentation/widgets/quick_actions_grid.dart
import 'package:flutter/material.dart';
import '../../../core/design/showme_design_system.dart';
import '../../../shared/models/card.dart' as CardModel;

class QuickActionsGrid extends StatelessWidget {
  final Function(String) onActionTap;
  final CardModel.Card? currentCard;

  const QuickActionsGrid({
    super.key,
    required this.onActionTap,
    this.currentCard,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'id': 'share_nfc',
        'icon': Icons.nfc_rounded,
        'title': 'NFC',
        'subtitle': currentCard != null ? 'Partager "${currentCard!.title}"' : 'Partage tactile',
        'color': ShowmeDesign.primaryBlue,
        'isPro': false,
        'enabled': currentCard != null,
      },
      {
        'id': 'share_qr',
        'icon': Icons.qr_code_rounded,
        'title': 'QR Code',
        'subtitle': currentCard != null ? 'QR de "${currentCard!.title}"' : 'Scan rapide',
        'color': ShowmeDesign.primaryTeal,
        'isPro': false,
        'enabled': currentCard != null,
      },
      {
        'id': 'view_contacts',
        'icon': Icons.people_rounded,
        'title': 'Contacts',
        'subtitle': 'Mini CRM',
        'color': ShowmeDesign.primaryEmerald,
        'isPro': false,
        'enabled': true,
      },
      {
        'id': 'kiosk_mode',
        'icon': Icons.fullscreen_rounded,
        'title': 'Kiosque',
        'subtitle': currentCard != null ? 'Mode événement' : 'Créez une carte d\'abord',
        'color': ShowmeDesign.primaryAmber,
        'isPro': true,
        'enabled': currentCard != null,
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
    final isEnabled = action['enabled'] as bool;
    
    return GestureDetector(
      onTap: isEnabled ? () => onActionTap(action['id']) : null,
      child: Container(
        decoration: BoxDecoration(
          color: isEnabled ? ShowmeDesign.white : ShowmeDesign.neutral50,
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusLg),
          boxShadow: isEnabled ? ShowmeDesign.cardShadow : [],
          border: !isEnabled ? Border.all(
            color: ShowmeDesign.neutral200,
            width: 1,
          ) : null,
        ),
        child: Stack(
          children: [
            // Contenu principal
            Padding(
              padding: const EdgeInsets.all(ShowmeDesign.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icône
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isEnabled 
                          ? (action['color'] as Color).withOpacity(0.1)
                          : ShowmeDesign.neutral200,
                      borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
                    ),
                    child: Icon(
                      action['icon'] as IconData,
                      color: isEnabled 
                          ? action['color'] as Color
                          : ShowmeDesign.neutral400,
                      size: 24,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Texte
                  Text(
                    action['title'],
                    style: ShowmeDesign.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isEnabled 
                          ? ShowmeDesign.neutral900
                          : ShowmeDesign.neutral500,
                    ),
                  ),
                  
                  const SizedBox(height: ShowmeDesign.spacingXs),
                  
                  Text(
                    action['subtitle'],
                    style: ShowmeDesign.bodySmall.copyWith(
                      color: isEnabled 
                          ? ShowmeDesign.neutral600
                          : ShowmeDesign.neutral400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: ShowmeDesign.spacingXs,
                    vertical: ShowmeDesign.spacingXs / 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: isEnabled 
                        ? ShowmeDesign.warmGradient
                        : LinearGradient(
                            colors: [ShowmeDesign.neutral300, ShowmeDesign.neutral300],
                          ),
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
            
            // Overlay disabled si non activé
            if (!isEnabled)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(ShowmeDesign.radiusLg),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}