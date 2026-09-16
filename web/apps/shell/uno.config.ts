import { defineConfig, presetUno } from 'unocss';
import { designTokensTheme, componentShortcuts, animations } from '@p9e.in/samavaya/uno';

export default defineConfig({
  // Do not merge selectors that share a declaration.
  //
  // UnoCSS groups rules with identical output, and the UI library's Slider uses
  // the arbitrary variant `[&::-moz-range-thumb]:bg-white`. That selector is
  // Firefox-only, so once it is grouped with `.bg-white` and
  // `.bg-neutral-white`, Chromium fails to parse one selector in the list and
  // discards *the whole rule* — every element using either class loses its
  // background. The class is on the element and the rule is in the file; only
  // getComputedStyle disagrees.
  mergeSelectors: false,

  presets: [
    presetUno(),
  ],

  theme: {
    ...designTokensTheme,
    animation: animations,
  },

  shortcuts: componentShortcuts,

  content: {
    pipeline: {
      // .ts is not in UnoCSS's default pipeline, and the component library
      // keeps its variant classes in `*.types.ts` — buttonVariantClasses,
      // alertVariantClasses and the rest — which the components compose with
      // cn(). UnoCSS only generates a utility it has read as text, so every
      // class living only in those maps produced no rule at all: buttons had
      // no background, no border colour and no ring.
      //
      // The symptom was partial and therefore easy to miss. Classes written
      // inline in a component's markup generated fine, so most of the library
      // looked right while exactly the ones defined in the types files
      // silently did nothing.
      include: [/\.(svelte|html|[jt]sx?|vue|mdx?|astro)($|\?)/],
    },
  },
});
