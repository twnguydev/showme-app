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

  @Get()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Récupérer les cartes de l\'utilisateur' })
  @ApiResponse({ status: 200, description: 'Cartes récupérées avec succès' })
  async getCards(@CurrentUser() user: User) {
    return this.cardsService.findAll(user.id);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Créer une nouvelle carte' })
  @ApiResponse({ status: 201, description: 'Carte créée avec succès' })
  async createCard(
    @CurrentUser() user: User,
    @Body() createCardDto: CreateCardDto,
  ) {
    return this.cardsService.create(createCardDto, user.id);
  }

  @Get('public/:slug')
  @Public()
  @ApiOperation({ summary: 'Voir une carte publique' })
  @ApiResponse({ status: 200, description: 'Carte publique' })
  @ApiResponse({ status: 404, description: 'Carte non trouvée' })
  async getPublicCard(@Param('slug') slug: string) {
    return this.cardsService.findBySlug(slug);
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
    return this.cardsService.findOne(id, user.id);
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
    return this.cardsService.update(id, updateCardDto, user.id);
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
    await this.cardsService.remove(id, user.id);
    return { message: 'Carte supprimée avec succès' };
  }
}