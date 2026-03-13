import type { FormSchema } from '@samavāya/core';
import { farmClient } from '../services';

export const submitProcessingJobFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'ingestionTaskId', label: 'Ingestion Task ID', required: true },
    { type: 'autocomplete', name: 'farmId', label: 'Farm', required: true, loadOptions: async (query: string) => {
        const res = await farmClient.listFarms({ search: query, pageSize: 50 });
        return (res.farms || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'select', name: 'outputLevel', label: 'Output Level', options: [
        { label: 'L1C (Top of Atmosphere)', value: '1' },
        { label: 'L2A (Surface Reflectance)', value: '2' },
        { label: 'L3 (Composited)', value: '3' },
      ] },
    { type: 'select', name: 'algorithm', label: 'Correction Algorithm', options: [
        { label: 'SEN2COR', value: '1' },
        { label: 'LaSRC', value: '2' },
        { label: 'FLAASH', value: '3' },
        { label: 'DOS', value: '4' },
      ] },
    { type: 'number', name: 'cloudMaskThreshold', label: 'Cloud Mask Threshold', min: 0, max: 1, step: 0.01 },
    { type: 'checkbox', name: 'applyAtmosphericCorrection', label: 'Apply Atmospheric Correction' },
    { type: 'checkbox', name: 'applyCloudMasking', label: 'Apply Cloud Masking' },
    { type: 'checkbox', name: 'applyOrthorectification', label: 'Apply Orthorectification' },
    { type: 'number', name: 'outputResolutionMeters', label: 'Output Resolution (m)', min: 1 },
    { type: 'text', name: 'outputCrs', label: 'Output CRS', placeholder: 'EPSG:4326' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      { id: 'input', title: 'Input Configuration', fields: ['ingestionTaskId', 'farmId'], columns: 2 },
      { id: 'processing', title: 'Processing Options', fields: ['outputLevel', 'algorithm', 'cloudMaskThreshold'], columns: 2 },
      { id: 'corrections', title: 'Corrections', fields: ['applyAtmosphericCorrection', 'applyCloudMasking', 'applyOrthorectification'], columns: 3 },
      { id: 'output', title: 'Output Settings', fields: ['outputResolutionMeters', 'outputCrs'], columns: 2 },
    ],
  },
};
