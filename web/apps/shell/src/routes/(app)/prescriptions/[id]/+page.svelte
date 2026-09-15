<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { prescriptionClient } from '@samavāya/agriculture/services';
  import {
    PrescriptionType,
    type PrescriptionBundle,
    type PrescriptionMap,
    type ZoneSummary,
  } from '@samavāya/proto';

  /**
   * One prescription bundle, over the message the service returns.
   *
   * The response is `{ prescription: PrescriptionBundle }`; this page assigned
   * the whole response and read `prescription.cropType`, `prescription.zones`,
   * `prescription.zoneGrid`, `prescription.totalArea`, `prescription.avgRate`
   * and `prescription.uniformRate` off it. The first six were one level too
   * shallow and the last three do not exist on the bundle at all, so every
   * field on the page rendered an em dash and both tables said "no data".
   *
   * A bundle carries several prescription maps — fertilizer, irrigation,
   * seeding, liming — each with its own rate grid and unit, so the map is
   * chosen rather than assumed.
   */

  let bundle: PrescriptionBundle | undefined;
  let zones: ZoneSummary[] = [];
  let maps: PrescriptionMap[] = [];
  let selectedMapId = '';
  let loading = true;
  let error: string | null = null;

  $: id = $page.params.id ?? '';

  $: if (id) loadData(id);

  $: selectedMap = maps.find((m) => m.id === selectedMapId) ?? maps[0];

  /**
   * Rate range across the selected map, so cells are shaded relative to what
   * this field actually gets rather than against a hard-coded scale.
   */
  $: rateValues = selectedMap?.rates.flatMap((r) => r.values) ?? [];
  $: minRate = rateValues.length ? Math.min(...rateValues) : 0;
  $: maxRate = rateValues.length ? Math.max(...rateValues) : 0;

  async function loadData(prescriptionId: string) {
    loading = true;
    error = null;
    try {
      const res = await prescriptionClient.getPrescription({ id: prescriptionId });
      bundle = res.prescription;
      zones = bundle?.zoneSummaries ?? [];
      maps = bundle?.prescriptions ?? [];
      selectedMapId = maps[0]?.id ?? '';
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load prescription';
    } finally {
      loading = false;
    }
  }

  function typeLabel(t: PrescriptionType | undefined): string {
    if (t === undefined) return '—';
    const name = PrescriptionType[t];
    if (!name || name === 'UNSPECIFIED') return '—';
    return name.charAt(0) + name.slice(1).toLowerCase();
  }

  /** Where a rate sits in the map's range: low, medium or high. */
  function band(rate: number): 'low' | 'medium' | 'high' {
    if (maxRate <= minRate) return 'medium';
    const t = (rate - minRate) / (maxRate - minRate);
    if (t < 1 / 3) return 'low';
    if (t < 2 / 3) return 'medium';
    return 'high';
  }

  function zoneColor(zone: string): string {
    const colors: Record<string, string> = {
      low: '#dcfce7',
      medium: '#fef3c7',
      high: '#fee2e2',
    };
    return colors[zone?.toLowerCase()] || '#f3f4f6';
  }

  function zoneBorder(zone: string): string {
    const colors: Record<string, string> = {
      low: '#86efac',
      medium: '#fcd34d',
      high: '#fca5a5',
    };
    return colors[zone?.toLowerCase()] || '#d1d5db';
  }

  function round(n: number | undefined): string {
    return n === undefined ? '—' : String(Math.round(n * 100) / 100);
  }
</script>

<div class="page-container">
  <header class="page-header">
    <div class="header-row">
      <div>
        <h1>Prescription Detail</h1>
        <p class="subtitle">Variable-rate prescription for {bundle?.fieldName || bundle?.fieldId || id}</p>
      </div>
      <div class="header-actions">
        <button
          class="rounded-md bg-blue-600 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-500"
          on:click={() => goto(`/prescriptions/${id}/export`)}
        >Export</button>
        <button
          class="rounded-md bg-gray-200 px-4 py-2 text-sm font-semibold text-gray-700 hover:bg-gray-300"
          on:click={() => goto('/prescriptions')}
        >Back to Prescriptions</button>
      </div>
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
  {:else}
    <!-- Prescription Info -->
    <div class="page-content">
      <div class="detail-grid">
        <div class="detail-field">
          <span class="detail-label">Field</span>
          <span class="detail-value">{bundle?.fieldName || bundle?.fieldId || '—'}</span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Crop Type</span>
          <span class="detail-value">{bundle?.cropType || '—'}</span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Target Yield</span>
          <span class="detail-value">{round(bundle?.targetYield)} <small>t/ha</small></span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Created</span>
          <span class="detail-value">{bundle?.createdAt ? new Date(bundle.createdAt).toLocaleDateString() : '—'}</span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Est. Cost Savings</span>
          <span class="detail-value savings">{bundle ? `$${round(bundle.estimatedCostSavings)}` : '—'}</span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Est. Yield Gain</span>
          <span class="detail-value">{round(bundle?.estimatedYieldGain)} <small>t/ha</small></span>
        </div>
      </div>
    </div>

    <!-- Zone Map Visualization -->
    <div class="page-content mt-4">
      <div class="map-header">
        <h2 class="section-title">Rate Map</h2>
        {#if maps.length > 1}
          <!-- A bundle can carry a fertilizer map and an irrigation map with
               different units; showing the first and calling it "the" zone map
               hid the others entirely. -->
          <select bind:value={selectedMapId} aria-label="Prescription layer">
            {#each maps as m}
              <option value={m.id}>{typeLabel(m.prescriptionType)}</option>
            {/each}
          </select>
        {/if}
      </div>

      {#if selectedMap && selectedMap.rates.length > 0}
        <p class="map-caption">
          {typeLabel(selectedMap.prescriptionType)} — {round(minRate)} to {round(maxRate)}
          {selectedMap.unit}, averaging {round(selectedMap.avgRate)}
        </p>
        <div class="zone-map">
          {#each selectedMap.rates as row}
            <div class="zone-row">
              {#each row.values as rate}
                <div
                  class="zone-cell"
                  style="background: {zoneColor(band(rate))}; border-color: {zoneBorder(band(rate))}"
                  title="{round(rate)} {selectedMap.unit}"
                >
                  <span class="cell-rate">{round(rate)}</span>
                </div>
              {/each}
            </div>
          {/each}
        </div>
        <div class="zone-legend">
          <div class="legend-item"><span class="legend-swatch" style="background: #dcfce7; border: 1px solid #86efac;"></span> Low</div>
          <div class="legend-item"><span class="legend-swatch" style="background: #fef3c7; border: 1px solid #fcd34d;"></span> Medium</div>
          <div class="legend-item"><span class="legend-swatch" style="background: #fee2e2; border: 1px solid #fca5a5;"></span> High</div>
        </div>
      {:else}
        <p class="empty-text">No rate map data available</p>
      {/if}
    </div>

    <!-- Zone Summary Table -->
    <div class="page-content mt-4">
      <h2 class="section-title">Zone Summary</h2>
      {#if zones.length > 0}
        <table class="data-table">
          <thead>
            <tr>
              <th>Zone</th>
              <th>Area (ha)</th>
              <th>Min Rate</th>
              <th>Mean Rate</th>
              <th>Max Rate</th>
              <th>Total Amount</th>
            </tr>
          </thead>
          <tbody>
            {#each zones as zone}
              <tr>
                <td>
                  <span class="zone-badge" style="background: {zoneColor(zone.zone)}; border: 1px solid {zoneBorder(zone.zone)}">
                    {zone.zone || '—'}
                  </span>
                </td>
                <td>{round(zone.areaHectares)}</td>
                <td>{round(zone.minRate)}</td>
                <td>{round(zone.meanRate)}</td>
                <td>{round(zone.maxRate)}</td>
                <td>{round(zone.totalAmount)}</td>
              </tr>
            {/each}
          </tbody>
        </table>
      {:else}
        <p class="empty-text">No zone summary data available</p>
      {/if}
    </div>

    <!-- Totals, summed from the zone summaries rather than invented -->
    <div class="page-content mt-4">
      <h2 class="section-title">Totals</h2>
      <!--
        This panel read `totalArea`, `totalAmount`, `avgRate` and `uniformRate`
        off the bundle. None of the four is a field on `PrescriptionBundle`, so
        all four showed an em dash. The first two are the sum of the zone
        summaries, and the average rate belongs to the selected map. There is
        no uniform-rate comparison anywhere in the service, so it is not shown.
      -->
      <div class="detail-grid">
        <div class="detail-field">
          <span class="detail-label">Total Area</span>
          <span class="detail-value">{round(zones.reduce((a, z) => a + z.areaHectares, 0))} <small>ha</small></span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Total Amount</span>
          <span class="detail-value">{round(zones.reduce((a, z) => a + z.totalAmount, 0))} <small>{selectedMap?.unit ?? ''}</small></span>
        </div>
        <div class="detail-field">
          <span class="detail-label">Avg Rate</span>
          <span class="detail-value">{round(selectedMap?.avgRate)} <small>{selectedMap?.unit ?? ''}/ha</small></span>
        </div>
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
  .header-actions { display: flex; gap: 0.5rem; flex-wrap: wrap; }
  .page-content { background: #fff; border: 1px solid #e5e7eb; border-radius: 0.5rem; padding: 1.5rem; }
  .error-banner { color: #dc2626; }
  .section-title { font-size: 1rem; font-weight: 600; margin: 0 0 1rem 0; }
  .detail-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1rem; }
  .map-header { display: flex; align-items: center; justify-content: space-between; gap: 1rem; flex-wrap: wrap; }
  .map-header select { padding: 0.375rem 0.75rem; border: 1px solid #d1d5db; border-radius: 0.375rem; font-size: 0.875rem; background: #fff; }
  .map-caption { font-size: 0.8125rem; color: #6b7280; margin: 0 0 0.75rem 0; }
  .detail-field { display: flex; flex-direction: column; gap: 0.25rem; }
  .detail-label { font-size: 0.75rem; font-weight: 500; color: #6b7280; text-transform: uppercase; }
  .detail-value { font-size: 0.875rem; color: #111827; }
  .detail-value small { font-size: 0.75rem; color: #6b7280; }
  .detail-value.savings { color: #16a34a; font-weight: 600; font-size: 1rem; }
  .zone-map { display: inline-grid; gap: 2px; padding: 0.5rem; background: #f9fafb; border-radius: 0.5rem; border: 1px solid #e5e7eb; }
  .zone-row { display: flex; gap: 2px; }
  .zone-cell { width: 40px; height: 40px; border-radius: 0.25rem; border: 1px solid; display: flex; align-items: center; justify-content: center; }
  .cell-rate { font-size: 0.625rem; font-weight: 500; color: #374151; }
  .zone-legend { display: flex; gap: 1rem; margin-top: 0.75rem; }
  .legend-item { display: flex; align-items: center; gap: 0.375rem; font-size: 0.75rem; color: #374151; }
  .legend-swatch { width: 16px; height: 16px; border-radius: 0.25rem; display: inline-block; }
  .data-table { width: 100%; border-collapse: collapse; font-size: 0.875rem; }
  .data-table th { text-align: left; padding: 0.5rem 0.75rem; border-bottom: 2px solid #e5e7eb; font-weight: 500; color: #6b7280; font-size: 0.75rem; text-transform: uppercase; }
  .data-table td { padding: 0.5rem 0.75rem; border-bottom: 1px solid #f3f4f6; }
  .zone-badge { display: inline-block; padding: 0.125rem 0.5rem; border-radius: 0.25rem; font-size: 0.75rem; font-weight: 500; text-transform: capitalize; }
  .empty-text { color: #6b7280; font-size: 0.875rem; }
  .mt-4 { margin-top: 1rem; }
</style>
