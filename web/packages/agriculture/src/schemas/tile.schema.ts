import type { FormSchema } from '@samavāya/core';
import { farmClient } from '../services';

export const generateTilesetFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'processingJobId', label: 'Processing Job ID', required: true },
    { type: 'autocomplete', name: 'farmId', label: 'Farm', required: true, loadOptions: async (query: string) => {
        const res = await farmClient.listFarms({ search: query, pageSize: 50 });
        return (res.farms || []).map((r: any) => ({ label: r.name || r.id, value: r.id }));
      } },
    { type: 'select', name: 'layer', label: 'Layer', options: [
        { label: 'RGB', value: '1' },
        { label: 'NDVI', value: '2' },
        { label: 'NDWI', value: '3' },
        { label: 'EVI', value: '4' },
        { label: 'STRESS', value: '5' },
        { label: 'FALSE_COLOR', value: '6' },
        { label: 'THERMAL', value: '7' },
      ] },
    { type: 'select', name: 'format', label: 'Format', options: [
        { label: 'PNG', value: '1' },
        { label: 'JPEG', value: '2' },
        { label: 'WEBP', value: '3' },
        { label: 'MVT', value: '4' },
      ] },
    { type: 'number', name: 'minZoom', label: 'Min Zoom', min: 0, max: 22 },
    { type: 'number', name: 'maxZoom', label: 'Max Zoom', min: 0, max: 22 },
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'input',
        title: 'Tileset Configuration',
        fields: ['processingJobId', 'farmId'],
        columns: 2,
      },
      {
        id: 'rendering',
        title: 'Rendering Options',
        fields: ['layer', 'format'],
        columns: 2,
      },
      {
        id: 'zoom',
        title: 'Zoom Range',
        fields: ['minZoom', 'maxZoom'],
        columns: 2,
      },
    ],
  },
};
