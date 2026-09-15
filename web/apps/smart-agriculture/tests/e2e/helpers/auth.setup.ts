import { test as setup, expect } from '@playwright/test';
import path from 'node:path';

/**
 * Global auth setup: logs in as the test user and persists the browser
 * storage state so all subsequent test projects can skip the login flow.
 *
 * Credentials are sourced from environment variables:
 *   TEST_USER_EMAIL    (default: test@samavaya.example)
 *   TEST_USER_PASSWORD (default: Test1234!)
 */

const authFile = path.join(__dirname, '..', '.auth', 'user.json');

setup('authenticate as test user', async ({ page }) => {
  const email = process.env.TEST_USER_EMAIL ?? 'test@samavaya.example';
  const password = process.env.TEST_USER_PASSWORD ?? 'Test1234!';

  // Navigate to the login page.
  await page.goto('/login');

  // Fill in credentials.
  await page.getByLabel(/email/i).fill(email);
  await page.getByLabel(/password/i).fill(password);

  // Submit the form.
  await page.getByRole('button', { name: /sign in|log in/i }).click();

  // Wait until we land on a page that confirms the session is active.
  // The root layout renders the ErpShell which implies a logged-in state.
  await expect(page.locator('[data-sveltekit-preload-data]')).toBeVisible({ timeout: 15_000 });

  // Persist storage state (cookies + localStorage) for dependent projects.
  await page.context().storageState({ path: authFile });
});
