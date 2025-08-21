// src/modules/users/users.service.ts
import {
  Injectable,
  NotFoundException,
  ConflictException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';
import * as fs from 'fs/promises';
import * as path from 'path';
import { ConfigService } from '@nestjs/config';
import { v4 as uuidv4 } from 'uuid';

import { User } from '../../entities/user.entity';
import { Profile } from '../../entities/profile.entity';
import { UpdateUserDto, UpdateProfileDto, ChangePasswordDto } from './dto';
import { UpdateUserAndProfileDto } from './dto/update-user-profile.dto';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Profile)
    private readonly profileRepository: Repository<Profile>,
    private readonly configService: ConfigService,
  ) {}

  async findById(id: number): Promise<User> {
    const user = await this.userRepository.findOne({
      where: { id },
      relations: ['subscription', 'profile'],
    });

    if (!user) {
      throw new NotFoundException('Utilisateur non trouvé');
    }

    return user;
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.userRepository.findOne({
      where: { email },
      relations: ['subscription'],
    });
  }

  async findByUsername(username: string): Promise<User | null> {
    return this.userRepository.findOne({
      where: { username },
      relations: ['subscription'],
    });
  }

  async updateUser(id: number, updateUserDto: UpdateUserAndProfileDto): Promise<User> {
    const user = await this.findById(id);
    const normalizedEmailDto = updateUserDto.user?.email.toLowerCase().trim();
    const normalizedEmailUser = user.email.toLowerCase().trim();

    // Vérifier l'unicité de l'email si modifié
    if (normalizedEmailDto !== normalizedEmailUser) {
      const existingUser = await this.findByEmail(normalizedEmailDto);
      if (existingUser) {
        throw new ConflictException('Un utilisateur avec cet email existe déjà');
      }
    }

    // Mettre à jour les champs
    Object.assign(user, updateUserDto);
    
    return this.userRepository.save(user);
  }

  async updateUserAndProfile(
    userId: number,
    updateUserProfileDto: UpdateUserAndProfileDto
  ): Promise<User> {
    const profile = await this.getProfile(userId);

    // Mettre à jour l'utilisateur
    const updatedUser = await this.updateUser(userId, updateUserProfileDto);

    // Mettre à jour le profil si nécessaire
    if (updateUserProfileDto.profile) {
      Object.assign(profile, updateUserProfileDto.profile);
      await this.profileRepository.save(profile);
    }

    const userWithProfile: User = await this.userRepository.findOne({
      where: { id: updatedUser.id },
      relations: ['profile'],
    });

    return userWithProfile;
  }

  async getProfile(userId: number): Promise<Profile> {
    const profile = await this.profileRepository.findOne({
      where: { user: { id: userId } },
      relations: ['user'],
    });

    if (!profile) {
      // Créer un profil par défaut si il n'existe pas
      const user = await this.findById(userId);
      const newProfile = this.profileRepository.create({
        user,
        isPublic: true,
      });

      return this.profileRepository.save(newProfile);
    }

    return profile;
  }

  async updateProfile(
    userId: number, 
    updateProfileDto?: UpdateProfileDto,
    avatarFile?: Express.Multer.File
  ): Promise<Profile> {
    let profile = await this.profileRepository.findOne({
      where: { user: { id: userId } },
      relations: ['user'],
    });

    // Traitement de l'upload d'avatar
    let avatarData: any = undefined;
    if (avatarFile) {
      const avatarUrl = await this.saveAvatarFile(avatarFile, userId);
      
      // Supprimer l'ancien avatar si il existe
      if (profile?.avatar?.url) {
        await this.deleteOldAvatar(profile.avatar.url);
      }

      // Créer l'objet avatar avec toutes les métadonnées
      avatarData = {
        url: avatarUrl,
        name: avatarFile.originalname,
        size: avatarFile.size,
        mimeType: avatarFile.mimetype,
        uploadedAt: new Date(),
      };
    }

    if (!profile) {
      const user = await this.userRepository.findOne({ where: { id: userId } });
      if (!user) {
        throw new Error('User not found');
      }
      
      profile = this.profileRepository.create({
        user,
        ...updateProfileDto,
        ...(avatarData && { avatar: avatarData }),
      });
    } else {
      if (updateProfileDto) {
        Object.assign(profile, updateProfileDto);
      }
      if (avatarData) {
        profile.avatar = avatarData;
      }
    }

    return this.profileRepository.save(profile);
  }

  private async saveAvatarFile(file: Express.Multer.File, userId: number): Promise<string> {
    try {
      // Créer le dossier uploads s'il n'existe pas
      const uploadsDir = path.join(process.cwd(), 'uploads');
      await fs.mkdir(uploadsDir, { recursive: true });

      // Générer un nom de fichier unique
      const fileExtension = path.extname(file.originalname);
      const fileName = `avatar_${userId}_${uuidv4()}${fileExtension}`;
      const filePath = path.join(uploadsDir, fileName);

      // Sauvegarder le fichier
      await fs.writeFile(filePath, file.buffer);

      // Construire l'URL complète à partir de la config
      const apiUrl = this.configService.get('API_URL');
      return `${apiUrl}/uploads/${fileName}`;
    } catch (error) {
      console.error('Error saving avatar file:', error);
      throw new Error('Failed to save avatar file');
    }
  }

  private async deleteOldAvatar(avatarUrl: string): Promise<void> {
    try {
      // Extraire le nom du fichier de l'URL
      const fileName = path.basename(avatarUrl);
      const filePath = path.join(process.cwd(), 'uploads', fileName);
      
      // Vérifier si le fichier existe avant de le supprimer
      try {
        await fs.access(filePath);
        await fs.unlink(filePath);
        console.log(`Old avatar deleted: ${fileName}`);
      } catch (error) {
        // Le fichier n'existe pas, on ignore l'erreur
        console.warn(`Avatar file not found: ${filePath}`);
      }
    } catch (error) {
      console.error('Error deleting old avatar:', error);
    }
  }

  async changePassword(userId: number, changePasswordDto: ChangePasswordDto): Promise<{ message: string }> {
    const { currentPassword, newPassword, confirmPassword } = changePasswordDto;

    if (newPassword !== confirmPassword) {
      throw new BadRequestException('Les nouveaux mots de passe ne correspondent pas');
    }

    const user = await this.userRepository
      .createQueryBuilder('user')
      .where('user.id = :id', { id: userId })
      .addSelect('user.passwordHash')
      .getOne();

    if (!user) {
      throw new NotFoundException('Utilisateur non trouvé');
    }

    // Vérifier le mot de passe actuel
    const isCurrentPasswordValid = await bcrypt.compare(currentPassword, user.passwordHash);
    if (!isCurrentPasswordValid) {
      throw new BadRequestException('Mot de passe actuel incorrect');
    }

    // Hasher le nouveau mot de passe
    const saltRounds = 12;
    const newPasswordHash = await bcrypt.hash(newPassword, saltRounds);

    await this.userRepository.update(userId, {
      passwordHash: newPasswordHash,
    });

    return { message: 'Mot de passe modifié avec succès' };
  }

  async deleteAccount(userId: number): Promise<{ message: string }> {
    const user = await this.findById(userId);

    // Désactiver le compte au lieu de le supprimer définitivement (RGPD)
    await this.userRepository.update(userId, {
      isActive: false,
      email: `deleted_${Date.now()}@deleted.local`,
      username: `deleted_${Date.now()}`
    });

    return { message: 'Compte supprimé avec succès' };
  }

  async getUsers(page: number = 1, limit: number = 10): Promise<{ users: User[]; total: number }> {
    const [users, total] = await this.userRepository.findAndCount({
      skip: (page - 1) * limit,
      take: limit,
      order: { createdAt: 'DESC' },
      relations: ['subscription'],
    });

    return { users, total };
  }
}