<script lang="ts">
  import { DynamicReportRenderer } from '@samavāya/ui';
  import { farmReportSchema } from '@samavāya/agriculture/schemas';
</script>

<div>
  <h1 class="text-xl font-semibold mb-4">Farm Summary Report</h1>
  <DynamicReportRenderer visualization={farmReportSchema} data={{ columns: [], rows: [], total_rows: 0 }} />
</div>
