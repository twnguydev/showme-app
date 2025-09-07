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
import { LoginDto, RegisterDto, ForgotPasswordDto, ResetPasswordDto } from './dto';
import { AuthResponseDto } from './dto/auth-response.dto';
import { CardsService } from '../cards/cards.service';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly cardsService: CardsService,
  ) {}

  /**
   * Inscription d'un nouvel utilisateur
   */
  async register(registerDto: RegisterDto) {
    // Vérifier si l'utilisateur existe déjà
    const existingUser = await this.userRepository.findOne({
      where: { email: registerDto.email },
    });

    if (existingUser) {
      throw new ConflictException('Un utilisateur avec cet email existe déjà');
    }

    // Hasher le mot de passe
    const saltRounds = 12;
    const hashedPassword = await bcrypt.hash(registerDto.password, saltRounds);

    // Créer l'utilisateur
    const user = this.userRepository.create({
      email: registerDto.email,
      password: hashedPassword,
      firstName: registerDto.firstName,
      lastName: registerDto.lastName,
      // Définir les valeurs par défaut pour les futures cartes
      defaultPhone: registerDto.phone,
      defaultCompany: registerDto.company,
      defaultPosition: registerDto.position,
    });

    const savedUser = await this.userRepository.save(user);

    // ✅ CRÉER LA CARTE PAR DÉFAUT
    try {
      await this.cardsService.createDefaultCard(savedUser);
      console.log(`✅ Carte par défaut créée pour ${savedUser.email}`);
    } catch (error) {
      console.error(`❌ Erreur création carte par défaut pour ${savedUser.email}:`, error);
      // Ne pas faire échouer l'inscription si la carte échoue
    }

    // Générer les tokens
    const { accessToken, refreshToken } = await this.generateTokens(savedUser);

    // Sauvegarder le refresh token
    savedUser.refreshToken = refreshToken;
    await this.userRepository.save(savedUser);

    // Retourner la réponse complète avec la carte
    const userWithCards = await this.userRepository.findOne({
      where: { id: savedUser.id },
      relations: ['cards'],
    });

    return {
      user: userWithCards,
      token: accessToken,
      refreshToken,
      expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000), // 24h
    };
  }

  async login(loginDto: LoginDto) {
    // Trouver l'utilisateur
    const user = await this.userRepository.findOne({
      where: { email: loginDto.identifier },
      relations: ['cards'],
    });

    if (!user) {
      throw new UnauthorizedException('Identifiants incorrects');
    }

    const passwordValid = await bcrypt.compare(loginDto.password, user.password);
    if (!passwordValid) {
      throw new UnauthorizedException('Identifiants incorrects');
    }

    if (!user.cards || user.cards.length === 0) {
      try {
        await this.cardsService.createDefaultCard(user);
        console.log(`✅ Carte par défaut créée lors de la connexion pour ${user.email}`);

        const userWithCards = await this.userRepository.findOne({
          where: { id: user.id },
          relations: ['cards'],
        });
        Object.assign(user, userWithCards);
      } catch (error) {
        console.error(`❌ Erreur création carte par défaut lors connexion:`, error);
      }
    }

    user.updateLastLogin();

    const { accessToken, refreshToken } = await this.generateTokens(user);

    user.refreshToken = refreshToken;
    await this.userRepository.save(user);

    return {
      user,
      token: accessToken,
      refreshToken,
      expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000), // 24h
    };
  }

  async getCurrentUser(userId: number) {
    const user = await this.userRepository.findOne({
      where: { id: userId },
      relations: ['cards', 'subscription'], // ✅ Inclure les cartes
    });

    if (!user) {
      throw new UnauthorizedException('Utilisateur non trouvé');
    }

    // ✅ VÉRIFIER SI L'UTILISATEUR A UNE CARTE PAR DÉFAUT
    if (!user.cards || user.cards.length === 0) {
      try {
        await this.cardsService.createDefaultCard(user);
        console.log(`✅ Carte par défaut créée pour getCurrentUser ${user.email}`);
        
        // Recharger l'utilisateur avec ses cartes
        const userWithCards = await this.userRepository.findOne({
          where: { id: user.id },
          relations: ['cards', 'subscription'],
        });
        return userWithCards;
      } catch (error) {
        console.error(`❌ Erreur création carte par défaut getCurrentUser:`, error);
      }
    }

    return user;
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

    const isPasswordValid = await bcrypt.compare(password, user.password);
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
        token: tokens.accessToken,
        refreshToken: tokens.refreshToken
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

    const password = await this.hashPassword(newPassword);

    await this.userRepository.update(user.id, {
      password,
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

  private async hashPassword(password: string): Promise<string> {
    const saltRounds = 12;
    return bcrypt.hash(password, saltRounds);
  }

  private async generateTokens(user: User) {
    const payload = {
      sub: user.id,
      email: user.email,
      role: user.role,
    };

    const accessToken = this.jwtService.sign(payload);
    const refreshToken = this.jwtService.sign(payload, { expiresIn: '7d' });

    return { accessToken, refreshToken };
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
      password, 
      passwordResetToken, 
      passwordResetExpires, 
      emailVerificationToken,
      ...sanitizedUser 
    } = user;

    return sanitizedUser;
  }
}