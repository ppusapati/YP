<script lang="ts">
  import { DynamicReportRenderer } from '@samavāya/ui';
  import { soilSampleReportSchema } from '@samavāya/agriculture/schemas';
</script>

<div>
  <h1 class="text-xl font-semibold mb-4">Soil Report</h1>
  <DynamicReportRenderer schema={soilSampleReportSchema} />
</div>
