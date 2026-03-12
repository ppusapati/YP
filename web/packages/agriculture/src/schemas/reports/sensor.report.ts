/**
 * @generated from proto — DO NOT EDIT
 * Run: node scripts/generate-schemas.mjs
 */
import type { ReportVisualization } from '@samavāya/core';

export const sensorReportSchema: ReportVisualization = {
  layout_mode: "grid",
  widgets: [
    {
      widget_id: "kpi-batteryLevelPct",
      title: "Battery Level Pct",
      widget_type: "kpi_card",
      grid_col: 1,
      grid_row: 1,
      grid_col_span: 6,
      grid_row_span: 2,
      kpi_config: {
        value_field_code: "batteryLevelPct",
        aggregate: "avg",
        label: "Battery Level Pct",
        format: {
          type: "percent",
          decimal_places: 1
        }
      }
    },
    {
      widget_id: "kpi-signalStrengthDbm",
      title: "Signal Strength Dbm",
      widget_type: "kpi_card",
      grid_col: 7,
      grid_row: 1,
      grid_col_span: 6,
      grid_row_span: 2,
      kpi_config: {
        value_field_code: "signalStrengthDbm",
        aggregate: "sum",
        label: "Signal Strength Dbm",
        format: {
          type: "number",
          decimal_places: 2
        }
      }
    },
    {
      widget_id: "kpi-readingIntervalSeconds",
      title: "Reading Interval Seconds",
      widget_type: "kpi_card",
      grid_col: 13,
      grid_row: 1,
      grid_col_span: 6,
      grid_row_span: 2,
      kpi_config: {
        value_field_code: "readingIntervalSeconds",
        aggregate: "sum",
        label: "Reading Interval Seconds",
        format: {
          type: "number",
          decimal_places: 0
        }
      }
    },
    {
      widget_id: "sensor-table",
      title: "Sensor Records",
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
            field_code: "deviceId",
            header: "Device Id",
            sortable: true
          },
          {
            field_code: "manufacturer",
            header: "Manufacturer",
            sortable: true
          },
          {
            field_code: "model",
            header: "Model",
            sortable: true
          },
          {
            field_code: "firmwareVersion",
            header: "Firmware Version",
            sortable: true
          },
          {
            field_code: "installationDate",
            header: "Installation Date",
            sortable: true,
            format: {
              type: "date",
              date_format: "YYYY-MM-DD"
            }
          },
          {
            field_code: "lastReadingAt",
            header: "Last Reading At",
            sortable: true,
            format: {
              type: "date",
              date_format: "YYYY-MM-DD"
            }
          },
          {
            field_code: "batteryLevelPct",
            header: "Battery Level Pct",
            sortable: true,
            format: {
              type: "percent",
              decimal_places: 1
            }
          },
          {
            field_code: "signalStrengthDbm",
            header: "Signal Strength Dbm",
            sortable: true,
            format: {
              type: "number",
              decimal_places: 2
            }
          },
          {
            field_code: "readingIntervalSeconds",
            header: "Reading Interval Seconds",
            sortable: true,
            format: {
              type: "number",
              decimal_places: 0
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
