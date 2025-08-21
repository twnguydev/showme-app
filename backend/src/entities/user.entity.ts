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
import { Profile } from './profile.entity';

export enum UserRole {
  USER = 'user',
  MODERATOR = 'moderator',
  ADMIN = 'admin',
}

@Entity('users')
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true })
  @Index('IDX_USER_USERNAME', { unique: true })
  username: string;

  @Column({ unique: true })
  @Index('IDX_USER_EMAIL', { unique: true })
  email: string;

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
  @Exclude()
  emailVerificationToken?: string;

  @Column({ nullable: true })
  @Exclude()
  passwordResetToken?: string;

  @Column({ nullable: true })
  @Exclude()
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

  @OneToOne(() => Profile, (profile) => profile.user)
  profile?: Profile;

  // Getters basés sur le profil ou l'email
  get displayName(): string {
    if (this.profile?.fullName) {
      return this.profile.fullName;
    }
    return this.email.split('@')[0];
  }

  get initials(): string {
    if (this.profile?.initials) {
      return this.profile.initials;
    }
    return this.email[0].toUpperCase();
  }

  get fullName(): string {
    return this.profile?.fullName || this.displayName;
  }
}