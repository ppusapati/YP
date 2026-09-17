<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { ownershipTransferSchema } from '@samavāya/agriculture/schemas';
  import { farmClient } from '@samavāya/agriculture/services';
  import { numberValue, stringValue } from '@samavāya/agriculture/convert';

  /**
   * Transferring farm ownership.
   *
   * The form's inputs carry the proto's snake_case names and the generated
   * client uses camelCase, so `transferOwnership(formValues as any)` handed
   * protobuf-es keys it does not recognise and sent an empty request. This one
   * failed visibly rather than silently — the service rejects it for a missing
   * farm_id — which is the only reason it was not mistaken for working.
   */

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await farmClient.transferOwnership({
        farmId: stringValue(formValues.farm_id),
        fromUserId: stringValue(formValues.from_user_id),
        toUserId: stringValue(formValues.to_user_id),
        toOwnerName: stringValue(formValues.to_owner_name),
        toEmail: stringValue(formValues.to_email),
        toPhone: stringValue(formValues.to_phone),
        ownershipPercentage: numberValue(formValues.ownership_percentage) ?? 0,
      });
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
