import { defineConfig } from 'vite';
import { svelte } from '@sveltejs/vite-plugin-svelte';
import { resolve } from 'path';

export default defineConfig({
  plugins: [svelte()],
  resolve: {
    alias: {
      '$lib': resolve(__dirname, './src'),
      '@': resolve(__dirname, './src')
    },
    // Under vitest, resolve Svelte's browser build.
    //
    // Without this the client-side `mount()` the testing library calls comes
    // from Svelte's server entry, which throws lifecycle_function_unavailable —
    // "mount(...) is not available on the server". Everything else about the
    // setup can be right and every test still fails on its first render.
    conditions: process.env.VITEST ? ['browser'] : []
  },
  test: {
    // jsdom, not node. Every component test renders into a document, and the
    // default node environment has none — which is why all 38 of them failed
    // with "document is not defined" rather than with anything about the
    // components.
    environment: 'jsdom',
    setupFiles: ['./vitest-setup.ts'],
    include: ['src/**/*.{test,spec}.{js,ts}'],
    globals: false,
  },
  build: {
    lib: {
      entry: resolve(__dirname, 'src/index.ts'),
      formats: ['es'],
      fileName: 'index'
    },
    rollupOptions: {
      external: [
        'svelte', 'svelte/internal', 'svelte/store',
        'xlsx', 'jspdf', 'jspdf-autotable',
        '@samavāya/stores', '@samavāya/core', '@samavāya/proto',
      ]
    }
  }
});
