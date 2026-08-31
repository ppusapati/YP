import type { FormSchema } from '@samavāya/core';
import { farmClient, fieldClient } from '../services';

export const detectStressFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'autocomplete', name: 'farmId', label: 'Farm', required: true, loadOptions: async (query: string) => {
        const res = await farmClient.listFarms({ search: query, pageSize: 50 });
        return (res.farms || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'autocomplete', name: 'fieldId', label: 'Field', required: true, loadOptions: async (query: string) => {
        const res = await fieldClient.listFields({ search: query, pageSize: 50 });
        return (res.fields || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'text', name: 'processingJobId', label: 'Processing Job ID', required: true },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'basic',
        title: 'Stress Detection Parameters',
        fields: ['farmId', 'fieldId'],
        columns: 2,
      },
      {
        id: 'input',
        title: 'Processing Input',
        fields: ['processingJobId'],
        columns: 1,
      },
    ],
  },
};

export const runTemporalAnalysisFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'autocomplete', name: 'farmId', label: 'Farm', required: true, loadOptions: async (query: string) => {
        const res = await farmClient.listFarms({ search: query, pageSize: 50 });
        return (res.farms || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'autocomplete', name: 'fieldId', label: 'Field', required: true, loadOptions: async (query: string) => {
        const res = await fieldClient.listFields({ search: query, pageSize: 50 });
        return (res.fields || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'select', name: 'analysisType', label: 'Analysis Type', required: true, options: [
        { label: 'Stress Detection', value: '1' },
        { label: 'Change Detection', value: '2' },
        { label: 'Temporal Trend', value: '3' },
        { label: 'Anomaly Detection', value: '4' },
        { label: 'Crop Classification', value: '5' },
      ] },
    { type: 'date', name: 'periodStart', label: 'Period Start', required: true },
    { type: 'date', name: 'periodEnd', label: 'Period End', required: true },
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
        id: 'analysis',
        title: 'Analysis Configuration',
        fields: ['analysisType'],
        columns: 1,
      },
      {
        id: 'period',
        title: 'Time Period',
        fields: ['periodStart', 'periodEnd'],
        columns: 2,
      },
    ],
  },
};
