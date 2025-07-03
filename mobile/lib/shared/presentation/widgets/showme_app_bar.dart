// mobile/lib/shared/presentation/widgets/showme_sliver_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/design/showme_design_system.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_state.dart';

class ShowmeSliverAppBar extends StatefulWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool showWelcomeSection;
  final bool showProfileIcon;
  final VoidCallback? onProfilePressed;
  final bool showBrandedTitle;
  final bool pinned;
  final bool floating;

  const ShowmeSliverAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.showWelcomeSection = false,
    this.showProfileIcon = false,
    this.onProfilePressed,
    this.showBrandedTitle = false,
    this.pinned = true,
    this.floating = false,
  });

  @override
  State<ShowmeSliverAppBar> createState() => _ShowmeSliverAppBarState();
}

class _ShowmeSliverAppBarState extends State<ShowmeSliverAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _contentStaggerAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _contentStaggerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    if (widget.showWelcomeSection) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: null, // Pas de section étendue !
      floating: widget.floating,
      pinned: widget.pinned,
      backgroundColor: ShowmeDesign.neutral50,
      foregroundColor: ShowmeDesign.neutral900,
      elevation: 0,
      surfaceTintColor: ShowmeDesign.neutral50,
      shadowColor: Colors.transparent,
      leading: widget.leading ?? (widget.showBackButton && Navigator.canPop(context)
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                size: 20,
                color: ShowmeDesign.neutral700,
              ),
              onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
            )
          : null),
      title: _buildTitle(),
      centerTitle: false,
      titleSpacing: 20, // Toujours un espacement pour éviter le collage
      actions: _buildActions(),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(
          height: 0.5,
          color: ShowmeDesign.neutral200.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    if (widget.showBrandedTitle) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: ShowmeDesign.primaryGradient,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.business_center_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          SizedBox(width: 10),
          Text(
            widget.title,
            style: ShowmeDesign.h4.copyWith(
              color: ShowmeDesign.neutral900,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      );
    }
    
    // Pour les pages avec section de bienvenue, afficher le message dans la barre de titre
    if (widget.showWelcomeSection) {
      return BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final userName = state is AuthAuthenticated 
              ? state.user.firstName 
              : 'Utilisateur';
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Bonjour $userName',
                    style: ShowmeDesign.h4.copyWith(
                      color: ShowmeDesign.neutral900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    '👋🏻',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              Text(
                'Prêt à networker ?',
                style: ShowmeDesign.bodyMedium.copyWith(
                  color: ShowmeDesign.neutral500,
                  fontSize: 14,
                ),
              ),
            ],
          );
        },
      );
    }
    
    return Text(
      widget.title,
      style: ShowmeDesign.h4.copyWith(
        color: ShowmeDesign.neutral900,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  List<Widget>? _buildActions() {
    List<Widget> actionsList = [];
    
    if (widget.showProfileIcon) {
      actionsList.add(
        Container(
          margin: EdgeInsets.only(right: 16),
          child: IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: ShowmeDesign.neutral50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ShowmeDesign.neutral200,
                  width: 0.5,
                ),
              ),
              child: Icon(
                Icons.person_outline_rounded,
                size: 18,
                color: ShowmeDesign.neutral600,
              ),
            ),
            onPressed: widget.onProfilePressed,
          ),
        ),
      );
    }
    
    if (widget.actions != null) {
      actionsList.addAll(widget.actions!);
    }
    
    return actionsList.isEmpty ? null : actionsList;
  }

  Widget _buildExpandedWelcomeSection() {
    return AnimatedBuilder(
      animation: _contentStaggerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _contentStaggerAnimation.value) * 15),
          child: Opacity(
            opacity: _contentStaggerAnimation.value,
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final userName = state is AuthAuthenticated 
                    ? state.user.firstName 
                    : 'Utilisateur';
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Prêt à faire du networking ?',
                          style: ShowmeDesign.h3.copyWith(
                            color: ShowmeDesign.neutral900,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '👋',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Découvrez de nouveaux contacts et opportunités',
                      style: ShowmeDesign.bodyMedium.copyWith(
                        color: ShowmeDesign.neutral500,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}