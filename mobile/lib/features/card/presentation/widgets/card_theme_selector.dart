// mobile/lib/features/card/presentation/widgets/card_theme_selector.dart
import 'package:flutter/material.dart';

import '../../../../core/design/showme_design_system.dart';
import '../../../../shared/models/card_theme.dart' as CardTheme;

class CardThemeSelector extends StatefulWidget {
  final CardTheme.CardTheme selectedTheme;
  final Function(CardTheme.CardTheme) onThemeSelected;

  const CardThemeSelector({
    super.key,
    required this.selectedTheme,
    required this.onThemeSelected,
  });

  @override
  State<CardThemeSelector> createState() => _CardThemeSelectorState();
}

class _CardThemeSelectorState extends State<CardThemeSelector>
    with TickerProviderStateMixin {
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
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: ShowmeDesign.primaryCurve,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _scaleAnimation,
      child: Column(
        children: [
          // Grille de thèmes
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: ShowmeDesign.spacingMd,
              mainAxisSpacing: ShowmeDesign.spacingMd,
              childAspectRatio: 2.2,
            ),
            itemCount: CardTheme.CardTheme.values.length,
            itemBuilder: (context, index) {
              final theme = CardTheme.CardTheme.values[index];
              final isSelected = theme == widget.selectedTheme;
              
              return _buildThemeOption(theme, isSelected);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(CardTheme.CardTheme theme, bool isSelected) {
    return GestureDetector(
      onTap: () {
        widget.onThemeSelected(theme);
        _animateSelection();
      },
      child: AnimatedContainer(
        duration: ShowmeDesign.normalDuration,
        curve: ShowmeDesign.primaryCurve,
        decoration: BoxDecoration(
          gradient: CardTheme.CardThemeHelper.getGradient(theme),
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
          border: Border.all(
            color: isSelected 
                ? Colors.white 
                : Colors.white.withOpacity(0.2),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: CardTheme.CardThemeHelper.getPrimaryColor(theme).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  ...CardTheme.CardThemeHelper.getShadows(theme),
                ]
              : [
                  BoxShadow(
                    color: ShowmeDesign.neutral900.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            // Background effects
            _buildThemeBackground(theme),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(ShowmeDesign.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Theme name
                  Row(
                    children: [
                      Text(
                        _getThemeName(theme),
                        style: ShowmeDesign.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.check,
                            color: CardTheme.CardThemeHelper.getPrimaryColor(theme),
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Sample elements
                  Row(
                    children: [
                      // Mini avatar
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: ShowmeDesign.spacingSm),
                      
                      // Sample text lines
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 60,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            width: 40,
                            height: 2,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Theme accent
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeBackground(CardTheme.CardTheme theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
      child: Stack(
        children: [
          // Motifs subtils
          Positioned.fill(
            child: CustomPaint(
              painter: ThemePatternPainter(
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          
          // Cercle décoratif
          Positioned(
            top: -15,
            right: -15,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _animateSelection() {
    _animationController.reset();
    _animationController.forward();
  }

  String _getThemeName(CardTheme.CardTheme theme) {
    switch (theme) {
      case CardTheme.CardTheme.purple:
        return 'Purple';
      case CardTheme.CardTheme.blue:
        return 'Ocean';
      case CardTheme.CardTheme.teal:
        return 'Teal';
      case CardTheme.CardTheme.green:
        return 'Forest';
      case CardTheme.CardTheme.amber:
        return 'Sunset';
      case CardTheme.CardTheme.orange:
        return 'Fire';
      case CardTheme.CardTheme.red:
        return 'Ruby';
      case CardTheme.CardTheme.pink:
        return 'Rose';
      case CardTheme.CardTheme.indigo:
        return 'Indigo';
      // case CardTheme.CardTheme.cyan:
      //   return 'Sky';
      // case CardTheme.CardTheme.lime:
      //   return 'Lime';
      // case CardTheme.CardTheme.deepPurple:
      //   return 'Royal';
      // case CardTheme.CardTheme.lightBlue:
      //   return 'Aqua';
      // case CardTheme.CardTheme.lightGreen:
      //   return 'Spring';
      // case CardTheme.CardTheme.deepOrange:
      //   return 'Copper';
      // case CardTheme.blueGrey:
      //   return 'Steel';
      // case CardTheme.brown:
      //   return 'Earth';
      // case CardTheme.grey:
      //   return 'Minimal';
      // case CardTheme.black:
      //   return 'Dark';
      // case CardTheme.gradient1:
      //   return 'Galaxy';
      // case CardTheme.gradient2:
      //   return 'Aurora';
      // case CardTheme.gradient3:
      //   return 'Cosmic';
      default:
        return theme.name.toUpperCase();
    }
  }
}

// Painter pour les motifs de thème
class ThemePatternPainter extends CustomPainter {
  final Color color;

  ThemePatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Lignes géométriques subtiles
    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.lineTo(size.width * 0.7, size.height * 0.3);
    path.lineTo(size.width, size.height * 0.1);
    canvas.drawPath(path, paint);

    // Points décoratifs
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.7),
      2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Extension pour obtenir facilement le nom d'affichage
extension CardThemeDisplayName on CardTheme.CardTheme {
  String get displayName {
    switch (this) {
      case CardTheme.CardTheme.purple:
        return 'Purple';
      case CardTheme.CardTheme.blue:
        return 'Ocean';
      case CardTheme.CardTheme.teal:
        return 'Teal';
      case CardTheme.CardTheme.green:
        return 'Forest';
      case CardTheme.CardTheme.amber:
        return 'Sunset';
      case CardTheme.CardTheme.orange:
        return 'Fire';
      case CardTheme.CardTheme.red:
        return 'Ruby';
      case CardTheme.CardTheme.pink:
        return 'Rose';
      case CardTheme.CardTheme.indigo:
        return 'Indigo';
      // case CardTheme.CardTheme.cyan:
      //   return 'Sky';
      // case CardTheme.lime:
      //   return 'Lime';
      // case CardTheme.deepPurple:
      //   return 'Royal';
      // case CardTheme.lightBlue:
      //   return 'Aqua';
      // case CardTheme.lightGreen:
      //   return 'Spring';
      // case CardTheme.deepOrange:
      //   return 'Copper';
      // case CardTheme.blueGrey:
      //   return 'Steel';
      // case CardTheme.brown:
      //   return 'Earth';
      // case CardTheme.grey:
      //   return 'Minimal';
      // case CardTheme.black:
      //   return 'Dark';
      // case CardTheme.gradient1:
      //   return 'Galaxy';
      // case CardTheme.gradient2:
      //   return 'Aurora';
      // case CardTheme.gradient3:
      //   return 'Cosmic';
      default:
        return name.toUpperCase();
    }
  }
}