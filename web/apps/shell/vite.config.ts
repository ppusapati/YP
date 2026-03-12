import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import UnoCSS from 'unocss/vite';

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const unoCss = UnoCSS() as any;

export default defineConfig({
  plugins: [
    unoCss,
    sveltekit(),
  ],

  server: {
    port: 5173,
    strictPort: false,
    host: true,
    proxy: {
      '/farm-management': {
        target: 'http://localhost:5174',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/farm-management/, ''),
      },
      '/smart-agriculture': {
        target: 'http://localhost:5175',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/smart-agriculture/, ''),
      },
      '/crop-intelligence': {
        target: 'http://localhost:5176',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/crop-intelligence/, ''),
      },
      '/supply-chain': {
        target: 'http://localhost:5177',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/supply-chain/, ''),
      },
    },
  },

  preview: {
    port: 4173,
    strictPort: false,
  },

  optimizeDeps: {
    include: ['@samavāya/ui', '@samavāya/core', '@samavāya/stores'],
  },

  ssr: {
    noExternal: [/^@samavāya\//, /^@p9e\.in\//],
  },

  build: {
    target: 'esnext',
  },
});
