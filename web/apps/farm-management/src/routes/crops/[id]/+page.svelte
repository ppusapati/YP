<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { CrudFormPage } from '@samavāya/ui';
  import { createCropSchema } from '@samavāya/agriculture/schemas';
  import { cropClient } from '@samavāya/agriculture/services';
  import {
    CropCategorySchema,
    enumOption,
    enumValue,
    stringValue,
  } from '@samavāya/agriculture/convert';

  /**
   * Editing a crop.
   *
   * Mapped field by field in both directions. The spread this replaced was
   * wrong both ways and said nothing: loading copied the client's camelCase
   * fields into a form named after the proto's snake_case ones, so
   * `scientificName` never reached the `scientific_name` input; saving handed
   * protobuf-es keys it does not recognise, which it drops, so the request
   * succeeded and nothing changed.
   */

  $: id = $page.params.id;

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isLoading = true;
  let isSubmitting = false;
  let error: string | null = null;

  /**
   * The repeated string fields are edited as arrays of objects.
   *
   * The form's array editor gives each row a named sub-field — `disease`,
   * `plant` — while the proto holds a plain list of strings, so the two need
   * wrapping and unwrapping rather than passing through.
   */
  function toRows(list: string[] | undefined, key: string): Record<string, unknown>[] {
    return (list ?? []).map((value) => ({ [key]: value }));
  }

  function fromRows(value: unknown, key: string): string[] {
    if (!Array.isArray(value)) return [];
    return value
      .map((row) => (row && typeof row === 'object' ? stringValue((row as Record<string, unknown>)[key]) : ''))
      .map((entry) => entry.trim())
      .filter((entry) => entry !== '');
  }

  onMount(async () => {
    try {
      const res = await cropClient.getCrop({ id });
      const crop = res.crop;
      if (crop) {
        values = {
          name: crop.name,
          scientific_name: crop.scientificName,
          family: crop.family,
          category: enumOption(CropCategorySchema, crop.category),
          description: crop.description,
          image_url: crop.imageUrl,
          disease_susceptibilities: toRows(crop.diseaseSusceptibilities, 'disease'),
          companion_plants: toRows(crop.companionPlants, 'plant'),
          rotation_group: crop.rotationGroup,
        };
      }
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load crop';
    } finally {
      isLoading = false;
    }
  });

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await cropClient.updateCrop({
        id,
        name: stringValue(formValues.name),
        scientificName: stringValue(formValues.scientific_name),
        family: stringValue(formValues.family),
        category: enumValue(CropCategorySchema, formValues.category),
        description: stringValue(formValues.description),
        imageUrl: stringValue(formValues.image_url),
        diseaseSusceptibilities: fromRows(formValues.disease_susceptibilities, 'disease'),
        companionPlants: fromRows(formValues.companion_plants, 'plant'),
        rotationGroup: stringValue(formValues.rotation_group),
      });
      goto('/crops');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to update crop';
    } finally {
      isSubmitting = false;
    }
  }

  async function handleDelete() {
    try {
      await cropClient.deleteCrop({ id });
      goto('/crops');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to delete crop';
    }
  }
</script>

<CrudFormPage
  title="Edit Crop"
  subtitle="Update crop details"
  mode="edit"
  schema={createCropSchema}
  {values}
  {errors}
  {isLoading}
  {isSubmitting}
  {error}
  cancelHref="/crops"
  showDelete={true}
  onSubmit={handleSubmit}
  onDelete={handleDelete}
/>
