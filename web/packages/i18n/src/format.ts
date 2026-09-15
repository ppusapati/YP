/**
 * Locale-aware formatting for dates, numbers and money.
 *
 * Getting this wrong is not cosmetic here. Indian numbering groups as
 * 12,34,567 rather than 1,234,567, and a farmer reading a price in the wrong
 * grouping reads a different number — not merely an unfamiliar one. Intl knows
 * all of this already; the job is to route to it consistently and to fail soft
 * when a locale or currency is unrecognised, since a page that throws on a bad
 * locale tag is worse than one showing an unformatted number.
 */
import { derived } from 'svelte/store';

import { locale } from './i18n.js';
import type { Locale } from './types.js';

/** Locales that read right to left. */
const RTL_LANGUAGES = new Set(['ar', 'he', 'fa', 'ur', 'ps', 'sd', 'yi', 'dv']);

/** The currency each shipped locale is assumed to price in. */
const LOCALE_CURRENCY: Record<string, string> = {
  en: 'INR',
  hi: 'INR',
  mr: 'INR',
  gu: 'INR',
  ta: 'INR',
  te: 'INR',
  kn: 'INR',
  bn: 'INR',
  pa: 'INR',
};

/** Default currency when a locale has no mapping. */
export const DEFAULT_CURRENCY = 'INR';

/**
 * The BCP 47 tag for a locale.
 *
 * The app stores bare language codes, but Intl needs a region to pick a
 * numbering and calendar convention: `hi` alone will not group in the Indian
 * style, `hi-IN` will.
 */
export function toBcp47(value: Locale): string {
  const code = String(value || 'en');
  if (code.includes('-')) return code;
  return LOCALE_CURRENCY[code] === 'INR' ? `${code}-IN` : code;
}

/** Whether a locale reads right to left. */
export function isRtl(value: Locale): boolean {
  // `split` always yields at least one element, but the checker types the
  // index as possibly undefined, so the language is taken explicitly.
  const [language = 'en'] = String(value || 'en').split('-');
  return RTL_LANGUAGES.has(language.toLowerCase());
}

/** The `dir` attribute value for a locale. */
export function direction(value: Locale): 'ltr' | 'rtl' {
  return isRtl(value) ? 'rtl' : 'ltr';
}

/** Currency a locale prices in. */
export function currencyFor(value: Locale): string {
  const [language = 'en'] = String(value || 'en').split('-');
  return LOCALE_CURRENCY[language] ?? DEFAULT_CURRENCY;
}

/**
 * Run an Intl formatter, falling back to a plain rendering if the runtime
 * rejects the locale or options.
 *
 * A page that throws because a stored locale tag is malformed is worse than
 * one showing an unformatted number.
 */
function safely<T>(format: () => string, fallback: () => string): string {
  try {
    return format();
  } catch {
    return fallback();
  }
}

/** Format a number for a locale. */
export function formatNumber(
  value: number,
  loc: Locale = 'en',
  options: Intl.NumberFormatOptions = {},
): string {
  if (!Number.isFinite(value)) return '—';
  return safely(
    () => new Intl.NumberFormat(toBcp47(loc), options).format(value),
    () => String(value),
  );
}

/**
 * Format an amount of money.
 *
 * Currency defaults to what the locale prices in rather than to the user's
 * language: someone reading the Tamil interface is still being quoted rupees.
 */
export function formatCurrency(
  value: number,
  loc: Locale = 'en',
  currency: string = currencyFor(loc),
  options: Intl.NumberFormatOptions = {},
): string {
  if (!Number.isFinite(value)) return '—';
  return safely(
    () =>
      new Intl.NumberFormat(toBcp47(loc), {
        style: 'currency',
        currency,
        maximumFractionDigits: 2,
        ...options,
      }).format(value),
    () => `${currency} ${value}`,
  );
}

/** Coerce the several shapes a date arrives in. */
function toDate(value: Date | string | number | undefined | null): Date | null {
  if (value == null) return null;
  const d = value instanceof Date ? value : new Date(value);
  return Number.isNaN(d.getTime()) ? null : d;
}

/** Format a date for a locale. */
export function formatDate(
  value: Date | string | number | undefined | null,
  loc: Locale = 'en',
  options: Intl.DateTimeFormatOptions = { dateStyle: 'medium' },
): string {
  const d = toDate(value);
  if (!d) return '—';
  return safely(
    () => new Intl.DateTimeFormat(toBcp47(loc), options).format(d),
    () => d.toISOString().slice(0, 10),
  );
}

/** Format a date and time for a locale. */
export function formatDateTime(
  value: Date | string | number | undefined | null,
  loc: Locale = 'en',
  options: Intl.DateTimeFormatOptions = { dateStyle: 'medium', timeStyle: 'short' },
): string {
  return formatDate(value, loc, options);
}

/**
 * Format a quantity with its unit, e.g. "1,234.5 kg/ha".
 *
 * Units stay in Latin script deliberately. Agronomic units are written that way
 * on every bag, label and invoice a farmer handles, and translating them would
 * make the number harder to check, not easier to read.
 */
export function formatQuantity(
  value: number,
  unit: string,
  loc: Locale = 'en',
  options: Intl.NumberFormatOptions = { maximumFractionDigits: 1 },
): string {
  if (!Number.isFinite(value)) return '—';
  return `${formatNumber(value, loc, options)} ${unit}`.trim();
}

/** Format a fraction as a percentage. `0.42` becomes "42%". */
export function formatPercent(
  value: number,
  loc: Locale = 'en',
  options: Intl.NumberFormatOptions = { maximumFractionDigits: 0 },
): string {
  if (!Number.isFinite(value)) return '—';
  return safely(
    () => new Intl.NumberFormat(toBcp47(loc), { style: 'percent', ...options }).format(value),
    () => `${Math.round(value * 100)}%`,
  );
}

/**
 * Choose the best supported locale from a browser's preference list.
 *
 * Exact matches win, then language matches: a browser asking for `hi-IN` when
 * only `hi` ships should get Hindi rather than falling through to English.
 */
export function negotiateLocale(
  preferred: readonly string[],
  supported: readonly Locale[],
  fallback: Locale = 'en',
): Locale {
  const available = supported.map((l) => String(l).toLowerCase());
  for (const raw of preferred) {
    const want = String(raw || '').toLowerCase();
    if (!want) continue;
    // The indices come from `available`, which is `supported` mapped
    // one-for-one, so the lookups cannot miss — but the checker types an index
    // access as possibly undefined, so the result is narrowed rather than
    // asserted.
    const exact = supported[available.indexOf(want)];
    if (exact !== undefined) return exact;

    const base = want.split('-')[0];
    const byLanguage = supported[available.findIndex((l) => l.split('-')[0] === base)];
    if (byLanguage !== undefined) return byLanguage;
  }
  return fallback;
}

/**
 * Detect the locale to start in.
 *
 * A profile setting is a deliberate choice and outranks everything. Otherwise
 * the browser's languages are the best guess available. Falls back cleanly
 * during server-side rendering, where there is no navigator.
 */
export function detectLocale(
  supported: readonly Locale[],
  options: { profileLocale?: string | null; fallback?: Locale } = {},
): Locale {
  const fallback = options.fallback ?? 'en';
  if (options.profileLocale) {
    return negotiateLocale([options.profileLocale], supported, fallback);
  }
  if (typeof navigator === 'undefined') return fallback;
  const preferred = navigator.languages?.length
    ? navigator.languages
    : [navigator.language].filter(Boolean);
  return negotiateLocale(preferred as string[], supported, fallback);
}

/** Reactive text direction, for binding to `<html dir>`. */
export const textDirection = derived(locale, ($locale) => direction($locale));

/** Reactive formatters that follow the active locale. */
export const format = derived(locale, ($locale) => ({
  number: (v: number, o?: Intl.NumberFormatOptions) => formatNumber(v, $locale, o),
  currency: (v: number, c?: string, o?: Intl.NumberFormatOptions) =>
    formatCurrency(v, $locale, c ?? currencyFor($locale), o),
  date: (v: Date | string | number | null | undefined, o?: Intl.DateTimeFormatOptions) =>
    formatDate(v, $locale, o),
  dateTime: (v: Date | string | number | null | undefined, o?: Intl.DateTimeFormatOptions) =>
    formatDateTime(v, $locale, o),
  quantity: (v: number, unit: string, o?: Intl.NumberFormatOptions) =>
    formatQuantity(v, unit, $locale, o),
  percent: (v: number, o?: Intl.NumberFormatOptions) => formatPercent(v, $locale, o),
}));
