// mobile/lib/shared/presentation/widgets/stats_overview.dart
import 'package:flutter/material.dart';
import '../../../core/design/showme_design_system.dart';
import '../../models/contact_exchange.dart';
import '../../models/contact_stats.dart';

class StatsOverview extends StatelessWidget {
  final ContactStats stats;

  const StatsOverview({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final statItems = [
      {
        'label': 'Partages',
        'value': stats.weeklyExchanges.toString(),
        'icon': Icons.share_rounded,
        'color': ShowmeDesign.primaryBlue,
        'trend': '+12%',
      },
      {
        'label': 'Vues',
        'value': stats.totalViews.toString(),
        'icon': Icons.visibility_rounded,
        'color': ShowmeDesign.primaryTeal,
        'trend': '+8%',
      },
      {
        'label': 'Leads',
        'value': stats.uniqueContacts.toString(),
        'icon': Icons.person_add_rounded,
        'color': ShowmeDesign.primaryEmerald,
        'trend': '+24%',
      },
    ];

    return Row(
      children: statItems.map((item) {
        final index = statItems.indexOf(item);
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: index < statItems.length - 1 ? ShowmeDesign.spacingSm : 0,
            ),
            child: _buildStatCard(item),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> item) {
    return Container(
      padding: EdgeInsets.all(ShowmeDesign.spacingMd),
      decoration: BoxDecoration(
        color: ShowmeDesign.white,
        borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
        boxShadow: ShowmeDesign.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec icône et trend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ShowmeDesign.radiusSm),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: item['color'] as Color,
                  size: 18,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ShowmeDesign.spacingXs,
                  vertical: ShowmeDesign.spacingXs / 2,
                ),
                decoration: BoxDecoration(
                  color: ShowmeDesign.primaryEmerald.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ShowmeDesign.radiusXs),
                ),
                child: Text(
                  item['trend'],
                  style: ShowmeDesign.caption.copyWith(
                    color: ShowmeDesign.primaryEmerald,
                    fontWeight: FontWeight.w600,
                    fontSize: ShowmeDesign.text2xs,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: ShowmeDesign.spacingSm),
          
          // Valeur principale
          Text(
            item['value'],
            style: ShowmeDesign.h2.copyWith(
              color: ShowmeDesign.neutral900,
              fontWeight: FontWeight.w800,
            ),
          ),
          
          SizedBox(height: ShowmeDesign.spacingXs),
          
          // Label
          Text(
            item['label'],
            style: ShowmeDesign.bodySmall.copyWith(
              color: ShowmeDesign.neutral600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}