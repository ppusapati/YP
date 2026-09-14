import { describe, it, expect } from 'vitest';

import {
  currencyFor,
  detectLocale,
  direction,
  formatCurrency,
  formatDate,
  formatNumber,
  formatPercent,
  formatQuantity,
  isRtl,
  negotiateLocale,
  toBcp47,
} from '../format';

const SUPPORTED = ['en', 'hi', 'mr', 'gu', 'ta', 'te', 'kn', 'bn', 'pa'];

describe('number formatting', () => {
  it('groups Indian locales the Indian way', () => {
    // This is the whole reason the module exists: a farmer reading 12,34,567
    // as 1,234,567 has read a different number, not merely an odd-looking one.
    expect(formatNumber(1234567, 'hi')).toBe('12,34,567');
    expect(formatNumber(1234567, 'en-US')).toBe('1,234,567');
  });

  it('gives a bare language code a region so Intl can pick a convention', () => {
    // `hi` alone will not group Indian-style; `hi-IN` will.
    expect(toBcp47('hi')).toBe('hi-IN');
    expect(toBcp47('en-GB')).toBe('en-GB');
  });

  it('renders a missing or non-finite number as a dash', () => {
    expect(formatNumber(Number.NaN, 'en')).toBe('—');
    expect(formatNumber(Number.POSITIVE_INFINITY, 'en')).toBe('—');
  });

  it('degrades rather than throwing on a malformed locale tag', () => {
    // A page that throws because a stored tag is bad is worse than one showing
    // an unformatted number.
    expect(formatNumber(42, '!!not-a-locale!!')).toBe('42');
  });
});

describe('currency', () => {
  it('prices in what the locale uses, not what language it is', () => {
    // Someone reading the Tamil interface is still being quoted rupees.
    expect(currencyFor('ta')).toBe('INR');
    expect(formatCurrency(1234.5, 'ta')).toContain('₹');
  });

  it('accepts an explicit currency', () => {
    expect(formatCurrency(10, 'en', 'USD')).toContain('$');
  });

  it('falls back to a readable string for an unknown currency', () => {
    expect(formatCurrency(10, 'en', 'NOTACURRENCY')).toContain('10');
  });
});

describe('dates', () => {
  it('formats a date for the locale', () => {
    expect(formatDate('2026-07-15', 'en-GB', { dateStyle: 'short' })).toMatch(/15/);
  });

  it('renders missing or unparseable dates as a dash', () => {
    expect(formatDate(null, 'en')).toBe('—');
    expect(formatDate(undefined, 'en')).toBe('—');
    expect(formatDate('not a date', 'en')).toBe('—');
  });
});

describe('direction', () => {
  it('knows which scripts read right to left', () => {
    expect(isRtl('ur')).toBe(true);
    expect(isRtl('ar-EG')).toBe(true);
    expect(isRtl('hi')).toBe(false);
    expect(direction('ur')).toBe('rtl');
    expect(direction('en')).toBe('ltr');
  });
});

describe('locale negotiation', () => {
  it('prefers an exact match', () => {
    expect(negotiateLocale(['ta'], SUPPORTED)).toBe('ta');
  });

  it('matches on language when the region is not shipped', () => {
    // A browser asking for hi-IN should get Hindi, not fall through to English.
    expect(negotiateLocale(['hi-IN'], SUPPORTED)).toBe('hi');
  });

  it('walks the preference list in order', () => {
    expect(negotiateLocale(['fr-FR', 'te'], SUPPORTED)).toBe('te');
  });

  it('falls back when nothing matches', () => {
    expect(negotiateLocale(['fr-FR'], SUPPORTED)).toBe('en');
    expect(negotiateLocale([], SUPPORTED)).toBe('en');
  });
});

describe('locale detection', () => {
  it('lets a profile setting outrank the browser', () => {
    // A stored preference is a deliberate choice.
    expect(detectLocale(SUPPORTED, { profileLocale: 'bn' })).toBe('bn');
  });

  it('falls back cleanly where there is no navigator', () => {
    // Server-side rendering has no browser to ask.
    expect(detectLocale(SUPPORTED)).toBe('en');
  });
});

describe('quantities and percentages', () => {
  it('keeps agronomic units in Latin script', () => {
    // Units are written this way on every bag, label and invoice a farmer
    // handles; translating them would make the number harder to check.
    expect(formatQuantity(1234.5, 'kg/ha', 'en')).toBe('1,234.5 kg/ha');
  });

  it('turns a fraction into a percentage', () => {
    expect(formatPercent(0.42, 'en')).toBe('42%');
    expect(formatPercent(Number.NaN, 'en')).toBe('—');
  });
});
