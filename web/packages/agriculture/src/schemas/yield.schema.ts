/**
 * Yield & Harvest Form Schemas
 */
import type { FormSchema } from '@samavāya/core';

export const yieldRecordFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'field_id', label: 'Field', required: true },
    { type: 'text', name: 'crop_name', label: 'Crop', required: true },
    { type: 'date', name: 'harvest_date', label: 'Harvest Date', required: true } as any,
    { type: 'number', name: 'actual_yield', label: 'Actual Yield', required: true, min: 0, step: 0.01 } as any,
    {
      type: 'select', name: 'yield_unit', label: 'Yield Unit', required: true,
      options: [
        { label: 'Tonnes', value: 'tonnes' },
        { label: 'Quintals', value: 'quintals' },
        { label: 'Kilograms', value: 'kg' },
        { label: 'Bushels', value: 'bushels' },
      ],
    } as any,
    { type: 'number', name: 'area_harvested', label: 'Area Harvested', min: 0, step: 0.01 } as any,
    {
      type: 'select', name: 'area_unit', label: 'Area Unit',
      options: [
        { label: 'Hectares', value: 'hectares' },
        { label: 'Acres', value: 'acres' },
      ],
    } as any,
    {
      type: 'select', name: 'quality_grade', label: 'Quality Grade',
      options: [
        { label: 'Premium (A)', value: 'A' },
        { label: 'Standard (B)', value: 'B' },
        { label: 'Below Standard (C)', value: 'C' },
        { label: 'Reject (D)', value: 'D' },
      ],
    } as any,
    { type: 'number', name: 'moisture_content_pct', label: 'Moisture Content (%)', min: 0, max: 100, step: 0.1 } as any,
    { type: 'text', name: 'storage_location', label: 'Storage Location' },
    {
      type: 'select', name: 'harvest_method', label: 'Harvest Method',
      options: [
        { label: 'Manual', value: 'manual' },
        { label: 'Combine Harvester', value: 'combine' },
        { label: 'Semi-mechanized', value: 'semi_mechanized' },
        { label: 'Robotic', value: 'robotic' },
      ],
    } as any,
    { type: 'number', name: 'labor_hours', label: 'Labor Hours', min: 0, step: 0.5 } as any,
    { type: 'number', name: 'cost_per_unit', label: 'Cost per Unit', min: 0, step: 0.01 } as any,
    { type: 'number', name: 'market_price_per_unit', label: 'Market Price per Unit', min: 0, step: 0.01 } as any,
    { type: 'textarea', name: 'notes', label: 'Notes', rows: 3 } as any,
    {
      type: 'select', name: 'status', label: 'Status',
      options: [
        { label: 'Draft', value: 'draft' },
        { label: 'Confirmed', value: 'confirmed' },
        { label: 'In Storage', value: 'in_storage' },
        { label: 'Sold', value: 'sold' },
      ],
    } as any,
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'harvest',
        title: 'Harvest Details',
        fields: ['field_id', 'crop_name', 'harvest_date', 'harvest_method', 'status'],
        columns: 2,
      },
      {
        id: 'yield_data',
        title: 'Yield Data',
        fields: ['actual_yield', 'yield_unit', 'area_harvested', 'area_unit', 'quality_grade', 'moisture_content_pct'],
        columns: 3,
      },
      {
        id: 'economics',
        title: 'Economics',
        fields: ['labor_hours', 'cost_per_unit', 'market_price_per_unit', 'storage_location'],
        columns: 2,
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

export const harvestPlanFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'field_id', label: 'Field', required: true },
    { type: 'text', name: 'crop_name', label: 'Crop', required: true },
    { type: 'date', name: 'planned_start_date', label: 'Planned Start', required: true } as any,
    { type: 'date', name: 'planned_end_date', label: 'Planned End', required: true } as any,
    { type: 'number', name: 'estimated_yield', label: 'Estimated Yield', min: 0, step: 0.01 } as any,
    {
      type: 'select', name: 'yield_unit', label: 'Yield Unit',
      options: [
        { label: 'Tonnes', value: 'tonnes' },
        { label: 'Quintals', value: 'quintals' },
        { label: 'Kilograms', value: 'kg' },
      ],
    } as any,
    {
      type: 'select', name: 'harvest_method', label: 'Harvest Method',
      options: [
        { label: 'Manual', value: 'manual' },
        { label: 'Combine Harvester', value: 'combine' },
        { label: 'Semi-mechanized', value: 'semi_mechanized' },
        { label: 'Robotic', value: 'robotic' },
      ],
    } as any,
    { type: 'number', name: 'labor_required', label: 'Labor Required (persons)', min: 0 } as any,
    { type: 'textarea', name: 'storage_plan', label: 'Storage Plan', rows: 2 } as any,
    { type: 'textarea', name: 'transportation_plan', label: 'Transportation Plan', rows: 2 } as any,
    { type: 'text', name: 'quality_targets', label: 'Quality Targets' },
    { type: 'number', name: 'priority', label: 'Priority', min: 1, max: 10 } as any,
    { type: 'textarea', name: 'notes', label: 'Notes', rows: 3 } as any,
    {
      type: 'select', name: 'status', label: 'Status',
      options: [
        { label: 'Draft', value: 'draft' },
        { label: 'Approved', value: 'approved' },
        { label: 'In Progress', value: 'in_progress' },
        { label: 'Completed', value: 'completed' },
        { label: 'Cancelled', value: 'cancelled' },
      ],
    } as any,
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'plan',
        title: 'Harvest Plan',
        fields: ['field_id', 'crop_name', 'planned_start_date', 'planned_end_date', 'harvest_method', 'priority', 'status'],
        columns: 2,
      },
      {
        id: 'estimates',
        title: 'Estimates',
        fields: ['estimated_yield', 'yield_unit', 'labor_required', 'quality_targets'],
        columns: 2,
      },
      {
        id: 'logistics',
        title: 'Logistics',
        fields: ['storage_plan', 'transportation_plan', 'notes'],
        columns: 1,
      },
    ],
  },
};
