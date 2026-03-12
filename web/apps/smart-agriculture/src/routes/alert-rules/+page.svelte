<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { sensorClient } from '@samavāya/agriculture/services';

  let rows: any[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'sensor_name', label: 'Sensor' },
    { key: 'metric', label: 'Metric' },
    { key: 'condition', label: 'Condition' },
    { key: 'threshold', label: 'Threshold', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'severity', label: 'Severity' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await sensorClient.listAlertRules({ pageSize, pageOffset });
      rows = res.rules;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load alert rules';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Alert Rules"
  createHref="/alert-rules/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  {totalCount}
  onRowClick={(id) => goto(`/alert-rules/${id}`)}
  {fetchData}
/>
