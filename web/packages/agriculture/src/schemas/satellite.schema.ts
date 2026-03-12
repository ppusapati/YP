/**
 * Satellite Imagery Form Schema
 */
import type { FormSchema } from '@samavāya/core';

export const satelliteImageFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'field_id', label: 'Field', required: true },
    { type: 'date', name: 'capture_date', label: 'Capture Date', required: true } as any,
    { type: 'text', name: 'satellite_name', label: 'Satellite', placeholder: 'e.g. Sentinel-2, Landsat-8' },
    {
      type: 'select', name: 'image_type', label: 'Image Type', required: true,
      options: [
        { label: 'RGB (True Color)', value: 'rgb' },
        { label: 'NIR (Near Infrared)', value: 'nir' },
        { label: 'NDVI', value: 'ndvi' },
        { label: 'NDWI', value: 'ndwi' },
        { label: 'EVI', value: 'evi' },
        { label: 'Thermal', value: 'thermal' },
        { label: 'SAR', value: 'sar' },
        { label: 'Multispectral', value: 'multispectral' },
      ],
    } as any,
    { type: 'number', name: 'resolution_meters', label: 'Resolution (m)', min: 0.1, step: 0.1 } as any,
    { type: 'number', name: 'cloud_cover_pct', label: 'Cloud Cover (%)', min: 0, max: 100, step: 0.1 } as any,
    { type: 'url', name: 'image_url', label: 'Image URL' },
    { type: 'url', name: 'thumbnail_url', label: 'Thumbnail URL' },
    { type: 'number', name: 'bbox_north', label: 'North Bound', step: 0.000001 } as any,
    { type: 'number', name: 'bbox_south', label: 'South Bound', step: 0.000001 } as any,
    { type: 'number', name: 'bbox_east', label: 'East Bound', step: 0.000001 } as any,
    { type: 'number', name: 'bbox_west', label: 'West Bound', step: 0.000001 } as any,
    { type: 'number', name: 'ndvi_mean', label: 'NDVI Mean', min: -1, max: 1, step: 0.001 } as any,
    { type: 'number', name: 'ndwi_mean', label: 'NDWI Mean', min: -1, max: 1, step: 0.001 } as any,
    { type: 'number', name: 'evi_mean', label: 'EVI Mean', min: -1, max: 1, step: 0.001 } as any,
    {
      type: 'select', name: 'status', label: 'Status',
      options: [
        { label: 'Processing', value: 'processing' },
        { label: 'Available', value: 'available' },
        { label: 'Failed', value: 'failed' },
        { label: 'Archived', value: 'archived' },
      ],
    } as any,
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'capture',
        title: 'Capture Details',
        fields: ['field_id', 'capture_date', 'satellite_name', 'image_type', 'resolution_meters', 'cloud_cover_pct', 'status'],
        columns: 2,
      },
      {
        id: 'urls',
        title: 'Image URLs',
        fields: ['image_url', 'thumbnail_url'],
        columns: 1,
      },
      {
        id: 'bounds',
        title: 'Bounding Box',
        fields: ['bbox_north', 'bbox_south', 'bbox_east', 'bbox_west'],
        columns: 4,
      },
      {
        id: 'indices',
        title: 'Vegetation Indices',
        fields: ['ndvi_mean', 'ndwi_mean', 'evi_mean'],
        columns: 3,
      },
    ],
  },
};
