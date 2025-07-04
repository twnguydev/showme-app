// src/entities/contact-stats.entity.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
} from 'typeorm';
import { Card } from './card.entity';

@Entity('contact_stats')
export class ContactStats {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ default: 0 })
  totalExchanges: number;

  @Column({ default: 0 })
  weeklyExchanges: number;

  @Column({ default: 0 })
  monthlyExchanges: number;

  @Column({ default: 0 })
  totalViews: number;

  @Column({ default: 0 })
  uniqueContacts: number;

  @Column({ type: 'json', nullable: true })
  topLocations?: Array<{
    name: string;
    count: number;
    country?: string;
    latitude?: number;
    longitude?: number;
  }>;

  @Column({ type: 'json', nullable: true })
  methodBreakdown?: Record<string, number>;

  @Column({ nullable: true })
  lastExchange?: Date;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  averageExchangesPerDay?: number;

  @Column({ nullable: true })
  conversionRate?: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Relations
  @ManyToOne(() => Card)
  card: Card;

  // Getters
  get viewsToExchangesRatio(): number {
    if (this.totalExchanges === 0) return 0;
    return this.totalViews / this.totalExchanges;
  }

  get weeklyGrowthRate(): number {
    if (this.monthlyExchanges === 0 || this.weeklyExchanges === 0) return 0;
    const averageWeeklyFromMonth = this.monthlyExchanges / 4;
    return ((this.weeklyExchanges - averageWeeklyFromMonth) / averageWeeklyFromMonth) * 100;
  }
}