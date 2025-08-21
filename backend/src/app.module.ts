// src/app.module.ts
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ThrottlerModule } from '@nestjs/throttler';
import { CacheModule } from '@nestjs/cache-manager';
import { redisStore } from 'cache-manager-redis-yet';

import { DatabaseConfig } from './config/database.config';
import { AppConfig } from './config/app.config';
import { SeedsModule } from './database/seeds/seeds.module';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { HealthModule } from './modules/health/health.module';
import { CardsModule } from './modules/cards/cards.module';
import { UploadsModule } from './modules/uploads/uploads.module';
// import { AnalyticsModule } from './modules/analytics/analytics.module';
// import { SubscriptionsModule } from './modules/subscriptions/subscriptions.module';
// import { UploadsModule } from './modules/uploads/uploads.module';
// import { PaymentsModule } from './modules/payments/payments.module';
// import { AdminModule } from './modules/admin/admin.module';
// import { HealthModule } from './modules/health/health.module';

@Module({
  imports: [
    // Configuration globale
    ConfigModule.forRoot({
      isGlobal: true,
      load: [AppConfig],
      envFilePath: ['.env.local', '.env'],
    }),

    // Base de données TypeORM
    TypeOrmModule.forRootAsync({
      useClass: DatabaseConfig,
      inject: [DatabaseConfig],
    }),

    // Rate limiting
    ThrottlerModule.forRoot([
      {
        ttl: 60000, // 1 minute
        limit: 100, // 100 requests par minute
      },
    ]),

    // Cache Redis
    CacheModule.registerAsync({
      isGlobal: true,
      useFactory: async () => ({
        store: await redisStore({
          socket: {
            host: process.env.REDIS_HOST || 'localhost',
            port: parseInt(process.env.REDIS_PORT || '6379'),
          },
          ttl: 300, // 5 minutes par défaut
        }),
      }),
    }),

    // Modules fonctionnels
    AuthModule,
    UsersModule,
    SeedsModule,
    HealthModule,
    CardsModule,
    UploadsModule,
    // AnalyticsModule,
    // SubscriptionsModule,
    // UploadsModule,
    // PaymentsModule,
    // AdminModule
  ],
  providers: [DatabaseConfig],
})
export class AppModule {}