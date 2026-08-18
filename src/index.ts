import { serve } from '@hono/node-server';
import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { chatCompletions } from './routes/chat.js';
import * as dotenv from 'dotenv';
import { initPlaywright } from './services/playwright.js';

dotenv.config();

export const app = new Hono();

function modelEntry(id: string) {
  return {
    id,
    object: 'model',
    created: Math.floor(Date.now() / 1000),
    owned_by: 'deepseek',
    permission: [],
    root: id,
    parent: null,
    context_length: 128000,
    max_context_tokens: 128000,
    max_input_tokens: 128000,
    max_output_tokens: 8000,
  };
}

app.use('*', cors());

// Autenticação
app.use('*', async (c, next) => {
  const apiKey = process.env.API_KEY;
  if (apiKey) {
    const authHeader = c.req.header('Authorization');
    const xApiKey = c.req.header('X-API-Key');
    const providedKey = authHeader?.startsWith('Bearer ') ? authHeader.slice(7) : xApiKey;
    if (!providedKey || providedKey !== apiKey) {
      return c.json({ error: 'Unauthorized' }, 401);
    }
  }
  await next();
});

// Health check
app.get('/health', (c) => c.json({ status: 'ok' }));

// Chat completions
app.post('/v1/chat/completions', chatCompletions);

// List models
app.get('/v1/models', (c) => {
  return c.json({
    object: 'list',
    data: [
      modelEntry('deepseek-v4-flash'),
      modelEntry('deepseek-v4-flash-thinking'),
      modelEntry('deepseek-v4-pro'),
      modelEntry('deepseek-v4-pro-thinking')
    ]
  });
});

// Iniciar servidor
const port = process.env.PORT ? parseInt(process.env.PORT) : 3000;

initPlaywright().then(() => {
  console.log('✅ Playwright initialized.');
  console.log(`🚀 Server is running on port ${port}`);

  serve({
    fetch: app.fetch,
    port,
    hostname: '0.0.0.0'  // ← ESSENCIAL PARA O RAILWAY!
  });
}).catch((err) => {
  console.error('❌ Failed to initialize playwright:', err);
  process.exit(1);
});
