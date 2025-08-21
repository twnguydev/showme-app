// src/modules/uploads/uploads.service.ts
import { Injectable, Logger } from '@nestjs/common';
import { join } from 'path';
import { existsSync } from 'fs';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class UploadsService {
  private readonly logger = new Logger(UploadsService.name);
  private readonly uploadsPath: string;

  constructor(private configService: ConfigService) {
    // Chemin vers le dossier uploads
    this.uploadsPath = join(process.cwd(), 'uploads');
    this.logger.log(`Dossier uploads configuré: ${this.uploadsPath}`);
  }

  /**
   * Obtient le chemin complet d'un fichier
   */
  async getFilePath(filename: string): Promise<string | null> {
    try {
      const filePath = join(this.uploadsPath, filename);
      
      if (existsSync(filePath)) {
        return filePath;
      }
      
      return null;
    } catch (error) {
      this.logger.error(`Erreur lors de la recherche du fichier ${filename}:`, error);
      return null;
    }
  }

  /**
   * Obtient le chemin d'un avatar
   */
  async getAvatarPath(filename: string): Promise<string | null> {
    try {
      const avatarPath = join(this.uploadsPath, 'avatars', filename);
      
      if (existsSync(avatarPath)) {
        return avatarPath;
      }
      
      // Fallback: chercher dans le dossier principal uploads
      const fallbackPath = join(this.uploadsPath, filename);
      if (existsSync(fallbackPath)) {
        return fallbackPath;
      }
      
      return null;
    } catch (error) {
      this.logger.error(`Erreur lors de la recherche de l'avatar ${filename}:`, error);
      return null;
    }
  }

  /**
   * Obtient le chemin d'une image de carte
   */
  async getCardImagePath(filename: string): Promise<string | null> {
    try {
      const cardImagePath = join(this.uploadsPath, 'cards', filename);
      
      if (existsSync(cardImagePath)) {
        return cardImagePath;
      }
      
      // Fallback: chercher dans le dossier principal uploads
      const fallbackPath = join(this.uploadsPath, filename);
      if (existsSync(fallbackPath)) {
        return fallbackPath;
      }
      
      return null;
    } catch (error) {
      this.logger.error(`Erreur lors de la recherche de l'image de carte ${filename}:`, error);
      return null;
    }
  }

  /**
   * Détermine le type MIME d'un fichier basé sur son extension
   */
  getMimeType(filename: string): string {
    const extension = filename.toLowerCase().split('.').pop();
    
    const mimeTypes: Record<string, string> = {
      // Images
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'webp': 'image/webp',
      'svg': 'image/svg+xml',
      'bmp': 'image/bmp',
      'ico': 'image/x-icon',
      
      // Documents
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      
      // Autres
      'txt': 'text/plain',
      'csv': 'text/csv',
      'json': 'application/json',
      'xml': 'application/xml',
    };

    return mimeTypes[extension] || 'application/octet-stream';
  }

  /**
   * Vérifie si un fichier existe
   */
  async fileExists(filename: string): Promise<boolean> {
    const filePath = await this.getFilePath(filename);
    return filePath !== null;
  }

  /**
   * Obtient l'URL publique d'un fichier
   */
  getPublicUrl(filename: string): string {
    const baseUrl = this.configService.get<string>('app.url', 'http://localhost:3000');
    return `${baseUrl}/api/uploads/${filename}`;
  }

  /**
   * Obtient l'URL publique d'un avatar
   */
  getAvatarUrl(filename: string): string {
    const baseUrl = this.configService.get<string>('app.url', 'http://localhost:3000');
    return `${baseUrl}/api/uploads/avatars/${filename}`;
  }

  /**
   * Obtient l'URL publique d'une image de carte
   */
  getCardImageUrl(filename: string): string {
    const baseUrl = this.configService.get<string>('app.url', 'http://localhost:3000');
    return `${baseUrl}/api/uploads/cards/${filename}`;
  }
}