import { buildServer } from './server.js';
import { env } from './config/env.js';

async function main() {
  const server = await buildServer();

  try {
    const address = await server.listen({
      port: env.PORT,
      host: env.HOST,
    });
    server.log.info(`✦ AstroZen Backend running at: ${address}`);
    server.log.info(`✦ Interactive Swagger Documentation available at: ${address}/docs`);
  } catch (err) {
    server.log.error(err);
    process.exit(1);
  }
}

main();
