// src/modules/users/dto/update-profile.dto.ts
import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsBoolean, IsEmail, IsEnum, Matches, IsObject } from 'class-validator';
import { Transform } from 'class-transformer';
import { UserRole } from '@/entities/user.entity';

export class UpdateProfileDto {
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
    description: 'Adresse complète',
    example: '123 Rue de l\'Innovation, Paris, France',
    required: false,
  })
  @IsOptional()
  @IsString()
  address?: string;

  @ApiProperty({
    description: 'Ville',
    example: 'Paris',
    required: false,
  })
  @IsOptional()
  @IsString()
  city?: string;

  @ApiProperty({
    description: 'Pays',
    example: 'France',
    required: false,
  })
  @IsOptional()
  @IsString()
  country?: string;

  @ApiProperty({
    description: 'Avatar Object',
    example: '{"url": "https://example.com/avatar.jpg", "name": "Avatar de Jean Dupont", "size": 2048, "mimeType": "image/jpeg", "uploadedAt": "2023-10-01T12:00:00Z"}',
    required: false,
  })
  @IsOptional()
  @IsObject()
  avatar?: {
    url: string;
    name: string;
    size: number;
    mimeType: string;
    uploadedAt: string;
  };

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
    description: 'URL Instagram',
    example: '',
    required: false,
  })
  @IsOptional()
  @IsString()
  instagramUrl?: string;

  @ApiProperty({
    description: 'URL Twitter/X',
    example: '',
    required: false,
  })
  @IsOptional()
  @IsString()
  twitterUrl?: string;

  @ApiProperty({
    description: 'Numéro de téléphone',
    example: '+33 6 12 34 56 78',
    required: false,
  })
  @IsOptional()
  @IsString()
  phone?: string;

  @ApiProperty({
    description: 'Compte publique',
    example: true,
    required: false,
  })
  @IsOptional()
  @IsBoolean()
  isPublic?: boolean;
}