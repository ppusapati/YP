/**
 * @generated from proto — DO NOT EDIT
 * Run: node scripts/generate-schemas.mjs
 */
import type { FormSchema } from '@samavāya/core';
import { farmClient, fieldClient } from '../services';

export const soilSampleFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'autocomplete', name: 'fieldId', label: 'Field', loadOptions: async (query: string) => {
        const res = await fieldClient.listFields({ search: query, pageSize: 50 });
        return (res.fields || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'autocomplete', name: 'farmId', label: 'Farm', required: true, loadOptions: async (query: string) => {
        const res = await farmClient.listFarms({ search: query, pageSize: 50 });
        return (res.farms || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'number', name: 'sampleDepthCm', label: 'Sample Depth Cm' },
    { type: 'date', name: 'collectionDate', label: 'Collection Date' },
    { type: 'number', name: 'pH', label: 'P H' },
    { type: 'number', name: 'organicMatterPct', label: 'Organic Matter Pct', min: 0, max: 100 },
    { type: 'number', name: 'nitrogenPpm', label: 'Nitrogen Ppm' },
    { type: 'number', name: 'phosphorusPpm', label: 'Phosphorus Ppm' },
    { type: 'number', name: 'potassiumPpm', label: 'Potassium Ppm' },
    { type: 'number', name: 'calciumPpm', label: 'Calcium Ppm' },
    { type: 'number', name: 'magnesiumPpm', label: 'Magnesium Ppm' },
    { type: 'number', name: 'sulfurPpm', label: 'Sulfur Ppm' },
    { type: 'number', name: 'ironPpm', label: 'Iron Ppm' },
    { type: 'number', name: 'manganesePpm', label: 'Manganese Ppm' },
    { type: 'number', name: 'zincPpm', label: 'Zinc Ppm' },
    { type: 'number', name: 'copperPpm', label: 'Copper Ppm' },
    { type: 'number', name: 'boronPpm', label: 'Boron Ppm' },
    { type: 'number', name: 'moisturePct', label: 'Moisture Pct', min: 0, max: 100 },
    { type: 'select', name: 'texture', label: 'Texture', options: [
        { label: 'Sandy', value: '1' },
        { label: 'Loamy', value: '2' },
        { label: 'Clay', value: '3' },
        { label: 'Silt', value: '4' },
        { label: 'Peat', value: '5' },
        { label: 'Chalk', value: '6' },
      ] },
    { type: 'number', name: 'bulkDensity', label: 'Bulk Density' },
    { type: 'number', name: 'cationExchangeCapacity', label: 'Cation Exchange Capacity' },
    { type: 'number', name: 'electricalConductivity', label: 'Electrical Conductivity' },
    { type: 'textarea', name: 'notes', label: 'Notes', rows: 3 },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'basic',
        title: 'Soil Sample Details',
        fields: ['fieldId', 'farmId', 'notes'],
        columns: 2,
      },
      {
        id: 'classification',
        title: 'Status & Classification',
        fields: ['texture'],
        columns: 2,
      },
      {
        id: 'metrics',
        title: 'Measurements & Metrics',
        fields: ['sampleDepthCm', 'pH', 'organicMatterPct', 'nitrogenPpm', 'phosphorusPpm', 'potassiumPpm', 'calciumPpm', 'magnesiumPpm', 'sulfurPpm', 'ironPpm', 'manganesePpm', 'zincPpm', 'copperPpm', 'boronPpm', 'moisturePct', 'bulkDensity', 'cationExchangeCapacity', 'electricalConductivity'],
        columns: 2,
      },
      {
        id: 'dates',
        title: 'Dates',
        fields: ['collectionDate'],
        columns: 2,
      },
    ],
  },
};
