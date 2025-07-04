// src/entities/profile.entity.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToOne,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity';

@Entity('profiles')
export class Profile {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ nullable: true })
  firstName?: string;

  @Column({ nullable: true })
  lastName?: string;

  @Column({ nullable: true })
  email?: string;

  @Column({ nullable: true })
  phone?: string;

  @Column({ nullable: true })
  company?: string;

  @Column({ nullable: true })
  position?: string;

  @Column({ type: 'text', nullable: true })
  bio?: string;

  @Column({ nullable: true })
  website?: string;

  @Column({ nullable: true })
  linkedinUrl?: string;

  @Column({ nullable: true })
  twitterUrl?: string;

  @Column({ nullable: true })
  instagramUrl?: string;

  @Column({ nullable: true })
  address?: string;

  @Column({ nullable: true })
  city?: string;

  @Column({ nullable: true })
  country?: string;

  @Column({ type: 'json', nullable: true })
  avatar?: {
    url: string;
    name?: string;
    size?: number;
    mimeType?: string;
    uploadedAt?: Date;
  };

  @Column({ type: 'json', nullable: true })
  companyLogo?: {
    url: string;
    name?: string;
    size?: number;
    mimeType?: string;
    uploadedAt?: Date;
  };

  @Column({ default: true })
  isPublic: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Relations
  @OneToOne(() => User)
  @JoinColumn()
  user: User;

  // Getters
  get fullName(): string {
    const first = this.firstName || '';
    const last = this.lastName || '';
    return `${first} ${last}`.trim();
  }

  get displayName(): string {
    const name = this.fullName;
    return name.length > 0 ? name : this.email || 'Utilisateur';
  }
}