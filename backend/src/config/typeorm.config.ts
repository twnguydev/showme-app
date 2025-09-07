// src/config/typeorm.config.ts
import { DataSource } from 'typeorm';
import { config } from 'dotenv';

config();

import { User } from '../entities/user.entity';
import { Card } from '../entities/card.entity';
import { ContactExchange } from '../entities/contact-exchange.entity';
import { Visitor } from '../entities/visitor.entity';
import { WalletPass } from '../entities/wallet-pass.entity';
import { Subscription } from '../entities/subscription.entity';
import { Payment } from '../entities/payment.entity';
import { ContactStats } from '../entities/contact-stats.entity';

const AppDataSource = new DataSource({
  type: 'mysql',
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT, 10),
  username: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  entities: [
    User,
    Card,
    ContactExchange,
    Visitor,
    WalletPass,
    Subscription,
    Payment,
    ContactStats,
  ],
  migrations: ['src/database/migrations/*{.ts,.js}'],
  subscribers: ['src/database/subscribers/*{.ts,.js}'],
  synchronize: false,
  logging: process.env.NODE_ENV === 'development',
  timezone: 'Z',
  charset: 'utf8mb4',
  extra: {
    connectionLimit: 10
  },
});

export default AppDataSource;