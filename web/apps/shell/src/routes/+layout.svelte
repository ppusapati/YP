<script lang="ts">
  import 'virtual:uno.css';
  import '@p9e.in/samavaya/css';
  import '../app.css';
  import { ErpRootLayout } from '@samavāya/ui';
  import { createI18n, detectLocale, setLocale, textDirection, locale } from '@samavāya/i18n';
  import type { Locale } from '@samavāya/i18n';

  import en from '@samavāya/i18n/locales/en';
  import hi from '@samavāya/i18n/locales/hi';
  import mr from '@samavāya/i18n/locales/mr';
  import te from '@samavāya/i18n/locales/te';
  import ta from '@samavāya/i18n/locales/ta';
  import kn from '@samavāya/i18n/locales/kn';
  import pa from '@samavāya/i18n/locales/pa';
  import bn from '@samavāya/i18n/locales/bn';

  /**
   * Load the translations.
   *
   * Nothing called createI18n before this, which meant `t('common.save')`
   * returned the literal string "common.save" everywhere in every app — eight
   * translated locale files sitting in the repository, reachable by nothing.
   * The failure was invisible because almost nothing called `t()` either, so
   * there were no dotted keys on screen to give it away.
   */
  const SUPPORTED: Locale[] = ['en', 'hi', 'mr', 'te', 'ta', 'kn', 'pa', 'bn'];

  createI18n({
    locale: 'en',
    fallback: 'en',
    messages: { en, hi, mr, te, ta, kn, pa, bn },
  });

  let { children } = $props();

  // The browser's preferred language, chosen after mount rather than at import.
  //
  // Server-side rendering has no navigator, so picking a locale at module
  // scope would render English on the server and something else on the client
  // and mismatch every string during hydration. Starting from English and
  // moving once, after hydration, is one visible change instead of a broken
  // first paint.
  $effect(() => {
    if (typeof navigator === 'undefined') return;
    setLocale(detectLocale(SUPPORTED, { fallback: 'en' }));
  });

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
