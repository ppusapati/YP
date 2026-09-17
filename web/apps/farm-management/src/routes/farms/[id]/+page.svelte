<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { CrudFormPage } from '@samavāya/ui';
  import { createFarmSchema } from '@samavāya/agriculture/schemas';
  import { farmClient } from '@samavāya/agriculture/services';
  import {
    enumOption,
    enumValue,
    numberValue,
    stringValue,
    ClimateZoneSchema,
    FarmTypeSchema,
    SoilTypeSchema,
  } from '@samavāya/agriculture/convert';

  /**
   * Editing a farm.
   *
   * Both directions of this page were broken and neither failed loudly.
   *
   * Loading did `values = { ...res.farm }`, which copies the generated client's
   * camelCase fields into a form whose inputs are named after the proto's
   * snake_case ones — so `totalAreaHectares` never reached the
   * `total_area_hectares` input and most of the form rendered blank on a farm
   * that had every field set.
   *
   * Saving did `updateFarm({ id, ...formValues } as any)`, which hands
   * protobuf-es keys it does not recognise. It drops them silently, the request
   * succeeds, and nothing changes. The `as any` is what kept the typechecker
   * from saying so.
   *
   * Both directions are now mapped field by field. It is more code than a
   * spread and it is the only version that actually saves.
   */

  $: id = $page.params.id;

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isLoading = true;
  let isSubmitting = false;
  let error: string | null = null;
  let mode: 'edit' | 'view' = 'edit';

  onMount(async () => {
    try {
      const res = await farmClient.getFarm({ id });
      const farm = res.farm;
      if (farm) {
        values = {
          name: farm.name,
          description: farm.description,
          total_area_hectares: farm.totalAreaHectares,
          farm_type: enumOption(FarmTypeSchema, farm.farmType),
          soil_type: enumOption(SoilTypeSchema, farm.soilType),
          climate_zone: enumOption(ClimateZoneSchema, farm.climateZone),
          elevation: farm.elevationMeters,
          address: farm.address,
          region: farm.region,
          country: farm.country,
          latitude: farm.location?.latitude,
          longitude: farm.location?.longitude,
        };
      }
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load farm';
    } finally {
      isLoading = false;
    }
  });

  async function handleSubmit(formValues: Record<string, unknown>) {
    isSubmitting = true;
    error = null;
    try {
      const latitude = numberValue(formValues.latitude);
      const longitude = numberValue(formValues.longitude);
      const elevation = numberValue(formValues.elevation);

      await farmClient.updateFarm({
        id,
        name: stringValue(formValues.name),
        description: stringValue(formValues.description),
        totalAreaHectares: numberValue(formValues.total_area_hectares) ?? 0,
        farmType: enumValue(FarmTypeSchema, formValues.farm_type),
        soilType: enumValue(SoilTypeSchema, formValues.soil_type),
        climateZone: enumValue(ClimateZoneSchema, formValues.climate_zone),
        elevationMeters: elevation ?? 0,
        address: stringValue(formValues.address),
        region: stringValue(formValues.region),
        country: stringValue(formValues.country),
        // Only sent when there is a coordinate to send. An empty location
        // message would overwrite a stored position with 0,0 — a point in the
        // Atlantic that every map in the product would then draw the farm at.
        location:
          latitude === undefined && longitude === undefined
            ? undefined
            : {
                latitude: latitude ?? 0,
                longitude: longitude ?? 0,
                elevationMeters: elevation ?? 0,
              },
      });
      goto('/farms');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to update farm';
    } finally {
      isSubmitting = false;
    }
  }

  async function handleDelete() {
    try {
      await farmClient.deleteFarm({ id });
      goto('/farms');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to delete farm';
    }
  }
</script>

<CrudFormPage
  title="Edit Farm"
  subtitle="Update farm details"
  {mode}
  schema={createFarmSchema}
  {values}
  {errors}
  {isLoading}
  {isSubmitting}
  {error}
  cancelHref="/farms"
  showDelete={true}
  onSubmit={handleSubmit}
  onDelete={handleDelete}
/>
