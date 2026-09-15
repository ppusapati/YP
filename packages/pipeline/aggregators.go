package pipeline

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

// --------------------------------------------------------------------------
// DailyYieldSummary
// --------------------------------------------------------------------------

// DailyYieldSummary aggregates per-field yield data into daily summaries.
type DailyYieldSummary struct {
	Pool     *pgxpool.Pool
	TenantID string
}

func (d *DailyYieldSummary) Name() string     { return "daily_yield_summary" }
func (d *DailyYieldSummary) Schedule() string { return "24h" }

func (d *DailyYieldSummary) Extract(ctx context.Context) ([]RawRecord, error) {
	yesterday := time.Now().AddDate(0, 0, -1).Truncate(24 * time.Hour)
	rows, err := d.Pool.Query(ctx, `
		SELECT field_id, crop, yield_value, area
		FROM yield_readings
		WHERE tenant_id = $1
		  AND reading_time >= $2
		  AND reading_time < $3`,
		d.TenantID, yesterday, yesterday.AddDate(0, 0, 1))
	if err != nil {
		return nil, fmt.Errorf("daily_yield_summary extract: %w", err)
	}
	defer rows.Close()

	var records []RawRecord
	for rows.Next() {
		var fieldID, crop string
		var yieldVal, area float64
		if err := rows.Scan(&fieldID, &crop, &yieldVal, &area); err != nil {
			return nil, fmt.Errorf("daily_yield_summary scan: %w", err)
		}
		records = append(records, RawRecord{
			TenantID:  d.TenantID,
			FieldID:   fieldID,
			Timestamp: yesterday,
			Data: map[string]interface{}{
				"crop":  crop,
				"yield": yieldVal,
				"area":  area,
			},
		})
	}
	return records, rows.Err()
}

func (d *DailyYieldSummary) Transform(ctx context.Context, records []RawRecord) ([]TransformedRecord, error) {
	type key struct {
		FieldID string
		Crop    string
	}
	type accum struct {
		MinYield float64
		MaxYield float64
		SumYield float64
		SumArea  float64
		Count    int
	}

	grouped := make(map[key]*accum)
	var date time.Time

	for _, r := range records {
		date = r.Timestamp
		k := key{FieldID: r.FieldID, Crop: r.Data["crop"].(string)}
		yieldVal := r.Data["yield"].(float64)
		area := r.Data["area"].(float64)

		a, ok := grouped[k]
		if !ok {
			a = &accum{MinYield: yieldVal, MaxYield: yieldVal}
			grouped[k] = a
		}
		if yieldVal < a.MinYield {
			a.MinYield = yieldVal
		}
		if yieldVal > a.MaxYield {
			a.MaxYield = yieldVal
		}
		a.SumYield += yieldVal
		a.SumArea += area
		a.Count++
	}

	var results []TransformedRecord
	for k, a := range grouped {
		avgYield := 0.0
		if a.Count > 0 {
			avgYield = a.SumYield / float64(a.Count)
		}
		results = append(results, TransformedRecord{
			TenantID:  d.TenantID,
			FieldID:   k.FieldID,
			Timestamp: date,
			Table:     "daily_yield_summaries",
			Values: map[string]interface{}{
				"crop":       k.Crop,
				"min_yield":  a.MinYield,
				"avg_yield":  avgYield,
				"max_yield":  a.MaxYield,
				"total_area": a.SumArea,
			},
		})
	}
	return results, nil
}

func (d *DailyYieldSummary) Load(ctx context.Context, records []TransformedRecord) error {
	for _, r := range records {
		_, err := d.Pool.Exec(ctx, `
			INSERT INTO daily_yield_summaries
				(tenant_id, field_id, date, crop, min_yield, avg_yield, max_yield, total_area)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
			ON CONFLICT (tenant_id, field_id, date, crop)
			DO UPDATE SET
				min_yield  = EXCLUDED.min_yield,
				avg_yield  = EXCLUDED.avg_yield,
				max_yield  = EXCLUDED.max_yield,
				total_area = EXCLUDED.total_area,
				updated_at = NOW()`,
			r.TenantID, r.FieldID, r.Timestamp,
			r.Values["crop"], r.Values["min_yield"], r.Values["avg_yield"],
			r.Values["max_yield"], r.Values["total_area"])
		if err != nil {
			return fmt.Errorf("daily_yield_summary load: %w", err)
		}
	}
	return nil
}

// --------------------------------------------------------------------------
// WeeklySoilTrends
// --------------------------------------------------------------------------

// WeeklySoilTrends computes weekly averages for soil metrics.
type WeeklySoilTrends struct {
	Pool     *pgxpool.Pool
	TenantID string
}

func (w *WeeklySoilTrends) Name() string     { return "weekly_soil_trends" }
func (w *WeeklySoilTrends) Schedule() string { return "168h" } // 7 days

func (w *WeeklySoilTrends) Extract(ctx context.Context) ([]RawRecord, error) {
	weekStart := time.Now().AddDate(0, 0, -7).Truncate(24 * time.Hour)
	rows, err := w.Pool.Query(ctx, `
		SELECT field_id, moisture, ph, nitrogen, phosphorus, potassium
		FROM soil_readings
		WHERE tenant_id = $1
		  AND reading_time >= $2
		  AND reading_time < $3`,
		w.TenantID, weekStart, weekStart.AddDate(0, 0, 7))
	if err != nil {
		return nil, fmt.Errorf("weekly_soil_trends extract: %w", err)
	}
	defer rows.Close()

	var records []RawRecord
	for rows.Next() {
		var fieldID string
		var moisture, ph, nitrogen, phosphorus, potassium float64
		if err := rows.Scan(&fieldID, &moisture, &ph, &nitrogen, &phosphorus, &potassium); err != nil {
			return nil, fmt.Errorf("weekly_soil_trends scan: %w", err)
		}
		records = append(records, RawRecord{
			TenantID:  w.TenantID,
			FieldID:   fieldID,
			Timestamp: weekStart,
			Data: map[string]interface{}{
				"moisture":   moisture,
				"ph":         ph,
				"nitrogen":   nitrogen,
				"phosphorus": phosphorus,
				"potassium":  potassium,
			},
		})
	}
	return records, rows.Err()
}

func (w *WeeklySoilTrends) Transform(ctx context.Context, records []RawRecord) ([]TransformedRecord, error) {
	type accum struct {
		Moisture   float64
		PH         float64
		Nitrogen   float64
		Phosphorus float64
		Potassium  float64
		Count      int
	}

	grouped := make(map[string]*accum)
	var weekStart time.Time

	for _, r := range records {
		weekStart = r.Timestamp
		a, ok := grouped[r.FieldID]
		if !ok {
			a = &accum{}
			grouped[r.FieldID] = a
		}
		a.Moisture += r.Data["moisture"].(float64)
		a.PH += r.Data["ph"].(float64)
		a.Nitrogen += r.Data["nitrogen"].(float64)
		a.Phosphorus += r.Data["phosphorus"].(float64)
		a.Potassium += r.Data["potassium"].(float64)
		a.Count++
	}

	var results []TransformedRecord
	for fieldID, a := range grouped {
		n := float64(a.Count)
		results = append(results, TransformedRecord{
			TenantID:  w.TenantID,
			FieldID:   fieldID,
			Timestamp: weekStart,
			Table:     "weekly_soil_trends",
			Values: map[string]interface{}{
				"avg_moisture":   a.Moisture / n,
				"avg_ph":         a.PH / n,
				"avg_nitrogen":   a.Nitrogen / n,
				"avg_phosphorus": a.Phosphorus / n,
				"avg_potassium":  a.Potassium / n,
			},
		})
	}
	return results, nil
}

func (w *WeeklySoilTrends) Load(ctx context.Context, records []TransformedRecord) error {
	for _, r := range records {
		_, err := w.Pool.Exec(ctx, `
			INSERT INTO weekly_soil_trends
				(tenant_id, field_id, week_start, avg_moisture, avg_ph, avg_nitrogen, avg_phosphorus, avg_potassium)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
			ON CONFLICT (tenant_id, field_id, week_start)
			DO UPDATE SET
				avg_moisture   = EXCLUDED.avg_moisture,
				avg_ph         = EXCLUDED.avg_ph,
				avg_nitrogen   = EXCLUDED.avg_nitrogen,
				avg_phosphorus = EXCLUDED.avg_phosphorus,
				avg_potassium  = EXCLUDED.avg_potassium,
				updated_at     = NOW()`,
			r.TenantID, r.FieldID, r.Timestamp,
			r.Values["avg_moisture"], r.Values["avg_ph"], r.Values["avg_nitrogen"],
			r.Values["avg_phosphorus"], r.Values["avg_potassium"])
		if err != nil {
			return fmt.Errorf("weekly_soil_trends load: %w", err)
		}
	}
	return nil
}

// --------------------------------------------------------------------------
// SeasonalCropPerformance
// --------------------------------------------------------------------------

// SeasonalCropPerformance computes seasonal yield vs. input cost analysis.
type SeasonalCropPerformance struct {
	Pool     *pgxpool.Pool
	TenantID string
	Season   string // e.g. "2024-kharif", "2024-rabi"
}

func (s *SeasonalCropPerformance) Name() string     { return "seasonal_crop_performance" }
func (s *SeasonalCropPerformance) Schedule() string { return "720h" } // ~30 days

func (s *SeasonalCropPerformance) Extract(ctx context.Context) ([]RawRecord, error) {
	rows, err := s.Pool.Query(ctx, `
		SELECT field_id, crop, total_yield, total_input_cost, area_hectares
		FROM crop_seasons
		WHERE tenant_id = $1
		  AND season = $2`,
		s.TenantID, s.Season)
	if err != nil {
		return nil, fmt.Errorf("seasonal_crop_performance extract: %w", err)
	}
	defer rows.Close()

	var records []RawRecord
	for rows.Next() {
		var fieldID, crop string
		var totalYield, totalCost, area float64
		if err := rows.Scan(&fieldID, &crop, &totalYield, &totalCost, &area); err != nil {
			return nil, fmt.Errorf("seasonal_crop_performance scan: %w", err)
		}
		records = append(records, RawRecord{
			TenantID: s.TenantID,
			FieldID:  fieldID,
			Data: map[string]interface{}{
				"crop":             crop,
				"total_yield":      totalYield,
				"total_input_cost": totalCost,
				"area_hectares":    area,
			},
		})
	}
	return records, rows.Err()
}

func (s *SeasonalCropPerformance) Transform(ctx context.Context, records []RawRecord) ([]TransformedRecord, error) {
	var results []TransformedRecord
	for _, r := range records {
		totalYield := r.Data["total_yield"].(float64)
		totalCost := r.Data["total_input_cost"].(float64)
		area := r.Data["area_hectares"].(float64)

		yieldPerHectare := 0.0
		if area > 0 {
			yieldPerHectare = totalYield / area
		}
		roi := 0.0
		if totalCost > 0 {
			roi = (totalYield - totalCost) / totalCost * 100
		}

		results = append(results, TransformedRecord{
			TenantID: r.TenantID,
			FieldID:  r.FieldID,
			Table:    "seasonal_crop_performance",
			Values: map[string]interface{}{
				"season":            s.Season,
				"crop":              r.Data["crop"],
				"total_yield":       totalYield,
				"total_input_cost":  totalCost,
				"yield_per_hectare": yieldPerHectare,
				"roi":               roi,
			},
		})
	}
	return results, nil
}

func (s *SeasonalCropPerformance) Load(ctx context.Context, records []TransformedRecord) error {
	for _, r := range records {
		_, err := s.Pool.Exec(ctx, `
			INSERT INTO seasonal_crop_performance
				(tenant_id, field_id, season, crop, total_yield, total_input_cost, yield_per_hectare, roi)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
			ON CONFLICT (tenant_id, field_id, season, crop)
			DO UPDATE SET
				total_yield       = EXCLUDED.total_yield,
				total_input_cost  = EXCLUDED.total_input_cost,
				yield_per_hectare = EXCLUDED.yield_per_hectare,
				roi               = EXCLUDED.roi,
				updated_at        = NOW()`,
			r.TenantID, r.FieldID,
			r.Values["season"], r.Values["crop"],
			r.Values["total_yield"], r.Values["total_input_cost"],
			r.Values["yield_per_hectare"], r.Values["roi"])
		if err != nil {
			return fmt.Errorf("seasonal_crop_performance load: %w", err)
		}
	}
	return nil
}

// --------------------------------------------------------------------------
// MonthlySensorStats
// --------------------------------------------------------------------------

// MonthlySensorStats computes monthly min/max/avg for all sensor readings per field.
type MonthlySensorStats struct {
	Pool     *pgxpool.Pool
	TenantID string
}

func (m *MonthlySensorStats) Name() string     { return "monthly_sensor_stats" }
func (m *MonthlySensorStats) Schedule() string { return "720h" } // ~30 days

func (m *MonthlySensorStats) Extract(ctx context.Context) ([]RawRecord, error) {
	monthStart := time.Date(time.Now().Year(), time.Now().Month()-1, 1, 0, 0, 0, 0, time.UTC)
	monthEnd := time.Date(time.Now().Year(), time.Now().Month(), 1, 0, 0, 0, 0, time.UTC)

	rows, err := m.Pool.Query(ctx, `
		SELECT field_id, sensor_type, value
		FROM sensor_readings
		WHERE tenant_id = $1
		  AND reading_time >= $2
		  AND reading_time < $3`,
		m.TenantID, monthStart, monthEnd)
	if err != nil {
		return nil, fmt.Errorf("monthly_sensor_stats extract: %w", err)
	}
	defer rows.Close()

	var records []RawRecord
	for rows.Next() {
		var fieldID, sensorType string
		var value float64
		if err := rows.Scan(&fieldID, &sensorType, &value); err != nil {
			return nil, fmt.Errorf("monthly_sensor_stats scan: %w", err)
		}
		records = append(records, RawRecord{
			TenantID:  m.TenantID,
			FieldID:   fieldID,
			Timestamp: monthStart,
			Data: map[string]interface{}{
				"sensor_type": sensorType,
				"value":       value,
			},
		})
	}
	return records, rows.Err()
}

func (m *MonthlySensorStats) Transform(ctx context.Context, records []RawRecord) ([]TransformedRecord, error) {
	type key struct {
		FieldID    string
		SensorType string
	}
	type accum struct {
		Min   float64
		Max   float64
		Sum   float64
		Count int64
	}

	grouped := make(map[key]*accum)
	var month time.Time

	for _, r := range records {
		month = r.Timestamp
		k := key{FieldID: r.FieldID, SensorType: r.Data["sensor_type"].(string)}
		v := r.Data["value"].(float64)

		a, ok := grouped[k]
		if !ok {
			a = &accum{Min: v, Max: v}
			grouped[k] = a
		}
		if v < a.Min {
			a.Min = v
		}
		if v > a.Max {
			a.Max = v
		}
		a.Sum += v
		a.Count++
	}

	var results []TransformedRecord
	for k, a := range grouped {
		avg := 0.0
		if a.Count > 0 {
			avg = a.Sum / float64(a.Count)
		}
		results = append(results, TransformedRecord{
			TenantID:  m.TenantID,
			FieldID:   k.FieldID,
			Timestamp: month,
			Table:     "monthly_sensor_stats",
			Values: map[string]interface{}{
				"sensor_type":   k.SensorType,
				"min_value":     a.Min,
				"avg_value":     avg,
				"max_value":     a.Max,
				"reading_count": a.Count,
			},
		})
	}
	return results, nil
}

func (m *MonthlySensorStats) Load(ctx context.Context, records []TransformedRecord) error {
	for _, r := range records {
		_, err := m.Pool.Exec(ctx, `
			INSERT INTO monthly_sensor_stats
				(tenant_id, field_id, sensor_type, month, min_value, avg_value, max_value, reading_count)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
			ON CONFLICT (tenant_id, field_id, sensor_type, month)
			DO UPDATE SET
				min_value     = EXCLUDED.min_value,
				avg_value     = EXCLUDED.avg_value,
				max_value     = EXCLUDED.max_value,
				reading_count = EXCLUDED.reading_count,
				updated_at    = NOW()`,
			r.TenantID, r.FieldID,
			r.Values["sensor_type"], r.Timestamp,
			r.Values["min_value"], r.Values["avg_value"],
			r.Values["max_value"], r.Values["reading_count"])
		if err != nil {
			return fmt.Errorf("monthly_sensor_stats load: %w", err)
		}
	}
	return nil
}
