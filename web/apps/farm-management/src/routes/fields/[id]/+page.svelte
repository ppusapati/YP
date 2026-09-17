<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { CrudFormPage } from '@samavāya/ui';
  import { createFieldSchema } from '@samavāya/agriculture/schemas';
  import { fieldClient } from '@samavāya/agriculture/services';
  import {
    AspectDirectionSchema,
    FieldSoilTypeSchema,
    FieldTypeSchema,
    IrrigationTypeSchema,
    enumOption,
    enumValue,
    numberValue,
    stringValue,
  } from '@samavāya/agriculture/convert';

  /**
   * Editing a field.
   *
   * Two names differ between the form and the proto beyond case —
   * `elevation`/`elevationMeters` and `slope`/`slopeDegrees` — so even a
   * camelCase rewrite of the old spread would have dropped both.
   *
   * `farm_id` is shown, because knowing which farm a field belongs to matters
   * while editing it, and it is *not* sent: UpdateFieldRequest has no farm_id,
   * since moving a field between farms is a different operation from editing
   * one.
   *
   * The soil type descriptor is the field one, not the farm one. They are
   * different enums — farm has CHALKY and LATERITE, field has CHALK and
   * CLAY_LOAM — and converting through the wrong one maps the wrong number to
   * the wrong name with no error anywhere.
   */

  $: id = $page.params.id;

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isLoading = true;
  let isSubmitting = false;
  let error: string | null = null;

  onMount(async () => {
    try {
      const res = await fieldClient.getField({ id });
      const field = res.field;
      if (field) {
        values = {
          farm_id: field.farmId,
          name: field.name,
          area_hectares: field.areaHectares,
          field_type: enumOption(FieldTypeSchema, field.fieldType),
          soil_type: enumOption(FieldSoilTypeSchema, field.soilType),
          irrigation_type: enumOption(IrrigationTypeSchema, field.irrigationType),
          elevation: field.elevationMeters,
          slope: field.slopeDegrees,
          aspect_direction: enumOption(AspectDirectionSchema, field.aspectDirection),
        };
      }
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load field';
    } finally {
      isLoading = false;
    }
  });

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      await fieldClient.updateField({
        id,
        name: stringValue(formValues.name),
        areaHectares: numberValue(formValues.area_hectares) ?? 0,
        fieldType: enumValue(FieldTypeSchema, formValues.field_type),
        soilType: enumValue(FieldSoilTypeSchema, formValues.soil_type),
        irrigationType: enumValue(IrrigationTypeSchema, formValues.irrigation_type),
        elevationMeters: numberValue(formValues.elevation) ?? 0,
        slopeDegrees: numberValue(formValues.slope) ?? 0,
        aspectDirection: enumValue(AspectDirectionSchema, formValues.aspect_direction),
      });
      goto('/fields');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to update field';
    } finally {
      isSubmitting = false;
    }
  }

  async function handleDelete() {
    try {
      await fieldClient.deleteField({ id });
      goto('/fields');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to delete field';
    }
  }
</script>

<CrudFormPage
  title="Edit Field"
  subtitle="Update field details"
  mode="edit"
  schema={createFieldSchema}
  {values}
  {errors}
  {isLoading}
  {isSubmitting}
  {error}
  cancelHref="/fields"
  showDelete={true}
  onSubmit={handleSubmit}
  onDelete={handleDelete}
/>
