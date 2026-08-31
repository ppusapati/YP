/**
 * Irrigation Service Form Schemas
 * Based on agriculture.irrigation.v1 protobuf definitions
 */
import type { FormSchema } from '@samavāya/core';

/** Form for creating an irrigation schedule (CreateIrrigationScheduleRequest) */
export const irrigationScheduleSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'select', name: 'field_id', label: 'Field', required: true, options: [], searchable: true }, // RPC: FieldService.ListFields
    { type: 'select', name: 'zone_id', label: 'Irrigation Zone', options: [], searchable: true }, // RPC: IrrigationService.ListZones
    { type: 'select', name: 'schedule_type', label: 'Schedule Type', required: true, options: [
      { label: 'Fixed', value: 'SCHEDULE_TYPE_FIXED' },
      { label: 'Adaptive', value: 'SCHEDULE_TYPE_ADAPTIVE' },
      { label: 'AI-Driven', value: 'SCHEDULE_TYPE_AI_DRIVEN' },
    ] },
    { type: 'datetime', name: 'start_time', label: 'Start Time' },
    { type: 'datetime', name: 'end_time', label: 'End Time' },
    { type: 'number', name: 'duration_minutes', label: 'Duration (minutes)', min: 0, step: 1, suffix: 'min' },
    { type: 'number', name: 'water_quantity_liters', label: 'Water Quantity (liters)', min: 0, step: 0.01, suffix: 'L' },
    { type: 'number', name: 'flow_rate_liters_per_hour', label: 'Flow Rate (L/hr)', min: 0, step: 0.01, suffix: 'L/hr' },
    { type: 'select', name: 'frequency', label: 'Frequency', options: [
      { label: 'Daily', value: 'FREQUENCY_DAILY' },
      { label: 'Weekly', value: 'FREQUENCY_WEEKLY' },
      { label: 'Bi-Weekly', value: 'FREQUENCY_BI_WEEKLY' },
      { label: 'Monthly', value: 'FREQUENCY_MONTHLY' },
      { label: 'Custom', value: 'FREQUENCY_CUSTOM' },
    ] },
    { type: 'number', name: 'moisture_threshold_pct', label: 'Moisture Threshold (%)', min: 0, max: 100, step: 0.1, suffix: '%' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'target',
        title: 'Target',
        fields: ['field_id', 'zone_id', 'schedule_type', 'frequency'],
        columns: 2,
      },
      {
        id: 'timing',
        title: 'Timing',
        fields: ['start_time', 'end_time', 'duration_minutes'],
        columns: 2,
      },
      {
        id: 'water',
        title: 'Water Parameters',
        fields: ['water_quantity_liters', 'flow_rate_liters_per_hour', 'moisture_threshold_pct'],
        columns: 2,
      },
    ],
  },
};

/** Form for creating an irrigation zone (CreateIrrigationZoneRequest) */
export const irrigationZoneSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'select', name: 'field_id', label: 'Field', required: true, options: [], searchable: true }, // RPC: FieldService.ListFields
    { type: 'text', name: 'name', label: 'Zone Name', required: true, placeholder: 'Enter zone name' },
    { type: 'number', name: 'area_hectares', label: 'Area (hectares)', min: 0, step: 0.01, suffix: 'ha' },
    { type: 'select', name: 'irrigation_type', label: 'Irrigation Type', options: [
      { label: 'Drip', value: 'IRRIGATION_TYPE_DRIP' },
      { label: 'Sprinkler', value: 'IRRIGATION_TYPE_SPRINKLER' },
      { label: 'Flood', value: 'IRRIGATION_TYPE_FLOOD' },
      { label: 'Center Pivot', value: 'IRRIGATION_TYPE_CENTER_PIVOT' },
      { label: 'Furrow', value: 'IRRIGATION_TYPE_FURROW' },
      { label: 'Subsurface', value: 'IRRIGATION_TYPE_SUBSURFACE' },
    ] },
    { type: 'select', name: 'controller_id', label: 'Controller', options: [], searchable: true }, // RPC: IrrigationService.ListControllers
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'zone',
        title: 'Zone Details',
        fields: ['field_id', 'name', 'area_hectares', 'irrigation_type', 'controller_id'],
        columns: 2,
      },
    ],
  },
};

/** Form for registering an irrigation controller (RegisterControllerRequest) */
export const irrigationControllerSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'name', label: 'Controller Name', required: true, placeholder: 'Enter controller name' },
    { type: 'select', name: 'controller_type', label: 'Controller Type', required: true, options: [
      { label: 'Manual', value: 'CONTROLLER_TYPE_MANUAL' },
      { label: 'Timer-Based', value: 'CONTROLLER_TYPE_TIMER' },
      { label: 'Smart', value: 'CONTROLLER_TYPE_SMART' },
      { label: 'IoT', value: 'CONTROLLER_TYPE_IOT' },
    ] },
    { type: 'select', name: 'protocol', label: 'Communication Protocol', options: [
      { label: 'MQTT', value: 'PROTOCOL_MQTT' },
      { label: 'LoRaWAN', value: 'PROTOCOL_LORAWAN' },
      { label: 'Zigbee', value: 'PROTOCOL_ZIGBEE' },
      { label: 'WiFi', value: 'PROTOCOL_WIFI' },
      { label: 'Cellular', value: 'PROTOCOL_CELLULAR' },
      { label: 'Bluetooth', value: 'PROTOCOL_BLUETOOTH' },
    ] },
    { type: 'text', name: 'firmware_version', label: 'Firmware Version', placeholder: 'e.g. v2.1.0' },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'controller',
        title: 'Controller Details',
        fields: ['name', 'controller_type', 'protocol', 'firmware_version'],
        columns: 2,
      },
    ],
  },
};
