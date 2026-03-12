<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { irrigationScheduleFormSchema } from '@samavāya/agriculture/schemas';
  import { irrigationClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = { status: 'draft', is_active: false, schedule_type: 'time_based', trigger_condition: 'none' };
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await irrigationClient.createSchedule(formValues as any);
      goto('/irrigation');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to create irrigation schedule';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="New Irrigation Schedule"
  subtitle="Create a new irrigation schedule"
  mode="create"
  schema={irrigationScheduleFormSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/irrigation"
  onSubmit={handleSubmit}
/>
