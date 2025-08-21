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

  // Informations personnelles
  @Column({ nullable: true })
  firstName?: string;

  @Column({ nullable: true })
  lastName?: string;

  @Column({ nullable: true })
  email?: string;

  @Column({ nullable: true })
  phone?: string;

  // Informations professionnelles
  @Column({ nullable: true })
  company?: string;

  @Column({ nullable: true })
  position?: string;

  @Column({ type: 'text', nullable: true })
  bio?: string;

  // Liens web
  @Column({ nullable: true })
  website?: string;

  @Column({ nullable: true })
  linkedinUrl?: string;

  @Column({ nullable: true })
  twitterUrl?: string;

  @Column({ nullable: true })
  instagramUrl?: string;

  // Adresse
  @Column({ nullable: true })
  address?: string;

  @Column({ nullable: true })
  city?: string;

  @Column({ nullable: true })
  country?: string;

  // Médias
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

  // Paramètres
  @Column({ default: true })
  isPublic: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Relations
  @OneToOne(() => User, (user) => user.profile, { nullable: true })
  @JoinColumn()
  user?: User;

  // Getters
  get fullName(): string {
    const first = this.firstName || '';
    const last = this.lastName || '';
    return `${first} ${last}`.trim();
  }

  get initials(): string {
    const first = this.firstName?.[0] || '';
    const last = this.lastName?.[0] || '';
    const result = `${first}${last}`.toUpperCase();
    return result.length > 0 ? result : this.email?.[0]?.toUpperCase() || '?';
  }

  get displayName(): string {
    const name = this.fullName;
    return name.length > 0 ? name : this.email || 'Utilisateur';
  }

  get fullAddress(): string | null {
    const parts = [this.address, this.city, this.country].filter(part => part?.trim());
    return parts.length > 0 ? parts.join(', ') : null;
  }

  get hasContactInfo(): boolean {
    return !!(this.phone || this.email);
  }

  get hasSocialLinks(): boolean {
    return !!(this.linkedinUrl || this.twitterUrl || this.instagramUrl);
  }

  get hasCompanyInfo(): boolean {
    return !!(this.company || this.position);
  }
}