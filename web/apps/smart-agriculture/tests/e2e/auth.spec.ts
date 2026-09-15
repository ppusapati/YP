import { test, expect } from '@playwright/test';

/**
 * E2E tests for authentication flows.
 *
 * The default storage state (from auth.setup.ts) gives us an authenticated
 * session. Tests that need an unauthenticated browser override it with an
 * empty storageState.
 */

test.describe('Authentication', () => {
  // -------------------------------------------------------------------------
  // Login
  // -------------------------------------------------------------------------

  test('login with valid credentials navigates to the dashboard', async ({ browser }) => {
    // Use a fresh context with no stored auth.
    const context = await browser.newContext({ storageState: { cookies: [], origins: [] } });
    const page = await context.newPage();

    await page.goto('/login');

    await page.getByLabel(/email/i).fill(process.env.TEST_USER_EMAIL ?? 'test@samavaya.example');
    await page.getByLabel(/password/i).fill(process.env.TEST_USER_PASSWORD ?? 'Test1234!');
    await page.getByRole('button', { name: /sign in|log in/i }).click();

    // After a successful login, we should land on the main dashboard.
    await expect(page).toHaveURL(/\/(dashboard)?$/);
    await expect(page.getByRole('heading', { name: /smart agriculture/i })).toBeVisible();

    await context.close();
  });

  test('login with invalid credentials shows an error message', async ({ browser }) => {
    const context = await browser.newContext({ storageState: { cookies: [], origins: [] } });
    const page = await context.newPage();

    await page.goto('/login');

    await page.getByLabel(/email/i).fill('wrong@example.com');
    await page.getByLabel(/password/i).fill('WrongPassword!');
    await page.getByRole('button', { name: /sign in|log in/i }).click();

    // An error alert / message should appear.
    await expect(
      page.getByText(/invalid|incorrect|failed|unauthorized/i),
    ).toBeVisible({ timeout: 10_000 });

    // Should remain on the login page.
    await expect(page).toHaveURL(/\/login/);

    await context.close();
  });

  // -------------------------------------------------------------------------
  // Logout
  // -------------------------------------------------------------------------

  test('logout clears the session and redirects to login', async ({ page }) => {
    // Start on the authenticated home page.
    await page.goto('/');
    await expect(page.getByRole('heading', { name: /smart agriculture/i })).toBeVisible();

    // Trigger logout via the user menu or dedicated logout button.
    const logoutTrigger =
      page.getByRole('button', { name: /logout|sign out/i });

    // Some shells hide logout inside a dropdown; try opening it first.
    const userMenu = page.getByRole('button', { name: /user|account|profile|avatar/i });
    if (await userMenu.isVisible().catch(() => false)) {
      await userMenu.click();
    }

    await logoutTrigger.click();

    // Should end up on the login page.
    await expect(page).toHaveURL(/\/login/, { timeout: 10_000 });
  });

  // -------------------------------------------------------------------------
  // Protected routes
  // -------------------------------------------------------------------------

  test('protected routes redirect unauthenticated users to login', async ({ browser }) => {
    const context = await browser.newContext({ storageState: { cookies: [], origins: [] } });
    const page = await context.newPage();

    // Try to visit a route that requires authentication.
    await page.goto('/sensors');

    // Should be redirected to /login (possibly with a redirect query param).
    await expect(page).toHaveURL(/\/login/);

    await context.close();
  });

  // -------------------------------------------------------------------------
  // Session persistence
  // -------------------------------------------------------------------------

  test('session persists after a full page refresh', async ({ page }) => {
    await page.goto('/');
    await expect(page.getByRole('heading', { name: /smart agriculture/i })).toBeVisible();

    // Hard reload.
    await page.reload();

    // Still authenticated - should see the dashboard heading.
    await expect(page.getByRole('heading', { name: /smart agriculture/i })).toBeVisible();
    // Should NOT have been bounced to login.
    await expect(page).not.toHaveURL(/\/login/);
  });
});
