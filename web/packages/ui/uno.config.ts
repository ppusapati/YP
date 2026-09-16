import { defineConfig, presetUno } from 'unocss';
import { resolve } from 'node:path';
import { designTokensTheme, componentShortcuts, animations } from '@p9e.in/samavaya/uno';

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
  presets: [presetUno()],
  theme: {
    ...designTokensTheme,
    animation: animations,
  },
  shortcuts: componentShortcuts,
  content: {
    // Absolute paths, resolved from this file.
    //
    // A relative glob here is resolved against Vite's `root`, which the
    // gallery sets to gallery/ — so 'src/**' meant 'gallery/src/**', matched
    // nothing, and UnoCSS generated no utilities for any component. Every
    // component then rendered unstyled, which is stable, so 57 screenshot
    // baselines were captured of unstyled components and compared clean for
    // ever. The suite passed a deliberately broken Button; that is how this
    // was found.
    //
    // src/**/*.ts matters as much as the .svelte files: the class strings live
    // in *.types.ts constants that the components compose with cn(), and
    // UnoCSS only ever sees a class it has read as text somewhere.
    filesystem: [
      resolve(__dirname, 'gallery/**/*.{svelte,ts,html}'),
      resolve(__dirname, 'src/**/*.{svelte,ts}'),
    ],
  },
});
