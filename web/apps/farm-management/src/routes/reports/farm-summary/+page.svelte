<script lang="ts">
  import { DynamicReportRenderer } from '@samavāya/ui';
  import { farmReportSchema } from '@samavāya/agriculture/schemas';
</script>

<div>
  <h1 class="text-xl font-semibold mb-4">Farm Summary Report</h1>
  <DynamicReportRenderer schema={farmReportSchema} />
</div>
