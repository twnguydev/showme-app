// src/modules/cards/cards.module.ts
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { CardsController } from './cards.controller';
import { CardsService } from './cards.service';
import { Card } from '../../entities/card.entity';
import { Profile } from '../../entities/profile.entity';
import { User } from '../../entities/user.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([Card, Profile, User]),
  ],
  controllers: [CardsController],
  providers: [CardsService],
  exports: [CardsService],
})
export class CardsModule {}