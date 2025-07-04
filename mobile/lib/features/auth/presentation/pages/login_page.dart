// mobile/lib/features/auth/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/showme_design_system.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _logoController;
  late AnimationController _formController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _formOpacityAnimation;
  late Animation<Offset> _formSlideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    // Animation du logo
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Animation du formulaire
    _formController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Animations du logo
    _logoScaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    // Animations du formulaire
    _formOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));
  }

  void _startAnimations() {
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 800), () {
      _formController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _formController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: ShowmeDesign.primaryRose,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
                ),
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ShowmeDesign.primaryPurple.withOpacity(0.05),
                ShowmeDesign.primaryBlue.withOpacity(0.05),
                ShowmeDesign.white,
              ],
            ),
          ),
          child: Padding(
                padding: EdgeInsets.all(ShowmeDesign.spacingXl),
                child: Column(
                  children: [
                    SizedBox(height: ShowmeDesign.spacing3xl),
                    
                    // Logo animé
                    _buildAnimatedLogo(),
                    
                    SizedBox(height: ShowmeDesign.spacing3xl),
                    
                    // Formulaire animé
                    _buildAnimatedForm(),
                  ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return SlideTransition(
          position: _logoSlideAnimation,
          child: FadeTransition(
            opacity: _logoOpacityAnimation,
            child: ScaleTransition(
              scale: _logoScaleAnimation,
              child: Column(
                children: [
                  // Icône avec gradient
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: ShowmeDesign.primaryGradient,
                      borderRadius: BorderRadius.circular(ShowmeDesign.radius2xl),
                      boxShadow: ShowmeDesign.premiumShadow,
                    ),
                    child: const Icon(
                      Icons.business_center_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  
                  SizedBox(height: ShowmeDesign.spacingXl),
                  
                  // Nom de l'app avec effet
                  Text(
                      'Showme',
                      style: ShowmeDesign.h1.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2,
                      ),
                  ),
                  
                  SizedBox(height: ShowmeDesign.spacingSm),
                  
                  Text(
                    'Votre identité professionnelle digitale',
                    style: ShowmeDesign.bodyLarge.copyWith(
                      color: ShowmeDesign.neutral600,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedForm() {
    return AnimatedBuilder(
      animation: _formController,
      builder: (context, child) {
        return SlideTransition(
          position: _formSlideAnimation,
          child: FadeTransition(
            opacity: _formOpacityAnimation,
            child: Container(
              padding: EdgeInsets.all(0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: ShowmeDesign.spacingXl),
                    
                    AuthTextField(
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez saisir votre email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Email invalide';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: ShowmeDesign.spacingMd),
                    
                    AuthTextField(
                      controller: _passwordController,
                      label: 'Mot de passe',
                      obscureText: _obscurePassword,
                      prefixIcon: Icons.lock_outlined,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: ShowmeDesign.neutral500,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez saisir votre mot de passe';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: ShowmeDesign.spacingXl),
                    
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return AuthButton(
                          text: 'Se connecter',
                          onPressed: state is AuthLoading ? null : _handleLogin,
                          isLoading: state is AuthLoading,
                        );
                      },
                    ),
                    
                    SizedBox(height: ShowmeDesign.spacingLg),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pas encore de compte ? ',
                          style: ShowmeDesign.bodyMedium.copyWith(
                            color: ShowmeDesign.neutral600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/register'),
                          child: Text(
                            'S\'inscrire',
                            style: ShowmeDesign.bodyMedium.copyWith(
                              color: ShowmeDesign.primaryPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}