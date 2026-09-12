import { test, expect } from '@playwright/test';

/**
 * E2E tests for the irrigation scheduling module.
 *
 * Routes exercised:
 *   /irrigation           - list schedules
 *   /irrigation/new       - create schedule
 *   /irrigation/[id]      - view / edit schedule
 *   /irrigation-schedules - alternative schedule list
 */

test.describe('Irrigation', () => {
  // -------------------------------------------------------------------------
  // Create irrigation schedule
  // -------------------------------------------------------------------------

  test('create an irrigation schedule', async ({ page }) => {
    await page.goto('/irrigation/new');

    // The CrudFormPage should be visible.
    await expect(
      page.getByRole('heading', { name: /new irrigation schedule/i }),
    ).toBeVisible();

    // Fill in form fields defined by irrigationScheduleFormSchema.
    await page.getByLabel(/name|schedule/i).first().fill('Morning Drip Cycle');

    // Schedule type dropdown/select.
    const typeSelect = page.getByLabel(/type/i);
    if (await typeSelect.isVisible().catch(() => false)) {
      await typeSelect.selectOption({ index: 1 });
    }

    // Duration.
    const durationField = page.getByLabel(/duration/i);
    if (await durationField.isVisible().catch(() => false)) {
      await durationField.fill('45');
    }

    // Submit.
    await page.getByRole('button', { name: /create|save|submit/i }).click();

    // Redirects to the list.
    await expect(page).toHaveURL(/\/irrigation$/, { timeout: 10_000 });

    // New schedule visible.
    await expect(page.getByText('Morning Drip Cycle')).toBeVisible();
  });

  // -------------------------------------------------------------------------
  // View schedule calendar
  // -------------------------------------------------------------------------

  test('view schedule calendar / list', async ({ page }) => {
    await page.goto('/irrigation-schedules');

    // Heading should match.
    await expect(
      page.getByRole('heading', { name: /irrigation schedule/i }),
    ).toBeVisible();

    // A table or calendar view should render.
    const contentArea = page
      .locator('table, [data-testid="calendar"], [data-testid="schedule-list"]')
      .first();
    await expect(contentArea).toBeVisible({ timeout: 10_000 });
  });

  // -------------------------------------------------------------------------
  // Modify schedule parameters
  // -------------------------------------------------------------------------

  test('modify schedule parameters', async ({ page }) => {
    await page.goto('/irrigation');

    // Open the first schedule.
    const firstRow = page.locator('table tbody tr, [data-testid="entity-row"]').first();
    await firstRow.click();
    await expect(page).toHaveURL(/\/irrigation\/[\w-]+/);

    // Should see the edit form.
    await expect(
      page.getByRole('heading', { name: /edit irrigation schedule/i }),
    ).toBeVisible();

    // Change the duration.
    const durationField = page.getByLabel(/duration/i);
    if (await durationField.isVisible().catch(() => false)) {
      await durationField.clear();
      await durationField.fill('60');
    }

    // Change the name as a second signal.
    const nameField = page.getByLabel(/name|schedule/i).first();
    await nameField.clear();
    await nameField.fill('Evening Drip Cycle');

    // Save.
    await page.getByRole('button', { name: /save|update|submit/i }).click();

    // Redirects to list.
    await expect(page).toHaveURL(/\/irrigation$/, { timeout: 10_000 });

    // Updated name should appear.
    await expect(page.getByText('Evening Drip Cycle')).toBeVisible();
  });
});
