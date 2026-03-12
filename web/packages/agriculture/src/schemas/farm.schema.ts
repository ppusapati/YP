/**
 * @generated from proto — DO NOT EDIT
 * Run: node scripts/generate-schemas.mjs
 */
import type { FormSchema } from '@samavāya/core';

export const farmFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'name', label: 'Name', required: true },
    { type: 'textarea', name: 'description', label: 'Description', rows: 3 },
    { type: 'number', name: 'totalAreaHectares', label: 'Total Area Hectares', min: 0, step: 0.01 },
    { type: 'select', name: 'farmType', label: 'Farm Type', options: [
        { label: 'Crop', value: '1' },
        { label: 'Livestock', value: '2' },
        { label: 'Mixed', value: '3' },
        { label: 'Aquaculture', value: '4' },
      ] },
    { type: 'select', name: 'soilType', label: 'Soil Type', options: [
        { label: 'Clay', value: '1' },
        { label: 'Sandy', value: '2' },
        { label: 'Loamy', value: '3' },
        { label: 'Silt', value: '4' },
        { label: 'Peat', value: '5' },
        { label: 'Chalk', value: '6' },
        { label: 'Clay Loam', value: '7' },
        { label: 'Sandy Loam', value: '8' },
      ] },
    { type: 'select', name: 'climateZone', label: 'Climate Zone', options: [
        { label: 'Tropical', value: '1' },
        { label: 'Subtropical', value: '2' },
        { label: 'Arid', value: '3' },
        { label: 'Semiarid', value: '4' },
        { label: 'Temperate', value: '5' },
        { label: 'Continental', value: '6' },
        { label: 'Polar', value: '7' },
        { label: 'Mediterranean', value: '8' },
        { label: 'Monsoon', value: '9' },
      ] },
    { type: 'number', name: 'elevationMeters', label: 'Elevation Meters', min: 0, step: 0.01 },
    { type: 'text', name: 'address', label: 'Address' },
    { type: 'text', name: 'region', label: 'Region' },
    { type: 'text', name: 'country', label: 'Country' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'basic',
        title: 'Farm Details',
        fields: ['name', 'description', 'farmType', 'soilType', 'address', 'region', 'country'],
        columns: 2,
      },
      {
        id: 'classification',
        title: 'Status & Classification',
        fields: ['climateZone'],
        columns: 2,
      },
      {
        id: 'metrics',
        title: 'Measurements & Metrics',
        fields: ['totalAreaHectares', 'elevationMeters'],
        columns: 2,
      },
    ],
  },
};
