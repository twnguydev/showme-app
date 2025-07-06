// src/modules/health/health.controller.ts
import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import {
  HealthCheckService,
  HealthCheck,
  TypeOrmHealthIndicator,
  MemoryHealthIndicator,
  DiskHealthIndicator,
} from '@nestjs/terminus';
import { Public } from '../auth/decorators/public.decorator';

@ApiTags('health')
@Controller('health')
@Public()
export class HealthController {
  constructor(
    private health: HealthCheckService,
    private db: TypeOrmHealthIndicator,
    private memory: MemoryHealthIndicator,
    private disk: DiskHealthIndicator,
  ) {}

  @Get()
  @ApiOperation({ summary: 'Health check de l\'application' })
  @ApiResponse({ status: 200, description: 'Application en bonne santé' })
  @ApiResponse({ status: 503, description: 'Service indisponible' })
  @HealthCheck()
  check() {
    return this.health.check([
      // Vérifier la base de données
      () => this.db.pingCheck('database'),
      
      // Vérifier la mémoire (moins de 300MB utilisés)
      () => this.memory.checkHeap('memory_heap', 300 * 1024 * 1024),
      
      // Vérifier l'espace disque (moins de 90% utilisé)
      () => this.disk.checkStorage('storage', { 
        path: '/', 
        thresholdPercent: 0.9 
      }),
    ]);
  }

  @Get('simple')
  @ApiOperation({ summary: 'Health check simple' })
  simple() {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      memory: process.memoryUsage(),
      env: process.env.NODE_ENV,
    };
  }
}