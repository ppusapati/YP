<script lang="ts">
  import { goto } from '$app/navigation';
  import { alertClient } from '@samavāya/agriculture/services';

  interface FieldRisk {
    fieldId: string;
    fieldName: string;
    overallScore: number;
    riskFactors: Record<string, number>;
    calculatedAt: string;
    trend?: string;
  }

  let fieldRisks: FieldRisk[] = [];
  let loading = true;
  let error: string | null = null;
  let sortKey: 'overallScore' | 'fieldName' = 'overallScore';
  let sortDesc = true;

  loadFieldRisks();

  async function loadFieldRisks() {
    loading = true;
    error = null;
    try {
      const res = await alertClient.listFieldRisks({});
      fieldRisks = res.fieldRisks ?? [];
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load field risk scores';
    } finally {
      loading = false;
    }
  }

  $: sorted = [...fieldRisks].sort((a, b) => {
    if (sortKey === 'fieldName') {
      return sortDesc
        ? b.fieldName.localeCompare(a.fieldName)
        : a.fieldName.localeCompare(b.fieldName);
    }
    return sortDesc ? b.overallScore - a.overallScore : a.overallScore - b.overallScore;
  });

  function riskColor(score: number): string {
    if (score >= 80) return '#dc2626';
    if (score >= 60) return '#ea580c';
    if (score >= 40) return '#ca8a04';
    if (score >= 20) return '#65a30d';
    return '#16a34a';
  }

  function riskLabel(score: number): string {
    if (score >= 80) return 'Critical';
    if (score >= 60) return 'High';
    if (score >= 40) return 'Moderate';
    if (score >= 20) return 'Low';
    return 'Minimal';
  }

  function riskBg(score: number): string {
    if (score >= 80) return '#fef2f2';
    if (score >= 60) return '#fff7ed';
    if (score >= 40) return '#fefce8';
    return '#f0fdf4';
  }

  function trendDisplay(trend: string | undefined): string {
    switch (trend) {
      case 'increasing': return 'Rising';
      case 'decreasing': return 'Falling';
      case 'stable': return 'Stable';
      default: return '';
    }
  }

  // SVG gauge arc helpers.
  function gaugeArc(score: number): string {
    const clamped = Math.min(100, Math.max(0, score));
    const angle = (clamped / 100) * 270;
    const rad = (angle - 135) * (Math.PI / 180);
    const cx = 50, cy = 50, r = 40;
    const startRad = -135 * (Math.PI / 180);
    const x1 = cx + r * Math.cos(startRad);
    const y1 = cy + r * Math.sin(startRad);
    const x2 = cx + r * Math.cos(rad);
    const y2 = cy + r * Math.sin(rad);
    const largeArc = angle > 180 ? 1 : 0;
    return `M ${x1} ${y1} A ${r} ${r} 0 ${largeArc} 1 ${x2} ${y2}`;
  }

  function trackArc(): string {
    const cx = 50, cy = 50, r = 40;
    const startRad = -135 * (Math.PI / 180);
    const endRad = 135 * (Math.PI / 180);
    const x1 = cx + r * Math.cos(startRad);
    const y1 = cy + r * Math.sin(startRad);
    const x2 = cx + r * Math.cos(endRad);
    const y2 = cy + r * Math.sin(endRad);
    return `M ${x1} ${y1} A ${r} ${r} 0 1 1 ${x2} ${y2}`;
  }
</script>

<svelte:head>
  <title>Field Risk Overview - YieldPoint</title>
</svelte:head>

<div class="page-container">
  <div class="page-header">
    <h1>Field Risk Overview</h1>
    <p class="subtitle">Risk scores per field displayed as cards with gauge indicators</p>
  </div>

  {#if loading}
    <div class="page-content"><p>Loading field risk data...</p></div>
  {:else if error}
    <div class="page-content error-banner"><p>{error}</p></div>
  {:else if fieldRisks.length === 0}
    <div class="page-content empty"><p>No field risk data available.</p></div>
  {:else}
    <div class="fields-grid">
      {#each sorted as field (field.fieldId)}
        <button class="field-card" style:border-left-color={riskColor(field.overallScore)} on:click={() => goto(`/alerts?fieldId=${field.fieldId}`)}>
          <div class="field-header">
            <div>
              <h3 class="field-name">{field.fieldName}</h3>
              {#if field.trend}
                <span class="trend" style:color={field.trend === 'increasing' ? '#dc2626' : field.trend === 'decreasing' ? '#16a34a' : '#6b7280'}>
                  {trendDisplay(field.trend)}
                </span>
              {/if}
            </div>
            <span class="risk-badge" style:background={riskBg(field.overallScore)} style:color={riskColor(field.overallScore)}>
              {riskLabel(field.overallScore)}
            </span>
          </div>

          <div class="gauge-container">
            <svg viewBox="0 0 100 100" class="gauge-svg">
              <path d={trackArc()} fill="none" stroke="#e5e7eb" stroke-width="8" stroke-linecap="round" />
              {#if field.overallScore > 0}
                <path d={gaugeArc(field.overallScore)} fill="none" stroke={riskColor(field.overallScore)} stroke-width="8" stroke-linecap="round" />
              {/if}
              <text x="50" y="48" text-anchor="middle" font-size="16" font-weight="700" fill={riskColor(field.overallScore)}>
                {Math.round(field.overallScore)}%
              </text>
              <text x="50" y="62" text-anchor="middle" font-size="7" fill="#6b7280">
                {riskLabel(field.overallScore)}
              </text>
            </svg>
          </div>

          {#if Object.keys(field.riskFactors).length > 0}
            <div class="risk-breakdown">
              {#each Object.entries(field.riskFactors) as [factor, score]}
                <div class="risk-item">
                  <span class="risk-label">{factor.replace(/_/g, ' ')}</span>
                  <div class="factor-bar-track">
                    <div class="factor-bar" style:width="{score}%" style:background={riskColor(score)}></div>
                  </div>
                  <span class="risk-val" style:color={riskColor(score)}>{Math.round(score)}</span>
                </div>
              {/each}
            </div>
          {/if}

          <div class="card-footer">
            <span class="calculated-at">Updated {new Date(field.calculatedAt).toLocaleDateString()}</span>
          </div>
        </button>
      {/each}
    </div>
  {/if}

  <div class="back-link">
    <button class="btn btn-secondary" on:click={() => goto('/alerts')}>Back to Alerts</button>
  </div>
</div>

<style>
  .page-container { max-width: 1200px; margin: 0 auto; }
  .page-header { margin-bottom: 2rem; }
  .page-header h1 { font-size: 1.5rem; font-weight: 600; margin-bottom: 0.25rem; }
  .subtitle { color: #6b7280; font-size: 0.875rem; }
  .page-content { background: #fff; border: 1px solid #e5e7eb; border-radius: 0.5rem; padding: 1.5rem; }
  .error-banner { color: #dc2626; }
  .empty { text-align: center; color: #6b7280; }
  .fields-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 1rem; }
  .field-card { background: #fff; border: 1px solid #e5e7eb; border-left: 4px solid; border-radius: 0.75rem; padding: 1.25rem; text-align: left; cursor: pointer; width: 100%; transition: box-shadow 0.15s; }
  .field-card:hover { box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08); }
  .field-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.5rem; }
  .field-name { font-size: 1rem; font-weight: 600; margin: 0; }
  .trend { font-size: 0.75rem; font-weight: 500; }
  .risk-badge { padding: 0.25rem: 0.5rem; border-radius: 0.25rem; font-size: 0.7rem; font-weight: 600; text-transform: uppercase; padding: 0.25rem 0.5rem; }
  .gauge-container { display: flex; justify-content: center; padding: 0.25rem 0; }
  .gauge-svg { width: 120px; height: 120px; }
  .risk-breakdown { display: flex; flex-direction: column; gap: 0.375rem; margin-top: 0.5rem; padding-top: 0.5rem; border-top: 1px solid #f3f4f6; }
  .risk-item { display: flex; align-items: center; gap: 0.5rem; }
  .risk-label { font-size: 0.75rem; color: #6b7280; width: 70px; text-transform: capitalize; flex-shrink: 0; }
  .factor-bar-track { flex: 1; height: 6px; background: #f3f4f6; border-radius: 3px; overflow: hidden; }
  .factor-bar { height: 100%; border-radius: 3px; min-width: 2px; transition: width 0.3s; }
  .risk-val { font-size: 0.75rem; font-weight: 600; width: 1.5rem; text-align: right; }
  .card-footer { margin-top: 0.75rem; padding-top: 0.5rem; border-top: 1px solid #f3f4f6; }
  .calculated-at { font-size: 0.7rem; color: #9ca3af; }
  .back-link { margin-top: 1.5rem; }
  .btn { padding: 0.5rem 1rem; border-radius: 0.375rem; font-size: 0.875rem; font-weight: 500; cursor: pointer; border: 1px solid #d1d5db; }
  .btn-secondary { background: #fff; color: #374151; }
  .btn-secondary:hover { background: #f3f4f6; }
</style>
