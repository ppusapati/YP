import { describe, it, expect, vi } from 'vitest';
import { get } from 'svelte/store';
import { usePagination } from '../usePagination.js';

// This package declared a test script and had no tests, so `vitest` exited 1
// and the whole web suite failed before reaching anything. These cover the
// pagination rules that are easy to get wrong and impossible to notice: a page
// number that survives the list shrinking under it, and a page size change that
// leaves the reader somewhere they did not ask to be.

describe('usePagination', () => {
  it('reports the page count from the total and page size', () => {
    const p = usePagination({ total: 95, initialPageSize: 10 });
    expect(get(p.totalPages)).toBe(10);
  });

  it('reports one page, not zero, when there is nothing to show', () => {
    // Zero pages makes "page 1 of 0" and turns the next/previous arithmetic
    // into nonsense; an empty list is one empty page.
    const p = usePagination({ total: 0 });
    expect(get(p.totalPages)).toBe(1);
    expect(get(p.hasNext)).toBe(false);
    expect(get(p.hasPrevious)).toBe(false);
  });

  it('will not walk past either end', () => {
    const p = usePagination({ total: 25, initialPageSize: 10 });

    p.prevPage();
    expect(get(p.page)).toBe(1);

    p.goToLast();
    expect(get(p.page)).toBe(3);
    p.nextPage();
    expect(get(p.page)).toBe(3);
  });

  it('clamps a page set beyond the end', () => {
    const p = usePagination({ total: 25, initialPageSize: 10 });
    p.setPage(99);
    expect(get(p.page)).toBe(3);
    p.setPage(-4);
    expect(get(p.page)).toBe(1);
  });

  it('pulls the reader back when the list shrinks under them', () => {
    // Someone on page 5 of a filtered list who then narrows the filter must not
    // be left looking at an empty page with no way to tell whether the data
    // went away or the request failed.
    const p = usePagination({ total: 100, initialPageSize: 10 });
    p.setPage(9);
    expect(get(p.page)).toBe(9);

    p.setTotal(25);
    expect(get(p.page)).toBe(3);
  });

  it('returns to the first page when the page size changes', () => {
    // Staying on "page 9" at a larger page size lands somewhere unrelated to
    // what was on screen.
    const p = usePagination({ total: 100, initialPageSize: 10 });
    p.setPage(5);

    p.setPageSize(25);
    expect(get(p.page)).toBe(1);
    expect(get(p.totalPages)).toBe(4);
  });

  it('slices the items for the current page', () => {
    const items = Array.from({ length: 25 }, (_, i) => i + 1);
    const p = usePagination({ total: items.length, initialPageSize: 10 });

    expect(p.getPageItems(items)).toEqual([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    p.setPage(3);
    // The last page is short, which is the case an off-by-one turns into an
    // empty page or a repeated row.
    expect(p.getPageItems(items)).toEqual([21, 22, 23, 24, 25]);
  });

  it('reports start and end indices that match the slice', () => {
    const p = usePagination({ total: 25, initialPageSize: 10 });
    p.setPage(3);

    expect(get(p.startIndex)).toBe(20);
    // Clamped to the total rather than 30: this drives "21–25 of 25".
    expect(get(p.endIndex)).toBe(25);
  });

  it('refuses a page size that is not on offer', () => {
    const p = usePagination({ initialPageSize: 10, pageSizeOptions: [10, 25] });
    p.setPageSize(37);
    expect(get(p.pageSize)).toBe(10);
    p.setPageSize(25);
    expect(get(p.pageSize)).toBe(25);
  });

  it('will not accept a negative total', () => {
    const p = usePagination({ total: 10 });
    p.setTotal(-5);
    expect(get(p.total)).toBe(0);
  });

  it('notifies on change but not on creation', () => {
    // A composable that fires onChange while being constructed makes its
    // consumer refetch the page it is already rendering.
    const onChange = vi.fn();
    const p = usePagination({ total: 100, initialPageSize: 10, onChange });

    expect(onChange).not.toHaveBeenCalled();

    p.setPage(2);
    expect(onChange).toHaveBeenCalled();
    expect(onChange.mock.calls[onChange.mock.calls.length - 1][0]).toMatchObject({
      page: 2,
      pageSize: 10,
      total: 100,
      totalPages: 10,
      hasNext: true,
      hasPrevious: true,
    });
  });

  it('resets to what it was created with', () => {
    const p = usePagination({ initialPage: 2, initialPageSize: 25, total: 500 });
    p.setPage(7);
    p.setTotal(40);

    p.reset();
    expect(get(p.page)).toBe(2);
    expect(get(p.pageSize)).toBe(25);
    expect(get(p.total)).toBe(500);
  });

  it('shows every page when they all fit', () => {
    const p = usePagination({ total: 30, initialPageSize: 10 });
    expect(p.getVisiblePages(7)).toEqual([1, 2, 3]);
  });

  it('never returns more entries than it was asked for', () => {
    // maxVisible used to bound only the window around the current page, and
    // the first page, last page and two ellipses were added on top — so
    // getVisiblePages(7) returned eleven entries and overflowed a control laid
    // out for seven.
    const p = usePagination({ total: 1000, initialPageSize: 10 });

    for (const page of [1, 2, 3, 50, 97, 99, 100]) {
      p.setPage(page);
      const visible = p.getVisiblePages(7);

      expect(visible.length, `page ${page}`).toBeLessThanOrEqual(7);
      expect(visible, `page ${page}`).toContain(page);
      // The ends are always reachable in one click.
      expect(visible[0], `page ${page}`).toBe(1);
      expect(visible[visible.length - 1], `page ${page}`).toBe(100);
    }
  });

  it('returns page numbers in order, with -1 marking a gap', () => {
    const p = usePagination({ total: 1000, initialPageSize: 10 });
    p.setPage(50);

    const visible = p.getVisiblePages(7);
    const numbers = visible.filter((n) => n !== -1);
    expect([...numbers].sort((a, b) => a - b)).toEqual(numbers);
    // A gap is only ever marked where there really is one.
    visible.forEach((entry, i) => {
      if (entry !== -1) return;
      const before = visible[i - 1] as number;
      const after = visible[i + 1] as number;
      expect(after - before).toBeGreaterThan(1);
    });
  });
});
