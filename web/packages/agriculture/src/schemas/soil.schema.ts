/**
 * Soil Sample Form Schema — derived from agriculture.soil.v1 proto
 */
import type { FormSchema } from '@samavāya/core';

export const soilSampleFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'fieldId', label: 'Field', placeholder: 'Select field', required: true },
    { type: 'text', name: 'farmId', label: 'Farm', placeholder: 'Select farm', required: true },
    { type: 'number', name: 'sampleDepthCm', label: 'Sample Depth (cm)', min: 0, max: 300 } as any,
    { type: 'date', name: 'collectionDate', label: 'Collection Date' } as any,
    { type: 'number', name: 'pH', label: 'pH', min: 0, max: 14, step: 0.01 } as any,
    { type: 'number', name: 'organicMatterPct', label: 'Organic Matter (%)', min: 0, max: 100, step: 0.01 } as any,
    { type: 'number', name: 'nitrogenPpm', label: 'Nitrogen (ppm)', min: 0, step: 0.1 } as any,
    { type: 'number', name: 'phosphorusPpm', label: 'Phosphorus (ppm)', min: 0, step: 0.1 } as any,
    { type: 'number', name: 'potassiumPpm', label: 'Potassium (ppm)', min: 0, step: 0.1 } as any,
    { type: 'number', name: 'calciumPpm', label: 'Calcium (ppm)', min: 0, step: 0.1 } as any,
    { type: 'number', name: 'magnesiumPpm', label: 'Magnesium (ppm)', min: 0, step: 0.1 } as any,
    { type: 'number', name: 'sulfurPpm', label: 'Sulfur (ppm)', min: 0, step: 0.1 } as any,
    { type: 'number', name: 'ironPpm', label: 'Iron (ppm)', min: 0, step: 0.1 } as any,
    { type: 'number', name: 'manganesePpm', label: 'Manganese (ppm)', min: 0, step: 0.1 } as any,
    { type: 'number', name: 'zincPpm', label: 'Zinc (ppm)', min: 0, step: 0.1 } as any,
    { type: 'number', name: 'copperPpm', label: 'Copper (ppm)', min: 0, step: 0.1 } as any,
    { type: 'number', name: 'boronPpm', label: 'Boron (ppm)', min: 0, step: 0.1 } as any,
    { type: 'number', name: 'moisturePct', label: 'Moisture (%)', min: 0, max: 100, step: 0.1 } as any,
    {
      type: 'select', name: 'texture', label: 'Soil Texture',
      options: [
        { label: 'Sandy', value: '1' },
        { label: 'Loamy', value: '2' },
        { label: 'Clay', value: '3' },
        { label: 'Silt', value: '4' },
        { label: 'Peat', value: '5' },
        { label: 'Chalk', value: '6' },
      ],
    } as any,
    { type: 'number', name: 'bulkDensity', label: 'Bulk Density (g/cm³)', min: 0, step: 0.01 } as any,
    { type: 'number', name: 'cationExchangeCapacity', label: 'CEC (meq/100g)', min: 0, step: 0.01 } as any,
    { type: 'number', name: 'electricalConductivity', label: 'EC (dS/m)', min: 0, step: 0.01 } as any,
    { type: 'textarea', name: 'notes', label: 'Notes', rows: 3 } as any,
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'sample_info',
        title: 'Sample Info',
        fields: ['fieldId', 'farmId', 'sampleDepthCm', 'collectionDate'],
        columns: 2,
      },
      {
        id: 'primary_nutrients',
        title: 'Primary Nutrients',
        fields: ['pH', 'organicMatterPct', 'nitrogenPpm', 'phosphorusPpm', 'potassiumPpm'],
        columns: 3,
      },
      {
        id: 'secondary_micro',
        title: 'Secondary & Micro Nutrients',
        fields: ['calciumPpm', 'magnesiumPpm', 'sulfurPpm', 'ironPpm', 'manganesePpm', 'zincPpm', 'copperPpm', 'boronPpm'],
        columns: 4,
      },
      {
        id: 'physical',
        title: 'Physical Properties',
        fields: ['moisturePct', 'texture', 'bulkDensity', 'cationExchangeCapacity', 'electricalConductivity', 'notes'],
        columns: 3,
      },
    ],
  },
};
