/**
 * @generated from proto — DO NOT EDIT
 * Run: node scripts/generate-schemas.mjs
 */
import type { ReportVisualization } from '@samavāya/core';

export const farmReportSchema: ReportVisualization = {
  layout_mode: "grid",
  widgets: [
    {
      widget_id: "kpi-totalAreaHectares",
      title: "Total Area Hectares",
      widget_type: "kpi_card",
      grid_col: 1,
      grid_row: 1,
      grid_col_span: 6,
      grid_row_span: 2,
      kpi_config: {
        value_field_code: "totalAreaHectares",
        aggregate: "sum",
        label: "Total Area Hectares",
        format: {
          type: "number",
          decimal_places: 2
        }
      }
    },
    {
      widget_id: "kpi-elevationMeters",
      title: "Elevation Meters",
      widget_type: "kpi_card",
      grid_col: 7,
      grid_row: 1,
      grid_col_span: 6,
      grid_row_span: 2,
      kpi_config: {
        value_field_code: "elevationMeters",
        aggregate: "sum",
        label: "Elevation Meters",
        format: {
          type: "number",
          decimal_places: 2
        }
      }
    },
    {
      widget_id: "farm-table",
      title: "Farm Records",
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
            field_code: "name",
            header: "Name",
            sortable: true
          },
          {
            field_code: "description",
            header: "Description",
            sortable: true
          },
          {
            field_code: "totalAreaHectares",
            header: "Total Area Hectares",
            sortable: true,
            format: {
              type: "number",
              decimal_places: 2
            }
          },
          {
            field_code: "elevationMeters",
            header: "Elevation Meters",
            sortable: true,
            format: {
              type: "number",
              decimal_places: 2
            }
          },
          {
            field_code: "address",
            header: "Address",
            sortable: true
          },
          {
            field_code: "region",
            header: "Region",
            sortable: true
          },
          {
            field_code: "country",
            header: "Country",
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
