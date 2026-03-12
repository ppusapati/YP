/**
 * Irrigation Form Schemas
 */
import type { FormSchema } from '@samavāya/core';

export const irrigationScheduleFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'schedule_name', label: 'Schedule Name', required: true },
    { type: 'text', name: 'field_id', label: 'Field', placeholder: 'Select field', required: true },
    { type: 'text', name: 'zone_id', label: 'Irrigation Zone', placeholder: 'Select zone' },
    {
      type: 'select', name: 'schedule_type', label: 'Schedule Type', required: true,
      options: [
        { label: 'Time-based', value: 'time_based' },
        { label: 'Sensor-triggered', value: 'sensor_triggered' },
        { label: 'Weather-based', value: 'weather_based' },
        { label: 'Manual', value: 'manual' },
        { label: 'AI-optimized', value: 'ai_optimized' },
      ],
    } as any,
    { type: 'time', name: 'start_time', label: 'Start Time', required: true } as any,
    { type: 'number', name: 'duration_minutes', label: 'Duration (min)', min: 1, max: 1440, required: true } as any,
    { type: 'number', name: 'interval_hours', label: 'Interval (hours)', min: 1, max: 168 } as any,
    { type: 'number', name: 'water_volume_liters', label: 'Water Volume (L)', min: 0 } as any,
    { type: 'number', name: 'flow_rate_lph', label: 'Flow Rate (L/h)', min: 0 } as any,
    { type: 'date', name: 'start_date', label: 'Start Date', required: true } as any,
    { type: 'date', name: 'end_date', label: 'End Date' } as any,
    { type: 'switch', name: 'is_active', label: 'Active' } as any,
    { type: 'number', name: 'priority', label: 'Priority', min: 1, max: 10 } as any,
    {
      type: 'select', name: 'trigger_condition', label: 'Trigger Condition',
      options: [
        { label: 'None', value: 'none' },
        { label: 'Soil Moisture Below Threshold', value: 'moisture_low' },
        { label: 'Temperature Above Threshold', value: 'temp_high' },
        { label: 'Evapotranspiration Rate', value: 'et_rate' },
        { label: 'Weather Forecast', value: 'weather' },
      ],
    } as any,
    { type: 'number', name: 'moisture_threshold', label: 'Moisture Threshold (%)', min: 0, max: 100 } as any,
    { type: 'number', name: 'temperature_threshold', label: 'Temp Threshold (°C)', min: 0, max: 60 } as any,
    { type: 'textarea', name: 'notes', label: 'Notes', rows: 3 } as any,
    {
      type: 'select', name: 'status', label: 'Status',
      options: [
        { label: 'Active', value: 'active' },
        { label: 'Paused', value: 'paused' },
        { label: 'Completed', value: 'completed' },
        { label: 'Draft', value: 'draft' },
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
        title: 'Schedule Details',
        fields: ['schedule_name', 'field_id', 'zone_id', 'schedule_type', 'is_active', 'priority', 'status'],
        columns: 2,
      },
      {
        id: 'timing',
        title: 'Timing',
        fields: ['start_time', 'duration_minutes', 'interval_hours', 'start_date', 'end_date'],
        columns: 2,
      },
      {
        id: 'water',
        title: 'Water Parameters',
        fields: ['water_volume_liters', 'flow_rate_lph'],
        columns: 2,
      },
      {
        id: 'triggers',
        title: 'Smart Triggers',
        fields: ['trigger_condition', 'moisture_threshold', 'temperature_threshold'],
        columns: 3,
      },
      {
        id: 'notes_section',
        title: 'Additional Notes',
        fields: ['notes'],
        columns: 1,
      },
    ],
  },
};

export const irrigationZoneFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'name', label: 'Zone Name', required: true },
    { type: 'text', name: 'code', label: 'Zone Code', required: true },
    { type: 'text', name: 'field_id', label: 'Field', required: true },
    { type: 'number', name: 'area', label: 'Area', min: 0, step: 0.01 } as any,
    {
      type: 'select', name: 'area_unit', label: 'Area Unit',
      options: [
        { label: 'Hectares', value: 'hectares' },
        { label: 'Acres', value: 'acres' },
        { label: 'Square Meters', value: 'sq_meters' },
      ],
    } as any,
    {
      type: 'select', name: 'irrigation_method', label: 'Irrigation Method', required: true,
      options: [
        { label: 'Drip', value: 'drip' },
        { label: 'Sprinkler', value: 'sprinkler' },
        { label: 'Micro-sprinkler', value: 'micro_sprinkler' },
        { label: 'Flood', value: 'flood' },
        { label: 'Subsurface', value: 'subsurface' },
      ],
    } as any,
    { type: 'text', name: 'controller_id', label: 'Controller ID' },
    { type: 'number', name: 'valve_number', label: 'Valve Number', min: 0 } as any,
    { type: 'number', name: 'emitter_count', label: 'Emitter Count', min: 0 } as any,
    { type: 'number', name: 'emitter_flow_rate', label: 'Emitter Flow Rate (L/h)', min: 0, step: 0.1 } as any,
    {
      type: 'select', name: 'status', label: 'Status',
      options: [
        { label: 'Active', value: 'active' },
        { label: 'Inactive', value: 'inactive' },
        { label: 'Maintenance', value: 'maintenance' },
      ],
    } as any,
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'zone_details',
        title: 'Zone Details',
        fields: ['name', 'code', 'field_id', 'area', 'area_unit', 'irrigation_method', 'status'],
        columns: 2,
      },
      {
        id: 'hardware',
        title: 'Hardware Configuration',
        fields: ['controller_id', 'valve_number', 'emitter_count', 'emitter_flow_rate'],
        columns: 2,
      },
    ],
  },
};
