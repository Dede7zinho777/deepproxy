const port = process.env.PORT ? parseInt(process.env.PORT) : 3000;

serve({
  fetch: app.fetch,
  port,
  hostname: '0.0.0.0'  // ← ADICIONE ESTA LINHA!
});
