/**
 * @generated from proto — DO NOT EDIT
 * Run: node scripts/generate-schemas.mjs
 */
import type { FormSchema } from '@samavāya/core';
import { farmClient, fieldClient, pestClient } from '../services';

export const pestPredictionFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'autocomplete', name: 'farmId', label: 'Farm', required: true, loadOptions: async (query: string) => {
        const res = await farmClient.listFarms({ search: query, pageSize: 50 });
        return (res.farms || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'autocomplete', name: 'fieldId', label: 'Field', loadOptions: async (query: string) => {
        const res = await fieldClient.listFields({ search: query, pageSize: 50 });
        return (res.fields || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'autocomplete', name: 'pestSpeciesId', label: 'Pest Species', loadOptions: async (query: string) => {
        const res = await pestClient.listPestSpecies({ search: query, pageSize: 50 });
        return (res.species || []).map((r: any) => ({ label: r.commonName || r.id, value: r.id }));
      } },
    { type: 'date', name: 'predictionDate', label: 'Prediction Date' },
    { type: 'select', name: 'riskLevel', label: 'Risk Level', options: [
        { label: 'None', value: '1' },
        { label: 'Low', value: '2' },
        { label: 'Moderate', value: '3' },
        { label: 'High', value: '4' },
        { label: 'Critical', value: '5' },
      ] },
    { type: 'number', name: 'riskScore', label: 'Risk Score', step: 1 },
    { type: 'number', name: 'confidencePct', label: 'Confidence Pct', min: 0, max: 100 },
    { type: 'text', name: 'cropType', label: 'Crop Type' },
    { type: 'select', name: 'growthStage', label: 'Growth Stage', options: [
        { label: 'Germination', value: '1' },
        { label: 'Seedling', value: '2' },
        { label: 'Vegetative', value: '3' },
        { label: 'Flowering', value: '4' },
        { label: 'Fruiting', value: '5' },
        { label: 'Maturation', value: '6' },
        { label: 'Harvest', value: '7' },
      ] },
    { type: 'number', name: 'geographicRiskFactor', label: 'Geographic Risk Factor' },
    { type: 'number', name: 'historicalOccurrenceCount', label: 'Historical Occurrence Count', step: 1 },
    { type: 'date', name: 'predictedOnsetDate', label: 'Predicted Onset Date' },
    { type: 'date', name: 'predictedPeakDate', label: 'Predicted Peak Date' },
    { type: 'date', name: 'treatmentWindowStart', label: 'Treatment Window Start' },
    { type: 'date', name: 'treatmentWindowEnd', label: 'Treatment Window End' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'basic',
        title: 'Pest Prediction Details',
        fields: ['farmId', 'fieldId', 'pestSpeciesId', 'cropType'],
        columns: 2,
      },
      {
        id: 'classification',
        title: 'Status & Classification',
        fields: ['riskLevel', 'growthStage'],
        columns: 2,
      },
      {
        id: 'metrics',
        title: 'Measurements & Metrics',
        fields: ['riskScore', 'confidencePct', 'geographicRiskFactor', 'historicalOccurrenceCount'],
        columns: 2,
      },
      {
        id: 'dates',
        title: 'Dates',
        fields: ['predictionDate', 'predictedOnsetDate', 'predictedPeakDate', 'treatmentWindowStart', 'treatmentWindowEnd'],
        columns: 2,
      },
    ],
  },
};

export const pestObservationFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'autocomplete', name: 'farmId', label: 'Farm', required: true, loadOptions: async (query: string) => {
        const res = await farmClient.listFarms({ search: query, pageSize: 50 });
        return (res.farms || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'autocomplete', name: 'fieldId', label: 'Field', loadOptions: async (query: string) => {
        const res = await fieldClient.listFields({ search: query, pageSize: 50 });
        return (res.fields || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'autocomplete', name: 'pestSpeciesId', label: 'Pest Species', loadOptions: async (query: string) => {
        const res = await pestClient.listPestSpecies({ search: query, pageSize: 50 });
        return (res.species || []).map((r: any) => ({ label: r.commonName || r.id, value: r.id }));
      } },
    { type: 'number', name: 'pestCount', label: 'Pest Count', step: 1 },
    { type: 'select', name: 'damageLevel', label: 'Damage Level', options: [
        { label: 'None', value: '1' },
        { label: 'Light', value: '2' },
        { label: 'Moderate', value: '3' },
        { label: 'Severe', value: '4' },
        { label: 'Devastating', value: '5' },
      ] },
    { type: 'text', name: 'trapType', label: 'Trap Type' },
    { type: 'url', name: 'imageUrl', label: 'Image Url', placeholder: 'https://...' },
    { type: 'number', name: 'latitude', label: 'Latitude', min: -90, max: 90, step: 0.000001 },
    { type: 'number', name: 'longitude', label: 'Longitude', min: -180, max: 180, step: 0.000001 },
    { type: 'textarea', name: 'notes', label: 'Notes', rows: 3 },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'basic',
        title: 'Pest Observation Details',
        fields: ['farmId', 'fieldId', 'pestSpeciesId', 'notes', 'trapType', 'imageUrl'],
        columns: 2,
      },
      {
        id: 'classification',
        title: 'Status & Classification',
        fields: ['damageLevel'],
        columns: 2,
      },
      {
        id: 'metrics',
        title: 'Measurements & Metrics',
        fields: ['pestCount', 'latitude', 'longitude'],
        columns: 2,
      },
    ],
  },
};
