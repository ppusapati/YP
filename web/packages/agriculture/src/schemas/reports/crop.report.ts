/**
 * @generated from proto — DO NOT EDIT
 * Run: node scripts/generate-schemas.mjs
 */
import type { ReportVisualization } from '@samavāya/core';

export const cropReportSchema: ReportVisualization = {
  layout_mode: "grid",
  widgets: [
    {
      widget_id: "crop-table",
      title: "Crop Records",
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
            field_code: "name",
            header: "Name",
            sortable: true
          },
          {
            field_code: "scientificName",
            header: "Scientific Name",
            sortable: true
          },
          {
            field_code: "family",
            header: "Family",
            sortable: true
          },
          {
            field_code: "description",
            header: "Description",
            sortable: true
          },
          {
            field_code: "imageUrl",
            header: "Image Url",
            sortable: true
          },
          {
            field_code: "rotationGroup",
            header: "Rotation Group",
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
