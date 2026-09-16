import { defineConfig } from 'vite';
import { svelte } from '@sveltejs/vite-plugin-svelte';
import UnoCSS from 'unocss/vite';
import { resolve } from 'path';

/**
 * The component gallery: a static page that renders every component in
 * `gallery/stories.ts` with fixed props and no backend.
 *
 * It exists instead of Storybook. Storybook 9.1 and 10.6 both install and
 * build against this repo's Svelte 5, and every story then dies at runtime
 * inside Storybook's own PreviewRender.svelte, where a local `p` shadows the
 * module binding the compiler renamed to the same identifier. This is a page
 * we control end to end, and it renders components through the same UnoCSS
 * theme and shortcuts the real apps use — so a screenshot of it is a
 * screenshot of what a user would actually see, which a separate Storybook
 * build is not.
 */
export default defineConfig({
  root: resolve(__dirname, 'gallery'),

  plugins: [
    // Configured by uno.config.ts, which UnoCSS loads through jiti. Inlining
    // it here would make Vite load the design-tokens theme as native ESM, and
    // native ESM will not resolve that package's extensionless TypeScript
    // imports.
    //
    // `include` adds .ts to the plugin's default list, which is the whole
    // reason the component library's colours never appeared. This library keeps
    // its variant classes in `*.types.ts` — buttonVariantClasses,
    // alertVariantClasses and so on — and the components compose them with
    // cn(). UnoCSS only generates a utility it has read as *text* somewhere,
    // and its default include covers .svelte/.html/.jsx but not .ts, so every
    // class that lives only in those maps was invisible to it.
    //
    // The symptom was subtle because it was partial: classes written inline in
    // a component's markup generated fine, so most things looked right and
    // exactly the ones defined in the types files — `border-brand-primary-500`
    // and its neighbours — silently produced no rule at all.
    UnoCSS({
      include: [/\.(vue|svelte|[jt]sx|mdx?|astro|elm|php|phtml|html|ts)($|\?)/],
    }),
    svelte(),
  ],

  resolve: {
    alias: {
      $lib: resolve(__dirname, './src'),
      '@': resolve(__dirname, './src'),
    },
    // Resolve Svelte's browser build.
    //
    // Without this, `mount()` comes from Svelte's server entry and every
    // render dies with lifecycle_function_unavailable — "mount(...) is not
    // available on the server". The page still returns 200 with an empty
    // <div id="app">, so the failure looks like a blank gallery rather than
    // like an error. vite.config.ts carries the same line for vitest, for
    // exactly the same reason.
    conditions: ['browser'],
  },

  server: {
    port: 5199,
    strictPort: true,
  },

  preview: {
    port: 5199,
    strictPort: true,
  },

  build: {
    outDir: resolve(__dirname, 'gallery-dist'),
    emptyOutDir: true,
  },
});
