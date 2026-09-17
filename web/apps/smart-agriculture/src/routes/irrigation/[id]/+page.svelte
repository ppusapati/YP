<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import type { IrrigationSchedule } from '@samavāya/proto';
  import { CrudFormPage } from '@samavāya/ui';
  import { irrigationScheduleSchema } from '@samavāya/agriculture/schemas';
  import { irrigationClient } from '@samavāya/agriculture/services';
  import {
    FrequencySchema,
    ScheduleTypeSchema,
    enumOption,
    enumValue,
    numberValue,
    stringValue,
    toDateTimeInput,
    toTimestamp,
  } from '@samavāya/agriculture/convert';

  /**
   * Editing an irrigation schedule.
   *
   * `UpdateScheduleRequest` carries a whole `IrrigationSchedule`, not a set of
   * flat fields, so the old `{ id, ...formValues }` did not merely use the
   * wrong names — it had no `schedule` at all, and the service received an
   * empty request.
   *
   * The loaded schedule is kept and the edited fields are laid over it. Sending
   * a message built only from the form would blank everything the form does not
   * show — the farm, the controller, the schedule's name and description, its
   * status — because a replace with an unset field is a replace with the zero
   * value, not a skip.
   */

  $: id = $page.params.id;

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isLoading = true;
  let isSubmitting = false;
  let error: string | null = null;

  // What the service currently holds, kept so the update can be an overlay
  // rather than a replacement.
  let loaded: IrrigationSchedule | undefined;

  onMount(async () => {
    try {
      const res = await irrigationClient.getSchedule({ id });
      loaded = res.schedule;
      if (loaded) {
        values = {
          field_id: loaded.fieldId,
          zone_id: loaded.zoneId,
          schedule_type: enumOption(ScheduleTypeSchema, loaded.scheduleType),
          start_time: toDateTimeInput(loaded.startTime),
          end_time: toDateTimeInput(loaded.endTime),
          duration_minutes: loaded.durationMinutes,
          water_quantity_liters: loaded.waterQuantityLiters,
          flow_rate_liters_per_hour: loaded.flowRateLitersPerHour,
          frequency: enumOption(FrequencySchema, loaded.frequency),
          moisture_threshold_pct: loaded.soilMoistureThresholdPct,
        };
      }
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load irrigation schedule';
    } finally {
      isLoading = false;
    }
  });

  async function handleSubmit(formValues: Record<string, unknown>) {
    if (!loaded) {
      error = 'This schedule has not loaded yet, so there is nothing to update.';
      return;
    }

    isSubmitting = true;
    error = null;
    try {
      await irrigationClient.updateSchedule({
        schedule: {
          ...loaded,
          fieldId: stringValue(formValues.field_id) || loaded.fieldId,
          zoneId: stringValue(formValues.zone_id),
          scheduleType: enumValue(ScheduleTypeSchema, formValues.schedule_type) ?? loaded.scheduleType,
          startTime: toTimestamp(formValues.start_time) ?? loaded.startTime,
          endTime: toTimestamp(formValues.end_time) ?? loaded.endTime,
          durationMinutes: numberValue(formValues.duration_minutes) ?? 0,
          waterQuantityLiters: numberValue(formValues.water_quantity_liters) ?? 0,
          flowRateLitersPerHour: numberValue(formValues.flow_rate_liters_per_hour) ?? 0,
          frequency: enumValue(FrequencySchema, formValues.frequency) ?? loaded.frequency,
          soilMoistureThresholdPct: numberValue(formValues.moisture_threshold_pct) ?? 0,
        },
      });
      goto('/irrigation');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to update irrigation schedule';
    } finally {
      isSubmitting = false;
    }
  }

  async function handleDelete() {
    try {
      await irrigationClient.deleteSchedule({ id });
      goto('/irrigation');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to delete irrigation schedule';
    }
  }
</script>

<CrudFormPage
  title="Edit Irrigation Schedule"
  subtitle="Update irrigation schedule"
  mode="edit"
  schema={irrigationScheduleSchema}
  {values}
  {errors}
  {isLoading}
  {isSubmitting}
  {error}
  cancelHref="/irrigation"
  showDelete={true}
  onSubmit={handleSubmit}
  onDelete={handleDelete}
/>
