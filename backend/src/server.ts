import Fastify from 'fastify';
import websocket from '@fastify/websocket';
import corsPlugin from './plugins/cors.plugin.js';
import swaggerPlugin from './plugins/swagger.plugin.js';
import authPlugin from './plugins/auth.plugin.js';
import { AuthService } from './modules/auth/auth.service.js';
import { VedicAstronomyEngine } from './modules/astrology/ephemeris.engine.js';
import { AiAstrologyService } from './modules/ai/ai.service.js';
import { GooglePlayValidator } from './modules/iap/google-play.validator.js';
import { IapService } from './modules/iap/iap.service.js';
import { ConsultationSocketHub } from './modules/consultations/consultation.socket.js';

export async function buildServer() {
  const server = Fastify({
    bodyLimit: 30 * 1024 * 1024, // 30 MB payload limit for high-resolution palm photos
    logger: {
      level: 'info',
      transport: {
        target: 'pino-pretty',
        options: { colorize: true },
      },
    },
  });

  // Register core plugins
  await server.register(corsPlugin);
  await server.register(swaggerPlugin);
  await server.register(websocket);
  await server.register(authPlugin);

  // ── Root & Health Check ─────────────────────────────────────────────────────
  server.get('/', async () => ({
    service: 'AstroZen Backend API',
    version: '1.0.0',
    status: 'online',
    documentation: '/docs',
    timestamp: new Date().toISOString(),
  }));

  server.get('/health', async () => ({
    status: 'ok',
    service: 'AstroZen Backend API',
    timestamp: new Date().toISOString(),
  }));

  server.get('/api/v1/health', async () => ({
    status: 'healthy',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
  }));

  // ── Authentication & User Profiles ──────────────────────────────────────────
  server.post('/api/v1/auth/anonymous', async (req, reply) => {
    const body = (req.body as any) || {};
    const user = await AuthService.getOrCreateUser({
      displayName: body.displayName || 'Cosmic Seeker',
      zodiacSign: body.zodiacSign || 'Scorpio',
    });

    const token = server.jwt.sign({
      userId: user.id,
      role: 'user',
    });

    return reply.send({ success: true, token, user });
  });

  server.post('/api/v1/auth/login', async (req, reply) => {
    const body = (req.body as any) || {};
    const { identifier, displayName, zodiacSign } = body;
    if (!identifier) {
      return reply.status(400).send({ error: 'identifier (email or phone) is required' });
    }

    const user = await AuthService.getOrCreateUser({
      identifier,
      displayName,
      zodiacSign,
    });

    const token = server.jwt.sign({
      userId: user.id,
      email: user.email || undefined,
      phone: user.phone || undefined,
      role: 'user',
    });

    return reply.send({ success: true, token, user });
  });

  server.get('/api/v1/users/me', { preHandler: [server.authenticate] }, async (req, reply) => {
    const { userId } = req.user;
    const user = await AuthService.getUserProfile(userId);
    if (!user) {
      return reply.status(404).send({ error: 'User not found' });
    }
    return reply.send({ success: true, user });
  });

  server.put('/api/v1/users/me', { preHandler: [server.authenticate] }, async (req, reply) => {
    const { userId } = req.user;
    const body = (req.body as any) || {};
    const updated = await AuthService.updateUserProfile(userId, {
      displayName: body.displayName,
      zodiacSign: body.zodiacSign,
    });
    return reply.send({ success: true, user: updated });
  });

  // ── Astrology Endpoints ─────────────────────────────────────────────────────
  server.post('/api/v1/astrology/kundli', async (req, reply) => {
    const body = (req.body as any) || {};
    const { name, dob, tob, pob, lat, lon } = body;
    if (!dob) {
      return reply.status(400).send({ error: 'Date of birth (dob) is required (DD/MM/YYYY)' });
    }
    const result = VedicAstronomyEngine.calculateKundli(
      name || 'Cosmic Seeker',
      dob,
      tob || '12:00',
      pob || 'New Delhi, India',
      lat || 28.6139,
      lon || 77.2090
    );
    return reply.send({ success: true, data: result });
  });

  server.post('/api/v1/astrology/matching', async (req, reply) => {
    const body = (req.body as any) || {};
    const { boyDob, girlDob } = body;
    if (!boyDob || !girlDob) {
      return reply.status(400).send({ error: 'Both boyDob and girlDob are required (DD/MM/YYYY)' });
    }
    const result = VedicAstronomyEngine.calculateGunMilan(boyDob, girlDob);
    return reply.send({ success: true, data: result });
  });

  // ── Gemini AI Services ──────────────────────────────────────────────────────
  server.post('/api/v1/ai/palm-reading', async (req, reply) => {
    const body = (req.body as any) || {};
    const { name, dob, time, place, imageBase64 } = body;
    const reading = await AiAstrologyService.generateRoyalReading({
      name: name || 'Cosmic Seeker',
      dob: dob || '15/06/1995',
      time: time || '12:00 PM',
      place: place || 'New Delhi, India',
      imageBase64,
    });
    return reply.send({ success: true, data: reading });
  });

  server.post('/api/v1/ai/astrologer-chat', async (req, reply) => {
    const body = (req.body as any) || {};
    const { expertName, expertSpec, message, history } = body;
    if (!message) {
      return reply.status(400).send({ error: 'Message text is required' });
    }
    const answer = await AiAstrologyService.chatWithAstrologer({
      expertName: expertName || 'Acharya Suresh Kumar',
      expertSpec: expertSpec || 'Vedic Astrology & Palmistry',
      message,
      history: history || [],
    });
    return reply.send({ success: true, reply: answer });
  });

  // ── Google Play In-App Billing (IAP) ─────────────────────────────────────────
  server.post('/api/v1/iap/verify-purchase', async (req, reply) => {
    const body = (req.body as any) || {};
    const { userId, packageName, productId, purchaseToken, isSubscription } = body;
    if (!productId || !purchaseToken) {
      return reply.status(400).send({ error: 'productId and purchaseToken are required' });
    }

    const verification = await IapService.processAndRecordPurchase({
      userId: userId || 'anonymous',
      packageName: packageName || 'com.example.astrozen',
      productId,
      purchaseToken,
      isSubscription: isSubscription ?? false,
    });

    return reply.send({ success: verification.success, data: verification.data, user: verification.updatedUser });
  });

  // ── Realtime Consultations WebSocket ────────────────────────────────────────
  server.get('/ws/consultation', { websocket: true }, (socket, req) => {
    ConsultationSocketHub.handleConnection(socket, req);
  });

  return server;
}
