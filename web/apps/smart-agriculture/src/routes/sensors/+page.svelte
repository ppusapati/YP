<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { sensorClient } from '@samavāya/agriculture/services';
  import type { Sensor } from '@samavāya/agriculture/types';

  let rows: Sensor[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'name', label: 'Sensor Name' },
    { key: 'code', label: 'Code' },
    { key: 'sensorType', label: 'Type' },
    { key: 'manufacturer', label: 'Manufacturer' },
    { key: 'batteryLevelPct', label: 'Battery %' },
    { key: 'lastReadingAt', label: 'Last Reading' },
    { key: 'status', label: 'Status' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await sensorClient.listSensors({ pageSize, pageOffset });
      rows = res.sensors;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load sensors';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Sensors"
  createHref="/sensors/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  onRowClick={(id) => goto(`/sensors/${id}`)}
  {totalCount}
  {fetchData}
/>
