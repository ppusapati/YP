<script lang="ts">
  import { onMount } from 'svelte';

  /** Page title */
  export let title: string;
  /** Create new item URL */
  export let createHref: string;
  /** Column definitions for the table */
  export let columns: Array<{ key: string; label: string; format?: (v: unknown) => string }>;
  /** Row data */
  export let rows: Record<string, unknown>[] = [];
  /** Loading state */
  export let loading: boolean = false;
  /** Error message */
  export let error: string | null = null;
  /** Row click handler - receives item ID */
  export let onRowClick: ((id: string) => void) | null = null;
  /** Fetch function — receives page offset and page size, returns total count */
  export let fetchData: ((pageOffset?: number, pageSize?: number) => Promise<number | void>) | null = null;
  /** Total count from server (for pagination) */
  export let totalCount: number = 0;
  /** Page size */
  export let pageSize: number = 25;

  let searchQuery = '';
  let currentPage = 0;

  $: totalPages = totalCount > 0 ? Math.ceil(totalCount / pageSize) : 1;

  $: filteredRows = searchQuery
    ? rows.filter((row) =>
        columns.some((col) => {
          const val = row[col.key];
          return val != null && String(val).toLowerCase().includes(searchQuery.toLowerCase());
        })
      )
    : rows;

  async function loadPage(page: number) {
    currentPage = page;
    if (fetchData) {
      const count = await fetchData(page * pageSize, pageSize);
      if (typeof count === 'number') totalCount = count;
    }
  }

  function goNext() {
    if (currentPage < totalPages - 1) loadPage(currentPage + 1);
  }

  function goPrev() {
    if (currentPage > 0) loadPage(currentPage - 1);
  }

  onMount(() => {
    loadPage(0);
  });
</script>

<div class="p-6">
  <div class="flex items-center justify-between mb-6">
    <h1 class="text-2xl font-semibold text-gray-900">{title}</h1>
    <a
      href={createHref}
      class="inline-flex items-center gap-2 rounded-md px-4 py-2 text-sm font-medium
             bg-green-600 text-white hover:bg-green-700 transition-colors"
    >
      + New
    </a>
  </div>

  {#if error}
    <div class="mb-4 rounded-md border border-red-200 bg-red-50 p-4 text-sm text-red-600">
      {error}
    </div>
  {/if}

  <div class="mb-4">
    <input
      type="search"
      placeholder="Search..."
      bind:value={searchQuery}
      class="w-full max-w-sm rounded-md border border-gray-300 px-3 py-2 text-sm
             placeholder-gray-400 focus:border-green-500 focus:outline-none focus:ring-1 focus:ring-green-500"
    />
  </div>

  <div class="overflow-hidden rounded-lg border border-gray-200 bg-white shadow-sm">
    {#if loading}
      <div class="flex items-center justify-center py-12 text-sm text-gray-500">
        Loading...
      </div>
    {:else if filteredRows.length === 0}
      <div class="flex flex-col items-center justify-center py-12 text-sm text-gray-500">
        <p>No records found</p>
        {#if searchQuery}
          <button
            type="button"
            class="mt-2 text-green-600 hover:underline"
            on:click={() => (searchQuery = '')}
          >
            Clear search
          </button>
        {/if}
      </div>
    {:else}
      <table class="w-full text-sm">
        <thead>
          <tr class="border-b border-gray-100 bg-gray-50">
            {#each columns as col}
              <th class="px-4 py-3 text-left font-medium text-gray-600">{col.label}</th>
            {/each}
          </tr>
        </thead>
        <tbody>
          {#each filteredRows as row, i}
            <tr
              class="border-b border-gray-50 hover:bg-gray-50 transition-colors
                     {onRowClick ? 'cursor-pointer' : ''}"
              on:click={() => onRowClick?.(String(row.id ?? i))}
            >
              {#each columns as col}
                <td class="px-4 py-3 text-gray-700">
                  {#if col.format}
                    {col.format(row[col.key])}
                  {:else}
                    {row[col.key] ?? '—'}
                  {/if}
                </td>
              {/each}
            </tr>
          {/each}
        </tbody>
      </table>
    {/if}
  </div>

  <!-- Pagination & count -->
  <div class="mt-3 flex items-center justify-between text-sm text-gray-500">
    <div>
      {#if totalCount > 0}
        Showing {currentPage * pageSize + 1}–{Math.min((currentPage + 1) * pageSize, totalCount)} of {totalCount}
      {:else}
        {filteredRows.length} record{filteredRows.length !== 1 ? 's' : ''}
      {/if}
      {#if searchQuery && filteredRows.length !== rows.length}
        (filtered from {rows.length})
      {/if}
    </div>

    {#if totalPages > 1}
      <div class="flex items-center gap-2">
        <button
          type="button"
          disabled={currentPage === 0}
          on:click={goPrev}
          class="rounded-md border border-gray-300 px-3 py-1 text-sm
                 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed"
        >
          Previous
        </button>
        <span class="text-sm">
          Page {currentPage + 1} of {totalPages}
        </span>
        <button
          type="button"
          disabled={currentPage >= totalPages - 1}
          on:click={goNext}
          class="rounded-md border border-gray-300 px-3 py-1 text-sm
                 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed"
        >
          Next
        </button>
      </div>
    {/if}
  </div>
</div>
