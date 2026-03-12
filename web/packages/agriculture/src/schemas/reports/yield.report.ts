/**
 * @generated from proto — DO NOT EDIT
 * Run: node scripts/generate-schemas.mjs
 */
import type { ReportVisualization } from '@samavāya/core';

export const yieldPredictionReportSchema: ReportVisualization = {
  layout_mode: "grid",
  widgets: [
    {
      widget_id: "kpi-year",
      title: "Year",
      widget_type: "kpi_card",
      grid_col: 1,
      grid_row: 1,
      grid_col_span: 6,
      grid_row_span: 2,
      kpi_config: {
        value_field_code: "year",
        aggregate: "sum",
        label: "Year",
        format: {
          type: "number",
          decimal_places: 0
        }
      }
    },
    {
      widget_id: "kpi-predictedYieldKgPerHectare",
      title: "Predicted Yield Kg Per Hectare",
      widget_type: "kpi_card",
      grid_col: 7,
      grid_row: 1,
      grid_col_span: 6,
      grid_row_span: 2,
      kpi_config: {
        value_field_code: "predictedYieldKgPerHectare",
        aggregate: "sum",
        label: "Predicted Yield Kg Per Hectare",
        format: {
          type: "number",
          decimal_places: 2
        }
      }
    },
    {
      widget_id: "kpi-predictionConfidencePct",
      title: "Prediction Confidence Pct",
      widget_type: "kpi_card",
      grid_col: 13,
      grid_row: 1,
      grid_col_span: 6,
      grid_row_span: 2,
      kpi_config: {
        value_field_code: "predictionConfidencePct",
        aggregate: "avg",
        label: "Prediction Confidence Pct",
        format: {
          type: "percent",
          decimal_places: 1
        }
      }
    },
    {
      widget_id: "yieldprediction-table",
      title: "Yield Prediction Records",
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
            field_code: "season",
            header: "Season",
            sortable: true
          },
          {
            field_code: "year",
            header: "Year",
            sortable: true,
            format: {
              type: "number",
              decimal_places: 0
            }
          },
          {
            field_code: "predictedYieldKgPerHectare",
            header: "Predicted Yield Kg Per Hectare",
            sortable: true,
            format: {
              type: "number",
              decimal_places: 2
            }
          },
          {
            field_code: "predictionConfidencePct",
            header: "Prediction Confidence Pct",
            sortable: true,
            format: {
              type: "percent",
              decimal_places: 1
            }
          },
          {
            field_code: "predictionModelVersion",
            header: "Prediction Model Version",
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
