import { test, expect } from '@playwright/test';

/**
 * E2E tests for field management within a farm.
 *
 * Fields are sub-entities of farms and include geospatial boundaries,
 * satellite imagery sections, and map-based interactions.
 */

test.describe('Field Management', () => {
  // -------------------------------------------------------------------------
  // Add field to a farm
  // -------------------------------------------------------------------------

  test('add a field to a farm', async ({ page }) => {
    // Navigate to the fields section of the first available farm.
    await page.goto('/farms');

    // Open the first farm.
    const firstRow = page.locator('table tbody tr, [data-testid="entity-row"]').first();
    await firstRow.click();
    await expect(page).toHaveURL(/\/farms\/[\w-]+/);

    // Click the "Add Field" or "New Field" button within the farm detail.
    const addFieldBtn = page.getByRole('link', { name: /add field|new field/i })
      .or(page.getByRole('button', { name: /add field|new field/i }));
    await addFieldBtn.click();

    // Fill field details.
    await page.getByLabel(/name/i).fill('North Plot');
    await page.getByLabel(/code/i).fill('NP-01');

    const areaField = page.getByLabel(/area|size|hectares/i);
    if (await areaField.isVisible().catch(() => false)) {
      await areaField.fill('35');
    }

    // Submit.
    await page.getByRole('button', { name: /create|save|submit/i }).click();

    // Expect to see the new field listed.
    await expect(page.getByText('North Plot')).toBeVisible({ timeout: 10_000 });
  });

  // -------------------------------------------------------------------------
  // View field on map
  // -------------------------------------------------------------------------

  test('view field on map', async ({ page }) => {
    await page.goto('/field-analytics');

    // The field analytics page should render a map container.
    const mapContainer = page.locator(
      '[data-testid="map"], .maplibregl-map, .leaflet-container, canvas',
    );
    await expect(mapContainer.first()).toBeVisible({ timeout: 15_000 });
  });

  // -------------------------------------------------------------------------
  // Edit field boundaries
  // -------------------------------------------------------------------------

  test('edit field boundaries', async ({ page }) => {
    await page.goto('/farms');

    // Open first farm, then first field.
    const firstFarmRow = page.locator('table tbody tr, [data-testid="entity-row"]').first();
    await firstFarmRow.click();
    await expect(page).toHaveURL(/\/farms\/[\w-]+/);

    // Navigate to a field detail (could be a sub-tab or sub-link).
    const fieldLink = page.getByRole('link', { name: /field|plot/i }).first();
    if (await fieldLink.isVisible().catch(() => false)) {
      await fieldLink.click();
    }

    // Look for an "Edit Boundaries" or "Edit Geometry" control.
    const editBoundsBtn = page.getByRole('button', { name: /edit.*(boundar|geometr)/i });
    if (await editBoundsBtn.isVisible().catch(() => false)) {
      await editBoundsBtn.click();

      // The map should enter an editing mode (draw toolbar visible, for example).
      const drawControl = page.locator(
        '[data-testid="draw-toolbar"], .mapbox-gl-draw, .leaflet-draw',
      );
      await expect(drawControl.first()).toBeVisible({ timeout: 10_000 });
    }
  });

  // -------------------------------------------------------------------------
  // Field details page loads satellite imagery section
  // -------------------------------------------------------------------------

  test('field details page loads satellite imagery section', async ({ page }) => {
    await page.goto('/satellite-imagery');

    // Verify the satellite imagery list renders.
    await expect(
      page.getByRole('heading', { name: /satellite imagery/i }),
    ).toBeVisible();

    // The table or card list should contain entries (or an empty state message).
    const rowsOrEmpty = page
      .locator('table tbody tr, [data-testid="entity-row"]')
      .first()
      .or(page.getByText(/no.*data|no.*images|empty/i));
    await expect(rowsOrEmpty).toBeVisible({ timeout: 10_000 });
  });
});
