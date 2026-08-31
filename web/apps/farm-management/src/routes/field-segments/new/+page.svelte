<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { fieldSegmentSchema } from '@samavāya/agriculture/schemas';
  import { fieldClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await fieldClient.segmentField(formValues as any);
      goto('/field-segments');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to create field segment';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="Create Field Segment"
  subtitle="Divide a field into segments"
  mode="create"
  schema={fieldSegmentSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/field-segments"
  onSubmit={handleSubmit}
/>
