<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { sensorFormSchema } from '@samavāya/agriculture/schemas';
  import { sensorClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = { status: 'online', reading_interval_seconds: 300 };
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await sensorClient.registerSensor(formValues as any);
      goto('/sensors');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to register sensor';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="New Sensor"
  subtitle="Register a new IoT sensor"
  mode="create"
  schema={sensorFormSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/sensors"
  onSubmit={handleSubmit}
/>
