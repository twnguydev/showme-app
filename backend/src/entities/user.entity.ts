// src/entities/user.entity.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
  OneToOne,
  Index,
} from 'typeorm';
import { Exclude } from 'class-transformer';
import { Card } from './card.entity';
import { Subscription } from './subscription.entity';
import { ContactExchange } from './contact-exchange.entity';

export enum UserRole {
  USER = 'user',
  MODERATOR = 'moderator',
  ADMIN = 'admin',
}

@Entity('users')
@Index(['email'], { unique: true })
@Index(['username'], { unique: true })
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true })
  username: string;

  @Column({ unique: true })
  email: string;

  @Column({ nullable: true })
  firstName?: string;

  @Column({ nullable: true })
  lastName?: string;

  @Column({ nullable: true })
  company?: string;

  @Column({ nullable: true })
  position?: string;

  @Column({ nullable: true })
  phoneNumber?: string;

  @Column({ nullable: true })
  linkedinUrl?: string;

  @Column({ nullable: true })
  website?: string;

  @Column({ type: 'json', nullable: true })
  profilePicture?: {
    url: string;
    name?: string;
    size?: number;
    mimeType?: string;
    uploadedAt?: Date;
  };

  @Column({ select: false })
  @Exclude()
  passwordHash: string;

  @Column({ type: 'enum', enum: UserRole, default: UserRole.USER })
  role: UserRole;

  @Column({ default: true })
  isActive: boolean;

  @Column({ default: false })
  emailVerified: boolean;

  @Column({ nullable: true })
  emailVerificationToken?: string;

  @Column({ nullable: true })
  passwordResetToken?: string;

  @Column({ nullable: true })
  passwordResetExpires?: Date;

  @Column({ nullable: true })
  lastLoginAt?: Date;

  @Column({ nullable: true })
  timezone?: string;

  @Column({ nullable: true })
  language?: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Relations
  @OneToMany(() => Card, (card) => card.user)
  cards: Card[];

  @OneToOne(() => Subscription, (subscription) => subscription.user)
  subscription?: Subscription;

  // Getters
  get fullName(): string {
    const first = this.firstName || '';
    const last = this.lastName || '';
    return `${first} ${last}`.trim();
  }

  get displayName(): string {
    const name = this.fullName;
    return name.length > 0 ? name : this.email;
  }

  get initials(): string {
    const first = this.firstName?.[0] || '';
    const last = this.lastName?.[0] || '';
    const result = `${first}${last}`.toUpperCase();
    return result.length > 0 ? result : this.email[0].toUpperCase();
  }
}