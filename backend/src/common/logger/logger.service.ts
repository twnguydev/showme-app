// src/common/logger/logger.service.ts
import { Injectable, LoggerService } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as fs from 'fs';
import * as path from 'path';

@Injectable()
export class CustomLoggerService implements LoggerService {
  private readonly logDir: string;

  constructor(private configService: ConfigService) {
    this.logDir = './logs';
    this.ensureLogDirectory();
  }

  private ensureLogDirectory() {
    if (!fs.existsSync(this.logDir)) {
      fs.mkdirSync(this.logDir, { recursive: true });
    }
  }

  private writeToFile(level: string, message: any, context?: string) {
    const timestamp = new Date().toISOString();
    const logEntry = {
      timestamp,
      level: level.toUpperCase(),
      context,
      message: typeof message === 'object' ? JSON.stringify(message) : message,
      pid: process.pid,
    };

    const logLine = JSON.stringify(logEntry) + '\n';
    
    // Écrire dans le fichier du jour
    const today = new Date().toISOString().split('T')[0];
    const logFile = path.join(this.logDir, `app-${today}.log`);
    
    fs.appendFileSync(logFile, logLine);

    // Écrire dans le fichier d'erreur si c'est une erreur
    if (level === 'error') {
      const errorFile = path.join(this.logDir, `error-${today}.log`);
      fs.appendFileSync(errorFile, logLine);
    }
  }

  log(message: any, context?: string) {
    console.log(`[${new Date().toISOString()}] LOG [${context || 'Application'}] ${message}`);
    this.writeToFile('log', message, context);
  }

  error(message: any, trace?: string, context?: string) {
    console.error(`[${new Date().toISOString()}] ERROR [${context || 'Application'}] ${message}`);
    if (trace) {
      console.error(trace);
    }
    this.writeToFile('error', { message, trace }, context);
  }

  warn(message: any, context?: string) {
    console.warn(`[${new Date().toISOString()}] WARN [${context || 'Application'}] ${message}`);
    this.writeToFile('warn', message, context);
  }

  debug(message: any, context?: string) {
    if (this.configService.get('NODE_ENV') === 'development') {
      console.debug(`[${new Date().toISOString()}] DEBUG [${context || 'Application'}] ${message}`);
      this.writeToFile('debug', message, context);
    }
  }

  verbose(message: any, context?: string) {
    if (this.configService.get('NODE_ENV') === 'development') {
      console.log(`[${new Date().toISOString()}] VERBOSE [${context || 'Application'}] ${message}`);
      this.writeToFile('verbose', message, context);
    }
  }
}