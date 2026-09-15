// Test setup for the component suite.
//
// Two things were missing, and together they meant none of it ran: vitest had
// no browser-like environment, so `document` was undefined the moment a
// component was rendered, and the DOM matchers the tests are written against
// (`toBeInTheDocument`, `toHaveAttribute`, `toHaveClass`, `toBeDisabled`) were
// never registered. Every one of the 38 tests failed on the first line of its
// body, which is the failure mode that looks like a broken environment rather
// than broken code and gets skipped.
import '@testing-library/jest-dom/vitest';
import { afterEach } from 'vitest';
import { cleanup } from '@testing-library/svelte';

// Each test gets a fresh document. Without this a component left mounted by one
// test is still in the DOM for the next, so a `getByText` can match the
// previous test's render and pass for the wrong reason — the kind of green that
// is worse than red.
afterEach(() => {
  cleanup();
});

// jsdom has no ResizeObserver, and the chart components use one to follow their
// container. A stub rather than a polyfill: nothing here asserts on resizing,
// and what matters is that a component observing its size does not throw on
// mount.
if (!('ResizeObserver' in globalThis)) {
  class ResizeObserverStub {
    observe(): void {}
    unobserve(): void {}
    disconnect(): void {}
  }
  Object.defineProperty(globalThis, 'ResizeObserver', {
    writable: true,
    value: ResizeObserverStub,
  });
}
