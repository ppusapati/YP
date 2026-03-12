<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { CrudFormPage } from '@samavāya/ui';
  import { sensorFormSchema } from '@samavāya/agriculture/schemas';
  import { sensorClient } from '@samavāya/agriculture/services';

  $: id = $page.params.id;

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isLoading = true;
  let isSubmitting = false;
  let error: string | null = null;

  onMount(async () => {
    try {
      const res = await sensorClient.getSensor({ id });
      values = { ...res.sensor };
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load sensor';
    } finally {
      isLoading = false;
    }
  });

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await sensorClient.updateSensor({ id, ...formValues } as any);
      goto('/sensors');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to update sensor';
    } finally {
      isSubmitting = false;
    }
  }

  async function handleDelete() {
    try {
      await sensorClient.decommissionSensor({ id });
      goto('/sensors');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to delete sensor';
    }
  }
</script>

<CrudFormPage
  title="Edit Sensor"
  subtitle="Update sensor configuration"
  mode="edit"
  schema={sensorFormSchema}
  {values}
  {errors}
  {isLoading}
  {isSubmitting}
  {error}
  cancelHref="/sensors"
  showDelete={true}
  onSubmit={handleSubmit}
  onDelete={handleDelete}
/>
