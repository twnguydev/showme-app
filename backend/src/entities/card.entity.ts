// src/entities/card.entity.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  OneToMany,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity';
import { ContactExchange } from './contact-exchange.entity';
import { WalletPass } from './wallet-pass.entity';

export enum CardTheme {
  PURPLE = 'purple',
  BLUE = 'blue',
  TEAL = 'teal',
  GREEN = 'green',
  ROSE = 'rose',
  AMBER = 'amber',
}

@Entity('cards')
@Index(['userId', 'slug'], { unique: true })
@Index(['slug'])
export class Card {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 100 })
  slug: string;

  @Column({ length: 200 })
  title: string;

  @Column({ type: 'text', nullable: true })
  bio: string;

  @Column({ default: true })
  isPublic: boolean;

  @Column({ default: 0 })
  viewsCount: number;

  @Column({ nullable: true })
  walletPassUrl: string;

  @Column({ default: false })
  allowPayment: boolean;

  @Column({ default: true })
  nfcEnabled: boolean;

  @Column({ nullable: true })
  qrCodeUrl: string;

  @Column({ default: 0 })
  totalShared: number;

  @Column({ default: 0 })
  totalLeads: number;

  @Column({
    type: 'enum',
    enum: CardTheme,
    default: CardTheme.PURPLE,
  })
  theme: CardTheme;

  // === DONNÉES DE CONTACT (ex-Profile) ===
  
  @Column({ length: 255 })
  @Index()
  email: string; // Requis, peut être différent pour chaque carte

  @Column({ length: 20, nullable: true })
  phone: string;

  @Column({ length: 200, nullable: true })
  company: string; // Différent par carte/entreprise

  @Column({ length: 200, nullable: true })
  position: string; // Différent par carte/entreprise

  @Column({ length: 255, nullable: true })
  website: string;

  @Column({ length: 255, nullable: true })
  linkedinUrl: string;

  @Column({ length: 255, nullable: true })
  twitterUrl: string;

  @Column({ length: 255, nullable: true })
  instagramUrl: string;

  @Column({ length: 500, nullable: true })
  address: string;

  @Column({ length: 100, nullable: true })
  city: string;

  @Column({ length: 100, nullable: true })
  country: string;

  @Column({ type: 'json', nullable: true })
  avatar: {
    url: string;
    name: string;
    size: number;
    mimeType: string;
    uploadedAt: Date;
  };

  @Column({ type: 'json', nullable: true })
  companyLogo: {
    url: string;
    name: string;
    size: number;
    mimeType: string;
    uploadedAt: Date;
  };

  // === RELATIONS ===

  @Column()
  userId: number;

  @ManyToOne(() => User, user => user.cards, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @OneToMany(() => ContactExchange, exchange => exchange.card)
  contactExchanges: ContactExchange[];

  @OneToMany(() => WalletPass, walletPass => walletPass.card)
  walletPasses: WalletPass[];

  // === TIMESTAMPS ===

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // === GETTERS VIRTUELS ===

  get fullName(): string {
    if (this.user.firstName && this.user.lastName) {
      return `${this.user.firstName} ${this.user.lastName}`;
    } else if (this.user.firstName) {
      return this.user.firstName;
    } else if (this.user.lastName) {
      return this.user.lastName;
    }
    return this.email.split('@')[0]; // Fallback sur l'email
  }

  get isPro(): boolean {
    return this.user?.subscription?.isActive || false;
  }

  get publicUrl(): string {
    return `/card/${this.slug}`;
  }

  // === MÉTHODES ===

  incrementViews(): void {
    this.viewsCount++;
  }

  incrementShares(): void {
    this.totalShared++;
  }

  incrementLeads(): void {
    this.totalLeads++;
  }
}