import { describe, it, expect } from 'vitest';

/*
 * Utility formatting functions live in the shared @samavāya packages.
 * We import them here to validate the smart-agriculture app's transitive
 * dependency on those utilities and to guard against regressions in the
 * formatting helpers this app relies on most.
 */
import {
  formatDate,
  isValidDate,
  formatRelative,
  addDays,
} from '@samavāya/utility/date';

import {
  formatNumber,
  formatCurrency,
  formatBytes,
  round,
  toRadians,
  toDegrees,
} from '@samavāya/utility/number';

import {
  formatPercent,
  formatDuration,
  formatTime,
} from '@samavāya/utility/formatting';

// ===========================================================================
// Date formatting
// ===========================================================================

describe('date formatting', () => {
  const fixedDate = new Date('2026-06-15T14:30:00Z');

  it('formatDate produces a locale string', () => {
    const result = formatDate(fixedDate, 'en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
    });
    expect(result).toContain('Jun');
    expect(result).toContain('15');
    expect(result).toContain('2026');
  });

  it('isValidDate accepts valid ISO strings', () => {
    expect(isValidDate('2026-06-15')).toBe(true);
    expect(isValidDate('not-a-date')).toBe(false);
  });

  it('addDays shifts the date forward', () => {
    const shifted = addDays(fixedDate, 10);
    expect(shifted.getDate()).toBe(25);
  });

  it('formatDate handles Date objects and numeric timestamps', () => {
    expect(formatDate(fixedDate.getTime(), 'en-US')).toBeTruthy();
    expect(formatDate(fixedDate, 'en-US')).toBeTruthy();
  });
});

// ===========================================================================
// Number formatting (yields, areas)
// ===========================================================================

describe('number formatting', () => {
  it('formatNumber uses Intl with the given locale', () => {
    const result = formatNumber(1234567.89, 'en-US');
    expect(result).toBe('1,234,567.89');
  });

  it('formatNumber respects options like maximumFractionDigits', () => {
    const result = formatNumber(3.14159, 'en-US', { maximumFractionDigits: 2 });
    expect(result).toBe('3.14');
  });

  it('formatCurrency prepends the currency symbol', () => {
    const result = formatCurrency(250, 'USD', 'en-US');
    expect(result).toMatch(/\$250/);
  });

  it('formatBytes converts bytes to human-readable sizes', () => {
    expect(formatBytes(0)).toBe('0 Bytes');
    expect(formatBytes(1024)).toBe('1 KB');
    expect(formatBytes(1048576)).toBe('1 MB');
  });

  it('formatPercent renders a percentage', () => {
    // formatPercent(0.42) => "42%"
    const result = formatPercent(0.42, 'en-US');
    expect(result).toContain('42');
    expect(result).toContain('%');
  });

  it('round respects precision', () => {
    expect(round(3.14159, 2)).toBe(3.14);
    expect(round(3.14159, 0)).toBe(3);
  });
});

// ===========================================================================
// Coordinate formatting
// ===========================================================================

describe('coordinate formatting', () => {
  it('formatNumber can display lat/lng with fixed decimals', () => {
    const lat = formatNumber(45.523100, 'en-US', {
      minimumFractionDigits: 6,
      maximumFractionDigits: 6,
    });
    expect(lat).toBe('45.523100');

    const lng = formatNumber(-122.676500, 'en-US', {
      minimumFractionDigits: 6,
      maximumFractionDigits: 6,
    });
    expect(lng).toBe('-122.676500');
  });

  it('toRadians and toDegrees are inverses', () => {
    const deg = 45;
    expect(round(toDegrees(toRadians(deg)), 6)).toBe(deg);
  });
});

// ===========================================================================
// Unit conversions (hectares / acres)
// ===========================================================================

describe('unit conversions', () => {
  const HECTARE_TO_ACRE = 2.47105;
  const ACRE_TO_HECTARE = 1 / HECTARE_TO_ACRE;

  it('converts hectares to acres', () => {
    const hectares = 100;
    const acres = round(hectares * HECTARE_TO_ACRE, 2);
    expect(acres).toBe(247.11); // 100 ha ~ 247.11 ac
  });

  it('converts acres to hectares', () => {
    const acres = 247.11;
    const hectares = round(acres * ACRE_TO_HECTARE, 2);
    expect(hectares).toBe(100); // round-trip
  });

  it('formats area values with the correct unit suffix', () => {
    const ha = 52.3;
    const formatted = `${formatNumber(ha, 'en-US', { maximumFractionDigits: 1 })} ha`;
    expect(formatted).toBe('52.3 ha');
  });
});

// ===========================================================================
// Duration / time formatting
// ===========================================================================

describe('duration & time formatting', () => {
  it('formatDuration renders human-readable durations', () => {
    expect(formatDuration(0)).toBe('0s');
    expect(formatDuration(61_000)).toBe('1m 1s');
    expect(formatDuration(3_661_000)).toBe('1h 1m 1s');
    expect(formatDuration(90_061_000)).toBe('1d 1h 1m 1s');
  });

  it('formatTime renders 12-hour format by default', () => {
    const d = new Date('2026-06-15T14:30:00');
    const result = formatTime(d, '12');
    expect(result).toMatch(/2:30\s*PM/i);
  });

  it('formatTime renders 24-hour format when requested', () => {
    const d = new Date('2026-06-15T14:30:00');
    const result = formatTime(d, '24');
    expect(result).toMatch(/14:30/);
  });
});
