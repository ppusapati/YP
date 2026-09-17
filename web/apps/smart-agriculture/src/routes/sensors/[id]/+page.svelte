<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { CrudFormPage } from '@samavāya/ui';
  import { updateSensorSchema } from '@samavāya/agriculture/schemas';
  import { sensorClient } from '@samavāya/agriculture/services';
  import {
    SensorProtocolSchema,
    SensorStatusSchema,
    enumOption,
    enumValue,
    numberValue,
    stringValue,
  } from '@samavāya/agriculture/convert';

  /**
   * Editing a registered sensor.
   *
   * The form is the *update* schema, not the registration one.
   * `UpdateSensorRequest` accepts firmware version, location, status, protocol,
   * reading interval and metadata; field, type, manufacturer, model and
   * installation date are fixed at registration, because changing them would
   * describe a different physical device while keeping the readings the old one
   * recorded. Rendering the registration form here offered eight fields the RPC
   * silently discarded.
   */

  $: id = $page.params.id;

  let values: Record<string, unknown> = {};
  let errors: Record<string, string> = {};
  let isLoading = true;
  let isSubmitting = false;
  let error: string | null = null;

  // Shown above the form, since the fields it describes are no longer in it.
  let identity = '';

  onMount(async () => {
    try {
      const res = await sensorClient.getSensor({ id });
      const sensor = res.sensor;
      if (sensor) {
        values = {
          status: enumOption(SensorStatusSchema, sensor.status),
          protocol: enumOption(SensorProtocolSchema, sensor.protocol),
          firmware_version: sensor.firmwareVersion,
          reading_interval_seconds: sensor.readingIntervalSeconds,
          latitude: sensor.location?.latitude,
          longitude: sensor.location?.longitude,
          elevation: sensor.location?.elevationM,
        };
        identity = [sensor.manufacturer, sensor.model, sensor.deviceId]
          .map((part) => (part ?? '').trim())
          .filter((part) => part !== '')
          .join(' · ');
      }
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load sensor';
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

      await sensorClient.updateSensor({
        id,
        status: enumValue(SensorStatusSchema, formValues.status),
        protocol: enumValue(SensorProtocolSchema, formValues.protocol),
        firmwareVersion: stringValue(formValues.firmware_version),
        readingIntervalSeconds: numberValue(formValues.reading_interval_seconds) ?? 0,
        // Only sent when there is a coordinate to send. An empty location would
        // move the sensor to 0,0 — and a sensor's position is what ties its
        // readings to a place on a field.
        location:
          latitude === undefined && longitude === undefined
            ? undefined
            : {
                latitude: latitude ?? 0,
                longitude: longitude ?? 0,
                elevationM: elevation ?? 0,
              },
      });
      goto('/sensors');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to update sensor';
    } finally {
      isSubmitting = false;
    }
  }

  async function handleDelete() {
    try {
      await sensorClient.decommissionSensor({ id });
      goto('/sensors');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to decommission sensor';
    }
  }
</script>

<CrudFormPage
  title="Edit Sensor"
  subtitle={identity
    ? `${identity} — firmware, placement and reporting`
    : 'Firmware, placement and reporting'}
  mode="edit"
  schema={updateSensorSchema}
  {values}
  {errors}
  {isLoading}
  {isSubmitting}
  {error}
  cancelHref="/sensors"
  showDelete={true}
  onSubmit={handleSubmit}
  onDelete={handleDelete}
/>
