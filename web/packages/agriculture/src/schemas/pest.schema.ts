/**
 * Pest Prediction & Observation Form Schemas
 */
import type { FormSchema } from '@samavāya/core';

export const pestPredictionFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'field_id', label: 'Field', required: true },
    { type: 'text', name: 'crop_id', label: 'Crop', required: true },
    { type: 'text', name: 'pest_name', label: 'Pest Name', required: true },
    { type: 'date', name: 'prediction_date', label: 'Prediction Date', required: true } as any,
    {
      type: 'select', name: 'risk_level', label: 'Risk Level', required: true,
      options: [
        { label: 'Low', value: 'low' },
        { label: 'Medium', value: 'medium' },
        { label: 'High', value: 'high' },
        { label: 'Critical', value: 'critical' },
      ],
    } as any,
    { type: 'number', name: 'probability', label: 'Probability (%)', min: 0, max: 100, step: 0.1 } as any,
    { type: 'number', name: 'confidence', label: 'Confidence (%)', min: 0, max: 100, step: 0.1 } as any,
    { type: 'date', name: 'predicted_onset_date', label: 'Predicted Onset' } as any,
    { type: 'date', name: 'predicted_peak_date', label: 'Predicted Peak' } as any,
    { type: 'number', name: 'affected_area_pct', label: 'Affected Area (%)', min: 0, max: 100, step: 0.1 } as any,
    { type: 'textarea', name: 'weather_factors', label: 'Weather Factors', rows: 2 } as any,
    { type: 'text', name: 'model_version', label: 'Model Version' },
    {
      type: 'select', name: 'status', label: 'Status',
      options: [
        { label: 'Active', value: 'active' },
        { label: 'Expired', value: 'expired' },
        { label: 'Verified', value: 'verified' },
        { label: 'False Alarm', value: 'false_alarm' },
      ],
    } as any,
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'prediction',
        title: 'Prediction Details',
        fields: ['field_id', 'crop_id', 'pest_name', 'prediction_date', 'risk_level', 'status'],
        columns: 2,
      },
      {
        id: 'analysis',
        title: 'Analysis',
        fields: ['probability', 'confidence', 'predicted_onset_date', 'predicted_peak_date', 'affected_area_pct'],
        columns: 2,
      },
      {
        id: 'context',
        title: 'Context',
        fields: ['weather_factors', 'model_version'],
        columns: 1,
      },
    ],
  },
};

export const pestObservationFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'field_id', label: 'Field', required: true },
    { type: 'text', name: 'pest_name', label: 'Pest Name', required: true },
    { type: 'date', name: 'observation_date', label: 'Observation Date', required: true } as any,
    {
      type: 'select', name: 'severity', label: 'Severity', required: true,
      options: [
        { label: 'Trace', value: 'trace' },
        { label: 'Light', value: 'light' },
        { label: 'Moderate', value: 'moderate' },
        { label: 'Severe', value: 'severe' },
        { label: 'Devastating', value: 'devastating' },
      ],
    } as any,
    { type: 'number', name: 'affected_area_pct', label: 'Affected Area (%)', min: 0, max: 100, step: 0.1 } as any,
    {
      type: 'select', name: 'lifecycle_stage', label: 'Lifecycle Stage',
      options: [
        { label: 'Egg', value: 'egg' },
        { label: 'Larva', value: 'larva' },
        { label: 'Pupa', value: 'pupa' },
        { label: 'Adult', value: 'adult' },
        { label: 'Nymph', value: 'nymph' },
        { label: 'Multiple', value: 'multiple' },
      ],
    } as any,
    { type: 'number', name: 'population_density', label: 'Population Density (per sq m)', min: 0 } as any,
    {
      type: 'select', name: 'damage_type', label: 'Damage Type',
      options: [
        { label: 'Chewing', value: 'chewing' },
        { label: 'Sucking', value: 'sucking' },
        { label: 'Boring', value: 'boring' },
        { label: 'Mining', value: 'mining' },
        { label: 'Galling', value: 'galling' },
        { label: 'Root Damage', value: 'root_damage' },
      ],
    } as any,
    { type: 'number', name: 'latitude', label: 'Latitude', step: 0.000001, min: -90, max: 90 } as any,
    { type: 'number', name: 'longitude', label: 'Longitude', step: 0.000001, min: -180, max: 180 } as any,
    { type: 'text', name: 'observer_name', label: 'Observer Name' },
    { type: 'textarea', name: 'notes', label: 'Notes', rows: 3 } as any,
    {
      type: 'select', name: 'status', label: 'Status',
      options: [
        { label: 'Reported', value: 'reported' },
        { label: 'Confirmed', value: 'confirmed' },
        { label: 'Under Treatment', value: 'under_treatment' },
        { label: 'Resolved', value: 'resolved' },
      ],
    } as any,
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'observation',
        title: 'Observation Details',
        fields: ['field_id', 'pest_name', 'observation_date', 'severity', 'status'],
        columns: 2,
      },
      {
        id: 'pest_details',
        title: 'Pest Details',
        fields: ['affected_area_pct', 'lifecycle_stage', 'population_density', 'damage_type'],
        columns: 2,
      },
      {
        id: 'location',
        title: 'Location',
        fields: ['latitude', 'longitude', 'observer_name'],
        columns: 3,
      },
      {
        id: 'notes_section',
        title: 'Notes',
        fields: ['notes'],
        columns: 1,
      },
    ],
  },
};
