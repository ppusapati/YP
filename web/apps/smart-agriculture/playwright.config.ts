import { defineConfig, devices } from '@playwright/test';

/**
 * Playwright E2E configuration for the Smart Agriculture micro-frontend.
 *
 * Base URL defaults to the Vite dev server on port 5175 but can be
 * overridden via the PLAYWRIGHT_BASE_URL environment variable for CI
 * or staging environments.
 */

const isCI = !!process.env.CI;

export default defineConfig({
  testDir: './tests/e2e',
  testMatch: '**/*.spec.ts',

  /* Fail the build on CI if test.only was accidentally left in source. */
  forbidOnly: isCI,

  /* Retry flaky tests in CI only. */
  retries: isCI ? 2 : 0,

  /* Limit parallel workers in CI to avoid resource contention. */
  workers: isCI ? 1 : undefined,

  /* Reporter: rich HTML locally, machine-readable JSON in CI. */
  reporter: isCI ? [['json', { outputFile: 'test-results/results.json' }]] : [['html', { open: 'never' }]],

  /* Shared settings applied to every project. */
  use: {
    baseURL: process.env.PLAYWRIGHT_BASE_URL ?? 'http://localhost:5175',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },

  /* Browser matrix. CI runs Chromium only for speed; local runs all three. */
  projects: isCI
    ? [
        {
          name: 'chromium',
          use: {
            ...devices['Desktop Chrome'],
            storageState: 'tests/e2e/.auth/user.json',
          },
          dependencies: ['setup'],
        },
      ]
    : [
        {
          name: 'setup',
          testMatch: /auth\.setup\.ts/,
        },
        {
          name: 'chromium',
          use: {
            ...devices['Desktop Chrome'],
            storageState: 'tests/e2e/.auth/user.json',
          },
          dependencies: ['setup'],
        },
        {
          name: 'firefox',
          use: {
            ...devices['Desktop Firefox'],
            storageState: 'tests/e2e/.auth/user.json',
          },
          dependencies: ['setup'],
        },
        {
          name: 'webkit',
          use: {
            ...devices['Desktop Safari'],
            storageState: 'tests/e2e/.auth/user.json',
          },
          dependencies: ['setup'],
        },
      ],

  /* Auto-start the Vite dev server before tests when running locally. */
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:5175',
    reuseExistingServer: !isCI,
    timeout: 120_000,
  },
});
