// src/entities/wallet-pass.entity.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
} from 'typeorm';
import { Card } from './card.entity';

export enum PassStatus {
  PENDING = 'pending',
  ACTIVE = 'active',
  REVOKED = 'revoked',
  ERROR = 'error',
}

@Entity('wallet_passes')
export class WalletPass {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  passTypeIdentifier: string;

  @Column({ unique: true })
  serialNumber: string;

  @Column({ nullable: true })
  passUrl?: string;

  @Column({ type: 'json', nullable: true })
  qrCodeMedia?: {
    url: string;
    name?: string;
    size?: number;
    mimeType?: string;
    uploadedAt?: Date;
  };

  @Column({ type: 'enum', enum: PassStatus })
  status: PassStatus;

  @Column({ nullable: true })
  generatedAt?: Date;

  @Column({ nullable: true })
  expiresAt?: Date;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Relations
  @ManyToOne(() => Card, (card) => card.walletPasses)
  card: Card;

  // Getters
  get isExpired(): boolean {
    return !!this.expiresAt && this.expiresAt < new Date();
  }

  get isValid(): boolean {
    return this.status === PassStatus.ACTIVE && !this.isExpired;
  }

  get canDownload(): boolean {
    return !!this.passUrl && this.isValid;
  }
}