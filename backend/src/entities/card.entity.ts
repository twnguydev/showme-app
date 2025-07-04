// src/entities/card.entity.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  OneToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { User } from './user.entity';
import { Profile } from './profile.entity';
import { Subscription } from './subscription.entity';
import { ContactExchange } from './contact-exchange.entity';
import { WalletPass } from './wallet-pass.entity';

export enum CardTheme {
  PURPLE = 'purple',
  BLUE = 'blue',
  GREEN = 'green',
  RED = 'red',
  ORANGE = 'orange',
  DARK = 'dark',
  LIGHT = 'light',
}

@Entity('cards')
@Index(['slug'], { unique: true })
export class Card {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true })
  slug: string;

  @Column()
  title: string;

  @Column({ type: 'text', nullable: true })
  bio?: string;

  @Column({ default: true })
  isPublic: boolean;

  @Column({ default: 0 })
  viewsCount: number;

  @Column({ nullable: true })
  walletPassUrl?: string;

  @Column({ default: false })
  allowPayment: boolean;

  @Column({ default: false })
  nfcEnabled: boolean;

  @Column({ type: 'json', nullable: true })
  qrCodeUrl?: {
    url: string;
    name?: string;
    size?: number;
    mimeType?: string;
    uploadedAt?: Date;
  };

  @Column({ default: 0 })
  totalShared: number;

  @Column({ default: 0 })
  totalLeads: number;

  @Column({ type: 'enum', enum: CardTheme, default: CardTheme.PURPLE })
  theme: CardTheme;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Relations
  @ManyToOne(() => User, (user) => user.cards)
  user: User;

  @OneToOne(() => Profile)
  @JoinColumn()
  profile: Profile;

  @ManyToOne(() => Subscription)
  subscription?: Subscription;

  @OneToMany(() => ContactExchange, (exchange) => exchange.card)
  exchanges: ContactExchange[];

  @OneToMany(() => WalletPass, (pass) => pass.card)
  walletPasses: WalletPass[];

  // Getters
  get publicUrl(): string {
    return `https://showmeapp.com/card/${this.slug}`;
  }

  get shortUrl(): string {
    return `https://showme.app/u/${this.slug}`;
  }

  get isPro(): boolean {
    return this.subscription?.status === 'active';
  }
}