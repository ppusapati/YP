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
    { key: 'severity', label: 'Severity' },
    { key: 'message', label: 'Message' },
    { key: 'triggered_at', label: 'Triggered At' },
    { key: 'acknowledged', label: 'Acknowledged', format: (v: unknown) => v ? 'Yes' : 'No' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await sensorClient.getAlerts({ pageSize, pageOffset });
      rows = res.alerts;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load sensor alerts';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Sensor Alerts"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  {totalCount}
  onRowClick={(id) => goto(`/sensor-alerts/${id}`)}
  {fetchData}
/>
