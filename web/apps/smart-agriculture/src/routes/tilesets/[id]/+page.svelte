<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { CrudFormPage } from '@samavāya/ui';
  import { generateTilesetFormSchema } from '@samavāya/agriculture/schemas';
  import { tileClient } from '@samavāya/agriculture/services';

  $: id = $page.params.id;

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isLoading = true;
  let isSubmitting = false;
  let error: string | null = null;

  onMount(async () => {
    try {
      const res = await tileClient.getTileset({ id });
      values = { ...res.tileset };
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load tileset';
    } finally {
      isLoading = false;
    }
  });

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await tileClient.updateTileset({ id, ...formValues } as any);
      goto('/tilesets');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to update tileset';
    } finally {
      isSubmitting = false;
    }
  }

  async function handleDelete() {
    try {
      await tileClient.deleteTileset({ id });
      goto('/tilesets');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to delete tileset';
    }
  }
</script>

<CrudFormPage
  title="Edit Tileset"
  subtitle="Update tileset configuration"
  mode="edit"
  schema={generateTilesetFormSchema}
  {values}
  {errors}
  {isLoading}
  {isSubmitting}
  {error}
  cancelHref="/tilesets"
  showDelete={true}
  onSubmit={handleSubmit}
  onDelete={handleDelete}
/>
