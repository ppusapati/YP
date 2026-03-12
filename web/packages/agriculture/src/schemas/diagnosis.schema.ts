/**
 * @generated from proto — DO NOT EDIT
 * Run: node scripts/generate-schemas.mjs
 */
import type { FormSchema } from '@samavāya/core';
import { diagnosisClient, farmClient, fieldClient } from '../services';

export const diagnosisRequestFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'autocomplete', name: 'farmId', label: 'Farm', required: true, loadOptions: async (query: string) => {
        const res = await farmClient.listFarms({ search: query, pageSize: 50 });
        return (res.farms || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'autocomplete', name: 'fieldId', label: 'Field', loadOptions: async (query: string) => {
        const res = await fieldClient.listFields({ search: query, pageSize: 50 });
        return (res.fields || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'autocomplete', name: 'plantSpeciesId', label: 'Plant Species', loadOptions: async (query: string) => {
        const res = await diagnosisClient.listDiseases({ search: query, pageSize: 50 });
        return (res.diseases || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'textarea', name: 'notes', label: 'Notes', rows: 3 },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'basic',
        title: 'Diagnosis Request Details',
        fields: ['farmId', 'fieldId', 'plantSpeciesId', 'notes'],
        columns: 2,
      },
    ],
  },
};
