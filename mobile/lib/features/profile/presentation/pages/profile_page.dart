// mobile/lib/features/profile/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../shared/presentation/widgets/showme_app_bar.dart';
import '../../../../core/design/showme_design_system.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_event.dart';
import '../../../auth/bloc/auth_state.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_info_tile.dart';
import '../widgets/profile_section.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShowmeDesign.neutral50,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            final user = state.user;
            
            return CustomScrollView(
              slivers: [
                // AppBar personnalisée
                ShowmeSliverAppBar(
                  title: 'Mon profil',
                  showBackButton: true,
                  showProfileIcon: false, // Pas d'icône profil sur la page profil !
                  actions: [
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
                            Icons.edit_rounded,
                            size: 18,
                            color: ShowmeDesign.neutral600,
                          ),
                        ),
                        onPressed: () => _showEditProfile(),
                      ),
                    ),
                  ],
                ),
                
                // Contenu principal
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.only(
                      top: ShowmeDesign.spacingLg,
                      left: 20,
                      right: 20,
                    ),
                    child: Column(
                      children: [
                        // Avatar et nom
                        ProfileAvatar(
                          user: user,
                          onImagePicked: _handleImagePicked,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Informations personnelles
                        ProfileSection(
                          title: 'Informations personnelles',
                          children: [
                            ProfileInfoTile(
                              icon: Icons.person,
                              label: 'Nom complet',
                              value: user.fullName,
                            ),
                            ProfileInfoTile(
                              icon: Icons.email,
                              label: 'Email',
                              value: user.email,
                            ),
                            if (user.company != null)
                              ProfileInfoTile(
                                icon: Icons.business,
                                label: 'Entreprise',
                                value: user.company!,
                              ),
                            if (user.position != null)
                              ProfileInfoTile(
                                icon: Icons.work,
                                label: 'Poste',
                                value: user.position!,
                              ),
                            if (user.phoneNumber != null)
                              ProfileInfoTile(
                                icon: Icons.phone,
                                label: 'Téléphone',
                                value: user.phoneNumber!,
                              ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Actions
                        ProfileSection(
                          title: 'Actions',
                          children: [
                            ListTile(
                              leading: const Icon(Icons.business_center),
                              title: const Text('Mes cartes de visite'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.go('/cards'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.analytics),
                              title: const Text('Statistiques'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.go('/crm'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.settings),
                              title: const Text('Paramètres'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _showSettings(),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Déconnexion
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _handleLogout(),
                            icon: const Icon(Icons.logout, color: Colors.red),
                            label: const Text(
                              'Se déconnecter',
                              style: TextStyle(color: Colors.red),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: ShowmeDesign.spacing3xl),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  void _handleImagePicked() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    
    if (image != null) {
      // TODO: Implémenter l'upload de l'image
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload d\'image en cours de développement'),
        ),
      );
    }
  }

  void _showEditProfile() {
    // TODO: Implémenter l'édition du profil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Édition du profil en cours de développement'),
      ),
    );
  }

  void _showSettings() {
    // TODO: Implémenter les paramètres
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Paramètres en cours de développement'),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            child: const Text(
              'Déconnecter',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}