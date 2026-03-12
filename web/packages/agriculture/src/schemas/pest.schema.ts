import type { FormSchema } from '@samavāya/core';

export const pestPredictionFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'farmId', label: 'Farm', required: true },
    { type: 'text', name: 'fieldId', label: 'Field', required: true },
    { type: 'text', name: 'pestSpeciesId', label: 'Pest Species' },
    { type: 'text', name: 'cropType', label: 'Crop Type' },
    {
      type: 'select', name: 'growthStage', label: 'Growth Stage',
      options: [
        { label: 'Germination', value: '1' },
        { label: 'Seedling', value: '2' },
        { label: 'Vegetative', value: '3' },
        { label: 'Flowering', value: '4' },
        { label: 'Fruiting', value: '5' },
        { label: 'Maturation', value: '6' },
        { label: 'Harvest', value: '7' },
      ],
    } as any,
    { type: 'number', name: 'latitude', label: 'Latitude', step: 0.000001, min: -90, max: 90 } as any,
    { type: 'number', name: 'longitude', label: 'Longitude', step: 0.000001, min: -180, max: 180 } as any,
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'prediction_request',
        title: 'Prediction Request',
        fields: ['farmId', 'fieldId', 'pestSpeciesId', 'cropType', 'growthStage', 'latitude', 'longitude'],
        columns: 2,
      },
    ],
  },
};

export const pestObservationFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'farmId', label: 'Farm', required: true },
    { type: 'text', name: 'fieldId', label: 'Field', required: true },
    { type: 'text', name: 'pestSpeciesId', label: 'Pest Species' },
    { type: 'number', name: 'pestCount', label: 'Pest Count', min: 0 } as any,
    {
      type: 'select', name: 'damageLevel', label: 'Damage Level',
      options: [
        { label: 'None', value: '1' },
        { label: 'Light', value: '2' },
        { label: 'Moderate', value: '3' },
        { label: 'Severe', value: '4' },
        { label: 'Devastating', value: '5' },
      ],
    } as any,
    { type: 'text', name: 'trapType', label: 'Trap Type' },
    { type: 'number', name: 'latitude', label: 'Latitude', step: 0.000001, min: -90, max: 90 } as any,
    { type: 'number', name: 'longitude', label: 'Longitude', step: 0.000001, min: -180, max: 180 } as any,
    { type: 'textarea', name: 'notes', label: 'Notes' } as any,
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'observation_details',
        title: 'Observation Details',
        fields: ['farmId', 'fieldId', 'pestSpeciesId', 'pestCount', 'damageLevel', 'trapType', 'notes'],
        columns: 2,
      },
      {
        id: 'location',
        title: 'Location',
        fields: ['latitude', 'longitude'],
        columns: 2,
      },
    ],
  },
};
