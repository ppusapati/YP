/**
 * @generated from proto — DO NOT EDIT
 * Run: node scripts/generate-schemas.mjs
 */
import type { ReportVisualization } from '@samavāya/core';

export const irrigationScheduleReportSchema: ReportVisualization = {
  layout_mode: "grid",
  widgets: [
    {
      widget_id: "kpi-durationMinutes",
      title: "Duration Minutes",
      widget_type: "kpi_card",
      grid_col: 1,
      grid_row: 1,
      grid_col_span: 6,
      grid_row_span: 2,
      kpi_config: {
        value_field_code: "durationMinutes",
        aggregate: "sum",
        label: "Duration Minutes",
        format: {
          type: "number",
          decimal_places: 0
        }
      }
    },
    {
      widget_id: "kpi-waterQuantityLiters",
      title: "Water Quantity Liters",
      widget_type: "kpi_card",
      grid_col: 7,
      grid_row: 1,
      grid_col_span: 6,
      grid_row_span: 2,
      kpi_config: {
        value_field_code: "waterQuantityLiters",
        aggregate: "sum",
        label: "Water Quantity Liters",
        format: {
          type: "number",
          decimal_places: 2
        }
      }
    },
    {
      widget_id: "kpi-flowRateLitersPerHour",
      title: "Flow Rate Liters Per Hour",
      widget_type: "kpi_card",
      grid_col: 13,
      grid_row: 1,
      grid_col_span: 6,
      grid_row_span: 2,
      kpi_config: {
        value_field_code: "flowRateLitersPerHour",
        aggregate: "sum",
        label: "Flow Rate Liters Per Hour",
        format: {
          type: "number",
          decimal_places: 2
        }
      }
    },
    {
      widget_id: "kpi-soilMoistureThresholdPct",
      title: "Soil Moisture Threshold Pct",
      widget_type: "kpi_card",
      grid_col: 19,
      grid_row: 1,
      grid_col_span: 6,
      grid_row_span: 2,
      kpi_config: {
        value_field_code: "soilMoistureThresholdPct",
        aggregate: "avg",
        label: "Soil Moisture Threshold Pct",
        format: {
          type: "percent",
          decimal_places: 1
        }
      }
    },
    {
      widget_id: "irrigationschedule-table",
      title: "Irrigation Schedule Records",
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
            field_code: "zoneId",
            header: "Zone Id",
            sortable: true
          },
          {
            field_code: "startTime",
            header: "Start Time",
            sortable: true,
            format: {
              type: "date",
              date_format: "YYYY-MM-DD"
            }
          },
          {
            field_code: "endTime",
            header: "End Time",
            sortable: true,
            format: {
              type: "date",
              date_format: "YYYY-MM-DD"
            }
          },
          {
            field_code: "durationMinutes",
            header: "Duration Minutes",
            sortable: true,
            format: {
              type: "number",
              decimal_places: 0
            }
          },
          {
            field_code: "waterQuantityLiters",
            header: "Water Quantity Liters",
            sortable: true,
            format: {
              type: "number",
              decimal_places: 2
            }
          },
          {
            field_code: "flowRateLitersPerHour",
            header: "Flow Rate Liters Per Hour",
            sortable: true,
            format: {
              type: "number",
              decimal_places: 2
            }
          },
          {
            field_code: "soilMoistureThresholdPct",
            header: "Soil Moisture Threshold Pct",
            sortable: true,
            format: {
              type: "percent",
              decimal_places: 1
            }
          },
          {
            field_code: "weatherAdjusted",
            header: "Weather Adjusted",
            sortable: true
          },
          {
            field_code: "cropGrowthStage",
            header: "Crop Growth Stage",
            sortable: true
          },
          {
            field_code: "controllerId",
            header: "Controller Id",
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
