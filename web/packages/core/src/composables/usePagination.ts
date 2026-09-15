/**
 * usePagination Composable
 * Creates a reactive pagination state with page navigation
 */

import { writable, derived, get, type Writable, type Readable } from 'svelte/store';
import type { PaginationState } from '../types/index.js';

// ============================================================================
// TYPES
// ============================================================================

export interface UsePaginationOptions {
  initialPage?: number;
  initialPageSize?: number;
  total?: number;
  pageSizeOptions?: number[];
  onChange?: (pagination: PaginationState) => void;
}

export interface UsePaginationReturn {
  // State
  page: Writable<number>;
  pageSize: Writable<number>;
  total: Writable<number>;

  // Derived
  pagination: Readable<PaginationState>;
  totalPages: Readable<number>;
  hasNext: Readable<boolean>;
  hasPrevious: Readable<boolean>;
  pageRange: Readable<number[]>;
  startIndex: Readable<number>;
  endIndex: Readable<number>;

  // Methods
  setPage: (page: number) => void;
  setPageSize: (size: number) => void;
  setTotal: (total: number) => void;
  nextPage: () => void;
  prevPage: () => void;
  goToFirst: () => void;
  goToLast: () => void;
  reset: () => void;

  // Utility
  getPageItems: <T>(items: T[]) => T[];
  getVisiblePages: (maxVisible?: number) => number[];
}

// ============================================================================
// IMPLEMENTATION
// ============================================================================

export function usePagination(options: UsePaginationOptions = {}): UsePaginationReturn {
  const {
    initialPage = 1,
    initialPageSize = 10,
    total: initialTotal = 0,
    pageSizeOptions = [10, 25, 50, 100],
    onChange,
  } = options;

  // ============================================================================
  // STORES
  // ============================================================================

  const page = writable<number>(initialPage);
  const pageSize = writable<number>(initialPageSize);
  const total = writable<number>(initialTotal);

  // ============================================================================
  // DERIVED STORES
  // ============================================================================

  const totalPages = derived([total, pageSize], ([$total, $pageSize]) =>
    Math.max(1, Math.ceil($total / $pageSize))
  );

  const hasNext = derived([page, totalPages], ([$page, $totalPages]) => $page < $totalPages);

  const hasPrevious = derived(page, ($page) => $page > 1);

  const startIndex = derived([page, pageSize], ([$page, $pageSize]) => ($page - 1) * $pageSize);

  const endIndex = derived([page, pageSize, total], ([$page, $pageSize, $total]) =>
    Math.min($page * $pageSize, $total)
  );

  const pageRange = derived([page, totalPages], ([$page, $totalPages]) => {
    const range: number[] = [];
    for (let i = 1; i <= $totalPages; i++) {
      range.push(i);
    }
    return range;
  });

  const pagination = derived(
    [page, pageSize, total, totalPages, hasNext, hasPrevious],
    ([$page, $pageSize, $total, $totalPages, $hasNext, $hasPrevious]) => ({
      page: $page,
      pageSize: $pageSize,
      total: $total,
      totalPages: $totalPages,
      hasNext: $hasNext,
      hasPrevious: $hasPrevious,
    })
  );

  // ============================================================================
  // SUBSCRIPTIONS
  // ============================================================================

  // Notify on change
  let isInitial = true;
  pagination.subscribe(($pagination) => {
    if (!isInitial) {
      onChange?.($pagination);
    }
    isInitial = false;
  });

  // Ensure page is within bounds when total changes
  total.subscribe(($total) => {
    const $page = get(page);
    const $pageSize = get(pageSize);
    const maxPage = Math.max(1, Math.ceil($total / $pageSize));
    if ($page > maxPage) {
      page.set(maxPage);
    }
  });

  // Reset to page 1 when page size changes
  pageSize.subscribe(() => {
    if (!isInitial) {
      page.set(1);
    }
  });

  // ============================================================================
  // METHODS
  // ============================================================================

  function setPage(newPage: number): void {
    const $totalPages = get(totalPages);
    page.set(Math.max(1, Math.min(newPage, $totalPages)));
  }

  function setPageSize(size: number): void {
    if (pageSizeOptions.includes(size) || pageSizeOptions.length === 0) {
      pageSize.set(size);
    }
  }

  function setTotal(newTotal: number): void {
    total.set(Math.max(0, newTotal));
  }

  function nextPage(): void {
    if (get(hasNext)) {
      page.update(($p) => $p + 1);
    }
  }

  function prevPage(): void {
    if (get(hasPrevious)) {
      page.update(($p) => $p - 1);
    }
  }

  function goToFirst(): void {
    page.set(1);
  }

  function goToLast(): void {
    page.set(get(totalPages));
  }

  function reset(): void {
    page.set(initialPage);
    pageSize.set(initialPageSize);
    total.set(initialTotal);
  }

  // ============================================================================
  // UTILITY FUNCTIONS
  // ============================================================================

  function getPageItems<T>(items: T[]): T[] {
    const $startIndex = get(startIndex);
    const $pageSize = get(pageSize);
    return items.slice($startIndex, $startIndex + $pageSize);
  }

  /**
   * The page numbers to show in a paginator, with -1 marking an ellipsis.
   *
   * `maxVisible` caps the length of the returned array — every entry, the
   * first and last page and the ellipsis markers included. It used to bound
   * only the window around the current page, so `getVisiblePages(7)` could
   * return eleven entries and overflow a control laid out for seven. Below
   * five it is treated as five, because the first page, the last page, the
   * current page and two ellipses are the least that can be shown without
   * losing one of them.
   */
  function getVisiblePages(maxVisible = 7): number[] {
    const $page = get(page);
    const $totalPages = get(totalPages);

    if ($totalPages <= maxVisible) {
      return Array.from({ length: $totalPages }, (_, i) => i + 1);
    }

    const slots = Math.max(5, maxVisible);

    // Widest window first, narrowing until the assembled list fits. Computing
    // the window size directly would need to know in advance how many ellipsis
    // markers it will produce, which depends on the window.
    for (let window = slots; window >= 1; window--) {
      const half = Math.floor(window / 2);
      const end = Math.min($totalPages, Math.max(1, $page - half) + window - 1);
      const start = Math.max(1, end - window + 1);

      const pages: number[] = [];
      if (start > 1) {
        pages.push(1);
        if (start > 2) pages.push(-1);
      }
      for (let i = start; i <= end; i++) pages.push(i);
      if (end < $totalPages) {
        if (end < $totalPages - 1) pages.push(-1);
        pages.push($totalPages);
      }

      if (pages.length <= slots) return pages;
    }

    // Unreachable: a window of one always fits in five slots. Present so the
    // function has no path that returns undefined.
    return [$page];
  }

  // ============================================================================
  // RETURN
  // ============================================================================

  return {
    // State
    page,
    pageSize,
    total,

    // Derived
    pagination,
    totalPages,
    hasNext,
    hasPrevious,
    pageRange,
    startIndex,
    endIndex,

    // Methods
    setPage,
    setPageSize,
    setTotal,
    nextPage,
    prevPage,
    goToFirst,
    goToLast,
    reset,

    // Utility
    getPageItems,
    getVisiblePages,
  };
}
