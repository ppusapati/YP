<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { certificationFormSchema } from '@samavāya/agriculture/schemas';
  import { traceabilityClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = { status: 'active' };
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await traceabilityClient.createCertification(formValues as any);
      goto('/certifications');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to create certification';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="New Certification"
  subtitle="Register a new certification"
  mode="create"
  schema={certificationFormSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/certifications"
  onSubmit={handleSubmit}
/>
