// backend/src/modules/cards/dto/create-card.dto.ts
import {
  IsString,
  IsEmail,
  IsBoolean,
  IsOptional,
  IsEnum,
  IsUrl,
  MaxLength,
  MinLength,
} from 'class-validator';
import { Transform } from 'class-transformer';
import { CardTheme } from '../../../entities/card.entity';

export class CreateCardDto {
  @IsString()
  @MinLength(3)
  @MaxLength(100)
  @Transform(({ value }) => value?.toLowerCase().replace(/[^a-z0-9-]/g, '-'))
  slug: string;

  @IsString()
  @MinLength(3)
  @MaxLength(200)
  title: string;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  bio?: string;

  @IsOptional()
  @IsBoolean()
  isPublic?: boolean = true;

  @IsOptional()
  @IsBoolean()
  allowPayment?: boolean = false;

  @IsOptional()
  @IsBoolean()
  nfcEnabled?: boolean = true;

  @IsOptional()
  @IsEnum(CardTheme)
  theme?: CardTheme = CardTheme.PURPLE;

  // === DONNÉES DE CONTACT ===

  @IsEmail()
  @MaxLength(255)
  email: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  firstName?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  lastName?: string;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  phone?: string;

  @IsOptional()
  @IsString()
  @MaxLength(200)
  company?: string;

  @IsOptional()
  @IsString()
  @MaxLength(200)
  position?: string;

  @IsOptional()
  @IsUrl()
  @MaxLength(255)
  website?: string;

  @IsOptional()
  @IsUrl()
  @MaxLength(255)
  linkedinUrl?: string;

  @IsOptional()
  @IsUrl()
  @MaxLength(255)
  twitterUrl?: string;

  @IsOptional()
  @IsUrl()
  @MaxLength(255)
  instagramUrl?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  address?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  city?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  country?: string;
}