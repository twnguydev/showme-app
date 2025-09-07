// mobile/lib/shared/presentation/widgets/showme_sliver_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qard/shared/models/user.dart';
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
  final dynamic user; // Paramètre user ajouté

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
    this.user,
  });

  @override
  State<ShowmeSliverAppBar> createState() => _ShowmeSliverAppBarState();
}

class _ShowmeSliverAppBarState extends State<ShowmeSliverAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

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
      expandedHeight: null,
      floating: widget.floating,
      pinned: widget.pinned,
      backgroundColor: ShowmeDesign.neutral50,
      foregroundColor: ShowmeDesign.neutral900,
      elevation: 0,
      surfaceTintColor: ShowmeDesign.neutral50,
      shadowColor: Colors.transparent,
      leading: _buildLeading(context),
      title: _buildTitle(),
      centerTitle: false,
      titleSpacing: 20,
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

  Widget? _buildLeading(BuildContext context) {
    if (widget.leading != null) {
      return widget.leading;
    }

    if (widget.showWelcomeSection) {
      return null;
    }

    if (!widget.showBackButton) {
      return null;
    }

    return IconButton(
      icon: const Icon(
        Icons.arrow_back,
        size: 24,
        color: ShowmeDesign.neutral900,
      ),
      onPressed: widget.onBackPressed,
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
          const SizedBox(width: 10),
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

    // Pour les pages avec section de bienvenue, afficher le message personnalisé
    if (widget.showWelcomeSection) {
      // Utiliser le user passé en paramètre, sinon fallback sur AuthBloc
      if (widget.user != null) {
        return _buildWelcomeTitle(widget.user);
      } else {
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final user = state is AuthAuthenticated ? state.user : null;
            return _buildWelcomeTitle(user);
          },
        );
      }
    }

    return Text(
      widget.title,
      style: ShowmeDesign.h4.copyWith(
        color: ShowmeDesign.neutral900,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildWelcomeTitle(dynamic user) {
    final userName = _getUserName(user);
    final timeGreeting = _getTimeBasedGreeting();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              '$timeGreeting $userName',
              style: ShowmeDesign.h4.copyWith(
                color: ShowmeDesign.neutral900,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            Text(_getTimeBasedEmoji(), style: const TextStyle(fontSize: 18)),
          ],
        ),
        Text(
          _getMotivationalMessage(),
          style: ShowmeDesign.bodyMedium.copyWith(
            color: ShowmeDesign.neutral500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  List<Widget>? _buildActions() {
    List<Widget> actionsList = [];

    if (widget.showProfileIcon) {
      actionsList.add(
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: widget.onProfilePressed,
            child: _buildProfileAvatar(),
          ),
        ),
      );
    }

    if (widget.actions != null) {
      actionsList.addAll(widget.actions!);
    }

    return actionsList.isEmpty ? null : actionsList;
  }

  Widget _buildProfileAvatar() {
    // Utiliser le user passé en paramètre, sinon fallback sur AuthBloc
    if (widget.user != null) {
      return _buildAvatarFromUser(widget.user);
    } else {
      return BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state is AuthAuthenticated ? state.user : null;
          return _buildAvatarFromUser(user);
        },
      );
    }
  }

  Widget _buildAvatarFromUser(User? user) {
    return _buildDefaultAvatar(user);
  }

  Widget _buildDefaultAvatar(dynamic user) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: ShowmeDesign.primaryGradient,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ShowmeDesign.neutral200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _getUserInitials(user),
          style: ShowmeDesign.bodySmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // Méthodes utilitaires
  String _getUserName(dynamic user) {
    if (user.firstName != null && user.firstName!.isNotEmpty) {
      return user.firstName!;
    } else if (user?.email != null) {
      return user.email!.split('@').first;
    }
    return 'Utilisateur';
  }

  String _getUserInitials(dynamic user) {
    final firstName = user?.profile.firstName ?? '';
    final lastName = user?.profile.lastName ?? '';

    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    } else if (firstName.isNotEmpty) {
      return firstName.substring(0, firstName.length > 1 ? 2 : 1).toUpperCase();
    } else if (lastName.isNotEmpty) {
      return lastName.substring(0, lastName.length > 1 ? 2 : 1).toUpperCase();
    } else {
      final email = user?.email;
      if (email != null && email.isNotEmpty) {
        return email.substring(0, email.length > 1 ? 2 : 1).toUpperCase();
      }
      return 'US';
    }
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 6) {
      return 'Bonne nuit';
    } else if (hour < 12) {
      return 'Bonjour';
    } else if (hour < 17) {
      return 'Bon après-midi';
    } else if (hour < 22) {
      return 'Bonsoir';
    } else {
      return 'Bonne soirée';
    }
  }

  String _getTimeBasedEmoji() {
    final hour = DateTime.now().hour;

    if (hour < 6) {
      return '🌙';
    } else if (hour < 12) {
      return '👋🏻';
    } else if (hour < 17) {
      return '☀️';
    } else if (hour < 22) {
      return '🌅';
    } else {
      return '✨';
    }
  }

  String _getMotivationalMessage() {
    final messages = [
      'Prêt à networker ?',
      'Votre réseau vous attend !',
      'Partagez votre expertise !',
      'Créez des connexions !',
      'Développez votre réseau !',
      'Montrez votre talent !',
    ];

    final hour = DateTime.now().hour;
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final index = (hour + dayOfYear) % messages.length;

    return messages[index];
  }
}
