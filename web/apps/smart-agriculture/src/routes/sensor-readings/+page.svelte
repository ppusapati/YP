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
    { key: 'value', label: 'Value', format: (v: unknown) => v != null ? `${v}` : '—' },
    { key: 'unit', label: 'Unit' },
    { key: 'timestamp', label: 'Timestamp' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await sensorClient.getSensorReadings({ pageSize, pageOffset });
      rows = res.readings;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load sensor readings';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Sensor Readings"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  {totalCount}
  onRowClick={(id) => goto(`/sensor-readings/${id}`)}
  {fetchData}
/>
