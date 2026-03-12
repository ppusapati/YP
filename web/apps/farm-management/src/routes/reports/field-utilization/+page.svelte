<script lang="ts">
  import { DynamicReportRenderer } from '@samavāya/ui';
  import { fieldReportSchema } from '@samavāya/agriculture/schemas';
</script>

<div>
  <h1 class="text-xl font-semibold mb-4">Field Utilization Report</h1>
  <DynamicReportRenderer schema={fieldReportSchema} />
</div>
