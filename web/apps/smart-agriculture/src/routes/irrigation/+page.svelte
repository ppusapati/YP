<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { irrigationClient } from '@samavāya/agriculture/services';
  import type { IrrigationSchedule } from '@samavāya/agriculture/types';

  let rows: IrrigationSchedule[] = [];
  let totalCount = 0;
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'name', label: 'Schedule' },
    { key: 'field_id', label: 'Field' },
    { key: 'scheduleType', label: 'Type' },
    { key: 'start_time', label: 'Start Time' },
    { key: 'duration_minutes', label: 'Duration (min)' },
    { key: 'is_active', label: 'Active', format: (v: unknown) => v ? 'Yes' : 'No' },
    { key: 'status', label: 'Status' },
  ];

  async function fetchData(pageOffset = 0, pageSize = 25): Promise<number> {
    loading = true;
    error = null;
    try {
      const res = await irrigationClient.listSchedules({ pageSize, pageOffset });
      rows = res.schedules;
      totalCount = res.totalCount;
      return res.totalCount;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load irrigation schedules';
      rows = [];
      return 0;
    } finally {
      loading = false;
    }
  }
</script>

<EntityListPage
  title="Irrigation Schedules"
  createHref="/irrigation/new"
  {columns}
  rows={rows as any}
  {loading}
  {error}
  onRowClick={(id) => goto(`/irrigation/${id}`)}
  {totalCount}
  {fetchData}
/>
