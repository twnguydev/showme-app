// src/modules/cards/dto/create-card.dto.ts
import { ApiProperty } from '@nestjs/swagger';
import { 
  IsString, 
  IsOptional, 
  IsBoolean, 
  IsEnum,
  IsObject,
  ValidateNested,
  MaxLength,
} from 'class-validator';
import { Type } from 'class-transformer';
import { CardTheme } from '../../../entities/card.entity';

class CreateProfileDto {
  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  firstName?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  lastName?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  email?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  phone?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  company?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  position?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  bio?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  website?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  linkedinUrl?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  twitterUrl?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  instagramUrl?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  address?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  city?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  country?: string;
}

export class CreateCardDto {
  @ApiProperty({
    description: 'Titre de la carte',
    example: 'Ma carte professionnelle',
  })
  @IsString()
  @MaxLength(100)
  title: string;

  @ApiProperty({
    description: 'Slug personnalisé (optionnel)',
    example: 'ma-carte-pro',
    required: false,
  })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  slug?: string;

  @ApiProperty({
    description: 'Description de la carte',
    example: 'Expert en développement web',
    required: false,
  })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  bio?: string;

  @ApiProperty({
    description: 'Thème de la carte',
    enum: CardTheme,
    example: CardTheme.PURPLE,
    required: false,
  })
  @IsOptional()
  @IsEnum(CardTheme)
  theme?: CardTheme;

  @ApiProperty({
    description: 'Carte publique',
    example: true,
    required: false,
  })
  @IsOptional()
  @IsBoolean()
  isPublic?: boolean;

  @ApiProperty({
    description: 'Autoriser les paiements',
    example: false,
    required: false,
  })
  @IsOptional()
  @IsBoolean()
  allowPayment?: boolean;

  @ApiProperty({
    description: 'NFC activé',
    example: false,
    required: false,
  })
  @IsOptional()
  @IsBoolean()
  nfcEnabled?: boolean;

  @ApiProperty({
    description: 'Profil associé à la carte',
    type: CreateProfileDto,
    required: false,
  })
  @IsOptional()
  @IsObject()
  @ValidateNested()
  @Type(() => CreateProfileDto)
  profile?: CreateProfileDto;
}