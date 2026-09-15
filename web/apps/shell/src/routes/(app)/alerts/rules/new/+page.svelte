<script lang="ts">
  import { goto } from '$app/navigation';
  import { alertClient, fieldClient } from '@samavāya/agriculture/services';
  import { AlertSeverity } from '@samavāya/proto';

  /**
   * A new alert rule, in the terms alert-service stores one.
   *
   * The form used to collect an alert type from a list of eight, a minimum
   * severity, and three notification checkboxes — none of which exist on
   * `AlertRule`. Submitting it sent a rule whose every meaningful field was
   * dropped on the wire, so the rule was created and then never fired.
   *
   * A rule is a threshold: when `metric` crosses `threshold` in the direction
   * `condition`, raise an alert at `severity` and notify `notify_channels`.
   */

  let fieldId = '';
  let metric = 'soil_moisture';
  let condition = '<';
  let threshold = 0;
  let severity: AlertSeverity = AlertSeverity.WARNING;
  let notifyChannels: string[] = ['push'];
  let enabled = true;

  let fields: { id: string; name: string }[] = [];
  let isSubmitting = false;
  let error: string | null = null;

  /**
   * The metrics sensor-service and the satellite pipeline publish. Free text
   * would let someone create a rule on a metric nothing ever reports, which
   * looks identical to a rule whose condition is never met.
   */
  const metrics = [
    { value: 'soil_moisture', label: 'Soil moisture (%)' },
    { value: 'soil_temperature', label: 'Soil temperature (°C)' },
    { value: 'air_temperature', label: 'Air temperature (°C)' },
    { value: 'humidity', label: 'Humidity (%)' },
    { value: 'rainfall', label: 'Rainfall (mm)' },
    { value: 'ndvi', label: 'NDVI' },
    { value: 'wind_speed', label: 'Wind speed (m/s)' },
  ];

  const conditions = [
    { value: '<', label: 'falls below' },
    { value: '<=', label: 'is at or below' },
    { value: '>', label: 'rises above' },
    { value: '>=', label: 'is at or above' },
  ];

  const severities = [
    { value: AlertSeverity.INFO, label: 'Info' },
    { value: AlertSeverity.WARNING, label: 'Warning' },
    { value: AlertSeverity.CRITICAL, label: 'Critical' },
    { value: AlertSeverity.EMERGENCY, label: 'Emergency' },
  ];

  const channels = [
    { value: 'push', label: 'Push notification' },
    { value: 'email', label: 'Email' },
    { value: 'sms', label: 'SMS' },
  ];

  loadFields();

  async function loadFields() {
    try {
      const res = await fieldClient.listFields({});
      fields = (res.fields ?? []).map((f) => ({ id: f.id, name: f.name || f.id }));
    } catch (e) {
      // Said out loud: a silently empty dropdown reads as "this farm has no
      // fields", which is a very different problem from "the call failed".
      error = e instanceof Error ? `Could not load fields: ${e.message}` : 'Could not load fields';
    }
  }

  function toggleChannel(value: string) {
    notifyChannels = notifyChannels.includes(value)
      ? notifyChannels.filter((c) => c !== value)
      : [...notifyChannels, value];
  }

  async function handleSubmit() {
    if (!fieldId) {
      error = 'Please select a field';
      return;
    }
    if (notifyChannels.length === 0) {
      error = 'Choose at least one channel, or the rule will fire with nobody told.';
      return;
    }

    isSubmitting = true;
    error = null;
    try {
      await alertClient.createAlertRule({
        rule: { fieldId, metric, condition, threshold, severity, enabled, notifyChannels },
      });
      goto('/alerts/rules');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to create alert rule';
    } finally {
      isSubmitting = false;
    }
  }
</script>

<div class="page-container">
  <header class="page-header">
    <h1>New Alert Rule</h1>
    <p class="subtitle">Configure a new alert rule for a field</p>
  </header>

  {#if error}
    <div class="error-banner">
      <p>{error}</p>
    </div>
  {/if}

  <form class="form" on:submit|preventDefault={handleSubmit}>
    <div class="form-section">
      <h3>Field</h3>

      <div class="form-group">
        <label for="field">Field</label>
        <select id="field" bind:value={fieldId}>
          <option value="">Select a field...</option>
          {#each fields as field}
            <option value={field.id}>{field.name}</option>
          {/each}
        </select>
      </div>
    </div>

    <div class="form-section">
      <h3>Condition</h3>

      <div class="form-group">
        <label for="metric">Metric</label>
        <select id="metric" bind:value={metric}>
          {#each metrics as m}
            <option value={m.value}>{m.label}</option>
          {/each}
        </select>
      </div>

      <div class="form-group">
        <label for="condition">When it</label>
        <select id="condition" bind:value={condition}>
          {#each conditions as c}
            <option value={c.value}>{c.label}</option>
          {/each}
        </select>
      </div>

      <div class="form-group">
        <label for="threshold">Threshold</label>
        <input id="threshold" type="number" step="any" bind:value={threshold} />
        <span class="help-text">The value the metric is compared against</span>
      </div>

      <div class="form-group">
        <label for="severity">Raise an alert at</label>
        <select id="severity" bind:value={severity}>
          {#each severities as s}
            <option value={s.value}>{s.label}</option>
          {/each}
        </select>
      </div>
    </div>

    <div class="form-section">
      <h3>Notification Channels</h3>

      <div class="checkbox-group">
        {#each channels as c}
          <label class="checkbox-label">
            <input
              type="checkbox"
              checked={notifyChannels.includes(c.value)}
              on:change={() => toggleChannel(c.value)}
            />
            {c.label}
          </label>
        {/each}
      </div>
    </div>

    <div class="form-section">
      <label class="checkbox-label">
        <input type="checkbox" bind:checked={enabled} />
        Enable rule immediately
      </label>
    </div>

    <div class="form-actions">
      <button type="submit" class="btn btn-primary" disabled={isSubmitting}>
        {isSubmitting ? 'Creating...' : 'Create Rule'}
      </button>
      <button type="button" class="btn btn-secondary" on:click={() => goto('/alerts/rules')}>
        Cancel
      </button>
    </div>
  </form>
</div>

<style>
  .page-container { max-width: 720px; }
  .page-header { margin-bottom: 1.5rem; }
  .page-header h1 { font-size: 1.5rem; font-weight: 600; margin: 0; }
  .subtitle { font-size: 0.875rem; color: #6b7280; margin: 0.25rem 0 0 0; }
  .error-banner { color: #dc2626; background: #fef2f2; border: 1px solid #fecaca; border-radius: 0.5rem; padding: 0.75rem 1rem; margin-bottom: 1rem; }
  .error-banner p { margin: 0; font-size: 0.875rem; }
  .form { background: #fff; border: 1px solid #e5e7eb; border-radius: 0.5rem; padding: 1.5rem; }
  .form-section { margin-bottom: 1.5rem; }
  .form-section h3 { font-size: 0.875rem; font-weight: 600; margin: 0 0 0.75rem 0; color: #374151; }
  .form-group { margin-bottom: 1rem; }
  .form-group label { display: block; font-size: 0.75rem; font-weight: 500; color: #374151; margin-bottom: 0.25rem; }
  .form-group select,
  .form-group input { width: 100%; padding: 0.5rem 0.75rem; border: 1px solid #d1d5db; border-radius: 0.375rem; font-size: 0.875rem; background: #fff; box-sizing: border-box; }
  .form-group select:focus,
  .form-group input:focus { outline: none; border-color: #2563eb; box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.15); }
  .help-text { font-size: 0.75rem; color: #9ca3af; margin-top: 0.25rem; display: block; }
  .checkbox-group { display: flex; flex-direction: column; gap: 0.5rem; }
  .checkbox-label { display: flex; align-items: center; gap: 0.5rem; font-size: 0.875rem; color: #374151; cursor: pointer; }
  .checkbox-label input { accent-color: #2563eb; }
  .form-actions { display: flex; gap: 0.75rem; padding-top: 1rem; border-top: 1px solid #e5e7eb; }
  .btn { padding: 0.5rem 1rem; border-radius: 0.375rem; font-size: 0.875rem; font-weight: 600; cursor: pointer; border: 1px solid; }
  .btn:disabled { opacity: 0.5; cursor: not-allowed; }
  .btn-primary { background: #2563eb; color: #fff; border-color: #2563eb; }
  .btn-primary:hover:not(:disabled) { background: #1d4ed8; }
  .btn-secondary { background: #fff; color: #374151; border-color: #d1d5db; }
  .btn-secondary:hover { background: #f3f4f6; }
</style>
