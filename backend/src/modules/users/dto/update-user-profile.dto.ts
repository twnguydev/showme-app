
// src/modules/users/dto/update-user-and-profile.dto.ts
import { IsOptional, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { UpdateUserDto } from './update-user.dto';
import { UpdateProfileDto } from './update-profile.dto';

export class UpdateUserAndProfileDto {
  @ApiPropertyOptional({
    description: 'Données utilisateur à mettre à jour',
    type: UpdateUserDto,
  })
  @IsOptional()
  @ValidateNested()
  @Type(() => UpdateUserDto)
  user?: UpdateUserDto;

  @ApiPropertyOptional({
    description: 'Données de profil à mettre à jour',
    type: UpdateProfileDto,
  })
  @IsOptional()
  @ValidateNested()
  @Type(() => UpdateProfileDto)
  profile?: UpdateProfileDto;
}