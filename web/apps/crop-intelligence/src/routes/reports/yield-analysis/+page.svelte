<script lang="ts">
  import { DynamicReportRenderer } from '@samavāya/ui';
</script>

<div class="report-page">
  <header class="report-header">
    <h1>Yield Analysis Report</h1>
    <p class="subtitle">Yield performance analysis across fields</p>
  </header>
  <div class="report-content">
    <DynamicReportRenderer schema={{visualizations:[]}} data={{}} />
  </div>
</div>

<style>
  .report-page { max-width: 1200px; }
  .report-header { margin-bottom: 1.5rem; }
  .report-header h1 { font-size: 1.5rem; font-weight: 600; margin: 0; }
  .subtitle { font-size: 0.875rem; color: #6b7280; margin: 0.25rem 0 0 0; }
  .report-content { background: #fff; border: 1px solid #e5e7eb; border-radius: 0.5rem; padding: 1.5rem; }
</style>
