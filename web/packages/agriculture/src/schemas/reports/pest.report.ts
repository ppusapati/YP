/**
 * @generated from proto — DO NOT EDIT
 * Run: node scripts/generate-schemas.mjs
 */
import type { ReportVisualization } from '@samavāya/core';

export const pestPredictionReportSchema: ReportVisualization = {
  layout_mode: "grid",
  widgets: [
    {
      widget_id: "kpi-riskScore",
      title: "Risk Score",
      widget_type: "kpi_card",
      grid_col: 1,
      grid_row: 1,
      grid_col_span: 6,
      grid_row_span: 2,
      kpi_config: {
        value_field_code: "riskScore",
        aggregate: "sum",
        label: "Risk Score",
        format: {
          type: "number",
          decimal_places: 0
        }
      }
    },
    {
      widget_id: "kpi-confidencePct",
      title: "Confidence Pct",
      widget_type: "kpi_card",
      grid_col: 7,
      grid_row: 1,
      grid_col_span: 6,
      grid_row_span: 2,
      kpi_config: {
        value_field_code: "confidencePct",
        aggregate: "avg",
        label: "Confidence Pct",
        format: {
          type: "percent",
          decimal_places: 1
        }
      }
    },
    {
      widget_id: "kpi-geographicRiskFactor",
      title: "Geographic Risk Factor",
      widget_type: "kpi_card",
      grid_col: 13,
      grid_row: 1,
      grid_col_span: 6,
      grid_row_span: 2,
      kpi_config: {
        value_field_code: "geographicRiskFactor",
        aggregate: "sum",
        label: "Geographic Risk Factor",
        format: {
          type: "number",
          decimal_places: 2
        }
      }
    },
    {
      widget_id: "kpi-historicalOccurrenceCount",
      title: "Historical Occurrence Count",
      widget_type: "kpi_card",
      grid_col: 19,
      grid_row: 1,
      grid_col_span: 6,
      grid_row_span: 2,
      kpi_config: {
        value_field_code: "historicalOccurrenceCount",
        aggregate: "sum",
        label: "Historical Occurrence Count",
        format: {
          type: "number",
          decimal_places: 0
        }
      }
    },
    {
      widget_id: "pestprediction-table",
      title: "Pest Prediction Records",
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
            field_code: "pestSpeciesId",
            header: "Pest Species Id",
            sortable: true
          },
          {
            field_code: "predictionDate",
            header: "Prediction Date",
            sortable: true,
            format: {
              type: "date",
              date_format: "YYYY-MM-DD"
            }
          },
          {
            field_code: "riskScore",
            header: "Risk Score",
            sortable: true,
            format: {
              type: "number",
              decimal_places: 0
            }
          },
          {
            field_code: "confidencePct",
            header: "Confidence Pct",
            sortable: true,
            format: {
              type: "percent",
              decimal_places: 1
            }
          },
          {
            field_code: "cropType",
            header: "Crop Type",
            sortable: true
          },
          {
            field_code: "geographicRiskFactor",
            header: "Geographic Risk Factor",
            sortable: true,
            format: {
              type: "number",
              decimal_places: 2
            }
          },
          {
            field_code: "historicalOccurrenceCount",
            header: "Historical Occurrence Count",
            sortable: true,
            format: {
              type: "number",
              decimal_places: 0
            }
          },
          {
            field_code: "predictedOnsetDate",
            header: "Predicted Onset Date",
            sortable: true,
            format: {
              type: "date",
              date_format: "YYYY-MM-DD"
            }
          },
          {
            field_code: "predictedPeakDate",
            header: "Predicted Peak Date",
            sortable: true,
            format: {
              type: "date",
              date_format: "YYYY-MM-DD"
            }
          },
          {
            field_code: "treatmentWindowStart",
            header: "Treatment Window Start",
            sortable: true,
            format: {
              type: "date",
              date_format: "YYYY-MM-DD"
            }
          },
          {
            field_code: "treatmentWindowEnd",
            header: "Treatment Window End",
            sortable: true,
            format: {
              type: "date",
              date_format: "YYYY-MM-DD"
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
