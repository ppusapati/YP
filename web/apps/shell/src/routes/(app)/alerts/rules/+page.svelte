<script lang="ts">
  import { goto } from '$app/navigation';
  import { alertClient } from '@samavāya/agriculture/services';

  interface AlertRule {
    id: string;
    fieldId: string;
    fieldName: string;
    alertType: string;
    enabled: boolean;
    threshold: number | null;
    minimumSeverity: string;
    pushEnabled: boolean;
    emailEnabled: boolean;
    smsEnabled: boolean;
  }

  let rules: AlertRule[] = [];
  let loading = true;
  let error: string | null = null;

  loadRules();

  async function loadRules() {
    loading = true;
    error = null;
    try {
      const res = await alertClient.listAlertRules({});
      rules = res.rules ?? [];
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load alert rules';
    } finally {
      loading = false;
    }
  }

  async function toggleRule(rule: AlertRule) {
    try {
      await alertClient.updateAlertRule({
        rule: { ...rule, enabled: !rule.enabled },
      });
      rules = rules.map((r) => r.id === rule.id ? { ...r, enabled: !r.enabled } : r);
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to update rule';
    }
  }

  function formatType(type: string): string {
    return type.replace(/([A-Z])/g, ' $1').replace(/^./, (s) => s.toUpperCase()).trim();
  }

  function channelIcons(rule: AlertRule): string[] {
    const ch: string[] = [];
    if (rule.pushEnabled) ch.push('Push');
    if (rule.emailEnabled) ch.push('Email');
    if (rule.smsEnabled) ch.push('SMS');
    return ch;
  }
</script>

<div class="page-container">
  <header class="page-header">
    <div class="header-row">
      <div>
        <h1>Alert Rules</h1>
        <p class="subtitle">Configure alert rules per field</p>
      </div>
      <button class="btn btn-primary" on:click={() => goto('/alerts/rules/new')}>
        + New Rule
      </button>
    </div>
  </header>

  {#if loading}
    <div class="page-content"><p>Loading...</p></div>
  {:else if error}
    <div class="page-content error-banner"><p>{error}</p></div>
  {:else if rules.length === 0}
    <div class="page-content empty">
      <p>No alert rules configured yet.</p>
      <button class="btn btn-primary" on:click={() => goto('/alerts/rules/new')}>Create First Rule</button>
    </div>
  {:else}
    <div class="rules-grid">
      {#each rules as rule (rule.id)}
        <div class="rule-card" class:disabled={!rule.enabled}>
          <div class="rule-header">
            <div class="rule-info">
              <span class="rule-type">{formatType(rule.alertType)}</span>
              <span class="rule-field">{rule.fieldName}</span>
            </div>
            <label class="toggle">
              <input type="checkbox" checked={rule.enabled} on:change={() => toggleRule(rule)} />
              <span class="toggle-slider"></span>
            </label>
          </div>
          {#if rule.enabled}
            <div class="rule-details">
              <div class="rule-detail">
                <span class="label">Min. Severity</span>
                <span class="value">{rule.minimumSeverity}</span>
              </div>
              {#if rule.threshold != null}
                <div class="rule-detail">
                  <span class="label">Threshold</span>
                  <span class="value">{rule.threshold}</span>
                </div>
              {/if}
              <div class="rule-detail">
                <span class="label">Channels</span>
                <span class="value channels">
                  {#each channelIcons(rule) as ch}
                    <span class="channel-badge">{ch}</span>
                  {/each}
                  {#if channelIcons(rule).length === 0}
                    <span class="none">None</span>
                  {/if}
                </span>
              </div>
            </div>
          {/if}
        </div>
      {/each}
    </div>
  {/if}

  <div class="back-link">
    <button class="btn btn-secondary" on:click={() => goto('/alerts')}>Back to Alerts</button>
  </div>
</div>

<style>
  .page-container { max-width: 1200px; }
  .page-header { margin-bottom: 1.5rem; }
  .page-header h1 { font-size: 1.5rem; font-weight: 600; margin: 0; }
  .subtitle { font-size: 0.875rem; color: #6b7280; margin: 0.25rem 0 0 0; }
  .header-row { display: flex; justify-content: space-between; align-items: flex-start; }
  .page-content { background: #fff; border: 1px solid #e5e7eb; border-radius: 0.5rem; padding: 1.5rem; }
  .error-banner { color: #dc2626; }
  .empty { text-align: center; padding: 3rem 1.5rem; }
  .empty p { color: #6b7280; margin-bottom: 1rem; }
  .rules-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 1rem; }
  .rule-card { background: #fff; border: 1px solid #e5e7eb; border-radius: 0.5rem; padding: 1rem; }
  .rule-card.disabled { opacity: 0.6; }
  .rule-header { display: flex; justify-content: space-between; align-items: center; }
  .rule-info { display: flex; flex-direction: column; gap: 0.125rem; }
  .rule-type { font-size: 0.875rem; font-weight: 600; color: #111827; }
  .rule-field { font-size: 0.75rem; color: #6b7280; }
  .rule-details { margin-top: 0.75rem; padding-top: 0.75rem; border-top: 1px solid #f3f4f6; display: flex; flex-direction: column; gap: 0.5rem; }
  .rule-detail { display: flex; justify-content: space-between; align-items: center; }
  .rule-detail .label { font-size: 0.75rem; color: #6b7280; }
  .rule-detail .value { font-size: 0.75rem; color: #111827; font-weight: 500; text-transform: capitalize; }
  .channels { display: flex; gap: 0.25rem; }
  .channel-badge { background: #eff6ff; color: #2563eb; padding: 0.125rem 0.5rem; border-radius: 9999px; font-size: 0.625rem; font-weight: 500; }
  .none { color: #9ca3af; }
  .toggle { position: relative; display: inline-block; width: 36px; height: 20px; }
  .toggle input { opacity: 0; width: 0; height: 0; }
  .toggle-slider { position: absolute; cursor: pointer; inset: 0; background: #d1d5db; border-radius: 20px; transition: 0.2s; }
  .toggle-slider::before { content: ''; position: absolute; height: 16px; width: 16px; left: 2px; bottom: 2px; background: #fff; border-radius: 50%; transition: 0.2s; }
  .toggle input:checked + .toggle-slider { background: #2563eb; }
  .toggle input:checked + .toggle-slider::before { transform: translateX(16px); }
  .back-link { margin-top: 1.5rem; }
  .btn { padding: 0.5rem 1rem; border-radius: 0.375rem; font-size: 0.875rem; font-weight: 500; cursor: pointer; border: 1px solid #d1d5db; }
  .btn-primary { background: #2563eb; color: #fff; border-color: #2563eb; }
  .btn-primary:hover { background: #1d4ed8; }
  .btn-secondary { background: #fff; color: #374151; }
  .btn-secondary:hover { background: #f3f4f6; }
</style>
