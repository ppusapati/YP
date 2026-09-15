<script lang="ts">
  import { authStore } from '@samavāya/stores';
  import { alertClient, farmClient, fieldClient } from '@samavāya/agriculture/services';

  // This dashboard used to render hardcoded numbers — $125,430 revenue, 1,234
  // orders, 856 customers — under a live greeting with the signed-in user's
  // name. Someone looking at it believed they were seeing their own tenant's
  // figures. The quick-action links went to /sales/orders/new and
  // /finance/invoices/new, routes this agriculture application does not have.
  //
  // Everything below is fetched. Where a figure cannot be fetched it is shown
  // as unavailable, never as a number.

  type Metric = {
    label: string;
    /** null while loading or when the call failed. */
    value: number | null;
    href: string;
    /** Set when the figure could not be retrieved. */
    error?: string;
  };

  let metrics = $state<Metric[]>([
    { label: 'Farms', value: null, href: '/farm-management' },
    { label: 'Fields', value: null, href: '/farm-management' },
    { label: 'Unread alerts', value: null, href: '/alerts' },
  ]);
  let loading = $state(true);

  /**
   * Fetch one figure, reporting failure rather than falling back to zero.
   *
   * Zero is a real answer — a tenant genuinely may have no farms — so
   * substituting it for "we could not ask" would make an outage look like an
   * empty account.
   */
  async function fetchCount(index: number, load: () => Promise<number>) {
    try {
      const value = await load();
      metrics[index] = { ...metrics[index], value, error: undefined };
    } catch (err) {
      metrics[index] = {
        ...metrics[index],
        value: null,
        error: err instanceof Error ? err.message : 'unavailable',
      };
    }
  }

  $effect(() => {
    // pageSize 1 because only the total is wanted; asking for a full page of
    // rows to count them would be a waste on every dashboard load.
    void Promise.all([
      fetchCount(0, async () => (await farmClient.listFarms({ pageSize: 1 })).totalCount),
      fetchCount(1, async () => (await fieldClient.listFields({ pageSize: 1 })).totalCount),
      // An empty farmId counts across the whole tenant.
      fetchCount(2, async () => (await alertClient.getUnreadCount({ farmId: '' })).count),
    ]).finally(() => {
      loading = false;
    });
  });

  const displayName = $derived($authStore.user?.displayName ?? '');
</script>

<svelte:head>
  <title>Dashboard - samavāya</title>
</svelte:head>

<div class="dashboard">
  <section class="welcome-section">
    <h2 class="welcome-title">
      {displayName ? `Welcome back, ${displayName}` : 'Dashboard'}
    </h2>
    <p class="welcome-subtitle">An overview of your farms and fields.</p>
  </section>

  <section class="metrics-section">
    <div class="metrics-grid">
      {#each metrics as metric}
        <a class="metric-card" href={metric.href}>
          <span class="metric-label">{metric.label}</span>
          {#if metric.value !== null}
            <span class="metric-value">{metric.value.toLocaleString()}</span>
          {:else if loading}
            <span class="metric-value metric-pending" aria-label="Loading">—</span>
          {:else}
            <span class="metric-value metric-unavailable" title={metric.error}>
              Unavailable
            </span>
          {/if}
        </a>
      {/each}
    </div>
  </section>

  <section class="quick-actions-section card">
    <h3 class="section-title">Quick actions</h3>
    <!--
      Only routes that exist. The previous set linked to /sales/orders/new,
      /finance/invoices/new and /masters/customers/new, none of which are
      mounted in this application.
    -->
    <div class="quick-actions-grid">
      <a href="/farm-management" class="quick-action">Farms and fields</a>
      <a href="/crop-intelligence/diagnose" class="quick-action">Diagnose a plant</a>
      <a href="/smart-agriculture/field-health" class="quick-action">Field health</a>
      <a href="/prescriptions" class="quick-action">Prescriptions</a>
      <a href="/alerts" class="quick-action">Alerts</a>
      <a href="/analytics" class="quick-action">Analytics</a>
    </div>
  </section>
</div>

<style>
  .dashboard {
    display: flex;
    flex-direction: column;
    gap: var(--spacing-lg, 1.5rem);
  }

  .welcome-title {
    margin: 0;
    font-size: 1.5rem;
    font-weight: 600;
  }

  .welcome-subtitle {
    margin: 0.25rem 0 0;
    color: var(--color-text-secondary, #666);
    font-size: 0.875rem;
  }

  .metrics-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: var(--spacing-md, 1rem);
  }

  .metric-card {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    padding: var(--spacing-md, 1rem);
    border: 1px solid var(--color-border, #e5e5e5);
    border-radius: var(--radius-md, 8px);
    background: var(--color-surface, #fff);
    text-decoration: none;
    color: inherit;
  }

  .metric-card:hover {
    border-color: var(--color-primary, #2d7a3e);
  }

  .metric-label {
    font-size: 0.8125rem;
    color: var(--color-text-secondary, #666);
  }

  .metric-value {
    font-size: 1.75rem;
    font-weight: 600;
    font-variant-numeric: tabular-nums;
  }

  /* An unavailable figure reads as text, not as a number, so it cannot be
     mistaken for one at a glance. */
  .metric-unavailable {
    font-size: 1rem;
    font-weight: 500;
    color: var(--color-text-secondary, #666);
  }

  .metric-pending {
    color: var(--color-text-secondary, #999);
  }

  .card {
    padding: var(--spacing-md, 1rem);
    border: 1px solid var(--color-border, #e5e5e5);
    border-radius: var(--radius-md, 8px);
    background: var(--color-surface, #fff);
  }

  .section-title {
    margin: 0 0 var(--spacing-md, 1rem);
    font-size: 1rem;
    font-weight: 600;
  }

  .quick-actions-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
    gap: var(--spacing-sm, 0.5rem);
  }

  .quick-action {
    padding: 0.75rem 1rem;
    border: 1px solid var(--color-border, #e5e5e5);
    border-radius: var(--radius-sm, 6px);
    text-decoration: none;
    color: inherit;
    font-size: 0.875rem;
  }

  .quick-action:hover {
    border-color: var(--color-primary, #2d7a3e);
  }
</style>
