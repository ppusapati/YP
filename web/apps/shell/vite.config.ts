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
