import type { FormSchema } from '@samavāya/core';

export const satelliteImageFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'fieldId', label: 'Field', required: true },
    { type: 'text', name: 'farmId', label: 'Farm' },
    {
      type: 'select', name: 'satelliteProvider', label: 'Satellite Provider',
      options: [
        { label: 'Sentinel-2', value: '1' },
        { label: 'Landsat 8', value: '2' },
        { label: 'Planet', value: '3' },
        { label: 'Custom', value: '4' },
      ],
    } as any,
    { type: 'number', name: 'maxCloudCoverPct', label: 'Max Cloud Cover (%)', min: 0, max: 100 } as any,
    { type: 'number', name: 'resolutionMeters', label: 'Resolution (m)', min: 0 } as any,
    {
      type: 'select', name: 'processingStatus', label: 'Processing Status',
      options: [
        { label: 'Pending', value: '1' },
        { label: 'Processing', value: '2' },
        { label: 'Completed', value: '3' },
        { label: 'Failed', value: '4' },
      ],
    } as any,
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'imagery_request',
        title: 'Imagery Request',
        fields: ['fieldId', 'farmId', 'satelliteProvider', 'maxCloudCoverPct', 'resolutionMeters', 'processingStatus'],
        columns: 2,
      },
    ],
  },
};
