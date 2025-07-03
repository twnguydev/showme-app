// mobile/lib/shared/presentation/widgets/showme_loading.dart
import 'package:flutter/material.dart';
import '../../../core/design/showme_design_system.dart';

class ShowmeLoading extends StatefulWidget {
  final String? message;
  final double size;

  const ShowmeLoading({
    super.key,
    this.message,
    this.size = 40,
  });

  @override
  State<ShowmeLoading> createState() => _ShowmeLoadingState();
}

class _ShowmeLoadingState extends State<ShowmeLoading>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _scaleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([_rotationController, _scaleController]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationController.value * 2 * 3.14159,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    gradient: ShowmeDesign.primaryGradient,
                    borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
                  ),
                  child: Icon(
                    Icons.business_center_rounded,
                    color: Colors.white,
                    size: widget.size * 0.5,
                  ),
                ),
              ),
            );
          },
        ),
        
        if (widget.message != null) ...[
          SizedBox(height: ShowmeDesign.spacingMd),
          Text(
            widget.message!,
            style: ShowmeDesign.bodyMedium.copyWith(
              color: ShowmeDesign.neutral600,
            ),
          ),
        ],
      ],
    );
  }
}