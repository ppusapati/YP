<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { sensorService } from '@samavāya/agriculture/services';
  import type { Sensor } from '@samavāya/agriculture/types';

  let rows: Sensor[] = [];
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'name', label: 'Sensor Name' },
    { key: 'code', label: 'Code' },
    { key: 'sensor_type', label: 'Type' },
    { key: 'manufacturer', label: 'Manufacturer' },
    { key: 'battery_level', label: 'Battery %' },
    { key: 'last_reading_at', label: 'Last Reading' },
    { key: 'status', label: 'Status' },
  ];

  async function fetchData() {
    loading = true;
    error = null;
    try {
      const res = await sensorService.list({ page: 1, page_size: 50 });
      rows = res.items;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load sensors';
      rows = [];
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
  {fetchData}
/>
