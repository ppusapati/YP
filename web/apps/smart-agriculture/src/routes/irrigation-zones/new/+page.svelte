<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { irrigationZoneFormSchema } from '@samavāya/agriculture/schemas';
  import { irrigationClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await irrigationClient.createZone(formValues as any);
      goto('/irrigation-zones');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to create irrigation zone';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="Create Irrigation Zone"
  subtitle="Define a new irrigation zone and its boundaries"
  mode="create"
  schema={irrigationZoneFormSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/irrigation-zones"
  onSubmit={handleSubmit}
/>
