/**
 * @generated from proto — DO NOT EDIT
 * Run: node scripts/generate-schemas.mjs
 */
import type { FormSchema } from '@samavāya/core';
import { farmClient, fieldClient } from '../services';

export const satelliteImageFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'autocomplete', name: 'fieldId', label: 'Field', loadOptions: async (query: string) => {
        const res = await fieldClient.listFields({ search: query, pageSize: 50 });
        return (res.fields || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'autocomplete', name: 'farmId', label: 'Farm', required: true, loadOptions: async (query: string) => {
        const res = await farmClient.listFarms({ search: query, pageSize: 50 });
        return (res.farms || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'select', name: 'satelliteProvider', label: 'Satellite Provider', options: [
        { label: 'Sentinel2', value: '1' },
        { label: 'Landsat8', value: '2' },
        { label: 'Planet', value: '3' },
        { label: 'Custom', value: '4' },
      ] },
    { type: 'number', name: 'maxCloudCoverPct', label: 'Max Cloud Cover Pct', min: 0, max: 100 },
    { type: 'number', name: 'resolutionMeters', label: 'Resolution Meters', min: 0, step: 0.01 },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'basic',
        title: 'Satellite Image Details',
        fields: ['fieldId', 'farmId'],
        columns: 2,
      },
      {
        id: 'classification',
        title: 'Status & Classification',
        fields: ['satelliteProvider'],
        columns: 2,
      },
      {
        id: 'metrics',
        title: 'Measurements & Metrics',
        fields: ['maxCloudCoverPct', 'resolutionMeters'],
        columns: 2,
      },
    ],
  },
};
