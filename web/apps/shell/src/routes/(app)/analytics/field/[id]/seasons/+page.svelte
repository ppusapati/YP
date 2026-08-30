<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { fieldAnalyticsClient } from '@samavāya/agriculture/services';

  let seasons: any[] = [];
  let loading = true;
  let error: string | null = null;
  let sortKey = 'season';
  let sortDirection: 'asc' | 'desc' = 'desc';

  $: id = $page.params.id;

  $: if (id) loadData(id);

  $: sortedSeasons = [...seasons].sort((a, b) => {
    const aVal = a[sortKey];
    const bVal = b[sortKey];
    if (aVal == null && bVal == null) return 0;
    if (aVal == null) return 1;
    if (bVal == null) return -1;
    const cmp = aVal < bVal ? -1 : aVal > bVal ? 1 : 0;
    return sortDirection === 'asc' ? cmp : -cmp;
  });

  async function loadData(fieldId: string) {
    loading = true;
    error = null;
    try {
      const res = await fieldAnalyticsClient.getSeasonComparisons({ fieldId });
      seasons = (res as any).seasons || [];
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load season comparisons';
    } finally {
      loading = false;
    }
  }

  function toggleSort(key: string) {
    if (sortKey === key) {
      sortDirection = sortDirection === 'asc' ? 'desc' : 'asc';
    } else {
      sortKey = key;
      sortDirection = 'desc';
    }
  }

  function formatPct(value: number | null | undefined): string {
    if (value == null) return '—';
    const sign = value > 0 ? '+' : '';
    return `${sign}${value}%`;
  }
</script>

<div class="page-container">
  <header class="page-header">
    <div class="header-row">
      <div>
        <h1>Season Comparison</h1>
        <p class="subtitle">Season-by-season analysis for field {id}</p>
      </div>
      <button
        class="rounded-md bg-gray-200 px-4 py-2 text-sm font-semibold text-gray-700 hover:bg-gray-300"
        on:click={() => goto(`/analytics/field/${id}`)}
      >Back to Field Analytics</button>
    </div>
  </header>

  {#if loading}
    <div class="page-content">
      <p>Loading...</p>
    </div>
  {:else if error}
    <div class="page-content error-banner">
      <p>{error}</p>
    </div>
  {:else if sortedSeasons.length === 0}
    <div class="page-content">
      <p class="empty-text">No season data available for this field</p>
    </div>
  {:else}
    <div class="page-content">
      <div class="table-wrapper">
        <table class="data-table">
          <thead>
            <tr>
              <th class="sortable" on:click={() => toggleSort('season')}>
                Season {sortKey === 'season' ? (sortDirection === 'asc' ? '↑' : '↓') : ''}
              </th>
              <th class="sortable" on:click={() => toggleSort('crop')}>
                Crop {sortKey === 'crop' ? (sortDirection === 'asc' ? '↑' : '↓') : ''}
              </th>
              <th class="sortable" on:click={() => toggleSort('yield')}>
                Yield (t/ha) {sortKey === 'yield' ? (sortDirection === 'asc' ? '↑' : '↓') : ''}
              </th>
              <th class="sortable" on:click={() => toggleSort('yieldVsMean')}>
                Yield vs Mean {sortKey === 'yieldVsMean' ? (sortDirection === 'asc' ? '↑' : '↓') : ''}
              </th>
              <th class="sortable" on:click={() => toggleSort('stressDays')}>
                Stress Days {sortKey === 'stressDays' ? (sortDirection === 'asc' ? '↑' : '↓') : ''}
              </th>
              <th class="sortable" on:click={() => toggleSort('stressVsMean')}>
                Stress vs Mean {sortKey === 'stressVsMean' ? (sortDirection === 'asc' ? '↑' : '↓') : ''}
              </th>
              <th class="sortable" on:click={() => toggleSort('ndviPeak')}>
                NDVI Peak {sortKey === 'ndviPeak' ? (sortDirection === 'asc' ? '↑' : '↓') : ''}
              </th>
              <th class="sortable" on:click={() => toggleSort('ndviVsMean')}>
                NDVI vs Mean {sortKey === 'ndviVsMean' ? (sortDirection === 'asc' ? '↑' : '↓') : ''}
              </th>
              <th>Notable Events</th>
            </tr>
          </thead>
          <tbody>
            {#each sortedSeasons as season}
              <tr>
                <td class="font-medium">{season.season ?? '—'}</td>
                <td>{season.crop ?? '—'}</td>
                <td>{season.yield ?? '—'}</td>
                <td class={season.yieldVsMean >= 0 ? 'positive' : 'negative'}>
                  {formatPct(season.yieldVsMean)}
                </td>
                <td>{season.stressDays ?? '—'}</td>
                <td class={season.stressVsMean <= 0 ? 'positive' : 'negative'}>
                  {formatPct(season.stressVsMean)}
                </td>
                <td>{season.ndviPeak ?? '—'}</td>
                <td class={season.ndviVsMean >= 0 ? 'positive' : 'negative'}>
                  {formatPct(season.ndviVsMean)}
                </td>
                <td class="events-cell">
                  {#if season.notableEvents?.length}
                    {#each season.notableEvents as event}
                      <span class="event-tag">{event}</span>
                    {/each}
                  {:else}
                    —
                  {/if}
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    </div>
  {/if}
</div>

<style>
  .page-container { max-width: 1200px; }
  .page-header { margin-bottom: 1.5rem; }
  .page-header h1 { font-size: 1.5rem; font-weight: 600; margin: 0; }
  .subtitle { font-size: 0.875rem; color: #6b7280; margin: 0.25rem 0 0 0; }
  .header-row { display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 1rem; }
  .page-content { background: #fff; border: 1px solid #e5e7eb; border-radius: 0.5rem; padding: 1.5rem; }
  .error-banner { color: #dc2626; }
  .table-wrapper { overflow-x: auto; }
  .data-table { width: 100%; border-collapse: collapse; font-size: 0.875rem; min-width: 900px; }
  .data-table th { text-align: left; padding: 0.5rem 0.75rem; border-bottom: 2px solid #e5e7eb; font-weight: 500; color: #6b7280; font-size: 0.75rem; text-transform: uppercase; white-space: nowrap; }
  .data-table td { padding: 0.5rem 0.75rem; border-bottom: 1px solid #f3f4f6; }
  .sortable { cursor: pointer; user-select: none; }
  .sortable:hover { color: #111827; }
  .font-medium { font-weight: 500; }
  .positive { color: #16a34a; font-weight: 500; }
  .negative { color: #dc2626; font-weight: 500; }
  .empty-text { color: #6b7280; font-size: 0.875rem; }
  .events-cell { max-width: 200px; }
  .event-tag { display: inline-block; background: #f3f4f6; border-radius: 0.25rem; padding: 0.125rem 0.5rem; font-size: 0.75rem; margin: 0.125rem; color: #374151; }
</style>
