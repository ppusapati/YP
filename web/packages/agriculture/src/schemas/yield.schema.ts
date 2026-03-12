import type { FormSchema } from '@samavāya/core';

export const yieldRecordFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'farmId', label: 'Farm', required: true },
    { type: 'text', name: 'fieldId', label: 'Field', required: true },
    { type: 'text', name: 'cropId', label: 'Crop', required: true },
    { type: 'text', name: 'season', label: 'Season' },
    { type: 'number', name: 'year', label: 'Year', min: 2000, max: 2100 } as any,
    { type: 'number', name: 'actualYieldKgPerHectare', label: 'Actual Yield (kg/ha)' } as any,
    {
      type: 'select', name: 'qualityGrade', label: 'Quality Grade',
      options: [
        { label: 'Grade A', value: '1' },
        { label: 'Grade B', value: '2' },
        { label: 'Grade C', value: '3' },
        { label: 'Grade D', value: '4' },
      ],
    } as any,
    { type: 'number', name: 'moistureContentPct', label: 'Moisture Content (%)', min: 0, max: 100 } as any,
    { type: 'date', name: 'harvestDate', label: 'Harvest Date' } as any,
    { type: 'text', name: 'harvestMethod', label: 'Harvest Method' },
    { type: 'number', name: 'laborHours', label: 'Labor Hours' } as any,
    { type: 'textarea', name: 'notes', label: 'Notes', rows: 3 } as any,
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'yield_details',
        title: 'Yield Details',
        fields: ['farmId', 'fieldId', 'cropId', 'season', 'year'],
        columns: 2,
      },
      {
        id: 'quality_metrics',
        title: 'Quality & Metrics',
        fields: ['actualYieldKgPerHectare', 'qualityGrade', 'moistureContentPct'],
        columns: 2,
      },
      {
        id: 'harvest_info',
        title: 'Harvest Info',
        fields: ['harvestDate', 'harvestMethod', 'laborHours', 'notes'],
        columns: 2,
      },
    ],
  },
};

export const harvestPlanFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'farmId', label: 'Farm', required: true },
    { type: 'text', name: 'fieldId', label: 'Field', required: true },
    { type: 'text', name: 'cropId', label: 'Crop', required: true },
    { type: 'text', name: 'season', label: 'Season' },
    { type: 'number', name: 'year', label: 'Year' } as any,
    { type: 'date', name: 'plannedStartDate', label: 'Planned Start Date' } as any,
    { type: 'date', name: 'plannedEndDate', label: 'Planned End Date' } as any,
    { type: 'number', name: 'estimatedYieldKgPerHectare', label: 'Estimated Yield (kg/ha)' } as any,
    { type: 'text', name: 'harvestMethod', label: 'Harvest Method' },
    { type: 'number', name: 'laborRequired', label: 'Labor Required' } as any,
    { type: 'textarea', name: 'storagePlan', label: 'Storage Plan', rows: 2 } as any,
    { type: 'textarea', name: 'transportationPlan', label: 'Transportation Plan', rows: 2 } as any,
    { type: 'textarea', name: 'qualityTargets', label: 'Quality Targets', rows: 2 } as any,
    {
      type: 'select', name: 'status', label: 'Status',
      options: [
        { label: 'Draft', value: '1' },
        { label: 'Scheduled', value: '2' },
        { label: 'In Progress', value: '3' },
        { label: 'Completed', value: '4' },
        { label: 'Cancelled', value: '5' },
      ],
    } as any,
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'plan_details',
        title: 'Plan Details',
        fields: ['farmId', 'fieldId', 'cropId', 'season', 'year', 'status'],
        columns: 2,
      },
      {
        id: 'timeline_yield',
        title: 'Timeline & Yield',
        fields: ['plannedStartDate', 'plannedEndDate', 'estimatedYieldKgPerHectare', 'harvestMethod'],
        columns: 2,
      },
      {
        id: 'logistics',
        title: 'Logistics',
        fields: ['laborRequired', 'storagePlan', 'transportationPlan', 'qualityTargets'],
        columns: 1,
      },
    ],
  },
};
