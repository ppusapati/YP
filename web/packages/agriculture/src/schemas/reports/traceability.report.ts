/**
 * @generated from proto — DO NOT EDIT
 * Run: node scripts/generate-schemas.mjs
 */
import type { ReportVisualization } from '@samavāya/core';

export const traceabilityRecordReportSchema: ReportVisualization = {
  layout_mode: "grid",
  widgets: [
    {
      widget_id: "traceabilityrecord-table",
      title: "Traceability Record Records",
      widget_type: "table",
      grid_col: 1,
      grid_row: 1,
      grid_col_span: 24,
      grid_row_span: 8,
      table_config: {
        columns: [
          {
            field_code: "id",
            header: "Id",
            sortable: true
          },
          {
            field_code: "farmId",
            header: "Farm Id",
            sortable: true
          },
          {
            field_code: "fieldId",
            header: "Field Id",
            sortable: true
          },
          {
            field_code: "cropId",
            header: "Crop Id",
            sortable: true
          },
          {
            field_code: "batchNumber",
            header: "Batch Number",
            sortable: true
          },
          {
            field_code: "productType",
            header: "Product Type",
            sortable: true
          },
          {
            field_code: "originCountry",
            header: "Origin Country",
            sortable: true
          },
          {
            field_code: "originRegion",
            header: "Origin Region",
            sortable: true
          },
          {
            field_code: "seedSource",
            header: "Seed Source",
            sortable: true
          },
          {
            field_code: "plantingDate",
            header: "Planting Date",
            sortable: true,
            format: {
              type: "date",
              date_format: "YYYY-MM-DD"
            }
          },
          {
            field_code: "harvestDate",
            header: "Harvest Date",
            sortable: true,
            format: {
              type: "date",
              date_format: "YYYY-MM-DD"
            }
          },
          {
            field_code: "processingDate",
            header: "Processing Date",
            sortable: true,
            format: {
              type: "date",
              date_format: "YYYY-MM-DD"
            }
          },
          {
            field_code: "packagingDate",
            header: "Packaging Date",
            sortable: true,
            format: {
              type: "date",
              date_format: "YYYY-MM-DD"
            }
          },
          {
            field_code: "qrCodeData",
            header: "Qr Code Data",
            sortable: true
          },
          {
            field_code: "blockchainHash",
            header: "Blockchain Hash",
            sortable: true
          },
          {
            field_code: "createdAt",
            header: "Created At",
            sortable: true,
            format: {
              type: "date",
              date_format: "YYYY-MM-DD"
            }
          },
          {
            field_code: "updatedAt",
            header: "Updated At",
            sortable: true,
            format: {
              type: "date",
              date_format: "YYYY-MM-DD"
            }
          }
        ],
        default_sort_field: "id",
        default_sort_direction: "asc",
        paginated: true,
        page_size: 25,
        exportable: true
      }
    }
  ]
};
