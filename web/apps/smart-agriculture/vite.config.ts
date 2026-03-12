import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import UnoCSS from 'unocss/vite';

const unoCss = UnoCSS() as any;

export default defineConfig({
  plugins: [unoCss, sveltekit()],
  server: { port: 5175, strictPort: false, host: true },
  preview: { port: 4175, strictPort: false },
  optimizeDeps: {
    include: ['@samavāya/ui', '@samavāya/core', '@samavāya/stores', '@samavāya/agriculture'],
  },
  ssr: {
    noExternal: [/^@samavāya\//, /^@p9e\.in\//],
  },
  build: { target: 'esnext' },
});
