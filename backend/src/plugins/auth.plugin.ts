import fp from 'fastify-plugin';
import fastifyJwt from '@fastify/jwt';
import { FastifyReply, FastifyRequest } from 'fastify';
import { env } from '../config/env.js';

declare module 'fastify' {
  interface FastifyInstance {
    authenticate: (request: FastifyRequest, reply: FastifyReply) => Promise<void>;
  }
}

declare module '@fastify/jwt' {
  interface FastifyJWT {
    payload: {
      userId: string;
      email?: string;
      phone?: string;
      role?: string;
    };
    user: {
      userId: string;
      email?: string;
      phone?: string;
      role?: string;
    };
  }
}

export default fp(async (fastify) => {
  await fastify.register(fastifyJwt, {
    secret: env.SUPABASE_JWT_SECRET,
    sign: {
      expiresIn: '30d', // 30-day mobile session token
    },
  });

  fastify.decorate('authenticate', async (request: FastifyRequest, reply: FastifyReply) => {
    try {
      await request.jwtVerify();
    } catch (err) {
      reply.status(401).send({
        success: false,
        error: 'Unauthorized',
        message: 'Invalid or missing authentication token',
      });
    }
  });
});
