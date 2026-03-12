/**
 * Traceability Form Schemas
 */
import type { FormSchema } from '@samavāya/core';

export const traceabilityRecordFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'batch_id', label: 'Batch ID', required: true },
    { type: 'text', name: 'product_name', label: 'Product Name', required: true },
    { type: 'text', name: 'product_code', label: 'Product Code', required: true },
    { type: 'text', name: 'origin_farm_name', label: 'Origin Farm', required: true },
    { type: 'text', name: 'origin_field_id', label: 'Origin Field' },
    { type: 'date', name: 'harvest_date', label: 'Harvest Date' } as any,
    { type: 'date', name: 'processing_date', label: 'Processing Date' } as any,
    { type: 'date', name: 'expiry_date', label: 'Expiry Date' } as any,
    { type: 'number', name: 'quantity', label: 'Quantity', min: 0, step: 0.01 } as any,
    {
      type: 'select', name: 'unit', label: 'Unit',
      options: [
        { label: 'Kilograms', value: 'kg' },
        { label: 'Tonnes', value: 'tonnes' },
        { label: 'Litres', value: 'litres' },
        { label: 'Units', value: 'units' },
        { label: 'Boxes', value: 'boxes' },
        { label: 'Crates', value: 'crates' },
      ],
    } as any,
    {
      type: 'select', name: 'quality_grade', label: 'Quality Grade',
      options: [
        { label: 'Premium (A)', value: 'A' },
        { label: 'Standard (B)', value: 'B' },
        { label: 'Below Standard (C)', value: 'C' },
      ],
    } as any,
    { type: 'text', name: 'current_location', label: 'Current Location' },
    { type: 'text', name: 'current_holder', label: 'Current Holder' },
    { type: 'url', name: 'qr_code_url', label: 'QR Code URL' },
    { type: 'text', name: 'blockchain_hash', label: 'Blockchain Hash' },
    {
      type: 'select', name: 'status', label: 'Status',
      options: [
        { label: 'Created', value: 'created' },
        { label: 'In Transit', value: 'in_transit' },
        { label: 'At Warehouse', value: 'at_warehouse' },
        { label: 'Processing', value: 'processing' },
        { label: 'Distributed', value: 'distributed' },
        { label: 'Sold', value: 'sold' },
        { label: 'Recalled', value: 'recalled' },
      ],
    } as any,
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'product',
        title: 'Product Information',
        fields: ['batch_id', 'product_name', 'product_code', 'quality_grade', 'status'],
        columns: 2,
      },
      {
        id: 'origin',
        title: 'Origin',
        fields: ['origin_farm_name', 'origin_field_id', 'harvest_date', 'processing_date', 'expiry_date'],
        columns: 2,
      },
      {
        id: 'quantity_info',
        title: 'Quantity',
        fields: ['quantity', 'unit'],
        columns: 2,
      },
      {
        id: 'tracking',
        title: 'Tracking',
        fields: ['current_location', 'current_holder', 'qr_code_url', 'blockchain_hash'],
        columns: 2,
      },
    ],
  },
};

export const certificationFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'name', label: 'Certification Name', required: true },
    { type: 'text', name: 'code', label: 'Code', required: true },
    { type: 'text', name: 'certifying_body', label: 'Certifying Body', required: true },
    {
      type: 'select', name: 'certification_type', label: 'Type', required: true,
      options: [
        { label: 'Organic', value: 'organic' },
        { label: 'Fair Trade', value: 'fair_trade' },
        { label: 'GlobalGAP', value: 'globalgap' },
        { label: 'Rainforest Alliance', value: 'rainforest_alliance' },
        { label: 'ISO 22000', value: 'iso_22000' },
        { label: 'HACCP', value: 'haccp' },
        { label: 'GI Tag', value: 'gi_tag' },
        { label: 'FSSAI', value: 'fssai' },
        { label: 'APEDA', value: 'apeda' },
      ],
    } as any,
    { type: 'textarea', name: 'scope', label: 'Scope', rows: 2 } as any,
    { type: 'date', name: 'issue_date', label: 'Issue Date', required: true } as any,
    { type: 'date', name: 'expiry_date', label: 'Expiry Date', required: true } as any,
    { type: 'text', name: 'certificate_number', label: 'Certificate Number' },
    { type: 'url', name: 'certificate_url', label: 'Certificate URL' },
    {
      type: 'select', name: 'status', label: 'Status',
      options: [
        { label: 'Active', value: 'active' },
        { label: 'Expired', value: 'expired' },
        { label: 'Suspended', value: 'suspended' },
        { label: 'Revoked', value: 'revoked' },
        { label: 'Pending Renewal', value: 'pending_renewal' },
      ],
    } as any,
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'cert',
        title: 'Certification Details',
        fields: ['name', 'code', 'certifying_body', 'certification_type', 'scope', 'status'],
        columns: 2,
      },
      {
        id: 'validity',
        title: 'Validity',
        fields: ['issue_date', 'expiry_date', 'certificate_number', 'certificate_url'],
        columns: 2,
      },
    ],
  },
};

export const batchRecordFormSchema: FormSchema<Record<string, unknown>> = {
  fields: [
    { type: 'text', name: 'batch_number', label: 'Batch Number', required: true },
    { type: 'text', name: 'product_name', label: 'Product Name', required: true },
    { type: 'text', name: 'product_code', label: 'Product Code', required: true },
    { type: 'number', name: 'quantity', label: 'Quantity', min: 0, step: 0.01 } as any,
    {
      type: 'select', name: 'unit', label: 'Unit',
      options: [
        { label: 'Kilograms', value: 'kg' },
        { label: 'Tonnes', value: 'tonnes' },
        { label: 'Litres', value: 'litres' },
        { label: 'Units', value: 'units' },
      ],
    } as any,
    { type: 'date', name: 'production_date', label: 'Production Date', required: true } as any,
    { type: 'date', name: 'expiry_date', label: 'Expiry Date' } as any,
    { type: 'text', name: 'source_farm_id', label: 'Source Farm' },
    { type: 'text', name: 'source_field_id', label: 'Source Field' },
    { type: 'text', name: 'processing_facility', label: 'Processing Facility' },
    {
      type: 'select', name: 'quality_check_status', label: 'Quality Check',
      options: [
        { label: 'Pending', value: 'pending' },
        { label: 'Passed', value: 'passed' },
        { label: 'Failed', value: 'failed' },
        { label: 'Conditional', value: 'conditional' },
      ],
    } as any,
    { type: 'number', name: 'quality_score', label: 'Quality Score', min: 0, max: 100, step: 0.1 } as any,
    { type: 'textarea', name: 'storage_conditions', label: 'Storage Conditions', rows: 2 } as any,
    { type: 'textarea', name: 'notes', label: 'Notes', rows: 2 } as any,
    {
      type: 'select', name: 'status', label: 'Status',
      options: [
        { label: 'Active', value: 'active' },
        { label: 'Consumed', value: 'consumed' },
        { label: 'Expired', value: 'expired' },
        { label: 'Recalled', value: 'recalled' },
      ],
    } as any,
  ],
  layout: {
    type: 'grid',
    columns: 2,
    gap: 'md',
    sections: [
      {
        id: 'batch',
        title: 'Batch Details',
        fields: ['batch_number', 'product_name', 'product_code', 'quantity', 'unit', 'status'],
        columns: 2,
      },
      {
        id: 'dates',
        title: 'Dates',
        fields: ['production_date', 'expiry_date'],
        columns: 2,
      },
      {
        id: 'source',
        title: 'Source',
        fields: ['source_farm_id', 'source_field_id', 'processing_facility'],
        columns: 3,
      },
      {
        id: 'quality',
        title: 'Quality',
        fields: ['quality_check_status', 'quality_score', 'storage_conditions', 'notes'],
        columns: 2,
      },
    ],
  },
};
