// src/config/app.config.ts
import { registerAs } from '@nestjs/config';

export const AppConfig = registerAs('app', () => ({
  port: parseInt(process.env.PORT, 10),
  environment: process.env.NODE_ENV,
  
  // JWT Configuration
  jwt: {
    secret: process.env.JWT_SECRET,
    refreshSecret: process.env.JWT_REFRESH_SECRET,
    expiresIn: process.env.JWT_EXPIRES_IN,
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN,
  },

  // Email Configuration
  email: {
    from: process.env.EMAIL_FROM,
    smtp: {
      host: process.env.SMTP_HOST,
      port: parseInt(process.env.SMTP_PORT, 10),
      secure: process.env.SMTP_SECURE === 'true',
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS,
      },
    },
  },

  // Storage Configuration
  storage: {
    provider: process.env.STORAGE_PROVIDER || 's3', // 's3' | 'local'
    local: {
      uploadPath: process.env.UPLOAD_PATH || './uploads',
      maxSize: parseInt(process.env.MAX_FILE_SIZE, 10) || 5 * 1024 * 1024, // 5MB
    },
    s3: {
      bucket: process.env.AWS_S3_BUCKET,
      region: process.env.AWS_REGION || 'eu-west-3',
      accessKeyId: process.env.AWS_ACCESS_KEY_ID,
      secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
      endpoint: process.env.S3_ENDPOINT, // Pour MinIO
    },
  },

  // Stripe Configuration
  stripe: {
    secretKey: process.env.STRIPE_SECRET_KEY,
    publishableKey: process.env.STRIPE_PUBLISHABLE_KEY,
    webhookSecret: process.env.STRIPE_WEBHOOK_SECRET,
  },

  // Application URLs
  urls: {
    frontend: process.env.FRONTEND_URL,
    admin: process.env.ADMIN_URL,
    api: process.env.API_URL,
    cardBase: process.env.CARD_BASE_URL,
  },

  // Features flags
  features: {
    registrationEnabled: process.env.REGISTRATION_ENABLED !== 'false',
    emailVerificationRequired: process.env.EMAIL_VERIFICATION_REQUIRED === 'true',
    analyticsEnabled: process.env.ANALYTICS_ENABLED !== 'false',
  },
}));