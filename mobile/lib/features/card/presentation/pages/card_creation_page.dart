// mobile/lib/features/card/presentation/pages/card_creation_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showme/shared/models/card.dart' as CardModel;
import 'package:showme/shared/models/card_theme.dart' as CardTheme;
import 'package:showme/shared/models/profile.dart';
import 'package:showme/shared/models/user.dart';

import '../../../../core/design/showme_design_system.dart';
import 'package:showme/shared/presentation/widgets/showme_app_bar.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_state.dart';
import '../widgets/dynamic_card_preview.dart';
import '../widgets/card_theme_selector.dart';
import '../../bloc/card_bloc.dart';

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
  final _bioController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _positionController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _linkedinController = TextEditingController();

  // Card data
  CardTheme.CardTheme _selectedTheme = CardTheme.CardTheme.purple;
  bool _isPublic = true;
  bool _allowPayment = false;
  bool _nfcEnabled = true;

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
        _firstNameController.text = user.firstName ?? '';
        _lastNameController.text = user.lastName ?? '';
        _emailController.text = user.email;
        _phoneController.text = user.profile?.phone ?? '';
        _companyController.text = user.profile?.company ?? '';
        _positionController.text = user.profile?.position ?? '';
        _websiteController.text = user.profile?.website ?? '';
        _linkedinController.text = user.profile?.linkedinUrl ?? '';
        
        // Générer un titre par défaut
        final fullName = '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
        if (fullName.isNotEmpty) {
          _titleController.text = 'Carte de $fullName';
        }
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
    _bioController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _positionController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _linkedinController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CardBloc, CardState>(
      listener: (context, state) {
        if (state is CardOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: ShowmeDesign.primaryTeal,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop();
        } else if (state is CardError) {
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
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // AppBar avec actions
            ShowmeSliverAppBar(
              title: 'Créer une carte',
              showBackButton: true,
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: BlocBuilder<CardBloc, CardState>(
                    builder: (context, state) {
                      final isLoading = state is CardLoading;

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
                              ? SizedBox(
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

            // Contenu principal
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Aperçu de la carte
                  _buildCardPreview(),
                  
                  const SizedBox(height: ShowmeDesign.spacingLg),
                  
                  // Tabs pour l'édition
                  _buildTabSection(),
                ],
              ),
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
          Row(
            children: [
              Text(
                'Aperçu de votre carte',
                style: ShowmeDesign.h4.copyWith(
                  color: ShowmeDesign.neutral900,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Badge du thème sélectionné
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ShowmeDesign.spacingSm,
                  vertical: ShowmeDesign.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: ShowmeDesign.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ShowmeDesign.radiusSm),
                  border: Border.all(
                    color: ShowmeDesign.primaryPurple.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  _selectedTheme.displayName,
                  style: ShowmeDesign.caption.copyWith(
                    color: ShowmeDesign.primaryPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: ShowmeDesign.spacingMd),
          
          // Aperçu dynamique
          FadeTransition(
            opacity: _previewAnimation,
            child: DynamicCardPreview(
              theme: _selectedTheme,
              title: _titleController.text.isEmpty ? 'Ma carte' : _titleController.text,
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
              position: _positionController.text,
              company: _companyController.text,
              email: _emailController.text,
              phone: _phoneController.text,
              website: _websiteController.text,
              bio: _bioController.text,
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
            decoration: BoxDecoration(
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
                  text: 'Infos',
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
          SizedBox(
            height: 600,
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
          Text(
            'Choisissez un thème',
            style: ShowmeDesign.h5.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: ShowmeDesign.spacingMd),
          
          Text(
            'Le thème détermine les couleurs et le style de votre carte',
            style: ShowmeDesign.bodyMedium.copyWith(
              color: ShowmeDesign.neutral600,
            ),
          ),
          
          const SizedBox(height: ShowmeDesign.spacingLg),
          
          // Sélecteur de thème
          CardThemeSelector(
            selectedTheme: _selectedTheme,
            onThemeSelected: (theme) {
              setState(() {
                _selectedTheme = theme;
              });
            },
          ),
          
          const SizedBox(height: ShowmeDesign.spacingXl),
          
          // Titre de la carte
          _buildTextField(
            controller: _titleController,
            label: 'Titre de la carte',
            hint: 'Ex: Ma carte professionnelle',
            icon: Icons.title,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Le titre est requis';
              }
              return null;
            },
            onChanged: (value) => setState(() {}),
          ),
          
          const SizedBox(height: ShowmeDesign.spacingLg),
          
          // Bio/Description
          _buildTextField(
            controller: _bioController,
            label: 'Description (optionnelle)',
            hint: 'Décrivez-vous en quelques mots...',
            icon: Icons.description,
            maxLines: 3,
            onChanged: (value) => setState(() {}),
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
            
            // Prénom et Nom
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _firstNameController,
                    label: 'Prénom',
                    hint: 'John',
                    icon: Icons.person,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Requis';
                      }
                      return null;
                    },
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(width: ShowmeDesign.spacingMd),
                Expanded(
                  child: _buildTextField(
                    controller: _lastNameController,
                    label: 'Nom',
                    hint: 'Doe',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Requis';
                      }
                      return null;
                    },
                    onChanged: (value) => setState(() {}),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: ShowmeDesign.spacingLg),
            
            // Email
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'john.doe@example.com',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'L\'email est requis';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                  return 'Email invalide';
                }
                return null;
              },
              onChanged: (value) => setState(() {}),
            ),
            
            const SizedBox(height: ShowmeDesign.spacingLg),
            
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
          
          const SizedBox(height: ShowmeDesign.spacingXl),
          
          // Preview des paramètres activés
          Container(
            padding: const EdgeInsets.all(ShowmeDesign.spacingMd),
            decoration: BoxDecoration(
              color: ShowmeDesign.neutral100,
              borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
              border: Border.all(
                color: ShowmeDesign.neutral200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.preview,
                      color: ShowmeDesign.neutral600,
                      size: 16,
                    ),
                    const SizedBox(width: ShowmeDesign.spacingSm),
                    Text(
                      'Fonctionnalités activées',
                      style: ShowmeDesign.bodySmall.copyWith(
                        color: ShowmeDesign.neutral700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ShowmeDesign.spacingSm),
                Wrap(
                  spacing: ShowmeDesign.spacingSm,
                  runSpacing: ShowmeDesign.spacingSm,
                  children: [
                    if (_isPublic) _buildFeatureChip('Public', Icons.public, ShowmeDesign.primaryTeal),
                    if (_allowPayment) _buildFeatureChip('Paiements', Icons.payment, ShowmeDesign.primaryAmber),
                    if (_nfcEnabled) _buildFeatureChip('NFC', Icons.nfc, ShowmeDesign.primaryBlue),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ShowmeDesign.spacingSm,
        vertical: ShowmeDesign.spacingXs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ShowmeDesign.radiusSm),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 12,
          ),
          const SizedBox(width: ShowmeDesign.spacingXs),
          Text(
            label,
            style: ShowmeDesign.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
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
          borderSide: BorderSide(
            color: ShowmeDesign.neutral300,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
          borderSide: BorderSide(
            color: ShowmeDesign.primaryPurple,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
          borderSide: BorderSide(
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
    if (_formKey.currentState?.validate() ?? false) {
      // Générer un slug unique basé sur le titre
      final slug = _generateSlug(_titleController.text);
      
      final cardData = {
        'slug': slug,
        'title': _titleController.text,
        'bio': _bioController.text.isEmpty ? null : _bioController.text,
        'isPublic': _isPublic,
        'allowPayment': _allowPayment,
        'nfcEnabled': _nfcEnabled,
        'theme': _selectedTheme.name,
        'profile': {
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'email': _emailController.text,
          'position': _positionController.text.isEmpty ? null : _positionController.text,
          'company': _companyController.text.isEmpty ? null : _companyController.text,
          'phone': _phoneController.text.isEmpty ? null : _phoneController.text,
          'website': _websiteController.text.isEmpty ? null : _websiteController.text,
          'linkedinUrl': _linkedinController.text.isEmpty ? null : _linkedinController.text,
        }
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