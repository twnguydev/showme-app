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
                  showProfileIcon: false,
                  actions: [
                    Container(
                      margin: const EdgeInsets.only(right: 16),
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
                          child: const Icon(
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
                    margin: const EdgeInsets.only(
                      top: ShowmeDesign.spacingLg,
                      left: 20,
                      right: 20,
                    ),
                    child: Column(
                      children: [
                        // Avatar et nom
                        _buildUserHeader(user),
                        
                        const SizedBox(height: 32),
                        
                        // Informations personnelles
                        ProfileSection(
                          title: 'Informations personnelles',
                          children: [
                            ProfileInfoTile(
                              icon: Icons.person,
                              label: 'Nom complet',
                              value: _getFullName(user),
                              valueColor: ShowmeDesign.neutral900,
                            ),
                            ProfileInfoTile(
                              icon: Icons.email,
                              label: 'Email',
                              value: user.email,
                              valueColor: ShowmeDesign.neutral600,
                            ),
                            if (user.company != null && user.company!.isNotEmpty)
                              ProfileInfoTile(
                                icon: Icons.business,
                                label: 'Entreprise',
                                value: user.company!,
                                valueColor: ShowmeDesign.neutral600,
                              ),
                            if (user.position != null && user.position!.isNotEmpty)
                              ProfileInfoTile(
                                icon: Icons.work,
                                label: 'Poste',
                                value: user.position!,
                                valueColor: ShowmeDesign.neutral600,
                              ),
                            if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
                              ProfileInfoTile(
                                icon: Icons.phone,
                                label: 'Téléphone',
                                value: user.phoneNumber!,
                                valueColor: ShowmeDesign.primaryTeal,
                              ),
                            if (user.website != null && user.website!.isNotEmpty)
                              ProfileInfoTile(
                                icon: Icons.language,
                                label: 'Site web',
                                value: user.website!,
                                valueColor: ShowmeDesign.primaryBlue,
                              ),
                            if (user.linkedinUrl != null && user.linkedinUrl!.isNotEmpty)
                              ProfileInfoTile(
                                icon: Icons.work_outline,
                                label: 'LinkedIn',
                                value: user.linkedinUrl!,
                                valueColor: ShowmeDesign.primaryBlue,
                              ),
                          ],
                        ),
                        
                        // Si certaines informations manquent, encourager à les compléter
                        if (_hasIncompleteProfile(user)) ...[
                          const SizedBox(height: 24),
                          _buildProfileCompletionCard(user),
                        ],
                        
                        const SizedBox(height: 24),
                        
                        // Actions
                        ProfileSection(
                          title: 'Actions',
                          children: [
                            ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: ShowmeDesign.primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.business_center,
                                  color: ShowmeDesign.primaryBlue,
                                  size: 20,
                                ),
                              ),
                              title: const Text('Mes cartes de visite'),
                              subtitle: const Text('Gérer mes cartes'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.go('/cards'),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: ShowmeDesign.primaryTeal.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.analytics,
                                  color: ShowmeDesign.primaryTeal,
                                  size: 20,
                                ),
                              ),
                              title: const Text('Statistiques'),
                              subtitle: const Text('Voir mes performances'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.go('/crm'),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: ShowmeDesign.neutral500.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.settings,
                                  color: ShowmeDesign.neutral500,
                                  size: 20,
                                ),
                              ),
                              title: const Text('Paramètres'),
                              subtitle: const Text('Confidentialité et sécurité'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _showSettings(),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Informations du compte
                        ProfileSection(
                          title: 'Informations du compte',
                          children: [
                            ProfileInfoTile(
                              icon: Icons.calendar_today,
                              label: 'Membre depuis',
                              value: _formatMemberSince(user.createdAt),
                              valueColor: ShowmeDesign.neutral500,
                            ),
                            if (user.lastLoginAt != null)
                              ProfileInfoTile(
                                icon: Icons.access_time,
                                label: 'Dernière connexion',
                                value: _formatLastLogin(user.lastLoginAt!),
                                valueColor: ShowmeDesign.neutral500,
                              ),
                            ProfileInfoTile(
                              icon: Icons.verified_user,
                              label: 'Statut du compte',
                              value: user.isActive == true ? 'Actif' : 'Inactif',
                              valueColor: user.isActive == true 
                                ? ShowmeDesign.primaryTeal 
                                : ShowmeDesign.primaryRose,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
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
                        
                        const SizedBox(height: ShowmeDesign.spacing3xl),
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

  Widget _buildUserHeader(dynamic user) {
    return Column(
      children: [
        // Avatar
        Stack(
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
                backgroundColor: ShowmeDesign.primaryBlue.withOpacity(0.1),
                backgroundImage: user.profilePicture != null
                    ? NetworkImage(user.profilePicture!)
                    : null,
                child: user.profilePicture == null
                    ? Text(
                        _getInitials(user),
                        style: ShowmeDesign.h1.copyWith(
                          color: ShowmeDesign.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
            // Bouton pour changer la photo
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _handleImagePicked,
                child: Container(
                  width: 36,
                  height: 36,
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
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Nom et informations principales
        Text(
          _getFullName(user),
          style: ShowmeDesign.h2.copyWith(
            fontWeight: FontWeight.bold,
            color: ShowmeDesign.neutral900,
          ),
          textAlign: TextAlign.center,
        ),
        
        if (user.position != null && user.position!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            user.position!,
            style: ShowmeDesign.bodyLarge.copyWith(
              color: ShowmeDesign.neutral600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        
        if (user.company != null && user.company!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.business,
                size: 16,
                color: ShowmeDesign.neutral500,
              ),
              const SizedBox(width: 4),
              Text(
                user.company!,
                style: ShowmeDesign.bodyMedium.copyWith(
                  color: ShowmeDesign.neutral500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildProfileCompletionCard(dynamic user) {
    final completionPercentage = _calculateProfileCompletion(user);
    final missingFields = _getMissingFields(user);
    
    return Container(
      padding: const EdgeInsets.all(ShowmeDesign.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ShowmeDesign.primaryBlue.withOpacity(0.1),
            ShowmeDesign.primaryTeal.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(ShowmeDesign.radiusLg),
        border: Border.all(
          color: ShowmeDesign.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
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
                  color: ShowmeDesign.primaryBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_pin,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complétez votre profil',
                      style: ShowmeDesign.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ShowmeDesign.neutral900,
                      ),
                    ),
                    Text(
                      '${completionPercentage.toInt()}% complété',
                      style: ShowmeDesign.bodySmall.copyWith(
                        color: ShowmeDesign.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Barre de progression
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: ShowmeDesign.neutral200,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: completionPercentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: ShowmeDesign.primaryBlue,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Champs manquants : ${missingFields.join(', ')}',
            style: ShowmeDesign.bodySmall.copyWith(
              color: ShowmeDesign.neutral600,
            ),
          ),
          
          const SizedBox(height: 12),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showEditProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: ShowmeDesign.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Compléter mon profil',
                style: ShowmeDesign.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Méthodes utilitaires
  String _getFullName(dynamic user) {
    final firstName = user.firstName ?? '';
    final lastName = user.lastName ?? '';
    final fullName = '$firstName $lastName'.trim();
    
    if (fullName.isEmpty) {
      return user.email ?? 'Utilisateur';
    }
    
    return fullName;
  }

  String _getInitials(dynamic user) {
    final firstName = user.firstName ?? '';
    final lastName = user.lastName ?? '';
    
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    } else if (firstName.isNotEmpty) {
      return firstName.substring(0, firstName.length > 1 ? 2 : 1).toUpperCase();
    } else if (lastName.isNotEmpty) {
      return lastName.substring(0, lastName.length > 1 ? 2 : 1).toUpperCase();
    } else {
      final email = user.email;
      if (email != null && email.isNotEmpty) {
        return email.substring(0, email.length > 1 ? 2 : 1).toUpperCase();
      }
      return 'US';
    }
  }

  bool _hasIncompleteProfile(dynamic user) {
    return _calculateProfileCompletion(user) < 100;
  }

  double _calculateProfileCompletion(dynamic user) {
    int totalFields = 7; // firstName, lastName, email, company, position, phone, website
    int completedFields = 0;
    
    if (user.firstName != null && user.firstName!.isNotEmpty) completedFields++;
    if (user.lastName != null && user.lastName!.isNotEmpty) completedFields++;
    if (user.email != null && user.email!.isNotEmpty) completedFields++;
    if (user.company != null && user.company!.isNotEmpty) completedFields++;
    if (user.position != null && user.position!.isNotEmpty) completedFields++;
    if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) completedFields++;
    if (user.website != null && user.website!.isNotEmpty) completedFields++;
    
    return (completedFields / totalFields) * 100;
  }

  List<String> _getMissingFields(dynamic user) {
    List<String> missing = [];
    
    if (user.firstName == null || user.firstName!.isEmpty) missing.add('Prénom');
    if (user.lastName == null || user.lastName!.isEmpty) missing.add('Nom');
    if (user.company == null || user.company!.isEmpty) missing.add('Entreprise');
    if (user.position == null || user.position!.isEmpty) missing.add('Poste');
    if (user.phoneNumber == null || user.phoneNumber!.isEmpty) missing.add('Téléphone');
    if (user.website == null || user.website!.isEmpty) missing.add('Site web');
    
    return missing;
  }

  String _formatMemberSince(DateTime? createdAt) {
    if (createdAt == null) return 'Date inconnue';
    
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays < 30) {
      return '${difference.inDays} jours';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months mois';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years an${years > 1 ? 's' : ''}';
    }
  }

  String _formatLastLogin(DateTime lastLogin) {
    final now = DateTime.now();
    final difference = now.difference(lastLogin);
    
    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return 'Il y a plus d\'une semaine';
    }
  }

  // Gestionnaires d'événements
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
        SnackBar(
          content: const Text('Upload d\'image en cours de développement'),
          backgroundColor: ShowmeDesign.primaryBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
          ),
        ),
      );
    }
  }

  void _showEditProfile() {
    // TODO: Implémenter l'édition du profil
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Édition du profil en cours de développement'),
        backgroundColor: ShowmeDesign.primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
        ),
      ),
    );
  }

  void _showSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Paramètres en cours de développement'),
        backgroundColor: ShowmeDesign.neutral600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
        ),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusLg),
        ),
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Annuler',
              style: TextStyle(color: ShowmeDesign.neutral600),
            ),
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