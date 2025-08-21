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
import { UpdateUserDto, UpdateProfileDto, ChangePasswordDto } from './dto';
import { UpdateUserAndProfileDto } from './dto/update-user-profile.dto';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
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
    const isCurrentPasswordValid = await bcrypt.compare(currentPassword, user.password);
    if (!isCurrentPasswordValid) {
      throw new BadRequestException('Mot de passe actuel incorrect');
    }

    // Hasher le nouveau mot de passe
    const saltRounds = 12;
    const newPasswordHash = await bcrypt.hash(newPassword, saltRounds);

    await this.userRepository.update(userId, {
      password: newPasswordHash,
    });

    return { message: 'Mot de passe modifié avec succès' };
  }

  async deleteAccount(userId: number): Promise<{ message: string }> {
    const user = await this.findById(userId);

    // Désactiver le compte au lieu de le supprimer définitivement (RGPD)
    await this.userRepository.update(userId, {
      isActive: false
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