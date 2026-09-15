import { defineConfig } from 'vitest/config';
import { sveltekit } from '@sveltejs/kit/vite';

/**
 * Vitest configuration for the Smart Agriculture unit / component tests.
 *
 * Uses the SvelteKit Vite plugin so path aliases ($lib, $app, etc.) resolve
 * the same way they do at build time.
 */
export default defineConfig({
  plugins: [sveltekit()],

  test: {
    /* Run in a browser-like environment so Svelte components can mount. */
    environment: 'jsdom',

    /* Allow `describe`, `it`, `expect` etc. without explicit imports. */
    globals: true,

    /* Only pick up *.test.ts files under src/ and tests/unit/. */
    include: ['src/**/*.test.ts', 'tests/unit/**/*.test.ts'],

    /* Shared setup: mocks, storage cleanup, etc. */
    setupFiles: ['tests/unit/setup.ts'],

    /* v8 coverage (fast, no native add-ons). */
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      reportsDirectory: 'coverage',
      include: ['src/**/*.ts', 'src/**/*.svelte'],
      exclude: [
        'src/**/*.d.ts',
        'src/**/*.config.*',
        'src/**/index.ts',
        'src/routes/**/+*.ts',
        'node_modules/',
      ],
    },
  },
});
