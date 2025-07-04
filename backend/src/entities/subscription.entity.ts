// src/entities/subscription.entity.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToOne,
  JoinColumn,
  OneToMany,
} from 'typeorm';
import { User } from './user.entity';
import { Payment } from './payment.entity';

export enum SubscriptionStatus {
  PENDING = 'pending',
  ACTIVE = 'active',
  TRIALING = 'trialing',
  CANCELED = 'canceled',
  EXPIRED = 'expired',
  PAUSED = 'paused',
}

export enum BillingPeriod {
  WEEKLY = 'weekly',
  MONTHLY = 'monthly',
  YEARLY = 'yearly',
  LIFETIME = 'lifetime',
}

@Entity('subscriptions')
export class Subscription {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  planId: string;

  @Column()
  planName: string;

  @Column({ type: 'enum', enum: SubscriptionStatus })
  status: SubscriptionStatus;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  price: number;

  @Column({ default: 'EUR' })
  currency: string;

  @Column({ type: 'enum', enum: BillingPeriod })
  billingPeriod: BillingPeriod;

  @Column({ type: 'date' })
  startDate: Date;

  @Column({ type: 'date', nullable: true })
  endDate?: Date;

  @Column({ type: 'date', nullable: true })
  trialEndDate?: Date;

  @Column({ nullable: true })
  canceledAt?: Date;

  @Column({ nullable: true })
  paymentMethod?: string;

  @Column({ nullable: true })
  externalSubscriptionId?: string;

  @Column({ type: 'json', nullable: true })
  features?: Record<string, any>;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Relations
  @OneToOne(() => User, (user) => user.subscription)
  @JoinColumn()
  user: User;

  @OneToMany(() => Payment, (payment) => payment.subscription)
  payments: Payment[];

  // Getters
  get isActive(): boolean {
    return this.status === SubscriptionStatus.ACTIVE;
  }

  get isTrialing(): boolean {
    return this.status === SubscriptionStatus.TRIALING;
  }

  get isExpired(): boolean {
    return this.status === SubscriptionStatus.EXPIRED;
  }

  get daysUntilExpiration(): number | null {
    if (!this.endDate) return null;
    const difference = this.endDate.getTime() - new Date().getTime();
    return Math.max(0, Math.floor(difference / (1000 * 60 * 60 * 24)));
  }
}