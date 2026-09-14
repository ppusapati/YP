<script lang="ts">
  import 'virtual:uno.css';
  import '@p9e.in/samavaya/css';
  import '../app.css';
  import { ErpRootLayout } from '@samavāya/ui';
  import { textDirection, locale } from '@samavāya/i18n';

  let { children } = $props();

  // Keep the document's language and direction in step with the active locale.
  // Setting `dir` on <html> is what makes the browser mirror layout, scrollbars
  // and text alignment for right-to-left scripts; CSS alone does not.
  $effect(() => {
    if (typeof document === 'undefined') return;
    document.documentElement.lang = $locale;
    document.documentElement.dir = $textDirection;
  });
</script>

<ErpRootLayout>
  {@render children()}
</ErpRootLayout>
