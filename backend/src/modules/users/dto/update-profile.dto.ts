// src/modules/users/dto/update-profile.dto.ts
import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsBoolean, IsEmail } from 'class-validator';

export class UpdateProfileDto {
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
    description: 'Email de contact',
    example: 'jean.dupont@example.com',
    required: false,
  })
  @IsOptional()
  @IsEmail()
  email?: string;

  @ApiProperty({
    description: 'Numéro de téléphone',
    example: '+33 6 12 34 56 78',
    required: false,
  })
  @IsOptional()
  @IsString()
  phone?: string;

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
    description: 'Biographie personnelle',
    example: 'Expert en transformation digitale avec 10+ ans d\'expérience.',
    required: false,
  })
  @IsOptional()
  @IsString()
  bio?: string;

  @ApiProperty({
    description: 'Site web personnel',
    example: 'https://jeandupont.com',
    required: false,
  })
  @IsOptional()
  @IsString()
  website?: string;

  @ApiProperty({
    description: 'URL LinkedIn',
    example: 'https://linkedin.com/in/jean-dupont',
    required: false,
  })
  @IsOptional()
  @IsString()
  linkedinUrl?: string;

  @ApiProperty({
    description: 'URL Twitter',
    example: 'https://twitter.com/jeandupont',
    required: false,
  })
  @IsOptional()
  @IsString