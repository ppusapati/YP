<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { calibrateSensorSchema } from '@samavāya/agriculture/schemas';
  import { sensorClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await sensorClient.calibrateSensor(formValues as any);
      goto('/sensors');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to calibrate sensor';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="Sensor Calibration"
  subtitle="Calibrate a sensor with reference values"
  mode="create"
  schema={calibrateSensorSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/sensors"
  onSubmit={handleSubmit}
/>
