/**
 * @generated from proto — DO NOT EDIT
 * Run: node scripts/generate-schemas.mjs
 */
import type { FormSchema } from '@samavāya/core';
import { cropClient } from '../services';

export const cropFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'name', label: 'Name', required: true },
    { type: 'text', name: 'scientificName', label: 'Scientific Name' },
    { type: 'text', name: 'family', label: 'Family' },
    { type: 'select', name: 'category', label: 'Category', options: [
        { label: 'Cereal', value: '1' },
        { label: 'Legume', value: '2' },
        { label: 'Vegetable', value: '3' },
        { label: 'Fruit', value: '4' },
        { label: 'Oilseed', value: '5' },
        { label: 'Fiber', value: '6' },
        { label: 'Spice', value: '7' },
      ] },
    { type: 'textarea', name: 'description', label: 'Description', rows: 3 },
    { type: 'url', name: 'imageUrl', label: 'Image Url', placeholder: 'https://...' },
    { type: 'text', name: 'diseaseSusceptibilities', label: 'Disease Susceptibilities' },
    { type: 'textarea', name: 'companionPlants', label: 'Companion Plants', rows: 3 },
    { type: 'text', name: 'rotationGroup', label: 'Rotation Group' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'basic',
        title: 'Crop Details',
        fields: ['name', 'scientificName', 'description', 'category', 'family', 'imageUrl', 'diseaseSusceptibilities', 'companionPlants', 'rotationGroup'],
        columns: 2,
      },
    ],
  },
};

export const cropVarietyFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'autocomplete', name: 'cropId', label: 'Crop', loadOptions: async (query: string) => {
        const res = await cropClient.listCrops({ search: query, pageSize: 50 });
        return (res.crops || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'text', name: 'name', label: 'Name', required: true },
    { type: 'textarea', name: 'description', label: 'Description', rows: 3 },
    { type: 'number', name: 'maturityDays', label: 'Maturity Days', min: 0, step: 1 },
    { type: 'number', name: 'yieldPotentialKgPerHectare', label: 'Yield Potential Kg Per Hectare', min: 0, step: 0.01 },
    { type: 'checkbox', name: 'isHybrid', label: 'Is Hybrid' },
    { type: 'text', name: 'diseaseResistance', label: 'Disease Resistance' },
    { type: 'text', name: 'suitableRegions', label: 'Suitable Regions' },
    { type: 'text', name: 'seedRateKgPerHectare', label: 'Seed Rate Kg Per Hectare' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'basic',
        title: 'Crop Variety Details',
        fields: ['cropId', 'name', 'description', 'diseaseResistance', 'suitableRegions', 'seedRateKgPerHectare'],
        columns: 2,
      },
      {
        id: 'metrics',
        title: 'Measurements & Metrics',
        fields: ['maturityDays', 'yieldPotentialKgPerHectare'],
        columns: 2,
      },
      {
        id: 'options',
        title: 'Options',
        fields: ['isHybrid'],
        columns: 2,
      },
    ],
  },
};
