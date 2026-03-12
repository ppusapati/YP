<script lang="ts">
  import { goto } from '$app/navigation';
  import { EntityListPage } from '@samavāya/agriculture/components';
  import { irrigationScheduleService } from '@samavāya/agriculture/services';
  import type { IrrigationSchedule } from '@samavāya/agriculture/types';

  let rows: IrrigationSchedule[] = [];
  let loading = true;
  let error: string | null = null;

  const columns = [
    { key: 'schedule_name', label: 'Schedule' },
    { key: 'field_id', label: 'Field' },
    { key: 'schedule_type', label: 'Type' },
    { key: 'start_time', label: 'Start Time' },
    { key: 'duration_minutes', label: 'Duration (min)' },
    { key: 'is_active', label: 'Active', format: (v: unknown) => v ? 'Yes' : 'No' },
    { key: 'status', label: 'Status' },
  ];

  async function fetchData() {
    loading = true;
    error = null;
    try {
      const res = await irrigationScheduleService.list({ page: 1, page_size: 50 });
      rows = res.items;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load irrigation schedules';
      rows = [];
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
  {fetchData}
/>
