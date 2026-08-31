/**
 * @generated from proto — DO NOT EDIT
 * Run: node scripts/generate-schemas.mjs
 */
import type { ReportVisualization } from '@samavāya/core';

export const satelliteImageReportSchema: ReportVisualization = {
  layout_mode: "grid",
  widgets: [
    {
      widget_id: "kpi-cloudCoverPct",
      title: "Cloud Cover Pct",
      widget_type: "kpi_card",
      grid_col: 1,
      grid_row: 1,
      grid_col_span: 6,
      grid_row_span: 2,
      kpi_config: {
        value_field_code: "cloudCoverPct",
        aggregate: "avg",
        label: "Cloud Cover Pct",
        format: {
          type: "percent",
          decimal_places: 1
        }
      }
    },
    {
      widget_id: "kpi-resolutionMeters",
      title: "Resolution Meters",
      widget_type: "kpi_card",
      grid_col: 7,
      grid_row: 1,
      grid_col_span: 6,
      grid_row_span: 2,
      kpi_config: {
        value_field_code: "resolutionMeters",
        aggregate: "sum",
        label: "Resolution Meters",
        format: {
          type: "number",
          decimal_places: 2
        }
      }
    },
    {
      widget_id: "satelliteimage-table",
      title: "Satellite Image Records",
      widget_type: "table",
      grid_col: 1,
      grid_row: 3,
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
            field_code: "fieldId",
            header: "Field Id",
            sortable: true
          },
          {
            field_code: "farmId",
            header: "Farm Id",
            sortable: true
          },
          {
            field_code: "acquisitionDate",
            header: "Acquisition Date",
            sortable: true,
            format: {
              type: "date",
              date_format: "YYYY-MM-DD"
            }
          },
          {
            field_code: "cloudCoverPct",
            header: "Cloud Cover Pct",
            sortable: true,
            format: {
              type: "percent",
              decimal_places: 1
            }
          },
          {
            field_code: "resolutionMeters",
            header: "Resolution Meters",
            sortable: true,
            format: {
              type: "number",
              decimal_places: 2
            }
          },
          {
            field_code: "imageUrl",
            header: "Image Url",
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
