<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { alertRuleSchema } from '@samavāya/agriculture/schemas';
  import { sensorClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await sensorClient.createAlertRule(formValues as any);
      goto('/alert-rules');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to create alert rule';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="Create Alert Rule"
  subtitle="Define a new sensor alert rule"
  mode="create"
  schema={alertRuleSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/alert-rules"
  onSubmit={handleSubmit}
/>
