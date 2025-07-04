// src/modules/auth/dto/auth-response.dto.ts
import { ApiProperty } from '@nestjs/swagger';
import { User } from '../../../entities/user.entity';

export class AuthResponseDto {
  @ApiProperty({
    description: 'Token JWT d\'accès',
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  })
  jwt: string;

  @ApiProperty({
    description: 'Informations de l\'utilisateur',
  })
  user: Partial<User>;

  @ApiProperty({
    description: 'Date d\'expiration du token',
    example: '2024-12-31T23:59:59.000Z',
    required: false,
  })
  expiresAt?: Date;

  @ApiProperty({
    description: 'Token de rafraîchissement',
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
    required: false,
  })
  refreshToken?: string;
}