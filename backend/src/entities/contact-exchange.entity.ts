// src/entities/contact-exchange.entity.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
} from 'typeorm';
import { Card } from './card.entity';
import { Visitor } from './visitor.entity';

export enum ExchangeMethod {
  NFC = 'nfc',
  QR = 'qr',
  LINK = 'link',
  KIOSK = 'kiosk',
}

export enum DeviceType {
  IOS = 'ios',
  ANDROID = 'android',
  WEB = 'web',
  UNKNOWN = 'unknown',
}

@Entity('contact_exchanges')
export class ContactExchange {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'timestamp' })
  timestamp: Date;

  @Column({ type: 'json', nullable: true })
  geoLocation?: {
    lat: number;
    lng: number;
    city?: string;
    country?: string;
  };

  @Column({ type: 'text', nullable: true })
  userAgent?: string;

  @Column({ type: 'enum', enum: ExchangeMethod })
  referrer: ExchangeMethod;

  @Column({ default: false })
  openedOnWallet: boolean;

  @Column({ default: false })
  contactAdded: boolean;

  @Column({ nullable: true })
  emailSubmitted?: string;

  @Column({ type: 'enum', enum: DeviceType })
  deviceType: DeviceType;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Relations
  @ManyToOne(() => Card, (card) => card.exchanges)
  card: Card;

  @ManyToOne(() => Visitor, { nullable: true })
  visitor?: Visitor;

  // Getters
  get isQualifiedLead(): boolean {
    return !!this.emailSubmitted || this.contactAdded;
  }

  get locationName(): string {
    if (!this.geoLocation) return 'Lieu inconnu';
    return this.geoLocation.city || this.geoLocation.country || 'Lieu inconnu';
  }
}