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

import { User } from '../../entities/user.entity';
import { Profile } from '../../entities/profile.entity';
import { UpdateUserDto, UpdateProfileDto, ChangePasswordDto } from './dto';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Profile)
    private readonly profileRepository: Repository<Profile>,
  ) {}

  async findById(id: number): Promise<User> {
    const user = await this.userRepository.findOne({
      where: { id },
      relations: ['subscription'],
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

  async updateUser(id: number, updateUserDto: UpdateUserDto): Promise<User> {
    const user = await this.findById(id);

    // Vérifier l'unicité de l'email si modifié
    if (updateUserDto.email && updateUserDto.email !== user.email) {
      const existingUser = await this.findByEmail(updateUserDto.email);
      if (existingUser) {
        throw new ConflictException('Cet email est déjà utilisé');
      }
    }

    // Vérifier l'unicité du nom d'utilisateur si modifié
    if (updateUserDto.username && updateUserDto.username !== user.username) {
      const existingUser = await this.findByUsername(updateUserDto.username);
      if (existingUser) {
        throw new ConflictException('Ce nom d\'utilisateur est déjà utilisé');
      }
    }

    // Mettre à jour les champs
    Object.assign(user, updateUserDto);
    
    return this.userRepository.save(user);
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
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        company: user.company,
        position: user.position,
        phone: user.phoneNumber,
        website: user.website,
        linkedinUrl: user.linkedinUrl,
        isPublic: true,
      });

      return this.profileRepository.save(newProfile);
    }

    return profile;
  }

  async updateProfile(userId: number, updateProfileDto: UpdateProfileDto): Promise<Profile> {
    let profile = await this.profileRepository.findOne({
      where: { user: { id: userId } },
      relations: ['user'],
    });

    if (!profile) {
      const user = await this.findById(userId);
      profile = this.profileRepository.create({
        user,
        ...updateProfileDto,
      });
    } else {
      Object.assign(profile, updateProfileDto);
    }

    return this.profileRepository.save(profile);
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
      username: `deleted_${Date.now()}`,
      firstName: null,
      lastName: null,
      phoneNumber: null,
      linkedinUrl: null,
      website: null,
      profilePicture: null,
    });

    return { message: 'Compte supprimé avec succès' };
  }

  async uploadProfilePicture(userId: number, file: Express.Multer.File): Promise<User> {
    const user = await this.findById(userId);

    // TODO: Uploader le fichier vers S3/MinIO et obtenir l'URL
    const profilePicture = {
      url: `/uploads/profiles/${file.filename}`,
      name: file.originalname,
      size: file.size,
      mimeType: file.mimetype,
      uploadedAt: new Date(),
    };

    user.profilePicture = profilePicture;
    return this.userRepository.save(user);
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