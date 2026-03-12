/**
 * @generated from proto — DO NOT EDIT
 * Run: node scripts/generate-schemas.mjs
 */
import type { FormSchema } from '@samavāya/core';
import { cropClient, farmClient, fieldClient } from '../services';

export const yieldPredictionFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'autocomplete', name: 'farmId', label: 'Farm', required: true, loadOptions: async (query: string) => {
        const res = await farmClient.listFarms({ search: query, pageSize: 50 });
        return (res.farms || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'autocomplete', name: 'fieldId', label: 'Field', loadOptions: async (query: string) => {
        const res = await fieldClient.listFields({ search: query, pageSize: 50 });
        return (res.fields || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'autocomplete', name: 'cropId', label: 'Crop', loadOptions: async (query: string) => {
        const res = await cropClient.listCrops({ search: query, pageSize: 50 });
        return (res.crops || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'text', name: 'season', label: 'Season' },
    { type: 'number', name: 'year', label: 'Year', min: 2000, max: 2100, step: 1 },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'basic',
        title: 'Yield Prediction Details',
        fields: ['farmId', 'fieldId', 'cropId', 'season'],
        columns: 2,
      },
      {
        id: 'metrics',
        title: 'Measurements & Metrics',
        fields: ['year'],
        columns: 2,
      },
    ],
  },
};

export const yieldRecordFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'autocomplete', name: 'farmId', label: 'Farm', required: true, loadOptions: async (query: string) => {
        const res = await farmClient.listFarms({ search: query, pageSize: 50 });
        return (res.farms || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'autocomplete', name: 'fieldId', label: 'Field', loadOptions: async (query: string) => {
        const res = await fieldClient.listFields({ search: query, pageSize: 50 });
        return (res.fields || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'autocomplete', name: 'cropId', label: 'Crop', loadOptions: async (query: string) => {
        const res = await cropClient.listCrops({ search: query, pageSize: 50 });
        return (res.crops || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'text', name: 'season', label: 'Season' },
    { type: 'number', name: 'year', label: 'Year', min: 2000, max: 2100, step: 1 },
    { type: 'number', name: 'actualYieldKgPerHectare', label: 'Actual Yield Kg Per Hectare', min: 0, step: 0.01 },
    { type: 'number', name: 'totalAreaHarvestedHectares', label: 'Total Area Harvested Hectares', min: 0, step: 0.01 },
    { type: 'number', name: 'totalYieldKg', label: 'Total Yield Kg' },
    { type: 'select', name: 'harvestQualityGrade', label: 'Harvest Quality Grade', options: [
        { label: 'A', value: '1' },
        { label: 'B', value: '2' },
        { label: 'C', value: '3' },
        { label: 'D', value: '4' },
      ] },
    { type: 'number', name: 'moistureContentPct', label: 'Moisture Content Pct', min: 0, max: 100 },
    { type: 'date', name: 'harvestDate', label: 'Harvest Date' },
    { type: 'number', name: 'revenuePerHectare', label: 'Revenue Per Hectare', min: 0, step: 0.01 },
    { type: 'number', name: 'costPerHectare', label: 'Cost Per Hectare', min: 0, step: 0.01 },
    { type: 'text', name: 'predictionId', label: 'Prediction Id' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'basic',
        title: 'Yield Record Details',
        fields: ['farmId', 'fieldId', 'cropId', 'season', 'predictionId'],
        columns: 2,
      },
      {
        id: 'classification',
        title: 'Status & Classification',
        fields: ['harvestQualityGrade'],
        columns: 2,
      },
      {
        id: 'metrics',
        title: 'Measurements & Metrics',
        fields: ['year', 'actualYieldKgPerHectare', 'totalAreaHarvestedHectares', 'totalYieldKg', 'moistureContentPct', 'revenuePerHectare', 'costPerHectare'],
        columns: 2,
      },
      {
        id: 'dates',
        title: 'Dates',
        fields: ['harvestDate'],
        columns: 2,
      },
    ],
  },
};

export const harvestPlanFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'autocomplete', name: 'farmId', label: 'Farm', required: true, loadOptions: async (query: string) => {
        const res = await farmClient.listFarms({ search: query, pageSize: 50 });
        return (res.farms || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'autocomplete', name: 'fieldId', label: 'Field', loadOptions: async (query: string) => {
        const res = await fieldClient.listFields({ search: query, pageSize: 50 });
        return (res.fields || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'autocomplete', name: 'cropId', label: 'Crop', loadOptions: async (query: string) => {
        const res = await cropClient.listCrops({ search: query, pageSize: 50 });
        return (res.crops || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'text', name: 'season', label: 'Season' },
    { type: 'number', name: 'year', label: 'Year', min: 2000, max: 2100, step: 1 },
    { type: 'date', name: 'plannedStartDate', label: 'Planned Start Date' },
    { type: 'date', name: 'plannedEndDate', label: 'Planned End Date' },
    { type: 'number', name: 'estimatedYieldKg', label: 'Estimated Yield Kg' },
    { type: 'number', name: 'totalAreaHectares', label: 'Total Area Hectares', min: 0, step: 0.01 },
    { type: 'textarea', name: 'notes', label: 'Notes', rows: 3 },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'basic',
        title: 'Harvest Plan Details',
        fields: ['farmId', 'fieldId', 'cropId', 'notes', 'season'],
        columns: 2,
      },
      {
        id: 'metrics',
        title: 'Measurements & Metrics',
        fields: ['year', 'estimatedYieldKg', 'totalAreaHectares'],
        columns: 2,
      },
      {
        id: 'dates',
        title: 'Dates',
        fields: ['plannedStartDate', 'plannedEndDate'],
        columns: 2,
      },
    ],
  },
};
