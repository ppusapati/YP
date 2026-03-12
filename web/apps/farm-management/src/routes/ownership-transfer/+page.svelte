<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { ownershipTransferSchema } from '@samavāya/agriculture/schemas';
  import { farmClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await farmClient.transferOwnership(formValues as any);
      goto('/farm-owners');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to transfer ownership';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="Transfer Ownership"
  subtitle="Transfer farm ownership to a new owner"
  mode="create"
  schema={ownershipTransferSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/farm-owners"
  onSubmit={handleSubmit}
/>
