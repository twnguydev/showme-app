// mobile/lib/features/profile/presentation/pages/edit_profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../../shared/presentation/widgets/showme_app_bar.dart';
import '../../../../core/design/showme_design_system.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_event.dart';
import '../../../auth/bloc/auth_state.dart';
import '../widgets/profile_text_field.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_event.dart';
import '../../bloc/profile_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  // Controllers pour les champs de texte
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _companyController;
  late TextEditingController _positionController;
  late TextEditingController _websiteController;
  late TextEditingController _linkedinController;
  late TextEditingController _bioController;

  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;
      _firstNameController = TextEditingController(text: user.firstName ?? '');
      _lastNameController = TextEditingController(text: user.lastName ?? '');
      _emailController = TextEditingController(text: user.email);
      _phoneController = TextEditingController(text: user.profile?.phone ?? '');
      _companyController = TextEditingController(text: user.profile?.company ?? '');
      _positionController = TextEditingController(text: user.profile?.position ?? '');
      _websiteController = TextEditingController(text: user.profile?.website ?? '');
      _linkedinController = TextEditingController(text: user.profile?.linkedinUrl ?? '');
      _bioController =
          TextEditingController(text: user.profile?.bio ?? ''); // Bio depuis le profil si disponible
    } else {
      _firstNameController = TextEditingController();
      _lastNameController = TextEditingController();
      _emailController = TextEditingController();
      _phoneController = TextEditingController();
      _companyController = TextEditingController();
      _positionController = TextEditingController();
      _websiteController = TextEditingController();
      _linkedinController = TextEditingController();
      _bioController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _positionController.dispose();
    _websiteController.dispose();
    _linkedinController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShowmeDesign.neutral50,
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            // Mettre à jour l'AuthBloc avec les nouvelles données
            context.read<AuthBloc>().add(AuthUserUpdated(user: state.user));

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profil mis à jour avec succès !'),
                backgroundColor: ShowmeDesign.primaryTeal,
                behavior: SnackBarBehavior.floating,
              ),
            );

            _navigateBack();
          } else if (state is ProfileUpdateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur : ${state.message}'),
                backgroundColor: ShowmeDesign.primaryRose,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: CustomScrollView(
          slivers: [
            // AppBar
            ShowmeSliverAppBar(
              title: 'Modifier mon profil',
              showBackButton: true,
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, state) {
                      final isLoading = state is ProfileUpdateLoading ||
                          state is ProfileAvatarUploadLoading;

                      return IconButton(
                        onPressed: isLoading ? null : _saveProfile,
                        icon: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isLoading
                                ? ShowmeDesign.neutral300
                                : ShowmeDesign.primaryBlue,
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

            // Contenu
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section photo de profil
                      _buildAvatarSection(),

                      const SizedBox(height: 32),

                      // Section informations personnelles
                      _buildPersonalInfoSection(),

                      const SizedBox(height: 24),

                      // Section professionnelle
                      _buildProfessionalInfoSection(),

                      const SizedBox(height: 24),

                      // Section contact
                      _buildContactInfoSection(),

                      const SizedBox(height: 24),

                      // Section biographie
                      _buildBioSection(),

                      const SizedBox(height: 32),

                      // Bouton de sauvegarde (version mobile)
                      _buildSaveButton(),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        String? currentAvatarUrl;
        if (authState is AuthAuthenticated) {
          currentAvatarUrl = authState.user.profile?.avatar?.url;
        }

        return Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ShowmeDesign.neutral200,
                          width: 4,
                        ),
                        boxShadow: ShowmeDesign.cardShadow,
                      ),
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor:
                            ShowmeDesign.primaryBlue.withOpacity(0.1),
                        backgroundImage: _getAvatarImage(currentAvatarUrl),
                        child: _getAvatarImage(currentAvatarUrl) == null
                            ? Text(
                                _getInitials(),
                                style: ShowmeDesign.h1.copyWith(
                                  color: ShowmeDesign.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: ShowmeDesign.primaryBlue,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          boxShadow: ShowmeDesign.cardShadow,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Touchez pour changer la photo',
                style: ShowmeDesign.bodyMedium.copyWith(
                  color: ShowmeDesign.neutral600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      title: 'Informations personnelles',
      icon: Icons.person,
      children: [
        Row(
          children: [
            Expanded(
              child: ProfileTextField(
                controller: _firstNameController,
                label: 'Prénom',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le prénom est requis';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ProfileTextField(
                controller: _lastNameController,
                label: 'Nom',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ProfileTextField(
          controller: _emailController,
          label: 'Email',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'L\'email est requis';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Email invalide';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildProfessionalInfoSection() {
    return _buildSection(
      title: 'Informations professionnelles',
      icon: Icons.work,
      children: [
        ProfileTextField(
          controller: _companyController,
          label: 'Entreprise',
          prefixIcon: Icons.business_outlined,
        ),
        const SizedBox(height: 16),
        ProfileTextField(
          controller: _positionController,
          label: 'Poste',
          prefixIcon: Icons.work_outline,
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return _buildSection(
      title: 'Contact',
      icon: Icons.contact_phone,
      children: [
        ProfileTextField(
          controller: _phoneController,
          label: 'Téléphone',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        ProfileTextField(
          controller: _websiteController,
          label: 'Site web',
          prefixIcon: Icons.language_outlined,
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 16),
        ProfileTextField(
          controller: _linkedinController,
          label: 'LinkedIn',
          prefixIcon: Icons.work_outline,
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    return _buildSection(
      title: 'Biographie',
      icon: Icons.description,
      children: [
        ProfileTextField(
          controller: _bioController,
          label: 'Parlez de vous...',
          prefixIcon: Icons.description_outlined,
          maxLines: 4,
          maxLength: 500,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ShowmeDesign.radiusLg),
        boxShadow: ShowmeDesign.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ShowmeDesign.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: ShowmeDesign.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: ShowmeDesign.h5.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ShowmeDesign.neutral900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final isLoading = state is ProfileUpdateLoading ||
            state is ProfileAvatarUploadLoading;

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: ShowmeDesign.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ShowmeDesign.radiusLg),
              ),
            ),
            child: isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Sauvegarde...',
                        style: ShowmeDesign.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Sauvegarder les modifications',
                    style: ShowmeDesign.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }

  void _navigateBack() {
    context.go('/profile');
  }

  // Méthodes utilitaires
  ImageProvider? _getAvatarImage(String? currentAvatarUrl) {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    } else if (currentAvatarUrl != null && currentAvatarUrl.isNotEmpty) {
      return NetworkImage(currentAvatarUrl);
    }
    return null;
  }

  String _getInitials() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    } else if (firstName.isNotEmpty) {
      return firstName.substring(0, firstName.length > 1 ? 2 : 1).toUpperCase();
    } else if (lastName.isNotEmpty) {
      return lastName.substring(0, lastName.length > 1 ? 2 : 1).toUpperCase();
    }
    return 'US';
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });

      // ignore: use_build_context_synchronously
      context
          .read<ProfileBloc>()
          .add(ProfileAvatarUploadRequested(_selectedImage!));
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final updateData = {
        'user': {
          'email': _emailController.text.trim(),
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
        },
        'profile': {
          'phone': _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          'bio': _bioController.text.trim().isEmpty
              ? null
              : _bioController.text.trim(),
          'company': _companyController.text.trim().isEmpty
              ? null
              : _companyController.text.trim(),
          'position': _positionController.text.trim().isEmpty
              ? null
              : _positionController.text.trim(),
          'website': _websiteController.text.trim().isEmpty
              ? null
              : _websiteController.text.trim(),
          'linkedinUrl': _linkedinController.text.trim().isEmpty
              ? null
              : _linkedinController.text.trim(),
        },
      };

      context.read<ProfileBloc>().add(ProfileUpdateRequested(updateData));
    }
  }
}
