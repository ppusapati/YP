/**
 * Soil Sample Form Schema
 */
import type { FormSchema } from '@samavāya/core';

export const soilSampleFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'field_id', label: 'Field', placeholder: 'Select field', required: true },
    { type: 'date', name: 'sample_date', label: 'Sample Date', required: true } as any,
    { type: 'number', name: 'sample_depth_cm', label: 'Sample Depth (cm)', min: 0, max: 300, required: true } as any,
    { type: 'number', name: 'latitude', label: 'Latitude', step: 0.000001, min: -90, max: 90 } as any,
    { type: 'number', name: 'longitude', label: 'Longitude', step: 0.000001, min: -180, max: 180 } as any,
    { type: 'number', name: 'ph', label: 'pH', min: 0, max: 14, step: 0.01, required: true } as any,
    { type: 'number', name: 'organic_matter_pct', label: 'Organic Matter (%)', min: 0, max: 100, step: 0.01 } as any,
    { type: 'number', name: 'nitrogen_ppm', label: 'Nitrogen (ppm)', min: 0, step: 0.1 } as any,
    { type: 'number', name: 'phosphorus_ppm', label: 'Phosphorus (ppm)', min: 0, step: 0.1 } as any,
    { type: 'number', name: 'potassium_ppm', label: 'Potassium (ppm)', min: 0, step: 0.1 } as any,
    { type: 'number', name: 'calcium_ppm', label: 'Calcium (ppm)', min: 0, step: 0.1 } as any,
    { type: 'number', name: 'magnesium_ppm', label: 'Magnesium (ppm)', min: 0, step: 0.1 } as any,
    { type: 'number', name: 'sulfur_ppm', label: 'Sulfur (ppm)', min: 0, step: 0.1 } as any,
    { type: 'number', name: 'iron_ppm', label: 'Iron (ppm)', min: 0, step: 0.1 } as any,
    { type: 'number', name: 'zinc_ppm', label: 'Zinc (ppm)', min: 0, step: 0.1 } as any,
    { type: 'number', name: 'manganese_ppm', label: 'Manganese (ppm)', min: 0, step: 0.1 } as any,
    { type: 'number', name: 'copper_ppm', label: 'Copper (ppm)', min: 0, step: 0.1 } as any,
    { type: 'number', name: 'boron_ppm', label: 'Boron (ppm)', min: 0, step: 0.1 } as any,
    {
      type: 'select', name: 'texture_class', label: 'Texture Class',
      options: [
        { label: 'Sand', value: 'sand' },
        { label: 'Sandy Loam', value: 'sandy_loam' },
        { label: 'Loam', value: 'loam' },
        { label: 'Silt Loam', value: 'silt_loam' },
        { label: 'Clay Loam', value: 'clay_loam' },
        { label: 'Clay', value: 'clay' },
        { label: 'Silty Clay', value: 'silty_clay' },
      ],
    } as any,
    { type: 'number', name: 'sand_pct', label: 'Sand (%)', min: 0, max: 100, step: 0.1 } as any,
    { type: 'number', name: 'silt_pct', label: 'Silt (%)', min: 0, max: 100, step: 0.1 } as any,
    { type: 'number', name: 'clay_pct', label: 'Clay (%)', min: 0, max: 100, step: 0.1 } as any,
    { type: 'number', name: 'cec', label: 'CEC (meq/100g)', min: 0, step: 0.01 } as any,
    { type: 'number', name: 'moisture_pct', label: 'Moisture (%)', min: 0, max: 100, step: 0.1 } as any,
    { type: 'number', name: 'electrical_conductivity', label: 'EC (dS/m)', min: 0, step: 0.01 } as any,
    { type: 'text', name: 'lab_name', label: 'Lab Name', placeholder: 'Testing laboratory name' },
    { type: 'text', name: 'lab_report_id', label: 'Lab Report ID' },
    { type: 'textarea', name: 'notes', label: 'Notes', rows: 3 } as any,
    {
      type: 'select', name: 'status', label: 'Status',
      options: [
        { label: 'Pending', value: 'pending' },
        { label: 'Analyzed', value: 'analyzed' },
        { label: 'Verified', value: 'verified' },
        { label: 'Rejected', value: 'rejected' },
      ],
    } as any,
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'sample_info',
        title: 'Sample Information',
        fields: ['field_id', 'sample_date', 'sample_depth_cm', 'latitude', 'longitude', 'status'],
        columns: 2,
      },
      {
        id: 'primary_nutrients',
        title: 'Primary Nutrients (N-P-K)',
        fields: ['ph', 'organic_matter_pct', 'nitrogen_ppm', 'phosphorus_ppm', 'potassium_ppm'],
        columns: 3,
      },
      {
        id: 'secondary_nutrients',
        title: 'Secondary & Micro Nutrients',
        fields: ['calcium_ppm', 'magnesium_ppm', 'sulfur_ppm', 'iron_ppm', 'zinc_ppm', 'manganese_ppm', 'copper_ppm', 'boron_ppm'],
        columns: 4,
      },
      {
        id: 'physical',
        title: 'Physical Properties',
        fields: ['texture_class', 'sand_pct', 'silt_pct', 'clay_pct', 'cec', 'moisture_pct', 'electrical_conductivity'],
        columns: 3,
      },
      {
        id: 'lab',
        title: 'Lab Information',
        fields: ['lab_name', 'lab_report_id', 'notes'],
        columns: 2,
      },
    ],
  },
};
