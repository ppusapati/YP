<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { irrigationScheduleFormSchema } from '@samavāya/agriculture/schemas';
  import { irrigationClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await irrigationClient.createSchedule(formValues as any);
      goto('/irrigation-schedules');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to create irrigation schedule';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="Create Irrigation Schedule"
  subtitle="Configure a new irrigation schedule for your fields"
  mode="create"
  schema={irrigationScheduleFormSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/irrigation-schedules"
  onSubmit={handleSubmit}
/>
