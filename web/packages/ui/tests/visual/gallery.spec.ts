import { test, expect, type Page } from '@playwright/test';
import { allStories, stableStories } from '../../gallery/catalog';

/**
 * One screenshot per story, each of the component's own box rather than of the
 * page.
 *
 * Screenshotting the page would mean a component growing by one pixel shifts
 * everything below it, so one change fails every test after it and the report
 * says nothing about which component moved. Per-element shots keep a change
 * local to the thing that changed.
 */

/** Load the gallery with animations frozen and fonts settled. */
async function openGallery(page: Page) {
  await page.goto('/?freeze=1', { waitUntil: 'load' });

  // Wait for web fonts. Text laid out in a fallback font and then reflowed
  // when the real one arrives is the single most common source of a diff that
  // appears once and never again.
  await page.evaluate(() => document.fonts.ready);

  // The gallery is client-rendered, so the first story box is the signal that
  // Svelte has mounted. Without it the first screenshot can catch an empty
  // div, which then becomes the baseline.
  await page.locator('[data-story]').first().waitFor({ state: 'visible' });
}

test.describe('component gallery', () => {
  test('every story in the manifest renders', async ({ page }) => {
    await openGallery(page);

    // This runs before the screenshots and is the more important test of the
    // two. A story whose component throws renders nothing, and an empty box
    // screenshots perfectly consistently for ever — so without this check a
    // broken component would be recorded as a passing baseline.
    const rendered = await page.locator('[data-story]').count();
    expect(rendered, 'every story in stories.ts should appear in the DOM').toBe(
      allStories.length,
    );

    for (const story of allStories) {
      const box = page.locator(`[data-story="${story.id}"]`);
      await expect(box, `story "${story.id}" should be in the DOM`).toHaveCount(1);

      // Non-empty, with Svelte's markers stripped first.
      //
      // A component that renders nothing still leaves `<!----><!---->` behind,
      // so a plain `.trim() !== ''` passes on a completely empty box — which is
      // exactly how a gallery of 66 blank boxes was recorded as rendering
      // correctly.
      const html = (await box.innerHTML()).replace(/<!--[\s\S]*?-->/g, '').trim();

      if (story.expectsEmpty) {
        // Declared empty, so assert it *is* empty. A story that opts out of
        // this check and then starts rendering something has changed
        // behaviour, and saying nothing about it would waste the declaration.
        expect(
          html,
          `story "${story.id}" is declared to render nothing (${story.expectsEmpty}) but rendered something`,
        ).toBe('');
      } else {
        expect(html, `story "${story.id}" rendered nothing`).not.toBe('');
      }
    }
  });

  // The check that would have caught a whole suite of meaningless baselines.
  //
  // Two separate faults produced 57 screenshots of blank, unstyled boxes that
  // compared clean for ever, and nothing else in this file could see either:
  //
  //  * `<story.component>` is lowercase, so Svelte parsed it as an unknown
  //    HTML element rather than a component. Every box rendered empty — no
  //    error, no warning, and `innerHTML` was not '' because Svelte leaves
  //    `<!---->` markers behind, which defeated the emptiness check below.
  //
  //  * The gallery did not import the design tokens, so every utility resolved
  //    to an undefined custom property: `.px-4` is `padding-left:
  //    var(--spacing-4)`, not `1rem`. The classes were all on the elements and
  //    all matched a rule; the rules just evaluated to nothing.
  //
  // Both were found by deliberately changing a Button's colour and watching
  // the suite pass. Only the computed style can tell.
  test('components are actually styled', async ({ page }) => {
    await openGallery(page);

    const button = page.locator('[data-story="button-primary"] button').first();
    await expect(button, 'the primary button story should render a <button>').toHaveCount(1);

    const padding = await button.evaluate(
      (element) => parseFloat(getComputedStyle(element).paddingLeft),
    );

    // px-4 resolves through var(--spacing-4). If the tokens stylesheet is
    // missing, or UnoCSS generated nothing for this element, this is 0.
    expect(
      padding,
      'the primary button has no horizontal padding — either the design tokens ' +
        'are not imported or UnoCSS generated no utilities for the components',
    ).toBeGreaterThan(8);

    // The brand colour, which is a guard against a bug this suite found.
    //
    // The components ask for `bg-brand-primary-500`, and for a long time no
    // such utility existed anywhere — not here and not in the apps. Four
    // separate faults had to be cleared before it did: the theme emitted
    // colours only under their full `color-` token path; it emitted them as
    // flat keys, which `bg-` tolerates and `border-` does not; `.ts` was
    // missing from UnoCSS's pipeline, and this library keeps its variant
    // classes in `*.types.ts`; and UnoCSS merged `.bg-white` into a selector
    // group containing a Firefox-only `::-moz-range-thumb`, which makes
    // Chromium discard the whole rule.
    //
    // Any one of them coming back leaves the button at the browser's default
    // grey with every class still on the element, so this asserts the computed
    // colour rather than trusting the class list.
    const background = await button.evaluate(
      (element) => getComputedStyle(element).backgroundColor,
    );

    expect(
      background,
      'the primary button has no brand background — a brand colour utility is ' +
        'not being generated again',
    ).not.toMatch(/rgba\(0,\s*0,\s*0,\s*0\)|transparent/);

    // Chromium's default button background. Matching it means the class
    // produced no rule at all, which is exactly how this failed before.
    expect(
      background,
      'the primary button is the browser default grey — the brand colour ' +
        'utility resolved to nothing',
    ).not.toBe('rgb(239, 239, 239)');

    const borderColour = await button.evaluate(
      (element) => getComputedStyle(element).borderTopColor,
    );

    // `border-` is checked separately from `bg-`. They resolve through
    // different code paths in UnoCSS — a nested colour tree works for both, a
    // flat key only for `bg-` — so a half-fix shows up as a blue button with a
    // black border, and only this assertion sees it.
    expect(
      borderColour,
      'the primary button has a black border — `border-brand-primary-500` is ' +
        'resolving to nothing while the background still works',
    ).not.toBe('rgb(0, 0, 0)');
  });

  test('no story logged a console error', async ({ page }) => {
    const errors: string[] = [];
    page.on('console', (message) => {
      if (message.type() === 'error') errors.push(message.text());
    });
    page.on('pageerror', (error) => errors.push(error.message));

    await openGallery(page);

    // Svelte reports a failed prop type or a missing required prop here and
    // still renders something plausible, so this catches the class of breakage
    // a screenshot cannot: the component that looks right and is not.
    expect(errors, 'the gallery should render without console errors').toEqual([]);
  });

  for (const story of stableStories) {
    test(`${story.id} matches its baseline`, async ({ page }) => {
      await openGallery(page);

      const box = page.locator(`[data-story="${story.id}"]`);
      await box.scrollIntoViewIfNeeded();

      await expect(box).toHaveScreenshot(`${story.id}.png`);
    });
  }
});

test.describe('unstable stories', () => {
  // Not screenshotted, but still rendered and still checked. An animated
  // component that stops rendering entirely would otherwise be invisible to
  // this suite, because the thing that excuses it from a screenshot is not a
  // reason to stop testing it at all.
  const unstable = allStories.filter((story) => story.unstable);

  test('animated stories still render', async ({ page }) => {
    test.skip(unstable.length === 0, 'no stories are marked unstable');

    await openGallery(page);

    for (const story of unstable) {
      const box = page.locator(`[data-story="${story.id}"]`);
      await expect(box, `unstable story "${story.id}" should still render`).toHaveCount(1);
      expect((await box.innerHTML()).trim()).not.toBe('');
    }
  });
});
