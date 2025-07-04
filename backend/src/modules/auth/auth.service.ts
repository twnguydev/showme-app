// src/modules/auth/auth.service.ts
import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  BadRequestException,
  NotFoundException,
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

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async register(registerDto: RegisterDto): Promise<AuthResponseDto> {
    const { email, password, firstName, lastName, acceptTerms } = registerDto;

    if (!acceptTerms) {
      throw new BadRequestException('Vous devez accepter les conditions d\'utilisation');
    }

    // Vérifier si l'utilisateur existe déjà
    const existingUser = await this.userRepository.findOne({
      where: [{ email }, { username: email }],
    });

    if (existingUser) {
      throw new ConflictException('Un utilisateur avec cet email existe déjà');
    }

    // Créer le nom d'utilisateur à partir de l'email
    const username = email.split('@')[0];
    let finalUsername = username;
    let counter = 1;

    // S'assurer que le nom d'utilisateur est unique
    while (await this.userRepository.findOne({ where: { username: finalUsername } })) {
      finalUsername = `${username}${counter}`;
      counter++;
    }

    // Hasher le mot de passe
    const saltRounds = 12;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    // Créer l'utilisateur
    const user = this.userRepository.create({
      email,
      username: finalUsername,
      firstName,
      lastName,
      passwordHash,
      emailVerified: !this.configService.get('app.features.emailVerificationRequired'),
      emailVerificationToken: this.configService.get('app.features.emailVerificationRequired') 
        ? uuidv4() 
        : undefined,
    });

    const savedUser = await this.userRepository.save(user);

    // Générer les tokens
    const tokens = await this.generateTokens(savedUser);

    return {
      user: this.sanitizeUser(savedUser),
      ...tokens,
    };
  }

  async login(loginDto: LoginDto): Promise<AuthResponseDto> {
    const user = await this.validateUser(loginDto.identifier, loginDto.password);
    
    if (!user) {
      throw new UnauthorizedException('Identifiants invalides');
    }

    if (!user.isActive) {
      throw new UnauthorizedException('Compte désactivé');
    }

    // Mettre à jour la date de dernière connexion
    await this.userRepository.update(user.id, { lastLoginAt: new Date() });

    const tokens = await this.generateTokens(user);

    return {
      user: this.sanitizeUser(user),
      ...tokens,
    };
  }

  async validateUser(identifier: string, password: string): Promise<User | null> {
    const user = await this.userRepository
      .createQueryBuilder('user')
      .where('user.email = :identifier OR user.username = :identifier', { identifier })
      .addSelect('user.passwordHash')
      .getOne();

    if (user && await bcrypt.compare(password, user.passwordHash)) {
      return user;
    }

    return null;
  }

  async refreshToken(refreshToken: string): Promise<AuthResponseDto> {
    try {
      const payload = this.jwtService.verify(refreshToken, {
        secret: this.configService.get('app.jwt.refreshSecret'),
      });

      const user = await this.userRepository.findOne({
        where: { id: payload.sub },
      });

      if (!user || !user.isActive) {
        throw new UnauthorizedException('Token invalide');
      }

      const tokens = await this.generateTokens(user);

      return {
        user: this.sanitizeUser(user),
        ...tokens,
      };
    } catch (error) {
      throw new UnauthorizedException('Token de rafraîchissement invalide');
    }
  }

  async forgotPassword(forgotPasswordDto: ForgotPasswordDto): Promise<{ message: string }> {
    const { email } = forgotPasswordDto;
    
    const user = await this.userRepository.findOne({ where: { email } });
    
    if (!user) {
      // Ne pas révéler si l'email existe ou non pour des raisons de sécurité
      return { message: 'Si cet email existe, un lien de réinitialisation a été envoyé' };
    }

    // Générer un token de réinitialisation
    const resetToken = uuidv4();
    const resetExpires = new Date(Date.now() + 3600000); // 1 heure

    await this.userRepository.update(user.id, {
      passwordResetToken: resetToken,
      passwordResetExpires: resetExpires,
    });

    // TODO: Envoyer l'email de réinitialisation
    // await this.emailService.sendPasswordReset(user.email, resetToken);

    return { message: 'Si cet email existe, un lien de réinitialisation a été envoyé' };
  }

  async resetPassword(resetPasswordDto: ResetPasswordDto): Promise<{ message: string }> {
    const { token, newPassword, confirmPassword } = resetPasswordDto;

    if (newPassword !== confirmPassword) {
      throw new BadRequestException('Les mots de passe ne correspondent pas');
    }

    const user = await this.userRepository.findOne({
      where: {
        passwordResetToken: token,
      },
    });

    if (!user || !user.passwordResetExpires || user.passwordResetExpires < new Date()) {
      throw new BadRequestException('Token de réinitialisation invalide ou expiré');
    }

    // Hasher le nouveau mot de passe
    const saltRounds = 12;
    const passwordHash = await bcrypt.hash(newPassword, saltRounds);

    // Mettre à jour le mot de passe et supprimer le token
    await this.userRepository.update(user.id, {
      passwordHash,
      passwordResetToken: null,
      passwordResetExpires: null,
    });

    return { message: 'Mot de passe réinitialisé avec succès' };
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
        secret: this.configService.get('app.jwt.secret'),
        expiresIn: this.configService.get('app.jwt.expiresIn'),
      }),
      this.jwtService.signAsync(payload, {
        secret: this.configService.get('app.jwt.refreshSecret'),
        expiresIn: this.configService.get('app.jwt.refreshExpiresIn'),
      }),
    ]);

    // Calculer la date d'expiration
    const expiresIn = this.configService.get('app.jwt.expiresIn');
    const expiresAt = new Date();
    
    // Parsing simple pour convertir "15m" en millisecondes
    const match = expiresIn.match(/^(\d+)([smhd])$/);
    if (match) {
      const [, number, unit] = match;
      const multipliers = { s: 1000, m: 60000, h: 3600000, d: 86400000 };
      expiresAt.setTime(expiresAt.getTime() + parseInt(number) * multipliers[unit]);
    }

    return {
      jwt: accessToken,
      refreshToken,
      expiresAt,
    };
  }

  private sanitizeUser(user: User) {
    const { passwordHash, passwordResetToken, passwordResetExpires, emailVerificationToken, ...sanitized } = user;
    return sanitized;
  }

  async getUserById(id: number): Promise<User | null> {
    return this.userRepository.findOne({ where: { id } });
  }
}