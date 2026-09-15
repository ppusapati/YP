<script lang="ts">
  import type { PageData } from './$types';

  let { data }: { data: PageData } = $props();

  // The list arrives already sorted so the tenants needing attention come
  // first — degraded, unknown, quiet, suspended, then healthy. That ordering is
  // the server's job rather than a default sort here, because a page sorted by
  // name buries the one broken tenant among nine hundred working ones.

  const counts = $derived(() => {
    const by: Record<string, number> = {
      degraded: 0, unknown: 0, quiet: 0, suspended: 0, ok: 0,
    };
    for (const t of data.tenants) by[t.health] = (by[t.health] ?? 0) + 1;
    return by;
  });

  const totals = $derived(() =>
    data.tenants.reduce(
      (acc, t) => ({
        farms: acc.farms + t.farms,
        fields: acc.fields + t.fields,
        sensors: acc.sensors + t.sensors,
        users: acc.users + t.users,
      }),
      { farms: 0, fields: 0, sensors: 0, users: 0 },
    ),
  );

  const HEALTH_LABEL: Record<string, string> = {
    ok: 'Healthy',
    quiet: 'Quiet',
    degraded: 'Needs attention',
    suspended: 'Suspended',
    unknown: 'Not measured',
  };

  function relative(iso?: string): string {
    if (!iso) return 'never';
    const then = new Date(iso).getTime();
    if (Number.isNaN(then)) return 'unknown';
    const days = Math.floor((Date.now() - then) / 86_400_000);
    if (days < 1) return 'today';
    if (days === 1) return 'yesterday';
    if (days < 30) return `${days} days ago`;
    return `${Math.floor(days / 30)} months ago`;
  }

  // Shown next to the counts rather than hidden. A snapshot taken six hours
  // ago presented as current is how an operator concludes nothing is wrong.
  function staleness(iso?: string): string {
    if (!iso) return 'not measured';
    const mins = Math.floor((Date.now() - new Date(iso).getTime()) / 60_000);
    if (mins < 2) return 'just now';
    if (mins < 60) return `${mins} min ago`;
    return `${Math.floor(mins / 60)} h ago`;
  }
</script>

<svelte:head>
  <title>Platform - samavāya</title>
</svelte:head>

<div class="platform">
  <header>
    <h2>Platform</h2>
    <p class="subtitle">
      Aggregate health across every tenant. Counts only — no tenant's own
      records are readable from here.
    </p>
  </header>

  <section class="summary">
    <div class="chip" class:urgent={counts().degraded > 0}>
      <span class="chip-value">{counts().degraded}</span>
      <span class="chip-label">need attention</span>
    </div>
    <div class="chip">
      <span class="chip-value">{data.tenants.length}</span>
      <span class="chip-label">tenants</span>
    </div>
    <div class="chip">
      <span class="chip-value">{totals().farms.toLocaleString()}</span>
      <span class="chip-label">farms</span>
    </div>
    <div class="chip">
      <span class="chip-value">{totals().fields.toLocaleString()}</span>
      <span class="chip-label">fields</span>
    </div>
    <div class="chip">
      <span class="chip-value">{totals().sensors.toLocaleString()}</span>
      <span class="chip-label">sensors</span>
    </div>
  </section>

  {#if data.tenants.length === 0}
    <p class="empty">No tenants are provisioned.</p>
  {:else}
    <div class="table-scroll">
      <table>
        <thead>
          <tr>
            <th>Tenant</th>
            <th>Health</th>
            <th class="num">Farms</th>
            <th class="num">Fields</th>
            <th class="num">Sensors</th>
            <th class="num">Users</th>
            <th>Last activity</th>
            <th>Measured</th>
          </tr>
        </thead>
        <tbody>
          {#each data.tenants as t (t.tenant_id)}
            <tr class:attention={t.health === 'degraded'}>
              <td>
                <span class="name">{t.name}</span>
                <span class="meta">{t.region || '—'} · {t.type}</span>
              </td>
              <td>
                <span class="health health-{t.health}">{HEALTH_LABEL[t.health] ?? t.health}</span>
                {#if t.health_reason}
                  <span class="meta">{t.health_reason}</span>
                {/if}
              </td>
              <td class="num">{t.farms.toLocaleString()}</td>
              <td class="num">{t.fields.toLocaleString()}</td>
              <td class="num">{t.sensors.toLocaleString()}</td>
              <td class="num">{t.users.toLocaleString()}</td>
              <td>{relative(t.last_activity_at)}</td>
              <td class="meta">{staleness(t.usage_gathered_at)}</td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  {/if}
</div>

<style>
  .platform {
    display: flex;
    flex-direction: column;
    gap: var(--spacing-lg, 1.5rem);
  }

  h2 {
    margin: 0;
    font-size: 1.5rem;
    font-weight: 600;
  }

  .subtitle {
    margin: 0.25rem 0 0;
    color: var(--color-text-secondary, #666);
    font-size: 0.875rem;
  }

  .summary {
    display: flex;
    flex-wrap: wrap;
    gap: var(--spacing-md, 1rem);
  }

  .chip {
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
    padding: 0.75rem 1.25rem;
    border: 1px solid var(--color-border, #e5e5e5);
    border-radius: var(--radius-md, 8px);
    background: var(--color-surface, #fff);
  }

  /* The only coloured chip. If everything is highlighted, nothing is. */
  .chip.urgent {
    border-color: #c0392b;
  }

  .chip-value {
    font-size: 1.5rem;
    font-weight: 600;
    font-variant-numeric: tabular-nums;
  }

  .chip-label {
    font-size: 0.75rem;
    color: var(--color-text-secondary, #666);
  }

  .table-scroll {
    overflow-x: auto;
  }

  table {
    width: 100%;
    border-collapse: collapse;
    font-size: 0.875rem;
  }

  th,
  td {
    padding: 0.625rem 0.75rem;
    text-align: left;
    border-bottom: 1px solid var(--color-border, #e5e5e5);
    vertical-align: top;
  }

  th {
    font-weight: 600;
    font-size: 0.75rem;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    color: var(--color-text-secondary, #666);
  }

  .num {
    text-align: right;
    font-variant-numeric: tabular-nums;
  }

  tr.attention {
    background: rgba(192, 57, 43, 0.04);
  }

  .name {
    display: block;
    font-weight: 500;
  }

  .meta {
    display: block;
    font-size: 0.75rem;
    color: var(--color-text-secondary, #666);
  }

  .health {
    display: inline-block;
    padding: 0.125rem 0.5rem;
    border-radius: 999px;
    font-size: 0.75rem;
    font-weight: 500;
  }

  .health-ok {
    background: rgba(45, 122, 62, 0.12);
    color: #2d7a3e;
  }
  .health-degraded {
    background: rgba(192, 57, 43, 0.12);
    color: #c0392b;
  }
  .health-quiet,
  .health-suspended,
  .health-unknown {
    background: var(--color-border, #eee);
    color: var(--color-text-secondary, #666);
  }

  .empty {
    color: var(--color-text-secondary, #666);
  }
</style>
