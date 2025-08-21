// src/modules/cards/cards.controller.ts
import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  UseGuards,
  ParseIntPipe,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';

import { CardsService } from './cards.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Public } from '../auth/decorators/public.decorator';
import { User } from '../../entities/user.entity';
import { CreateCardDto, UpdateCardDto } from './dto';

@ApiTags('cards')
@Controller('cards')
export class CardsController {
  constructor(private readonly cardsService: CardsService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Créer une nouvelle carte' })
  @ApiResponse({ status: 201, description: 'Carte créée avec succès' })
  async createCard(
    @CurrentUser() user: User,
    @Body() createCardDto: CreateCardDto,
  ) {
    return this.cardsService.createCard(user.id, createCardDto);
  }

  @Post(':id/duplicate')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Dupliquer une carte existante' })
  @ApiResponse({ status: 201, description: 'Carte dupliquée avec succès' })
  async duplicateCard(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser() user: User,
  ) {
    return this.cardsService.duplicateCard(id, user.id);
  }

  @Get()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtenir toutes mes cartes' })
  @ApiResponse({ status: 200, description: 'Liste des cartes' })
  async getMyCards(@CurrentUser() user: User) {
    return this.cardsService.getUserCards(user.id);
  }

  @Get('public/:slug')
  @Public()
  @ApiOperation({ summary: 'Voir une carte publique' })
  @ApiResponse({ status: 200, description: 'Carte publique' })
  @ApiResponse({ status: 404, description: 'Carte non trouvée' })
  async getPublicCard(@Param('slug') slug: string) {
    return this.cardsService.getPublicCard(slug);
  }

  @Get(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtenir une carte par ID' })
  @ApiResponse({ status: 200, description: 'Carte trouvée' })
  @ApiResponse({ status: 404, description: 'Carte non trouvée' })
  async getCard(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser() user: User,
  ) {
    return this.cardsService.getCardById(id, user.id);
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Mettre à jour une carte' })
  @ApiResponse({ status: 200, description: 'Carte mise à jour' })
  async updateCard(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser() user: User,
    @Body() updateCardDto: UpdateCardDto,
  ) {
    return this.cardsService.updateCard(id, user.id, updateCardDto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Supprimer une carte' })
  @ApiResponse({ status: 200, description: 'Carte supprimée' })
  async deleteCard(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser() user: User,
  ) {
    await this.cardsService.deleteCard(id, user.id);
    return { message: 'Carte supprimée avec succès' };
  }

  @Get(':id/stats')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtenir les statistiques d\'une carte' })
  @ApiResponse({ status: 200, description: 'Statistiques de la carte' })
  async getCardStats(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser() user: User,
  ) {
    return this.cardsService.getCardStats(id, user.id);
  }
}