// src/database/seeds/seeds.module.ts
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from '@/entities/user.entity';
import { Profile } from '@/entities/profile.entity';
import { UserSeeder } from './user.seed';

@Module({
  imports: [TypeOrmModule.forFeature([User, Profile])],
  providers: [UserSeeder],
  exports: [UserSeeder],
})
export class SeedsModule {}