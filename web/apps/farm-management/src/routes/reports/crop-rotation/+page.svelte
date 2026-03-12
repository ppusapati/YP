<script lang="ts">
  import { DynamicReportRenderer } from '@samavāya/ui';
  import { cropReportSchema } from '@samavāya/agriculture/schemas';
</script>

<div>
  <h1 class="text-xl font-semibold mb-4">Crop Rotation Report</h1>
  <DynamicReportRenderer schema={cropReportSchema} />
</div>
