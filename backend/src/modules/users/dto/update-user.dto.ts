// src/modules/users/dto/update-user.dto.ts
import { ApiProperty } from '@nestjs/swagger';
import { 
  IsEmail, 
  IsString, 
  IsOptional, 
  IsBoolean,
  Matches,
  IsEnum,
} from 'class-validator';
import { UserRole } from '../../../entities/user.entity';

export class UpdateUserDto {
  @ApiProperty({
    description: 'Nom d\'utilisateur',
    example: 'jean.dupont',
    required: false,
  })
  @IsOptional()
  @IsString()
  @Matches(/^[a-zA-Z0-9_.-]+$/, {
    message: 'Le nom d\'utilisateur ne peut contenir que des lettres, chiffres, points, tirets et underscores',
  })
  username?: string;

  @ApiProperty({
    description: 'Adresse email',
    example: 'jean.dupont@example.com',
    required: false,
  })
  @IsOptional()
  @IsEmail({}, { message: 'Adresse email invalide' })
  email?: string;

  @ApiProperty({
    description: 'Prénom',
    example: 'Jean',
    required: false,
  })
  @IsOptional()
  @IsString()
  firstName?: string;

  @ApiProperty({
    description: 'Nom de famille',
    example: 'Dupont',
    required: false,
  })
  @IsOptional()
  @IsString()
  lastName?: string;

  @ApiProperty({
    description: 'Nom de l\'entreprise',
    example: 'ShowMe Corp',
    required: false,
  })
  @IsOptional()
  @IsString()
  company?: string;

  @ApiProperty({
    description: 'Poste occupé',
    example: 'Consultant Senior',
    required: false,
  })
  @IsOptional()
  @IsString()
  position?: string;

  @ApiProperty({
    description: 'Numéro de téléphone',
    example: '+33 6 12 34 56 78',
    required: false,
  })
  @IsOptional()
  @IsString()
  phoneNumber?: string;

  @ApiProperty({
    description: 'URL LinkedIn',
    example: 'https://linkedin.com/in/jean-dupont',
    required: false,
  })
  @IsOptional()
  @IsString()
  linkedinUrl?: string;

  @ApiProperty({
    description: 'Site web personnel',
    example: 'https://jeandupont.com',
    required: false,
  })
  @IsOptional()
  @IsString()
  website?: string;

  @ApiProperty({
    description: 'Compte actif',
    example: true,
    required: false,
  })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;

  @ApiProperty({
    description: 'Email vérifié',
    example: true,
    required: false,
  })
  @IsOptional()
  @IsBoolean()
  emailVerified?: boolean;

  @ApiProperty({
    description: 'Fuseau horaire',
    example: 'Europe/Paris',
    required: false,
  })
  @IsOptional()
  @IsString()
  timezone?: string;

  @ApiProperty({
    description: 'Langue préférée',
    example: 'fr',
    required: false,
  })
  @IsOptional()
  @IsString()
  language?: string;

  @ApiProperty({
    description: 'Rôle utilisateur (Admin seulement)',
    enum: UserRole,
    required: false,
  })
  @IsOptional()
  @IsEnum(UserRole)
  role?: UserRole;
}