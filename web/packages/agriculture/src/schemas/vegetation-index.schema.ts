import type { FormSchema } from '@samavāya/core';
import { farmClient, fieldClient } from '../services';

export const computeIndicesFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'processingJobId', label: 'Processing Job ID', required: true },
    { type: 'autocomplete', name: 'farmId', label: 'Farm', required: true, loadOptions: async (query: string) => {
        const res = await farmClient.listFarms({ search: query, pageSize: 50 });
        return (res.farms || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'multiselect', name: 'indexTypes', label: 'Index Types', options: [
        { label: 'NDVI', value: '1' },
        { label: 'NDWI', value: '2' },
        { label: 'EVI', value: '3' },
        { label: 'SAVI', value: '4' },
        { label: 'MSAVI', value: '5' },
        { label: 'NDRE', value: '6' },
        { label: 'GNDVI', value: '7' },
        { label: 'LAI', value: '8' },
      ] },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'input',
        title: 'Computation Input',
        fields: ['processingJobId', 'farmId'],
        columns: 2,
      },
      {
        id: 'indices',
        title: 'Index Selection',
        fields: ['indexTypes'],
        columns: 1,
      },
    ],
  },
};

export const ndviTimeSeriesFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'autocomplete', name: 'farmId', label: 'Farm', required: true, loadOptions: async (query: string) => {
        const res = await farmClient.listFarms({ search: query, pageSize: 50 });
        return (res.farms || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'autocomplete', name: 'fieldId', label: 'Field', required: true, loadOptions: async (query: string) => {
        const res = await fieldClient.listFields({ search: query, pageSize: 50 });
        return (res.fields || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'date', name: 'dateFrom', label: 'Date From', required: true },
    { type: 'date', name: 'dateTo', label: 'Date To', required: true },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'location',
        title: 'Location',
        fields: ['farmId', 'fieldId'],
        columns: 2,
      },
      {
        id: 'dateRange',
        title: 'Date Range',
        fields: ['dateFrom', 'dateTo'],
        columns: 2,
      },
    ],
  },
};
