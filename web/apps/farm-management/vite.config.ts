import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import UnoCSS from 'unocss/vite';

const unoCss = UnoCSS() as any;

/**
 * Dev-server proxy to the api-gateway.
 *
 * The browser-side clients use relative URLs — `/api/<service>` for the
 * ConnectRPC clients and `/auth` for auth-service — so that a deployed build
 * talks to whatever origin served it, which is the gateway or a reverse proxy
 * in front of it. In `vite dev` the origin is this dev server, which serves
 * neither, so without these rules every backend call 404s against SvelteKit's
 * own router and reads as "the backend is down".
 *
 * `/api/<service>/...` strips the one-segment prefix, because the gateway
 * routes ConnectRPC by the fully-qualified service name at the root
 * (`/agriculture.farm.v1.FarmService/GetFarm`), while the client composes its
 * URL under the per-service base. `/auth` passes through unchanged — the
 * gateway already publishes it there.
 */
const GATEWAY = process.env.VITE_GATEWAY_URL ?? 'http://localhost:8080';

const proxy = {
  '/api': {
    target: GATEWAY,
    changeOrigin: true,
    rewrite: (path: string) => path.replace(/^\/api\/[^/]+/, ''),
  },
  '/auth': {
    target: GATEWAY,
    changeOrigin: true,
  },
};


export default defineConfig({
  plugins: [unoCss, sveltekit()],
  server: { port: 5174, strictPort: false, host: true, proxy },
  preview: { port: 4174, strictPort: false },
  optimizeDeps: {
    include: ['@samavāya/ui', '@samavāya/core', '@samavāya/stores', '@samavāya/agriculture'],
  },
  ssr: {
    noExternal: [/^@samavāya\//, /^@p9e\.in\//],
  },
  build: { target: 'esnext' },
});
