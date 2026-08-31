/**
 * @generated from proto — DO NOT EDIT
 * Run: node scripts/generate-schemas.mjs
 */
import type { FormSchema } from '@samavāya/core';
import { farmClient } from '../services';

export const requestIngestionFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'autocomplete', name: 'farmId', label: 'Farm', required: true, loadOptions: async (query: string) => {
        const res = await farmClient.listFarms({ search: query, pageSize: 50 });
        return (res.farms || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'select', name: 'provider', label: 'Provider', required: true, options: [
        { label: 'Sentinel2', value: '1' },
        { label: 'Landsat', value: '2' },
        { label: 'PlanetScope', value: '3' },
      ] },
    { type: 'date', name: 'dateFrom', label: 'Date From', required: true },
    { type: 'date', name: 'dateTo', label: 'Date To', required: true },
    { type: 'number', name: 'maxCloudCover', label: 'Max Cloud Cover (%)', min: 0, max: 100 },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'basic',
        title: 'Ingestion Request',
        fields: ['farmId', 'provider'],
        columns: 2,
      },
      {
        id: 'dateRange',
        title: 'Date Range',
        fields: ['dateFrom', 'dateTo'],
        columns: 2,
      },
      {
        id: 'parameters',
        title: 'Ingestion Parameters',
        fields: ['maxCloudCover'],
        columns: 2,
      },
    ],
  },
};
