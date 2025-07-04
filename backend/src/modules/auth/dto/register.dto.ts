// src/modules/auth/dto/register.dto.ts
import { ApiProperty } from '@nestjs/swagger';
import { 
  IsEmail, 
  IsString, 
  IsNotEmpty, 
  MinLength, 
  IsOptional, 
  IsBoolean,
  Matches,
} from 'class-validator';

export class RegisterDto {
  @ApiProperty({
    description: 'Adresse email',
    example: 'jean.dupont@example.com',
  })
  @IsEmail({}, { message: 'Adresse email invalide' })
  @IsNotEmpty()
  email: string;

  @ApiProperty({
    description: 'Mot de passe (minimum 8 caractères)',
    example: 'MotDePasse123!',
  })
  @IsString()
  @MinLength(8, { message: 'Le mot de passe doit contenir au moins 8 caractères' })
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).*$/, {
    message: 'Le mot de passe doit contenir au moins une minuscule, une majuscule et un chiffre',
  })
  password: string;

  @ApiProperty({
    description: 'Prénom',
    example: 'Jean',
  })
  @IsString()
  @IsNotEmpty()
  firstName: string;

  @ApiProperty({
    description: 'Nom de famille',
    example: 'Dupont',
  })
  @IsString()
  @IsNotEmpty()
  lastName: string;

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
  phone?: string;

  @ApiProperty({
    description: 'Acceptation des conditions d\'utilisation',
    example: true,
  })
  @IsBoolean()
  acceptTerms: boolean;

  @ApiProperty({
    description: 'Acceptation du marketing (optionnel)',
    example: false,
    required: false,
  })
  @IsOptional()
  @IsBoolean()
  acceptMarketing?: boolean = false;
}