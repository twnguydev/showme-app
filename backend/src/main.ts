// src/main.ts
import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import helmet from 'helmet';
import * as compression from 'compression';
import * as cookieParser from 'cookie-parser';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const configService = app.get(ConfigService);
  const logger = new Logger('Bootstrap');

  // Security middlewares
  app.use(helmet());
  app.use(compression());
  app.use(cookieParser());

  // CORS configuration
  app.enableCors({
    origin: [
      'http://localhost:3000',
      'http://localhost:8080',
      'https://app.showme.com',
      'https://admin.showme.com',
    ],
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  });

  // Global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  // API versioning
  app.setGlobalPrefix('api/v1');

  // Swagger documentation
  if (configService.get('NODE_ENV') !== 'production') {
    const config = new DocumentBuilder()
      .setTitle('ShowMe API')
      .setDescription('API pour l\'application ShowMe - Cartes de contact digitales')
      .setVersion('1.0')
      .addBearerAuth()
      .addTag('auth', 'Authentification et gestion des utilisateurs')
      .addTag('users', 'Gestion des profils utilisateur')
      .addTag('cards', 'Gestion des cartes de contact')
      .addTag('analytics', 'Statistiques et analytics')
      .addTag('subscriptions', 'Abonnements et paiements')
      .addTag('admin', 'Administration')
      .build();

    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api/docs', app, document);
    logger.log('Swagger documentation available at /api/docs');
  }

  const port = configService.get('PORT', 3000);
  await app.listen(port);
  
  logger.log(`Application running on port ${port}`);
  logger.log(`Environment: ${configService.get('NODE_ENV', 'development')}`);
}

bootstrap();
