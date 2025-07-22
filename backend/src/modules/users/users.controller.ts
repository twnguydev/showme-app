// src/modules/users/users.controller.ts
import {
  Controller,
  Get,
  Put,
  Delete,
  Body,
  Param,
  UseGuards,
  UseInterceptors,
  UploadedFile,
  ParseIntPipe,
  Query,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiConsumes } from '@nestjs/swagger';
import { BadRequestException } from '@nestjs/common/exceptions';

import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { User, UserRole } from '../../entities/user.entity';
import { UpdateUserDto, UpdateProfileDto, ChangePasswordDto } from './dto';
import { UpdateUserAndProfileDto } from './dto/update-user-profile.dto';

@ApiTags('users')
@Controller('users')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  @ApiOperation({ summary: 'Obtenir son profil utilisateur' })
  @ApiResponse({ status: 200, description: 'Profil utilisateur' })
  async getMyProfile(@CurrentUser() user: User) {
    return this.usersService.findById(user.id);
  }

  @Put('me')
  @ApiOperation({ summary: 'Mettre à jour son profil utilisateur' })
  @ApiResponse({ status: 200, description: 'Profil mis à jour' })
  async updateMyProfile(
    @CurrentUser() user: User,
    @Body() updateUserProfileDto: UpdateUserAndProfileDto,
  ) {
    return this.usersService.updateUserAndProfile(user.id, updateUserProfileDto);
  }

  @Get('me/profile')
  @ApiOperation({ summary: 'Obtenir son profil détaillé' })
  @ApiResponse({ status: 200, description: 'Profil détaillé' })
  async getMyDetailedProfile(@CurrentUser() user: User) {
    return this.usersService.getProfile(user.id);
  }

  @Put('me/profile')
  @UseInterceptors(FileInterceptor('avatar', {
    limits: {
      fileSize: 5 * 1024 * 1024, // 5MB max
    },
    fileFilter: (req, file, callback) => {
      if (!file.mimetype.match(/\/(jpg|jpeg|png|gif)$/)) {
        return callback(new Error('Only image files are allowed!'), false);
      }
      callback(null, true);
    },
  }))
  @ApiOperation({ summary: 'Mettre à jour son profil détaillé' })
  @ApiResponse({ status: 200, description: 'Profil détaillé mis à jour' })
  async updateMyDetailedProfile(
    @CurrentUser() user: User,
    @Body() updateProfileDto: UpdateProfileDto,
    @UploadedFile() avatar?: Express.Multer.File,
  ) {
    return this.usersService.updateProfile(user.id, updateProfileDto, avatar);
  }

  @Put('me/password')
  @ApiOperation({ summary: 'Changer son mot de passe' })
  @ApiResponse({ status: 200, description: 'Mot de passe modifié' })
  async changeMyPassword(
    @CurrentUser() user: User,
    @Body() changePasswordDto: ChangePasswordDto,
  ) {
    return this.usersService.changePassword(user.id, changePasswordDto);
  }

  @Put('me/avatar')
  @UseInterceptors(FileInterceptor('file', {
    limits: {
      fileSize: 5 * 1024 * 1024, // 5MB max
    },
    fileFilter: (req, file, callback) => {
      if (!file.mimetype.match(/\/(jpg|jpeg|png|gif|webp)$/)) {
        return callback(new Error('Only image files are allowed!'), false);
      }
      callback(null, true);
    },
  }))
  @ApiConsumes('multipart/form-data')
  @ApiOperation({ summary: 'Uploader une photo de profil' })
  @ApiResponse({ 
    status: 200, 
    description: 'Photo de profil uploadée',
    schema: {
      type: 'object',
      properties: {
        success: { type: 'boolean' },
        message: { type: 'string' },
        data: {
          type: 'object',
          properties: {
            avatar: {
              type: 'object',
              properties: {
                url: { type: 'string' },
                name: { type: 'string' },
                size: { type: 'number' },
                mimeType: { type: 'string' },
                uploadedAt: { type: 'string', format: 'date-time' }
              }
            }
          }
        }
      }
    }
  })
  async uploadMyAvatar(
    @CurrentUser() user: User,
    @UploadedFile() file: Express.Multer.File,
  ) {
    if (!file) {
      throw new BadRequestException('No file provided');
    }

    try {
      const updatedProfile = await this.usersService.updateProfile(user.id, undefined, file);
      
      return {
        success: true,
        message: 'Avatar uploaded successfully',
        data: {
          avatar: updatedProfile.avatar
        }
      };
    } catch (error) {
      throw new BadRequestException('Failed to upload avatar: ' + error.message);
    }
  }

  @Delete('me')
  @ApiOperation({ summary: 'Supprimer son compte' })
  @ApiResponse({ status: 200, description: 'Compte supprimé' })
  async deleteMyAccount(@CurrentUser() user: User) {
    return this.usersService.deleteAccount(user.id);
  }

  // Routes administrateur
  @Get()
  @Roles(UserRole.ADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Lister tous les utilisateurs (Admin)' })
  @ApiResponse({ status: 200, description: 'Liste des utilisateurs' })
  async getAllUsers(
    @Query('page', ParseIntPipe) page: number = 1,
    @Query('limit', ParseIntPipe) limit: number = 10,
  ) {
    return this.usersService.getUsers(page, limit);
  }

  @Get(':id')
  @Roles(UserRole.ADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Obtenir un utilisateur par ID (Admin)' })
  @ApiResponse({ status: 200, description: 'Utilisateur trouvé' })
  @ApiResponse({ status: 404, description: 'Utilisateur non trouvé' })
  async getUserById(@Param('id', ParseIntPipe) id: number) {
    return this.usersService.findById(id);
  }

  // @Put(':id')
  // @Roles(UserRole.ADMIN)
  // @UseGuards(RolesGuard)
  // @ApiOperation({ summary: 'Mettre à jour un utilisateur (Admin)' })
  // @ApiResponse({ status: 200, description: 'Utilisateur mis à jour' })
  // async updateUser(
  //   @Param('id', ParseIntPipe) id: number,
  //   @Body() updateUserDto: UpdateUserDto,
  // ) {
  //   return this.usersService.updateUser(id, updateUserDto);
  // }
}