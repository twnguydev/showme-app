// backend/src/entities/user.entity.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  OneToMany,
  OneToOne,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';
import { Exclude } from 'class-transformer';
import { Card } from './card.entity';
import { Subscription } from './subscription.entity';
import { Payment } from './payment.entity';
import { ContactExchange } from './contact-exchange.entity';

export enum UserRole {
  USER = 'user',
  ADMIN = 'admin',
  MODERATOR = 'moderator',
}

@Entity('users')
@Index(['email'], { unique: true })
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 255 })
  email: string;

  @Column()
  @Exclude({ toPlainOnly: true })
  password: string;

  @Column({ length: 100, nullable: true })
  firstName: string;

  @Column({ length: 100, nullable: true })
  lastName: string;

  @Column({
    type: 'enum',
    enum: UserRole,
    default: UserRole.USER,
  })
  role: UserRole;

  @Column({ default: false })
  emailVerified: boolean;

  @Column({ nullable: true })
  emailVerificationToken: string;

  @Column({ nullable: true })
  passwordResetToken: string;

  @Column({ nullable: true })
  passwordResetExpires: Date;

  @Column({ nullable: true })
  refreshToken: string;

  @Column({ nullable: true })
  lastLoginAt: Date;

  @Column({ default: true })
  isActive: boolean;

  // === DONNÉES DE BASE UTILISATEUR ===
  // Ces données peuvent être utilisées comme valeurs par défaut pour nouvelles cartes
  
  @Column({ length: 20, nullable: true })
  defaultPhone: string;

  @Column({ length: 200, nullable: true })
  defaultCompany: string;

  @Column({ length: 200, nullable: true })
  defaultPosition: string;

  @Column({ type: 'json', nullable: true })
  defaultAvatar: {
    url: string;
    name: string;
    size: number;
    mimeType: string;
    uploadedAt: Date;
  };

  // === RELATIONS ===

  @OneToMany(() => Card, card => card.user, { cascade: true })
  cards: Card[];

  @OneToOne(() => Subscription, subscription => subscription.user)
  subscription: Subscription;

  @OneToMany(() => Payment, payment => payment.user)
  payments: Payment[];

  @OneToMany(() => ContactExchange, exchange => exchange.visitor)
  contactExchanges: ContactExchange[];

  // === TIMESTAMPS ===

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // === GETTERS VIRTUELS ===

  get fullName(): string {
    if (this.firstName && this.lastName) {
      return `${this.firstName} ${this.lastName}`;
    } else if (this.firstName) {
      return this.firstName;
    } else if (this.lastName) {
      return this.lastName;
    }
    return this.email.split('@')[0];
  }

  get isAdmin(): boolean {
    return this.role === UserRole.ADMIN;
  }

  get isModerator(): boolean {
    return this.role === UserRole.MODERATOR;
  }

  get isPro(): boolean {
    return this.subscription?.isActive || false;
  }

  // === MÉTHODES ===

  updateLastLogin(): void {
    this.lastLoginAt = new Date();
  }

  // Méthode pour créer une carte par défaut pour un nouvel utilisateur
  createDefaultCard(): Partial<Card> {
    return {
      slug: this.generateSlug(),
      title: `Carte de ${this.fullName}`,
      bio: 'Ma carte de contact digitale',
      isPublic: true,
      email: this.email,
      phone: this.defaultPhone,
      company: this.defaultCompany,
      position: this.defaultPosition,
      avatar: this.defaultAvatar,
    };
  }

  private generateSlug(): string {
    const base = this.fullName
      .toLowerCase()
      .replace(/[^a-z0-9\s-]/g, '')
      .replace(/\s+/g, '-')
      .replace(/-+/g, '-')
      .trim();
    
    return base || `user-${this.id}`;
  }
}