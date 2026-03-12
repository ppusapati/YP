/**
 * Plant Diagnosis Form Schema
 */
import type { FormSchema } from '@samavāya/core';

export const diagnosisRequestFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'field_id', label: 'Field', required: true },
    { type: 'text', name: 'crop_name', label: 'Crop', required: true },
    { type: 'textarea', name: 'symptom_description', label: 'Symptom Description', required: true, rows: 4 } as any,
    {
      type: 'select', name: 'affected_plant_part', label: 'Affected Plant Part', required: true,
      options: [
        { label: 'Leaves', value: 'leaves' },
        { label: 'Stem', value: 'stem' },
        { label: 'Roots', value: 'roots' },
        { label: 'Flowers', value: 'flowers' },
        { label: 'Fruits', value: 'fruits' },
        { label: 'Seeds', value: 'seeds' },
        { label: 'Whole Plant', value: 'whole_plant' },
      ],
    } as any,
    {
      type: 'select', name: 'severity', label: 'Severity',
      options: [
        { label: 'Mild', value: 'mild' },
        { label: 'Moderate', value: 'moderate' },
        { label: 'Severe', value: 'severe' },
        { label: 'Critical', value: 'critical' },
      ],
    } as any,
    { type: 'date', name: 'onset_date', label: 'Onset Date' } as any,
    {
      type: 'select', name: 'spread_rate', label: 'Spread Rate',
      options: [
        { label: 'Stationary', value: 'stationary' },
        { label: 'Slow', value: 'slow' },
        { label: 'Moderate', value: 'moderate' },
        { label: 'Rapid', value: 'rapid' },
      ],
    } as any,
    { type: 'number', name: 'latitude', label: 'Latitude', step: 0.000001, min: -90, max: 90 } as any,
    { type: 'number', name: 'longitude', label: 'Longitude', step: 0.000001, min: -180, max: 180 } as any,
    { type: 'number', name: 'temperature', label: 'Temperature (°C)', step: 0.1 } as any,
    { type: 'number', name: 'humidity', label: 'Humidity (%)', min: 0, max: 100, step: 0.1 } as any,
    { type: 'text', name: 'submitted_by', label: 'Submitted By' },
    {
      type: 'select', name: 'status', label: 'Status',
      options: [
        { label: 'Submitted', value: 'submitted' },
        { label: 'Processing', value: 'processing' },
        { label: 'Diagnosed', value: 'diagnosed' },
        { label: 'Closed', value: 'closed' },
      ],
    } as any,
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'basic',
        title: 'Diagnosis Request',
        fields: ['field_id', 'crop_name', 'affected_plant_part', 'severity', 'status'],
        columns: 2,
      },
      {
        id: 'symptoms',
        title: 'Symptoms',
        fields: ['symptom_description', 'onset_date', 'spread_rate'],
        columns: 1,
      },
      {
        id: 'environment',
        title: 'Environmental Conditions',
        fields: ['latitude', 'longitude', 'temperature', 'humidity'],
        columns: 2,
      },
      {
        id: 'submitter',
        title: 'Submission',
        fields: ['submitted_by'],
        columns: 1,
      },
    ],
  },
};
