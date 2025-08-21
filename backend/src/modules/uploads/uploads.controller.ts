// src/modules/uploads/uploads.controller.ts
import {
  Controller,
  Get,
  Param,
  Res,
  NotFoundException,
  Logger,
} from '@nestjs/common';
import { Response } from 'express';
import { UploadsService } from './uploads.service';
import { Public } from '../auth/decorators/public.decorator';

@Controller('uploads')
export class UploadsController {
  private readonly logger = new Logger(UploadsController.name);

  constructor(private readonly uploadsService: UploadsService) {}

  @Public()
  @Get(':filename')
  async serveFile(@Param('filename') filename: string, @Res() res: Response) {
    try {
      this.logger.log(`Demande de fichier: ${filename}`);
      
      const filePath = await this.uploadsService.getFilePath(filename);
      
      if (!filePath) {
        this.logger.warn(`Fichier non trouvé: ${filename}`);
        throw new NotFoundException(`Fichier non trouvé: ${filename}`);
      }

      // Définir les headers appropriés
      const mimeType = this.uploadsService.getMimeType(filename);
      res.setHeader('Content-Type', mimeType);
      res.setHeader('Cache-Control', 'public, max-age=31536000'); // Cache 1 an
      
      this.logger.log(`Fichier servi: ${filename} (${mimeType})`);
      return res.sendFile(filePath);
    } catch (error) {
      this.logger.error(`Erreur lors du service du fichier ${filename}:`, error);
      throw new NotFoundException(`Fichier non trouvé: ${filename}`);
    }
  }

  @Public()
  @Get('avatars/:filename')
  async serveAvatar(@Param('filename') filename: string, @Res() res: Response) {
    try {
      this.logger.log(`Demande d'avatar: ${filename}`);
      
      const filePath = await this.uploadsService.getAvatarPath(filename);
      
      if (!filePath) {
        this.logger.warn(`Avatar non trouvé: ${filename}`);
        throw new NotFoundException(`Avatar non trouvé: ${filename}`);
      }

      const mimeType = this.uploadsService.getMimeType(filename);
      res.setHeader('Content-Type', mimeType);
      res.setHeader('Cache-Control', 'public, max-age=31536000');
      
      this.logger.log(`Avatar servi: ${filename} (${mimeType})`);
      return res.sendFile(filePath);
    } catch (error) {
      this.logger.error(`Erreur lors du service de l'avatar ${filename}:`, error);
      throw new NotFoundException(`Avatar non trouvé: ${filename}`);
    }
  }

  @Public()
  @Get('cards/:filename')
  async serveCardImage(@Param('filename') filename: string, @Res() res: Response) {
    try {
      this.logger.log(`Demande d'image de carte: ${filename}`);
      
      const filePath = await this.uploadsService.getCardImagePath(filename);
      
      if (!filePath) {
        this.logger.warn(`Image de carte non trouvée: ${filename}`);
        throw new NotFoundException(`Image de carte non trouvée: ${filename}`);
      }

      const mimeType = this.uploadsService.getMimeType(filename);
      res.setHeader('Content-Type', mimeType);
      res.setHeader('Cache-Control', 'public, max-age=31536000');
      
      this.logger.log(`Image de carte servie: ${filename} (${mimeType})`);
      return res.sendFile(filePath);
    } catch (error) {
      this.logger.error(`Erreur lors du service de l'image de carte ${filename}:`, error);
      throw new NotFoundException(`Image de carte non trouvée: ${filename}`);
    }
  }
}