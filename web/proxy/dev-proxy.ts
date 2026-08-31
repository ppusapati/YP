/**
 * Development Proxy Server
 *
 * Routes requests to the correct SvelteKit dev server based on URL path.
 * Run with: npx tsx proxy/dev-proxy.ts
 *
 * Start individual module apps first:
 *   pnpm --filter @samavāya/shell dev          # port 5173
 *   pnpm --filter @samavāya/identity dev       # port 5174
 *   pnpm --filter @samavāya/masters dev        # port 5175
 *   pnpm --filter @samavāya/finance dev        # port 5176
 *   ...etc
 *
 * Then run this proxy on port 3000:
 *   npx tsx proxy/dev-proxy.ts
 */

import http from 'node:http';
import httpProxy from 'http-proxy';

const PORT = Number(process.env.PROXY_PORT ?? 3000);

/**
 * Module routing table.
 * Maps URL path prefixes to SvelteKit dev server ports.
 * Comment out modules you're not working on.
 */
const ROUTES: Record<string, number> = {
  '/identity':      5174,
  '/masters':       5175,
  '/finance':       5176,
  '/sales':         5177,
  '/purchase':      5178,
  '/inventory':     5179,
  '/hr':            5180,
  '/manufacturing': 5181,
  '/projects':      5182,
  '/asset':         5183,
  '/fulfillment':   5184,
  '/insights':      5185,
};

/** Shell app handles everything else (dashboard, auth, settings) */
const SHELL_PORT = 5173;

const proxy = httpProxy.createProxyServer({ ws: true });

proxy.on('error', (err, _req, res) => {
  console.error('[proxy] Error:', err.message);
  if (res && 'writeHead' in res) {
    (res as http.ServerResponse).writeHead(502, { 'Content-Type': 'text/plain' });
    (res as http.ServerResponse).end(`Module app not running. Start it first.\n${err.message}`);
  }
});

function getTarget(url: string): string {
  for (const [prefix, port] of Object.entries(ROUTES)) {
    if (url.startsWith(prefix)) {
      return `http://localhost:${port}`;
    }
  }
  return `http://localhost:${SHELL_PORT}`;
}

const server = http.createServer((req, res) => {
  const target = getTarget(req.url ?? '/');
  proxy.web(req, res, { target, changeOrigin: true });
});

// WebSocket proxying (for HMR)
server.on('upgrade', (req, socket, head) => {
  const target = getTarget(req.url ?? '/');
  proxy.ws(req, socket, head, { target, changeOrigin: true });
});

server.listen(PORT, () => {
  console.log(`\n  Dev proxy running at http://localhost:${PORT}\n`);
  console.log('  Routes:');
  console.log(`    /              → http://localhost:${SHELL_PORT} (shell)`);
  for (const [prefix, port] of Object.entries(ROUTES)) {
    console.log(`    ${prefix.padEnd(18)} → http://localhost:${port}`);
  }
  console.log('');
});
