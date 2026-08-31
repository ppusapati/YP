/**
 * @generated from proto — DO NOT EDIT
 * Run: node scripts/generate-schemas.mjs
 */
import type { ReportVisualization } from '@samavāya/core';

export const fieldReportSchema: ReportVisualization = {
  layout_mode: "grid",
  widgets: [
    {
      widget_id: "kpi-areaHectares",
      title: "Area Hectares",
      widget_type: "kpi_card",
      grid_col: 1,
      grid_row: 1,
      grid_col_span: 6,
      grid_row_span: 2,
      kpi_config: {
        value_field_code: "areaHectares",
        aggregate: "sum",
        label: "Area Hectares",
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
      widget_id: "kpi-slopeDegrees",
      title: "Slope Degrees",
      widget_type: "kpi_card",
      grid_col: 13,
      grid_row: 1,
      grid_col_span: 6,
      grid_row_span: 2,
      kpi_config: {
        value_field_code: "slopeDegrees",
        aggregate: "sum",
        label: "Slope Degrees",
        format: {
          type: "number",
          decimal_places: 2
        }
      }
    },
    {
      widget_id: "field-table",
      title: "Field Records",
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
            field_code: "farmId",
            header: "Farm Id",
            sortable: true
          },
          {
            field_code: "name",
            header: "Name",
            sortable: true
          },
          {
            field_code: "areaHectares",
            header: "Area Hectares",
            sortable: true,
            format: {
              type: "number",
              decimal_places: 2
            }
          },
          {
            field_code: "currentCropId",
            header: "Current Crop Id",
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
            field_code: "expectedHarvestDate",
            header: "Expected Harvest Date",
            sortable: true,
            format: {
              type: "date",
              date_format: "YYYY-MM-DD"
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
            field_code: "slopeDegrees",
            header: "Slope Degrees",
            sortable: true,
            format: {
              type: "number",
              decimal_places: 2
            }
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
