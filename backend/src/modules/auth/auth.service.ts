// src/modules/auth/auth.service.ts
import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  BadRequestException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { v4 as uuidv4 } from 'uuid';

import { User } from '../../entities/user.entity';
import { Profile } from '../../entities/profile.entity';
import { LoginDto, RegisterDto, ForgotPasswordDto, ResetPasswordDto } from './dto';
import { AuthResponseDto } from './dto/auth-response.dto';
import { CardsService } from '../cards/cards.service';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Profile)
    private readonly profileRepository: Repository<Profile>,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly cardsService: CardsService,
  ) {}

  /**
   * Inscription d'un nouvel utilisateur
   */
  async register(registerDto: RegisterDto): Promise<AuthResponseDto> {
    const { email, password, firstName, lastName, acceptTerms } = registerDto;

    if (!acceptTerms) {
      throw new BadRequestException('Vous devez accepter les conditions d\'utilisation');
    }

    // Vérifier si l'utilisateur existe déjà
    const existingUser = await this.userRepository.findOne({
      where: [{ email }, { username: email.split('@')[0] }],
    });

    if (existingUser) {
      throw new ConflictException('Un utilisateur avec cet email existe déjà');
    }

    // Créer le nom d'utilisateur unique
    const username = await this.generateUniqueUsername(email);

    // Hasher le mot de passe
    const passwordHash = await this.hashPassword(password);

    // Créer l'utilisateur (SANS données personnelles)
    const user = this.userRepository.create({
      email,
      username,
      passwordHash,
      emailVerified: !this.configService.get('EMAIL_VERIFICATION_REQUIRED', false),
      emailVerificationToken: this.configService.get('EMAIL_VERIFICATION_REQUIRED', false) 
        ? uuidv4() 
        : null,
    });

    const savedUser = await this.userRepository.save(user);

    // Créer le profil avec les données personnelles
    const profile = this.profileRepository.create({
      firstName,
      lastName,
      email,
      company: registerDto.company,
      position: registerDto.position,
      phone: registerDto.phone,
      isPublic: true,
      user: savedUser,
    });

    await this.profileRepository.save(profile);

    // Créer une carte par défaut
    try {
      await this.cardsService.createDefaultCard(savedUser);
    } catch (error) {
      console.error('Erreur lors de la création de la carte par défaut:', error);
    }

    // Récupérer l'utilisateur avec ses relations
    const userWithRelations = await this.getUserWithRelations(savedUser.id);

    // Générer les tokens
    const tokens = await this.generateTokens(savedUser);

    return {
      user: this.sanitizeUser(userWithRelations),
      ...tokens,
    };
  }

  /**
   * Connexion d'un utilisateur
   */
  async login(loginDto: LoginDto): Promise<AuthResponseDto> {
    const { identifier, password } = loginDto;

    const user = await this.validateUser(identifier, password);
    
    if (!user) {
      throw new UnauthorizedException('Email ou mot de passe incorrect');
    }

    if (!user.isActive) {
      throw new UnauthorizedException('Votre compte a été désactivé');
    }

    // Mettre à jour la date de dernière connexion
    await this.userRepository.update(user.id, { 
      lastLoginAt: new Date() 
    });

    // Récupérer l'utilisateur avec ses relations
    const userWithRelations = await this.getUserWithRelations(user.id);

    // Générer les tokens
    const tokens = await this.generateTokens(user);

    return {
      user: this.sanitizeUser(userWithRelations),
      ...tokens,
    };
  }

  async validateUser(identifier: string, password: string): Promise<User | null> {
    const user = await this.userRepository
      .createQueryBuilder('user')
      .where('user.email = :identifier OR user.username = :identifier', { identifier })
      .addSelect('user.passwordHash')
      .getOne();

    if (!user) {
      return null;
    }

    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      return null;
    }

    return user;
  }

  async refreshToken(refreshToken: string): Promise<AuthResponseDto> {
    try {
      const payload = this.jwtService.verify(refreshToken, {
        secret: this.configService.get('JWT_REFRESH_SECRET'),
      });

      const user = await this.getUserWithRelations(payload.sub);

      if (!user || !user.isActive) {
        throw new UnauthorizedException('Token de rafraîchissement invalide');
      }

      const tokens = await this.generateTokens(user);

      return {
        user: this.sanitizeUser(user),
        ...tokens,
      };
    } catch (error) {
      throw new UnauthorizedException('Token de rafraîchissement invalide ou expiré');
    }
  }

  async forgotPassword(forgotPasswordDto: ForgotPasswordDto): Promise<{ message: string }> {
    const { email } = forgotPasswordDto;
    
    const user = await this.userRepository.findOne({ where: { email } });
    
    if (!user) {
      return { 
        message: 'Si cette adresse email est associée à un compte, vous recevrez un lien de réinitialisation' 
      };
    }

    const resetToken = uuidv4();
    const resetExpires = new Date(Date.now() + 3600000); // 1 heure

    await this.userRepository.update(user.id, {
      passwordResetToken: resetToken,
      passwordResetExpires: resetExpires,
    });

    // TODO: Envoyer l'email de réinitialisation

    return { 
      message: 'Si cette adresse email est associée à un compte, vous recevrez un lien de réinitialisation' 
    };
  }

  async resetPassword(resetPasswordDto: ResetPasswordDto): Promise<{ message: string }> {
    const { token, newPassword, confirmPassword } = resetPasswordDto;

    if (newPassword !== confirmPassword) {
      throw new BadRequestException('Les mots de passe ne correspondent pas');
    }

    const user = await this.userRepository.findOne({
      where: { passwordResetToken: token },
    });

    if (!user || !user.passwordResetExpires || user.passwordResetExpires < new Date()) {
      throw new BadRequestException('Token de réinitialisation invalide ou expiré');
    }

    const passwordHash = await this.hashPassword(newPassword);

    await this.userRepository.update(user.id, {
      passwordHash,
      passwordResetToken: null,
      passwordResetExpires: null,
    });

    return { 
      message: 'Votre mot de passe a été réinitialisé avec succès' 
    };
  }

  async getUserById(id: number): Promise<User | null> {
    return this.getUserWithRelations(id);
  }

  // Méthodes privées
  private async generateUniqueUsername(email: string): Promise<string> {
    const baseUsername = email.split('@')[0].toLowerCase();
    let username = baseUsername.replace(/[^a-z0-9]/g, '');
    let counter = 1;

    if (username.length < 3) {
      username = 'user' + username;
    }

    while (await this.userRepository.findOne({ where: { username } })) {
      username = `${baseUsername}${counter}`;
      counter++;
    }

    return username;
  }

  private async hashPassword(password: string): Promise<string> {
    const saltRounds = 12;
    return bcrypt.hash(password, saltRounds);
  }

  private async generateTokens(user: User) {
    const payload = { 
      sub: user.id, 
      email: user.email, 
      username: user.username,
      role: user.role,
    };

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(payload, {
        secret: this.configService.get('JWT_SECRET'),
        expiresIn: this.configService.get('JWT_EXPIRES_IN', '15m'),
      }),
      this.jwtService.signAsync(payload, {
        secret: this.configService.get('JWT_REFRESH_SECRET'),
        expiresIn: this.configService.get('JWT_REFRESH_EXPIRES_IN', '7d'),
      }),
    ]);

    const expiresIn = this.configService.get('JWT_EXPIRES_IN', '15m');
    const expiresAt = this.calculateExpirationDate(expiresIn);

    return {
      jwt: accessToken,
      refreshToken,
      expiresAt,
    };
  }

  private calculateExpirationDate(duration: string): Date {
    const expiresAt = new Date();
    
    const match = duration.match(/^(\d+)([smhd])$/);
    if (match) {
      const [, number, unit] = match;
      const multipliers = { s: 1000, m: 60000, h: 3600000, d: 86400000 };
      expiresAt.setTime(expiresAt.getTime() + parseInt(number) * multipliers[unit]);
    } else {
      expiresAt.setTime(expiresAt.getTime() + 15 * 60000);
    }

    return expiresAt;
  }

  private async getUserWithRelations(userId: number): Promise<User | null> {
    return this.userRepository.findOne({
      where: { id: userId },
      relations: ['cards', 'cards.profile', 'subscription', 'profile'],
    });
  }

  private sanitizeUser(user: User): Partial<User> {
    if (!user) return null;

    const { 
      passwordHash, 
      passwordResetToken, 
      passwordResetExpires, 
      emailVerificationToken,
      ...sanitizedUser 
    } = user;

    return sanitizedUser;
  }
}