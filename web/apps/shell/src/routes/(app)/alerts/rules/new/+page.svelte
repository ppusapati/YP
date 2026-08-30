<script lang="ts">
  import { goto } from '$app/navigation';
  import { analyticsClient } from '@samavāya/agriculture/services';

  let fieldId = '';
  let fieldName = '';
  let alertType = 'cropStress';
  let enabled = true;
  let threshold: number | null = null;
  let minimumSeverity = 'warning';
  let pushEnabled = true;
  let emailEnabled = false;
  let smsEnabled = false;

  let fields: { id: string; name: string }[] = [];
  let isSubmitting = false;
  let error: string | null = null;

  const alertTypes = [
    { value: 'cropStress', label: 'Crop Stress' },
    { value: 'waterShortage', label: 'Water Shortage' },
    { value: 'diseaseOutbreak', label: 'Disease Outbreak' },
    { value: 'pestOutbreak', label: 'Pest Outbreak' },
    { value: 'irrigationNeeded', label: 'Irrigation Needed' },
    { value: 'frostWarning', label: 'Frost Warning' },
    { value: 'soilHealth', label: 'Soil Health' },
    { value: 'weatherEvent', label: 'Weather Event' },
  ];

  const severities = [
    { value: 'info', label: 'Info' },
    { value: 'warning', label: 'Warning' },
    { value: 'critical', label: 'Critical' },
    { value: 'emergency', label: 'Emergency' },
  ];

  loadFields();

  async function loadFields() {
    try {
      const res = await analyticsClient.listFields({});
      fields = (res.fields ?? []).map((f: any) => ({ id: f.id, name: f.name || f.id }));
    } catch {
      // Fields will show as empty; user can still type an ID.
    }
  }

  function handleFieldSelect(e: Event) {
    const target = e.target as HTMLSelectElement;
    fieldId = target.value;
    const found = fields.find((f) => f.id === fieldId);
    fieldName = found?.name ?? fieldId;
  }

  async function handleSubmit() {
    if (!fieldId) {
      error = 'Please select a field';
      return;
    }

    isSubmitting = true;
    error = null;
    try {
      await analyticsClient.createAlertRule({
        rule: {
          fieldId,
          fieldName,
          alertType,
          enabled,
          threshold,
          minimumSeverity,
          pushEnabled,
          emailEnabled,
          smsEnabled,
        },
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
      <h3>Field & Alert Type</h3>

      <div class="form-group">
        <label for="field">Field</label>
        <select id="field" on:change={handleFieldSelect} value={fieldId}>
          <option value="">Select a field...</option>
          {#each fields as field}
            <option value={field.id}>{field.name}</option>
          {/each}
        </select>
      </div>

      <div class="form-group">
        <label for="alertType">Alert Type</label>
        <select id="alertType" bind:value={alertType}>
          {#each alertTypes as t}
            <option value={t.value}>{t.label}</option>
          {/each}
        </select>
      </div>
    </div>

    <div class="form-section">
      <h3>Thresholds</h3>

      <div class="form-group">
        <label for="minSeverity">Minimum Severity</label>
        <select id="minSeverity" bind:value={minimumSeverity}>
          {#each severities as s}
            <option value={s.value}>{s.label}</option>
          {/each}
        </select>
      </div>

      <div class="form-group">
        <label for="threshold">Threshold Value (optional)</label>
        <input
          id="threshold"
          type="number"
          step="any"
          placeholder="e.g. 75"
          bind:value={threshold}
        />
        <span class="help-text">The numeric threshold that triggers this alert</span>
      </div>
    </div>

    <div class="form-section">
      <h3>Notification Channels</h3>

      <div class="checkbox-group">
        <label class="checkbox-label">
          <input type="checkbox" bind:checked={pushEnabled} />
          Push Notifications
        </label>
        <label class="checkbox-label">
          <input type="checkbox" bind:checked={emailEnabled} />
          Email
        </label>
        <label class="checkbox-label">
          <input type="checkbox" bind:checked={smsEnabled} />
          SMS
        </label>
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
