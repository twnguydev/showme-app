// src/modules/cards/cards.service.ts
import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Card, CardTheme } from '../../entities/card.entity';
import { Profile } from '../../entities/profile.entity';
import { User } from '../../entities/user.entity';
import { CreateCardDto, UpdateCardDto } from './dto';

@Injectable()
export class CardsService {
  constructor(
    @InjectRepository(Card)
    private readonly cardRepository: Repository<Card>,
    @InjectRepository(Profile)
    private readonly profileRepository: Repository<Profile>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  /**
   * Créer une carte par défaut pour un nouvel utilisateur
   */
  async createDefaultCard(user: User): Promise<Card> {
    // Récupérer l'utilisateur avec son profil
    const userWithProfile = await this.userRepository.findOne({
      where: { id: user.id },
      relations: ['profile'],
    });

    if (!userWithProfile) {
      throw new NotFoundException('Utilisateur non trouvé');
    }

    // Générer un slug unique basé sur le nom d'utilisateur
    const slug = await this.generateUniqueSlug(userWithProfile.username);

    // Utiliser le profil existant ou créer un profil par défaut
    let profile = userWithProfile.profile;
    
    if (!profile) {
      // Si pas de profil, créer un profil basique
      profile = this.profileRepository.create({
        email: userWithProfile.email,
        bio: 'Ma carte de contact digitale',
        isPublic: true,
        user: userWithProfile,
      });
      profile = await this.profileRepository.save(profile);
    }

    // Créer la carte par défaut
    const card = this.cardRepository.create({
      slug,
      title: userWithProfile.displayName ? `Carte de ${userWithProfile.displayName}` : 'Ma carte de contact',
      bio: 'Ma carte de contact digitale',
      theme: CardTheme.PURPLE, // Thème par défaut
      isPublic: true,
      user: userWithProfile,
      profile,
    });

    return this.cardRepository.save(card);
  }

  /**
   * Créer une nouvelle carte
   */
  async createCard(userId: number, createCardDto: CreateCardDto): Promise<Card> {
    const user = await this.userRepository.findOne({ 
      where: { id: userId },
      relations: ['subscription', 'profile'],
    });

    if (!user) {
      throw new NotFoundException('Utilisateur non trouvé');
    }

    // Vérifier le nombre de cartes (limite pour les utilisateurs gratuits)
    const userCardsCount = await this.cardRepository.count({ 
      where: { user: { id: userId } } 
    });

    if (userCardsCount >= 5 && !user.subscription?.isActive) {
      throw new ForbiddenException(
        'Limite de cartes atteinte. Passez à la version Pro pour créer plus de cartes.'
      );
    }

    // Générer un slug unique
    const slug = await this.generateUniqueSlug(
      createCardDto.slug || createCardDto.title
    );

    // Créer le profil pour la carte
    let profile = null;
    if (createCardDto.profile) {
      // Nouveau profil avec les données fournies
      profile = this.profileRepository.create({
        ...createCardDto.profile,
        isPublic: createCardDto.isPublic ?? true,
      });
    } else if (user.profile) {
      // Cloner le profil utilisateur existant pour la carte
      const { id, createdAt, updatedAt, user: userRef, ...profileData } = user.profile;
      profile = this.profileRepository.create({
        ...profileData,
        isPublic: createCardDto.isPublic ?? true,
      });
    } else {
      // Profil minimal si aucun profil utilisateur
      profile = this.profileRepository.create({
        email: user.email,
        bio: createCardDto.bio || 'Ma carte de contact',
        isPublic: createCardDto.isPublic ?? true,
      });
    }

    const savedProfile = await this.profileRepository.save(profile);

    // Créer la carte
    const card = this.cardRepository.create({
      title: createCardDto.title,
      slug,
      bio: createCardDto.bio,
      theme: createCardDto.theme || CardTheme.PURPLE,
      isPublic: createCardDto.isPublic ?? true,
      allowPayment: createCardDto.allowPayment ?? false,
      nfcEnabled: createCardDto.nfcEnabled ?? false,
      user,
      profile: savedProfile,
    });

    return this.cardRepository.save(card);
  }

  /**
   * Obtenir toutes les cartes d'un utilisateur
   */
  async getUserCards(userId: number): Promise<Card[]> {
    return this.cardRepository.find({
      where: { user: { id: userId } },
      relations: ['profile', 'subscription'],
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Obtenir une carte par son ID
   */
  async getCardById(cardId: number, userId?: number): Promise<Card> {
    const card = await this.cardRepository.findOne({
      where: { id: cardId },
      relations: ['profile', 'user', 'subscription'],
    });

    if (!card) {
      throw new NotFoundException('Carte non trouvée');
    }

    // Vérifier les permissions si un userId est fourni
    if (userId && card.user.id !== userId) {
      throw new ForbiddenException('Vous n\'avez pas accès à cette carte');
    }

    return card;
  }

  /**
   * Obtenir une carte publique par son slug
   */
  async getPublicCard(slug: string): Promise<Card> {
    const card = await this.cardRepository.findOne({
      where: { slug, isPublic: true },
      relations: ['profile', 'user', 'user.profile'],
    });

    if (!card) {
      throw new NotFoundException('Carte non trouvée ou privée');
    }

    // Incrémenter le compteur de vues
    await this.cardRepository.increment({ id: card.id }, 'viewsCount', 1);

    return card;
  }

  /**
   * Mettre à jour une carte
   */
  async updateCard(cardId: number, userId: number, updateCardDto: UpdateCardDto): Promise<Card> {
    const card = await this.getCardById(cardId, userId);

    // Mettre à jour le slug si le titre change
    if (updateCardDto.title && updateCardDto.title !== card.title) {
      const newSlug = await this.generateUniqueSlug(updateCardDto.title, card.id);
      updateCardDto.slug = newSlug;
    }

    // Mettre à jour le profil si fourni
    if (updateCardDto.profile && card.profile) {
      await this.profileRepository.update(card.profile.id, updateCardDto.profile);
    } else if (updateCardDto.profile && !card.profile) {
      // Créer un nouveau profil si la carte n'en avait pas
      const profile = this.profileRepository.create({
        ...updateCardDto.profile,
        isPublic: updateCardDto.isPublic ?? card.isPublic,
      });
      const savedProfile = await this.profileRepository.save(profile);
      
      // Associer le profil à la carte
      await this.cardRepository.update(card.id, { profile: savedProfile });
    }

    // Mettre à jour la carte (exclure le profil de l'update direct)
    const { profile, ...cardUpdateData } = updateCardDto;
    if (Object.keys(cardUpdateData).length > 0) {
      await this.cardRepository.update(cardId, cardUpdateData);
    }

    return this.getCardById(cardId, userId);
  }

  /**
   * Supprimer une carte
   */
  async deleteCard(cardId: number, userId: number): Promise<void> {
    const card = await this.getCardById(cardId, userId);

    // Vérifier que ce n'est pas la seule carte de l'utilisateur
    const userCardsCount = await this.cardRepository.count({ 
      where: { user: { id: userId } } 
    });

    if (userCardsCount <= 1) {
      throw new BadRequestException(
        'Vous devez avoir au moins une carte. Créez une nouvelle carte avant de supprimer celle-ci.'
      );
    }

    // Supprimer le profil associé s'il existe
    if (card.profile) {
      await this.profileRepository.delete(card.profile.id);
    }

    // Supprimer la carte
    await this.cardRepository.delete(cardId);
  }

  /**
   * Obtenir les statistiques d'une carte
   */
  async getCardStats(cardId: number, userId: number) {
    const card = await this.getCardById(cardId, userId);

    const conversionRate = card.viewsCount > 0 
      ? Math.round((card.totalLeads / card.viewsCount) * 100 * 100) / 100 
      : 0;

    return {
      cardId: card.id,
      slug: card.slug,
      title: card.title,
      views: card.viewsCount,
      shares: card.totalShared,
      leads: card.totalLeads,
      conversionRate,
      theme: card.theme,
      isPublic: card.isPublic,
      createdAt: card.createdAt,
      lastViewed: null, // TODO: Implémenter depuis ContactExchange
      profileComplete: this.isProfileComplete(card.profile),
    };
  }

  /**
   * Vérifier si le profil d'une carte est complet
   */
  private isProfileComplete(profile: Profile | null): boolean {
    if (!profile) return false;
    
    const requiredFields = ['firstName', 'lastName', 'email'];
    const optionalFields = ['company', 'position', 'phone', 'bio'];
    
    const hasRequired = requiredFields.every(field => profile[field]);
    const hasOptional = optionalFields.some(field => profile[field]);
    
    return hasRequired && hasOptional;
  }

  /**
   * Dupliquer une carte existante
   */
  async duplicateCard(cardId: number, userId: number): Promise<Card> {
    const originalCard = await this.getCardById(cardId, userId);
    
    // Créer un nouveau profil basé sur l'original
    let newProfile = null;
    if (originalCard.profile) {
      const { id, createdAt, updatedAt, user, ...profileData } = originalCard.profile;
      newProfile = this.profileRepository.create(profileData);
      newProfile = await this.profileRepository.save(newProfile);
    }
    
    // Générer un nouveau slug
    const newSlug = await this.generateUniqueSlug(`${originalCard.title}-copie`);
    
    // Créer la nouvelle carte
    const newCard = this.cardRepository.create({
      title: `${originalCard.title} (Copie)`,
      slug: newSlug,
      bio: originalCard.bio,
      theme: originalCard.theme,
      isPublic: originalCard.isPublic,
      allowPayment: originalCard.allowPayment,
      nfcEnabled: originalCard.nfcEnabled,
      user: originalCard.user,
      profile: newProfile,
    });
    
    return this.cardRepository.save(newCard);
  }

  /**
   * Méthodes privées utilitaires
   */
  private async generateUniqueSlug(baseSlug: string, excludeId?: number): Promise<string> {
    let slug = this.slugify(baseSlug);
    let counter = 1;

    while (true) {
      const whereCondition: any = { slug };
      if (excludeId) {
        // Utiliser Not pour exclure l'ID
        whereCondition.id = excludeId;
      }

      const existingCard = await this.cardRepository
        .createQueryBuilder('card')
        .where('card.slug = :slug', { slug })
        .andWhere(excludeId ? 'card.id != :excludeId' : '1=1', { excludeId })
        .getOne();

      if (!existingCard) {
        break;
      }

      slug = `${this.slugify(baseSlug)}-${counter}`;
      counter++;

      // Éviter les boucles infinies
      if (counter > 100) {
        slug = `${this.slugify(baseSlug)}-${Date.now()}`;
        break;
      }
    }

    return slug;
  }

  private slugify(text: string): string {
    return text
      .toLowerCase()
      .trim()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .replace(/[^a-z0-9 -]/g, '')
      .replace(/\s+/g, '-')
      .replace(/-+/g, '-')
      .replace(/^-|-$/g, '')
      .substring(0, 50);
  }
}