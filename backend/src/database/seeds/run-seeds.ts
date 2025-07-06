// src/database/seeds/run-seed.ts
import { NestFactory } from '@nestjs/core';
import { AppModule } from '../../app.module';
import { Logger } from '@nestjs/common';
import { UserSeeder } from './user.seed';

async function runSeeds() {
  const logger = new Logger('Seeder');
  
  try {
    logger.log('🌱 Démarrage du seeding...');
    
    const app = await NestFactory.createApplicationContext(AppModule);
    
    // Exécuter les seeders
    const userSeeder = app.get(UserSeeder);
    await userSeeder.seed();
    
    await app.close();
    
    logger.log('✅ Seeding terminé avec succès!');
    process.exit(0);
  } catch (error) {
    logger.error('❌ Erreur lors du seeding:', error);
    process.exit(1);
  }
}

runSeeds();