<script lang="ts">
  import { goto } from '$app/navigation';
  import { CrudFormPage } from '@samavāya/ui';
  import { generateTilesetFormSchema } from '@samavāya/agriculture/schemas';
  import { tileClient } from '@samavāya/agriculture/services';

  let values: Record<string, unknown> = { format: '3', minZoom: 10, maxZoom: 18 };
  let errors: Record<string, string> = {};
  let isSubmitting = false;
  let error: string | null = null;

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await tileClient.generateTileset(formValues as any);
      goto('/tilesets');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to generate tileset';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<CrudFormPage
  title="Generate Tileset"
  subtitle="Create map tiles from processed satellite imagery"
  mode="create"
  schema={generateTilesetFormSchema}
  {values}
  {errors}
  {isSubmitting}
  {error}
  cancelHref="/tilesets"
  onSubmit={handleSubmit}
/>
