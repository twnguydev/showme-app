// mobile/lib/features/card/presentation/pages/card_creation_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: library_prefixes
import 'package:showme/shared/models/card_theme.dart' as CardTheme;

import '../../../../core/design/showme_design_system.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_state.dart';
import '../widgets/dynamic_card_preview.dart';
import '../widgets/card_theme_selector.dart';
import '../../bloc/card_bloc.dart';
import '../../bloc/card_event.dart';
import '../../bloc/card_state.dart';

class CardCreationPage extends StatefulWidget {
  const CardCreationPage({super.key});

  @override
  State<CardCreationPage> createState() => _CardCreationPageState();
}

class _CardCreationPageState extends State<CardCreationPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  late TabController _tabController;
  late AnimationController _previewAnimationController;
  late Animation<double> _previewAnimation;

  // Form controllers
  final _titleController = TextEditingController();
  final _positionController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  // final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _linkedinController = TextEditingController();

  // Card data
  CardTheme.CardTheme _selectedTheme = CardTheme.CardTheme.purple;
  bool _isPublic = true;
  bool _allowPayment = false;
  bool _nfcEnabled = true;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 3, vsync: this);
    
    _previewAnimationController = AnimationController(
      duration: ShowmeDesign.normalDuration,
      vsync: this,
    );
    
    _previewAnimation = CurvedAnimation(
      parent: _previewAnimationController,
      curve: ShowmeDesign.primaryCurve,
    );

    // Pré-remplir avec les données utilisateur existantes
    _prefillUserData();
    
    _previewAnimationController.forward();
  }

  void _prefillUserData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;
      
      setState(() {
        _titleController.text = '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
        // _emailController.text = user.email;
        _phoneController.text = user.profile?.phone ?? '';
        _companyController.text = user.profile?.company ?? '';
        _positionController.text = user.profile?.position ?? '';
        _websiteController.text = user.profile?.website ?? '';
        _linkedinController.text = user.profile?.linkedinUrl ?? '';
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _previewAnimationController.dispose();
    _scrollController.dispose();
    
    // Dispose controllers
    _titleController.dispose();
    _positionController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    // _emailController.dispose();
    _websiteController.dispose();
    _linkedinController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CardBloc, CardState>(
      listener: (context, state) {
        if (state is CardCreateSuccess) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Carte créée avec succès'),
              backgroundColor: ShowmeDesign.primaryTeal,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop();
        } else if (state is CardError) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: ShowmeDesign.primaryRose,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: ShowmeDesign.neutral50,
        appBar: AppBar(
          title: Text(
            'Créer une carte',
            style: ShowmeDesign.h4.copyWith(
              color: ShowmeDesign.neutral900,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: ShowmeDesign.neutral50,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: BlocBuilder<CardBloc, CardState>(
                builder: (context, state) {
                  final isLoading = state is CardCreateLoading || _isSubmitting;

                  return IconButton(
                    onPressed: isLoading ? null : _createCard,
                    icon: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isLoading
                            ? ShowmeDesign.neutral300
                            : ShowmeDesign.primaryTeal,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  ShowmeDesign.neutral600,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Aperçu de la carte
            _buildCardPreview(),
            
            const SizedBox(height: ShowmeDesign.spacingXs),
            
            // Tabs - prend le reste de l'espace
            Expanded(
              child: _buildTabSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPreview() {
    return Container(
      margin: const EdgeInsets.all(ShowmeDesign.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Aperçu dynamique
          FadeTransition(
            opacity: _previewAnimation,
            child: DynamicCardPreview(
              theme: _selectedTheme,
              title: _titleController.text.isEmpty ? 'Ma carte' : _titleController.text,
              position: _positionController.text,
              company: _companyController.text,
              // email: _emailController.text,
              phone: _phoneController.text,
              website: _websiteController.text
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      decoration: BoxDecoration(
        color: ShowmeDesign.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(ShowmeDesign.radiusXl),
          topRight: Radius.circular(ShowmeDesign.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: ShowmeDesign.neutral900.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tab Bar
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: ShowmeDesign.neutral200,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(Icons.palette),
                  text: 'Design',
                ),
                Tab(
                  icon: Icon(Icons.person),
                  text: 'Informations',
                ),
                Tab(
                  icon: Icon(Icons.settings),
                  text: 'Options',
                ),
              ],
              labelColor: ShowmeDesign.primaryPurple,
              unselectedLabelColor: ShowmeDesign.neutral600,
              indicatorColor: ShowmeDesign.primaryPurple,
              indicatorWeight: 3,
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDesignTab(),
                _buildInfoTab(),
                _buildOptionsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesignTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ShowmeDesign.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sélecteur de thème
          CardThemeSelector(
            selectedTheme: _selectedTheme,
            onThemeSelected: (theme) {
              setState(() {
                _selectedTheme = theme;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(ShowmeDesign.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations personnelles',
              style: ShowmeDesign.h5.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: ShowmeDesign.spacingLg),
            
            // Titre de la carte
            _buildTextField(
              controller: _titleController,
              label: 'Titre de la carte',
              hint: 'Ma carte professionnelle',
              icon: Icons.title,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Le titre est requis';
                }
                if (value!.length < 3) {
                  return 'Le titre doit contenir au moins 3 caractères';
                }
                return null;
              },
              onChanged: (value) => setState(() {}),
            ),

            const SizedBox(height: ShowmeDesign.spacingLg),

            // Email
            // _buildTextField(
            //   controller: _emailController,
            //   label: 'Email',
            //   hint: 'john.doe@example.com',
            //   icon: Icons.email,
            //   keyboardType: TextInputType.emailAddress,
            //   validator: (value) {
            //     if (value?.isEmpty ?? true) {
            //       return 'L\'email est requis';
            //     }
            //     if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
            //       return 'Email invalide';
            //     }
            //     return null;
            //   },
            //   onChanged: (value) => setState(() {}),
            // ),
            
            // const SizedBox(height: ShowmeDesign.spacingLg),
            
            Text(
              'Informations professionnelles',
              style: ShowmeDesign.h5.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: ShowmeDesign.spacingLg),
            
            // Poste
            _buildTextField(
              controller: _positionController,
              label: 'Poste/Fonction',
              hint: 'Développeur Full Stack',
              icon: Icons.work,
              onChanged: (value) => setState(() {}),
            ),
            
            const SizedBox(height: ShowmeDesign.spacingLg),
            
            // Entreprise
            _buildTextField(
              controller: _companyController,
              label: 'Entreprise',
              hint: 'Acme Corp',
              icon: Icons.business,
              onChanged: (value) => setState(() {}),
            ),
            
            const SizedBox(height: ShowmeDesign.spacingLg),
            
            Text(
              'Contact',
              style: ShowmeDesign.h5.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: ShowmeDesign.spacingLg),
            
            // Téléphone
            _buildTextField(
              controller: _phoneController,
              label: 'Téléphone',
              hint: '+33 6 12 34 56 78',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              onChanged: (value) => setState(() {}),
            ),
            
            const SizedBox(height: ShowmeDesign.spacingLg),
            
            // Site web
            _buildTextField(
              controller: _websiteController,
              label: 'Site web',
              hint: 'https://monsite.com',
              icon: Icons.language,
              keyboardType: TextInputType.url,
              onChanged: (value) => setState(() {}),
            ),
            
            const SizedBox(height: ShowmeDesign.spacingLg),
            
            // LinkedIn
            _buildTextField(
              controller: _linkedinController,
              label: 'LinkedIn',
              hint: 'https://linkedin.com/in/johndoe',
              icon: Icons.link,
              keyboardType: TextInputType.url,
              onChanged: (value) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ShowmeDesign.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paramètres de la carte',
            style: ShowmeDesign.h5.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: ShowmeDesign.spacingLg),
          
          // Visibilité publique
          _buildSwitchTile(
            title: 'Carte publique',
            subtitle: 'Votre carte sera visible sur votre profil public',
            icon: Icons.public,
            value: _isPublic,
            onChanged: (value) {
              setState(() {
                _isPublic = value;
              });
            },
          ),
          
          const Divider(height: ShowmeDesign.spacingXl),
          
          // Paiements
          _buildSwitchTile(
            title: 'Autoriser les paiements',
            subtitle: 'Les visiteurs pourront vous payer directement',
            icon: Icons.payment,
            value: _allowPayment,
            onChanged: (value) {
              setState(() {
                _allowPayment = value;
              });
            },
          ),
          
          const Divider(height: ShowmeDesign.spacingXl),
          
          // NFC
          _buildSwitchTile(
            title: 'Activer le NFC',
            subtitle: 'Partagez votre carte en approchant les téléphones',
            icon: Icons.nfc,
            value: _nfcEnabled,
            onChanged: (value) {
              setState(() {
                _nfcEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: ShowmeDesign.neutral100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
          borderSide: const BorderSide(
            color: ShowmeDesign.neutral300,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
          borderSide: const BorderSide(
            color: ShowmeDesign.primaryPurple,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
          borderSide: const BorderSide(
            color: ShowmeDesign.primaryRose,
            width: 2,
          ),
        ),
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: value ? ShowmeDesign.primaryPurple.withOpacity(0.1) : ShowmeDesign.neutral100,
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
        ),
        child: Icon(
          icon,
          color: value ? ShowmeDesign.primaryPurple : ShowmeDesign.neutral600,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: ShowmeDesign.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: ShowmeDesign.bodySmall.copyWith(
          color: ShowmeDesign.neutral600,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: ShowmeDesign.primaryPurple,
      ),
      onTap: () => onChanged(!value),
    );
  }

  void _createCard() {
    if (_isSubmitting) {
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      // Générer un slug unique basé sur le titre
      final slug = _generateSlug(_titleController.text);
      
      final cardData = {
        'slug': slug,
        'title': _titleController.text,
        'isPublic': _isPublic,
        'allowPayment': _allowPayment,
        'nfcEnabled': _nfcEnabled,
        'theme': _selectedTheme.name,
        // Données de contact directement dans la carte
        // 'email': _emailController.text,
        'phone': _phoneController.text.isEmpty ? null : _phoneController.text,
        'website': _websiteController.text.isEmpty ? null : _websiteController.text,
        'linkedinUrl': _linkedinController.text.isEmpty ? null : _linkedinController.text,
        'position': _positionController.text.isEmpty ? null : _positionController.text,
        'company': _companyController.text.isEmpty ? null : _companyController.text,
      };

      context.read<CardBloc>().add(CardCreateRequested(cardData));
    } else {
      // Passer au tab des infos si la validation échoue
      _tabController.animateTo(1);
    }
  }

  String _generateSlug(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();
  }
}