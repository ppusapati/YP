/**
 * Vitest global setup for Smart Agriculture unit tests.
 *
 * - Clears mocks between tests so state does not leak.
 * - Stubs browser storage APIs that are unavailable in jsdom.
 * - Provides a minimal $app/stores mock for SvelteKit store imports.
 */
import { vi, beforeEach, afterEach } from 'vitest';

// ---------------------------------------------------------------------------
// Storage stubs (jsdom provides them but they can be flaky across versions)
// ---------------------------------------------------------------------------

const storageMock = (): Storage => {
  let store: Record<string, string> = {};
  return {
    getItem: (key: string) => store[key] ?? null,
    setItem: (key: string, value: string) => {
      store[key] = value;
    },
    removeItem: (key: string) => {
      delete store[key];
    },
    clear: () => {
      store = {};
    },
    get length() {
      return Object.keys(store).length;
    },
    key: (index: number) => Object.keys(store)[index] ?? null,
  };
};

if (typeof globalThis.localStorage === 'undefined') {
  Object.defineProperty(globalThis, 'localStorage', { value: storageMock() });
}
if (typeof globalThis.sessionStorage === 'undefined') {
  Object.defineProperty(globalThis, 'sessionStorage', { value: storageMock() });
}

// ---------------------------------------------------------------------------
// Per-test lifecycle
// ---------------------------------------------------------------------------

beforeEach(() => {
  vi.clearAllMocks();
  localStorage.clear();
  sessionStorage.clear();
});

afterEach(() => {
  vi.restoreAllMocks();
});
