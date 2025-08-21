// backend/src/modules/cards/cards.service.ts
import {
  Injectable,
  NotFoundException,
  ConflictException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Card } from '../../entities/card.entity';
import { User } from '../../entities/user.entity';
import { CreateCardDto } from './dto/create-card.dto';
import { UpdateCardDto } from './dto/update-card.dto';

@Injectable()
export class CardsService {
  constructor(
    @InjectRepository(Card)
    private readonly cardRepository: Repository<Card>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  async create(createCardDto: CreateCardDto, userId: number): Promise<Card> {
    // Vérifier que l'utilisateur existe
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('Utilisateur non trouvé');
    }

    // Vérifier l'unicité du slug pour cet utilisateur
    const existingCard = await this.cardRepository.findOne({
      where: { slug: createCardDto.slug, userId },
    });

    if (existingCard) {
      throw new ConflictException('Une carte avec ce slug existe déjà');
    }

    // Créer la carte avec les données utilisateur par défaut si non fournies
    const card = this.cardRepository.create({
      ...createCardDto,
      userId,
      // Utiliser les données par défaut de l'utilisateur si non fournies
      firstName: createCardDto.firstName || user.firstName,
      lastName: createCardDto.lastName || user.lastName,
      phone: createCardDto.phone || user.defaultPhone,
      company: createCardDto.company || user.defaultCompany,
      position: createCardDto.position || user.defaultPosition,
      avatar: user.defaultAvatar, // Avatar par défaut de l'utilisateur
    });

    const savedCard = await this.cardRepository.save(card);

    // Générer le QR code après création
    await this.generateQRCode(savedCard);

    return this.findOne(savedCard.id, userId);
  }

  async findAll(userId: number): Promise<Card[]> {
    return this.cardRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: number, userId?: number): Promise<Card> {
    const whereCondition: any = { id };
    if (userId) {
      whereCondition.userId = userId;
    }

    const card = await this.cardRepository.findOne({
      where: whereCondition,
      relations: ['user'],
    });

    if (!card) {
      throw new NotFoundException('Carte non trouvée');
    }

    // Si pas de userId fourni, vérifier que la carte est publique
    if (!userId && !card.isPublic) {
      throw new ForbiddenException('Cette carte n\'est pas publique');
    }

    return card;
  }

  async findBySlug(slug: string, userId?: number): Promise<Card> {
    const whereCondition: any = { slug };
    if (userId) {
      whereCondition.userId = userId;
    }

    const card = await this.cardRepository.findOne({
      where: whereCondition,
      relations: ['user'],
    });

    if (!card) {
      throw new NotFoundException('Carte non trouvée');
    }

    // Si pas de userId fourni, vérifier que la carte est publique
    if (!userId && !card.isPublic) {
      throw new ForbiddenException('Cette carte n\'est pas publique');
    }

    // Incrémenter les vues si accès public
    if (!userId) {
      card.incrementViews();
      await this.cardRepository.save(card);
    }

    return card;
  }

  async update(id: number, updateCardDto: UpdateCardDto, userId: number): Promise<Card> {
    const card = await this.findOne(id, userId);

    // Mise à jour des données
    Object.assign(card, updateCardDto);
    
    const updatedCard = await this.cardRepository.save(card);

    // Régénérer le QR code si nécessaire
    if (updateCardDto.isPublic !== undefined) {
      await this.generateQRCode(updatedCard);
    }

    return updatedCard;
  }

  async remove(id: number, userId: number): Promise<void> {
    const card = await this.findOne(id, userId);
    await this.cardRepository.remove(card);
  }

  async togglePublic(id: number, userId: number): Promise<Card> {
    const card = await this.findOne(id, userId);
    card.isPublic = !card.isPublic;
    
    const updatedCard = await this.cardRepository.save(card);
    
    // Régénérer le QR code
    await this.generateQRCode(updatedCard);
    
    return updatedCard;
  }

  async uploadImage(
    cardId: number,
    userId: number,
    file: Express.Multer.File,
    imageType: 'avatar' | 'companyLogo',
  ): Promise<Card> {
    const card = await this.findOne(cardId, userId);

    if (!file) {
      throw new BadRequestException('Aucun fichier fourni');
    }

    // Construire l'URL du fichier
    const fileUrl = `/api/uploads/${file.filename}`;
    
    const imageData = {
      url: fileUrl,
      name: file.originalname,
      size: file.size,
      mimeType: file.mimetype,
      uploadedAt: new Date(),
    };

    // Mettre à jour le bon champ selon le type
    if (imageType === 'avatar') {
      card.avatar = imageData;
    } else if (imageType === 'companyLogo') {
      card.companyLogo = imageData;
    }

    return this.cardRepository.save(card);
  }

  async getPublicCards(limit: number = 20, offset: number = 0): Promise<Card[]> {
    return this.cardRepository.find({
      where: { isPublic: true },
      order: { createdAt: 'DESC' },
      take: limit,
      skip: offset,
      relations: ['user'],
    });
  }

  async getUserStats(userId: number): Promise<any> {
    const cards = await this.findAll(userId);
    
    const totalViews = cards.reduce((sum, card) => sum + card.viewsCount, 0);
    const totalShares = cards.reduce((sum, card) => sum + card.totalShared, 0);
    const totalLeads = cards.reduce((sum, card) => sum + card.totalLeads, 0);
    const publicCards = cards.filter(card => card.isPublic).length;

    return {
      totalCards: cards.length,
      publicCards,
      totalViews,
      totalShares,
      totalLeads,
    };
  }

  private async generateQRCode(card: Card): Promise<void> {
    // Générer l'URL du QR code (vous pouvez utiliser une librairie comme qrcode)
    const baseUrl = process.env.APP_URL || 'http://localhost:3000';
    const cardUrl = `${baseUrl}/card/${card.slug}`;
    
    // URL de génération de QR code externe (temporaire)
    card.qrCodeUrl = `https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${encodeURIComponent(cardUrl)}`;
    
    await this.cardRepository.save(card);
  }

  // Méthode pour créer la carte par défaut d'un utilisateur
  async createDefaultCard(user: User): Promise<Card> {
    const defaultCardData = user.createDefaultCard();
    
    const createDto: CreateCardDto = {
      slug: defaultCardData.slug!,
      title: defaultCardData.title!,
      bio: defaultCardData.bio,
      email: defaultCardData.email!,
      firstName: defaultCardData.firstName,
      lastName: defaultCardData.lastName,
      phone: defaultCardData.phone,
      company: defaultCardData.company,
      position: defaultCardData.position,
    };

    return this.create(createDto, user.id);
  }
}