import { test, expect } from '@playwright/test';

/**
 * E2E tests for farm management (CRUD).
 *
 * These tests assume an authenticated session via the global setup
 * storage state injected by playwright.config.ts.
 */

test.describe('Farm Management', () => {
  // -------------------------------------------------------------------------
  // Create
  // -------------------------------------------------------------------------

  test('create a new farm', async ({ page }) => {
    await page.goto('/farms/new');

    // Fill required fields exposed by the CrudFormPage.
    await page.getByLabel(/name/i).fill('Cypress Ridge Farm');
    await page.getByLabel(/code/i).fill('CRF-001');

    // Location fields (if present).
    const locationField = page.getByLabel(/location|address/i);
    if (await locationField.isVisible().catch(() => false)) {
      await locationField.fill('45.5231, -122.6765');
    }

    // Area / size (if present).
    const areaField = page.getByLabel(/area|size|hectares/i);
    if (await areaField.isVisible().catch(() => false)) {
      await areaField.fill('120');
    }

    // Submit.
    await page.getByRole('button', { name: /create|save|submit/i }).click();

    // After creation the app redirects to the farm list.
    await expect(page).toHaveURL(/\/farms$/, { timeout: 10_000 });

    // The new farm should appear in the table.
    await expect(page.getByText('Cypress Ridge Farm')).toBeVisible();
  });

  // -------------------------------------------------------------------------
  // Read (details)
  // -------------------------------------------------------------------------

  test('view farm details', async ({ page }) => {
    await page.goto('/farms');

    // Click the first row in the entity list.
    const firstRow = page.locator('table tbody tr, [data-testid="entity-row"]').first();
    await firstRow.click();

    // Should navigate to a detail / edit page.
    await expect(page).toHaveURL(/\/farms\/[\w-]+/);

    // The detail page should display the farm name in a heading or input.
    await expect(
      page.getByRole('heading', { level: 1 }).or(page.getByLabel(/name/i)),
    ).toBeVisible();
  });

  // -------------------------------------------------------------------------
  // Update
  // -------------------------------------------------------------------------

  test('edit farm information', async ({ page }) => {
    await page.goto('/farms');

    // Navigate into the first farm.
    const firstRow = page.locator('table tbody tr, [data-testid="entity-row"]').first();
    await firstRow.click();
    await expect(page).toHaveURL(/\/farms\/[\w-]+/);

    // Change the name.
    const nameInput = page.getByLabel(/name/i);
    await nameInput.clear();
    await nameInput.fill('Updated Farm Name');

    // Save.
    await page.getByRole('button', { name: /save|update|submit/i }).click();

    // Redirect back to list.
    await expect(page).toHaveURL(/\/farms$/, { timeout: 10_000 });

    // Updated name should be visible.
    await expect(page.getByText('Updated Farm Name')).toBeVisible();
  });

  // -------------------------------------------------------------------------
  // List with pagination
  // -------------------------------------------------------------------------

  test('list farms with pagination', async ({ page }) => {
    await page.goto('/farms');

    // The entity list page should render.
    await expect(page.getByRole('heading', { name: /farms/i })).toBeVisible();

    // If there are enough rows, pagination controls should be present.
    const nextButton = page.getByRole('button', { name: /next|>>/i });
    if (await nextButton.isVisible().catch(() => false)) {
      await nextButton.click();
      // After clicking next the URL or table rows should change.
      await expect(
        page.locator('table tbody tr, [data-testid="entity-row"]').first(),
      ).toBeVisible();
    }
  });

  // -------------------------------------------------------------------------
  // Delete
  // -------------------------------------------------------------------------

  test('delete farm with confirmation', async ({ page }) => {
    await page.goto('/farms');

    // Navigate to the first farm's detail page.
    const firstRow = page.locator('table tbody tr, [data-testid="entity-row"]').first();
    await firstRow.click();
    await expect(page).toHaveURL(/\/farms\/[\w-]+/);

    // Click the delete button.
    await page.getByRole('button', { name: /delete/i }).click();

    // A confirmation dialog should appear.
    const confirmButton = page.getByRole('button', { name: /confirm|yes|delete/i });
    await expect(confirmButton).toBeVisible();
    await confirmButton.click();

    // Should redirect back to the list.
    await expect(page).toHaveURL(/\/farms$/, { timeout: 10_000 });
  });
});
