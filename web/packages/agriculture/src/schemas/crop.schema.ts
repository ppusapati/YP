/**
 * Crop Form Schema — derived from agriculture.crop.v1 proto
 */
import type { FormSchema } from '@samavāya/core';

export const cropFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'name', label: 'Crop Name', placeholder: 'e.g. Rice, Wheat', required: true },
    { type: 'text', name: 'scientificName', label: 'Scientific Name', placeholder: 'e.g. Oryza sativa' },
    { type: 'text', name: 'family', label: 'Family', placeholder: 'e.g. Poaceae' },
    {
      type: 'select', name: 'category', label: 'Category', required: true,
      options: [
        { label: 'Cereal', value: '1' },
        { label: 'Legume', value: '2' },
        { label: 'Vegetable', value: '3' },
        { label: 'Fruit', value: '4' },
        { label: 'Oilseed', value: '5' },
        { label: 'Fiber', value: '6' },
        { label: 'Spice', value: '7' },
      ],
    } as any,
    { type: 'textarea', name: 'description', label: 'Description', rows: 3 } as any,
    { type: 'url', name: 'imageUrl', label: 'Image URL', placeholder: 'https://...' },
    { type: 'text', name: 'rotationGroup', label: 'Rotation Group', placeholder: 'e.g. Grain, Legume' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'basic',
        title: 'Crop Details',
        fields: ['name', 'scientificName', 'family', 'category', 'description', 'imageUrl', 'rotationGroup'],
        columns: 2,
      },
    ],
  },
};

export const cropVarietyFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'name', label: 'Variety Name', required: true },
    { type: 'textarea', name: 'description', label: 'Description', rows: 3 } as any,
    { type: 'number', name: 'maturityDays', label: 'Maturity (days)', min: 1 } as any,
    { type: 'number', name: 'yieldPotentialKgPerHectare', label: 'Yield Potential (kg/ha)', min: 0, step: 0.1 } as any,
    { type: 'checkbox', name: 'isHybrid', label: 'Is Hybrid' } as any,
    { type: 'text', name: 'diseaseResistance', label: 'Disease Resistance' },
    { type: 'text', name: 'suitableRegions', label: 'Suitable Regions' },
    { type: 'text', name: 'seedRateKgPerHectare', label: 'Seed Rate (kg/ha)' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'details',
        title: 'Variety Details',
        fields: ['name', 'description', 'maturityDays', 'yieldPotentialKgPerHectare', 'isHybrid', 'diseaseResistance', 'suitableRegions', 'seedRateKgPerHectare'],
        columns: 2,
      },
    ],
  },
};
