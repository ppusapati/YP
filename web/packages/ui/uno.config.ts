import { defineConfig, presetUno } from 'unocss';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { designTokensTheme, componentShortcuts, animations } from '@p9e.in/samavaya/uno';

// This file's own directory.
//
// `__dirname` is not defined when this config is loaded as an ES module, and
// the failure is quiet: the glob below resolves against an undefined base,
// matches nothing, and UnoCSS generates no utilities for anything it should
// have found there. Derived from import.meta.url instead, which is defined
// under every loader that reads this file.
const here = dirname(fileURLToPath(import.meta.url));

/**
 * UnoCSS for the component gallery.
 *
 * The same theme, shortcuts and animations the five apps use, so a screenshot
 * of the gallery is a screenshot of what a user actually sees. A gallery with
 * its own styling would happily go on passing while the real apps regressed.
 *
 * It lives in its own file rather than inline in vite.gallery.config.ts
 * because UnoCSS loads this through jiti, which reads the design-tokens
 * package's TypeScript sources; Vite loads its own config as native ESM,
 * which does not.
 */
export default defineConfig({
  // Do not merge selectors that share a declaration.
  //
  // UnoCSS groups rules with identical output, and the library has a range
  // input using the arbitrary variant `[&::-moz-range-thumb]:bg-white`. That
  // selector is Firefox-only, so when it is merged into the same group as
  // `.bg-white` and `.bg-neutral-white`, Chromium fails to parse one selector
  // in the list and throws away *the entire rule* — silently dropping the
  // background colour of every element using either class.
  //
  // Merging saves a few hundred bytes. Losing `bg-white` in Chromium is not a
  // trade worth making, and the failure is invisible: the class is on the
  // element, the rule is in the file, and only getComputedStyle disagrees.
  mergeSelectors: false,

  presets: [presetUno()],
  theme: {
    ...designTokensTheme,
    animation: animations,
  },
  shortcuts: componentShortcuts,
  content: {
    pipeline: {
      // Add .ts to the files UnoCSS reads as it transforms modules.
      //
      // This is the whole reason the component library's colours never
      // appeared. The library keeps its variant classes in `*.types.ts` —
      // buttonVariantClasses, alertVariantClasses and the rest — and the
      // components compose them with cn(). UnoCSS only generates a utility it
      // has read as *text*, and its default pipeline covers .svelte/.html/.jsx
      // but not .ts, so every class living only in those maps produced no rule.
      //
      // The symptom was partial, which is what made it hard to see: classes
      // written inline in a component's markup generated fine, so most of the
      // library looked right while exactly the ones defined in the types files
      // — `border-brand-primary-500` and its neighbours — silently did nothing.
      include: [/\.(svelte|html|[jt]sx?|vue|mdx?|astro)($|\?)/],
    },
    filesystem: [
      // Absolute, resolved from this file. A relative glob is resolved against
      // Vite's `root`, which the gallery sets to gallery/, so 'src/**' would
      // mean 'gallery/src/**' and match nothing.
      resolve(here, 'gallery/**/*.{svelte,ts,html}'),
      resolve(here, 'src/**/*.{svelte,ts}'),
    ],
  },
});
