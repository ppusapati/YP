<script lang="ts">
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { alertClient, sensorClient } from '@samavāya/agriculture/services';

  let rows: any[] = [];
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'sensor_name', label: 'Sensor' },
    { key: 'metric', label: 'Metric' },
    { key: 'condition', label: 'Condition' },
    { key: 'threshold', label: 'Threshold', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'severity', label: 'Severity' },
  ];

  async function load() {
    // ListAlertRules takes a field id and returns that field's rules. There is
    // no page size and no total count — a field has as many rules as it has.
    const fieldId = $page.url.searchParams.get('fieldId') ?? '';
    if (!fieldId) {
      error = 'Choose a field to see its alert rules.';
      loading = false;
      return;
    }

    loading = true;
    error = null;
    try {
      const res = await alertClient.listAlertRules({ fieldId });
      rows = res.rules;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load alert rules';
      rows = [];
    } finally {
      loading = false;
    }
  }

  onMount(load);
</script>

<EntityListPage
  title="Alert Rules"
  createHref="/alert-rules/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  onRowClick={(id) => goto(`/alert-rules/${id}`)}
/>
