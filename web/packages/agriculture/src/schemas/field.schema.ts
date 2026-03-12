/**
 * Field Form Schema
 */
import type { FormSchema } from '@samavāya/core';

export const fieldFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'name', label: 'Field Name', placeholder: 'e.g. North Paddy Field', required: true },
    { type: 'text', name: 'code', label: 'Field Code', placeholder: 'e.g. FLD-001', required: true },
    { type: 'text', name: 'farm_id', label: 'Farm', placeholder: 'Select farm', required: true },
    { type: 'number', name: 'area', label: 'Area', required: true, min: 0, step: 0.01 } as any,
    {
      type: 'select', name: 'area_unit', label: 'Area Unit',
      options: [
        { label: 'Hectares', value: 'hectares' },
        { label: 'Acres', value: 'acres' },
        { label: 'Square Meters', value: 'sq_meters' },
        { label: 'Bigha', value: 'bigha' },
        { label: 'Guntha', value: 'guntha' },
      ],
    } as any,
    {
      type: 'select', name: 'soil_type', label: 'Soil Type',
      options: [
        { label: 'Alluvial', value: 'alluvial' },
        { label: 'Black (Regur)', value: 'black' },
        { label: 'Red', value: 'red' },
        { label: 'Laterite', value: 'laterite' },
        { label: 'Sandy', value: 'sandy' },
        { label: 'Clay', value: 'clay' },
        { label: 'Loam', value: 'loam' },
        { label: 'Silt', value: 'silt' },
      ],
    } as any,
    {
      type: 'select', name: 'irrigation_type', label: 'Irrigation Type',
      options: [
        { label: 'Drip', value: 'drip' },
        { label: 'Sprinkler', value: 'sprinkler' },
        { label: 'Flood', value: 'flood' },
        { label: 'Furrow', value: 'furrow' },
        { label: 'Rain-fed', value: 'rainfed' },
        { label: 'Center Pivot', value: 'center_pivot' },
        { label: 'Subsurface', value: 'subsurface' },
      ],
    } as any,
    { type: 'text', name: 'current_crop_name', label: 'Current Crop', placeholder: 'Current crop planted' },
    {
      type: 'select', name: 'land_use_type', label: 'Land Use Type',
      options: [
        { label: 'Cropland', value: 'cropland' },
        { label: 'Pasture', value: 'pasture' },
        { label: 'Orchard', value: 'orchard' },
        { label: 'Fallow', value: 'fallow' },
        { label: 'Forest', value: 'forest' },
        { label: 'Wasteland', value: 'wasteland' },
      ],
    } as any,
    { type: 'number', name: 'latitude', label: 'Latitude', step: 0.000001, min: -90, max: 90 } as any,
    { type: 'number', name: 'longitude', label: 'Longitude', step: 0.000001, min: -180, max: 180 } as any,
    { type: 'number', name: 'elevation', label: 'Elevation (m)', min: 0 } as any,
    { type: 'number', name: 'slope', label: 'Slope (%)', min: 0, max: 100, step: 0.1 } as any,
    {
      type: 'select', name: 'aspect', label: 'Aspect (Direction)',
      options: [
        { label: 'North', value: 'north' },
        { label: 'South', value: 'south' },
        { label: 'East', value: 'east' },
        { label: 'West', value: 'west' },
        { label: 'Flat', value: 'flat' },
      ],
    } as any,
    {
      type: 'select', name: 'drainage_class', label: 'Drainage Class',
      options: [
        { label: 'Well Drained', value: 'well_drained' },
        { label: 'Moderately Drained', value: 'moderately_drained' },
        { label: 'Poorly Drained', value: 'poorly_drained' },
        { label: 'Excessively Drained', value: 'excessively_drained' },
      ],
    } as any,
    {
      type: 'select', name: 'status', label: 'Status',
      options: [
        { label: 'Active', value: 'active' },
        { label: 'Fallow', value: 'fallow' },
        { label: 'Under Preparation', value: 'preparation' },
        { label: 'Harvested', value: 'harvested' },
        { label: 'Inactive', value: 'inactive' },
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
        title: 'Field Details',
        fields: ['name', 'code', 'farm_id', 'area', 'area_unit', 'current_crop_name', 'land_use_type', 'status'],
        columns: 2,
      },
      {
        id: 'soil_irrigation',
        title: 'Soil & Irrigation',
        fields: ['soil_type', 'irrigation_type', 'drainage_class'],
        columns: 3,
      },
      {
        id: 'geography',
        title: 'Geography',
        fields: ['latitude', 'longitude', 'elevation', 'slope', 'aspect'],
        columns: 2,
      },
    ],
  },
};
