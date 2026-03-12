import type { FormSchema } from '@samavāya/core';

export const diagnosisRequestFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'farmId', label: 'Farm', required: true },
    { type: 'text', name: 'fieldId', label: 'Field', required: true },
    { type: 'text', name: 'plantSpeciesId', label: 'Plant Species' },
    { type: 'textarea', name: 'notes', label: 'Notes', rows: 3 } as any,
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'diagnosis_request',
        title: 'Diagnosis Request',
        fields: ['farmId', 'fieldId', 'plantSpeciesId', 'notes'],
        columns: 2,
      },
    ],
  },
};
