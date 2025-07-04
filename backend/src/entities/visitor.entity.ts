// src/entities/visitor.entity.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm';
import { ContactExchange } from './contact-exchange.entity';

@Entity('visitors')
export class Visitor {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true })
  deviceHash: string;

  @Column({ nullable: true })
  email?: string;

  @Column({ nullable: true })
  name?: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Relations
  @OneToMany(() => ContactExchange, (exchange) => exchange.visitor)
  exchanges: ContactExchange[];

  // Getters
  get displayName(): string {
    return this.name || this.email || 'Visiteur anonyme';
  }

  get isIdentified(): boolean {
    return !!(this.email || this.name);
  }
}