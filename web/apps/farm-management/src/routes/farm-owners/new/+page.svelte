<script lang="ts">
  import { goto } from '$app/navigation';
  import { page } from '$app/stores';
  import { CrudFormPage } from '@samavāya/ui';
  import { farmOwnerSchema } from '@samavāya/agriculture/schemas';
  import { farmClient } from '@samavāya/agriculture/services';

  const farmId = $page.url.searchParams.get('farm_id') ?? '';

  let values: Record<string, unknown> = { farm_id: farmId, is_primary: false };
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await farmClient.transferOwnership({ ...formValues, farm_id: farmId || formValues.farm_id } as any);
      goto('/farm-owners');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to add farm owner';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="Add Farm Owner"
  subtitle="Add a new owner to a farm"
  mode="create"
  schema={farmOwnerSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/farm-owners"
  onSubmit={handleSubmit}
/>
