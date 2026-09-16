import { defineConfig, devices } from '@playwright/test';

/**
 * Visual regression against the component gallery.
 *
 * Separate from apps/smart-agriculture's E2E config on purpose. Those tests
 * need a live backend and a logged-in session; these need a static page and
 * nothing else, which is what makes them runnable on every pull request
 * rather than only where a stack happens to be up.
 *
 * Chromium only, and only headless. A screenshot baseline is tied to the
 * engine that rendered it — font hinting, sub-pixel antialiasing and scrollbar
 * width all differ between browsers and between headed and headless — so a
 * second browser is not extra coverage, it is a second set of baselines that
 * fail for reasons that have nothing to do with the components.
 */
const isCI = !!process.env.CI;

export default defineConfig({
  testDir: './tests/visual',
  testMatch: '**/*.spec.ts',

  forbidOnly: isCI,

  // No retries. A visual test that passes on the second attempt is a flaky
  // test, and retrying hides exactly the thing worth knowing about.
  retries: 0,

  // Serial. Parallel workers share the machine's CPU and GPU, and a loaded
  // renderer produces subtly different antialiasing — which lands as a
  // one-pixel diff in an unrelated component.
  workers: 1,

  reporter: isCI
    ? [['list'], ['html', { open: 'never', outputFolder: 'playwright-report-visual' }]]
    : [['html', { open: 'never', outputFolder: 'playwright-report-visual' }]],

  snapshotPathTemplate: '{testDir}/__screenshots__/{arg}{ext}',

  use: {
    baseURL: 'http://localhost:5199',
    // A fixed viewport and device scale factor. Both feed into layout, and a
    // baseline captured at a different one differs everywhere at once.
    viewport: { width: 1280, height: 900 },
    deviceScaleFactor: 1,
    // Motion is already frozen by the gallery's ?freeze flag; this is the
    // belt to that pair of braces, and it also stops smooth scrolling.
    reducedMotion: 'reduce',
    trace: 'retain-on-failure',
  },

  expect: {
    toHaveScreenshot: {
      // Not zero.
      //
      // Identical input renders identically on the same machine, but not
      // across machines: a GitHub runner and a developer's laptop differ in
      // font rasterisation by a handful of subpixels on curves. A threshold of
      // zero means every baseline has to be regenerated on CI and can never be
      // checked locally, which is how a visual suite ends up disabled.
      //
      // maxDiffPixelRatio rather than maxDiffPixels because the stories differ
      // in size by two orders of magnitude — 40 pixels is nothing on a card
      // and is the whole component on a badge dot.
      maxDiffPixelRatio: 0.01,
      threshold: 0.2,
      animations: 'disabled',
      scale: 'css',
    },
  },

  projects: [
    {
      name: 'chromium',
      use: {
        ...devices['Desktop Chrome'],
        // An explicit binary when the environment provides one.
        //
        // Playwright pins a browser build per release, and a sandbox that
        // ships its own Chromium will not have the exact build this version
        // wants — it fails with "Executable doesn't exist" and the usual
        // advice, `playwright install`, is a download the sandbox is there to
        // avoid. PLAYWRIGHT_CHROMIUM_EXECUTABLE lets the runner point at what
        // it has; unset, Playwright uses its own, which is what CI does.
        launchOptions: process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE
          ? { executablePath: process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE }
          : {},
      },
    },
  ],

  webServer: {
    // `preview`, not `dev`. The dev server injects HMR client code and serves
    // unminified CSS in a different order, so a baseline taken against it
    // would not match what the build produces.
    command: 'pnpm gallery:build && pnpm gallery:preview',
    url: 'http://localhost:5199',
    reuseExistingServer: !isCI,
    timeout: 180_000,
    stdout: 'ignore',
    stderr: 'pipe',
  },
});
