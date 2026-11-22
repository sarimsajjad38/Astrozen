import dotenv from 'dotenv';
import { z } from 'zod';

dotenv.config();

const envSchema = z.object({
  PORT: z.coerce.number().default(4000),
  HOST: z.string().default('0.0.0.0'),
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  DATABASE_URL: z.string().default('postgresql://postgres:postgres@localhost:5432/astrozen?schema=public'),
  DIRECT_URL: z.string().optional(),
  GEMINI_API_KEY: z.string().optional().default(''),
  GOOGLE_PLAY_SERVICE_ACCOUNT_EMAIL: z.string().optional().default(''),
  GOOGLE_PLAY_PRIVATE_KEY: z.string().optional().default(''),
  GOOGLE_PLAY_PACKAGE_NAME: z.string().default('com.example.astrozen'),
  SUPABASE_JWT_SECRET: z.string().default('astrozen-jwt-development-secret-key-32chars'),
});

export const env = envSchema.parse(process.env);
