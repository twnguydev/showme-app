// mobile/lib/features/auth/presentation/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/showme_design_system.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late AnimationController _formController;
  late Animation<double> _formOpacityAnimation;
  late Animation<Offset> _formSlideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _formController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _formOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));
  }

  void _startAnimations() {
    _formController.forward();
  }

  @override
  void dispose() {
    _formController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _companyController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthRegisterRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          company: _companyController.text.trim().isEmpty 
              ? null 
              : _companyController.text.trim(),
          position: _positionController.text.trim().isEmpty 
              ? null 
              : _positionController.text.trim(),
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
                ShowmeDesign.primaryTeal.withOpacity(0.05),
                ShowmeDesign.primaryEmerald.withOpacity(0.05),
                ShowmeDesign.white,
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(ShowmeDesign.spacingXl),
                child: Column(
                  children: [
                    SizedBox(height: ShowmeDesign.spacingXl),
                    
                    // Header compact
                    _buildHeader(),
                    
                    SizedBox(height: ShowmeDesign.spacingXl),
                    
                    // Formulaire animé
                    _buildAnimatedForm(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: ShowmeDesign.successGradient,
            borderRadius: BorderRadius.circular(ShowmeDesign.radiusXl),
            boxShadow: ShowmeDesign.cardShadow,
          ),
          child: const Icon(
            Icons.person_add_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: ShowmeDesign.spacingLg),
        
        Text(
          'Rejoignez Showme',
          style: ShowmeDesign.h2.copyWith(
            color: ShowmeDesign.neutral900,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: ShowmeDesign.spacingSm),
        
        Text(
          'Créez votre identité professionnelle digitale',
          style: ShowmeDesign.bodyLarge.copyWith(
            color: ShowmeDesign.neutral600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
              padding: EdgeInsets.all(ShowmeDesign.spacingXs),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Champs nom et prénom
                    AuthTextField(
                        controller: _firstNameController,
                        label: 'Prénom',
                        prefixIcon: Icons.person_outlined,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Requis';
                          }
                          return null;
                        },
                    ),

                    SizedBox(height: ShowmeDesign.spacingMd),

                    AuthTextField(
                            controller: _lastNameController,
                            label: 'Nom',
                            prefixIcon: Icons.person_outlined,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Requis';
                              }
                              return null;
                            },
                          ),
                    
                    SizedBox(height: ShowmeDesign.spacingMd),
                    
                    AuthTextField(
                      controller: _emailController,
                      label: 'Email professionnel',
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
                    
                    // Champs optionnels avec style différent
                    Container(
                      padding: EdgeInsets.all(ShowmeDesign.spacingMd),
                      decoration: BoxDecoration(
                        color: ShowmeDesign.neutral50,
                        borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
                        border: Border.all(
                          color: ShowmeDesign.neutral200,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informations professionnelles',
                            style: ShowmeDesign.bodySmall.copyWith(
                              color: ShowmeDesign.neutral600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: ShowmeDesign.spacingSm),
                          AuthTextField(
                            controller: _companyController,
                            label: 'Entreprise (optionnel)',
                            prefixIcon: Icons.business_outlined,
                          ),
                          SizedBox(height: ShowmeDesign.spacingMd),
                          AuthTextField(
                            controller: _positionController,
                            label: 'Poste (optionnel)',
                            prefixIcon: Icons.work_outlined,
                          ),
                        ],
                      ),
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
                          return 'Veuillez saisir un mot de passe';
                        }
                        if (value.length < 6) {
                          return 'Le mot de passe doit contenir au moins 6 caractères';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: ShowmeDesign.spacingMd),
                    
                    AuthTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirmer le mot de passe',
                      obscureText: _obscureConfirmPassword,
                      prefixIcon: Icons.lock_outlined,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          color: ShowmeDesign.neutral500,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez confirmer votre mot de passe';
                        }
                        if (value != _passwordController.text) {
                          return 'Les mots de passe ne correspondent pas';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: ShowmeDesign.spacingXl),
                    
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return AuthButton(
                          text: 'Créer mon compte',
                          onPressed: state is AuthLoading ? null : _handleRegister,
                          isLoading: state is AuthLoading,
                        );
                      },
                    ),
                    
                    SizedBox(height: ShowmeDesign.spacingLg),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Déjà un compte ? ',
                          style: ShowmeDesign.bodyMedium.copyWith(
                            color: ShowmeDesign.neutral600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text(
                            'Se connecter',
                            style: ShowmeDesign.bodyMedium.copyWith(
                              color: ShowmeDesign.primaryTeal,
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