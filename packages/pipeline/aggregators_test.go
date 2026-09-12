package pipeline

import (
	"context"
	"testing"
	"time"
)

func TestDailyYieldSummary_TransformGrouping(t *testing.T) {
	job := &DailyYieldSummary{TenantID: "tenant-1"}
	yesterday := time.Now().AddDate(0, 0, -1).Truncate(24 * time.Hour)

	records := []RawRecord{
		{TenantID: "tenant-1", FieldID: "field-a", Timestamp: yesterday, Data: map[string]interface{}{"crop": "wheat", "yield": 100.0, "area": 10.0}},
		{TenantID: "tenant-1", FieldID: "field-a", Timestamp: yesterday, Data: map[string]interface{}{"crop": "wheat", "yield": 200.0, "area": 10.0}},
		{TenantID: "tenant-1", FieldID: "field-a", Timestamp: yesterday, Data: map[string]interface{}{"crop": "wheat", "yield": 50.0, "area": 5.0}},
		{TenantID: "tenant-1", FieldID: "field-b", Timestamp: yesterday, Data: map[string]interface{}{"crop": "rice", "yield": 300.0, "area": 20.0}},
	}

	results, err := job.Transform(context.Background(), records)
	if err != nil {
		t.Fatalf("Transform failed: %v", err)
	}

	if len(results) != 2 {
		t.Fatalf("expected 2 groups, got %d", len(results))
	}

	// Verify grouping by field+crop.
	found := make(map[string]TransformedRecord)
	for _, r := range results {
		key := r.FieldID + ":" + r.Values["crop"].(string)
		found[key] = r
	}

	wheat, ok := found["field-a:wheat"]
	if !ok {
		t.Fatal("missing field-a:wheat group")
	}
	if wheat.Values["min_yield"].(float64) != 50.0 {
		t.Errorf("expected min_yield=50, got %v", wheat.Values["min_yield"])
	}
	if wheat.Values["max_yield"].(float64) != 200.0 {
		t.Errorf("expected max_yield=200, got %v", wheat.Values["max_yield"])
	}
	expectedAvg := (100.0 + 200.0 + 50.0) / 3.0
	if avg := wheat.Values["avg_yield"].(float64); avg < expectedAvg-0.01 || avg > expectedAvg+0.01 {
		t.Errorf("expected avg_yield~%.2f, got %.2f", expectedAvg, avg)
	}
	if wheat.Values["total_area"].(float64) != 25.0 {
		t.Errorf("expected total_area=25, got %v", wheat.Values["total_area"])
	}
	if wheat.Table != "daily_yield_summaries" {
		t.Errorf("expected table=daily_yield_summaries, got %s", wheat.Table)
	}

	rice, ok := found["field-b:rice"]
	if !ok {
		t.Fatal("missing field-b:rice group")
	}
	if rice.Values["total_area"].(float64) != 20.0 {
		t.Errorf("expected total_area=20, got %v", rice.Values["total_area"])
	}
}

func TestDailyYieldSummary_TransformEmpty(t *testing.T) {
	job := &DailyYieldSummary{TenantID: "t1"}
	results, err := job.Transform(context.Background(), nil)
	if err != nil {
		t.Fatalf("Transform failed: %v", err)
	}
	if len(results) != 0 {
		t.Errorf("expected 0 results, got %d", len(results))
	}
}

func TestWeeklySoilTrends_TransformAveraging(t *testing.T) {
	job := &WeeklySoilTrends{TenantID: "tenant-1"}
	weekStart := time.Now().AddDate(0, 0, -7).Truncate(24 * time.Hour)

	records := []RawRecord{
		{TenantID: "tenant-1", FieldID: "f1", Timestamp: weekStart, Data: map[string]interface{}{
			"moisture": 30.0, "ph": 6.5, "nitrogen": 10.0, "phosphorus": 5.0, "potassium": 8.0,
		}},
		{TenantID: "tenant-1", FieldID: "f1", Timestamp: weekStart, Data: map[string]interface{}{
			"moisture": 40.0, "ph": 7.5, "nitrogen": 20.0, "phosphorus": 15.0, "potassium": 12.0,
		}},
	}

	results, err := job.Transform(context.Background(), records)
	if err != nil {
		t.Fatalf("Transform: %v", err)
	}
	if len(results) != 1 {
		t.Fatalf("expected 1 result, got %d", len(results))
	}

	r := results[0]
	if r.Table != "weekly_soil_trends" {
		t.Errorf("expected table weekly_soil_trends, got %s", r.Table)
	}
	if r.Values["avg_moisture"].(float64) != 35.0 {
		t.Errorf("expected avg_moisture=35, got %v", r.Values["avg_moisture"])
	}
	if r.Values["avg_ph"].(float64) != 7.0 {
		t.Errorf("expected avg_ph=7, got %v", r.Values["avg_ph"])
	}
	if r.Values["avg_nitrogen"].(float64) != 15.0 {
		t.Errorf("expected avg_nitrogen=15, got %v", r.Values["avg_nitrogen"])
	}
	if r.Values["avg_phosphorus"].(float64) != 10.0 {
		t.Errorf("expected avg_phosphorus=10, got %v", r.Values["avg_phosphorus"])
	}
	if r.Values["avg_potassium"].(float64) != 10.0 {
		t.Errorf("expected avg_potassium=10, got %v", r.Values["avg_potassium"])
	}
}

func TestSeasonalCropPerformance_TransformROI(t *testing.T) {
	job := &SeasonalCropPerformance{TenantID: "t1", Season: "2024-kharif"}

	records := []RawRecord{
		{TenantID: "t1", FieldID: "f1", Data: map[string]interface{}{
			"crop": "rice", "total_yield": 5000.0, "total_input_cost": 2000.0, "area_hectares": 10.0,
		}},
		{TenantID: "t1", FieldID: "f2", Data: map[string]interface{}{
			"crop": "wheat", "total_yield": 3000.0, "total_input_cost": 0.0, "area_hectares": 5.0,
		}},
	}

	results, err := job.Transform(context.Background(), records)
	if err != nil {
		t.Fatalf("Transform: %v", err)
	}
	if len(results) != 2 {
		t.Fatalf("expected 2 results, got %d", len(results))
	}

	// Find the rice record.
	var rice TransformedRecord
	for _, r := range results {
		if r.FieldID == "f1" {
			rice = r
			break
		}
	}

	// yield_per_hectare = 5000/10 = 500
	if rice.Values["yield_per_hectare"].(float64) != 500.0 {
		t.Errorf("expected yield_per_hectare=500, got %v", rice.Values["yield_per_hectare"])
	}
	// roi = (5000-2000)/2000 * 100 = 150
	if rice.Values["roi"].(float64) != 150.0 {
		t.Errorf("expected roi=150, got %v", rice.Values["roi"])
	}
	if rice.Values["season"].(string) != "2024-kharif" {
		t.Errorf("expected season=2024-kharif, got %v", rice.Values["season"])
	}

	// Zero cost should give roi=0.
	var wheat TransformedRecord
	for _, r := range results {
		if r.FieldID == "f2" {
			wheat = r
			break
		}
	}
	if wheat.Values["roi"].(float64) != 0.0 {
		t.Errorf("expected roi=0 for zero cost, got %v", wheat.Values["roi"])
	}
}

func TestSeasonalCropPerformance_TransformZeroArea(t *testing.T) {
	job := &SeasonalCropPerformance{TenantID: "t1", Season: "2024-rabi"}

	records := []RawRecord{
		{TenantID: "t1", FieldID: "f1", Data: map[string]interface{}{
			"crop": "rice", "total_yield": 100.0, "total_input_cost": 50.0, "area_hectares": 0.0,
		}},
	}

	results, err := job.Transform(context.Background(), records)
	if err != nil {
		t.Fatalf("Transform: %v", err)
	}
	if results[0].Values["yield_per_hectare"].(float64) != 0.0 {
		t.Errorf("expected 0 yield_per_hectare for zero area, got %v", results[0].Values["yield_per_hectare"])
	}
}

func TestMonthlySensorStats_TransformMinMaxAvg(t *testing.T) {
	job := &MonthlySensorStats{TenantID: "t1"}
	monthStart := time.Date(2024, 6, 1, 0, 0, 0, 0, time.UTC)

	records := []RawRecord{
		{TenantID: "t1", FieldID: "f1", Timestamp: monthStart, Data: map[string]interface{}{"sensor_type": "temperature", "value": 25.0}},
		{TenantID: "t1", FieldID: "f1", Timestamp: monthStart, Data: map[string]interface{}{"sensor_type": "temperature", "value": 35.0}},
		{TenantID: "t1", FieldID: "f1", Timestamp: monthStart, Data: map[string]interface{}{"sensor_type": "temperature", "value": 15.0}},
		{TenantID: "t1", FieldID: "f1", Timestamp: monthStart, Data: map[string]interface{}{"sensor_type": "humidity", "value": 60.0}},
	}

	results, err := job.Transform(context.Background(), records)
	if err != nil {
		t.Fatalf("Transform: %v", err)
	}
	if len(results) != 2 {
		t.Fatalf("expected 2 groups (temperature, humidity), got %d", len(results))
	}

	found := make(map[string]TransformedRecord)
	for _, r := range results {
		found[r.Values["sensor_type"].(string)] = r
	}

	temp := found["temperature"]
	if temp.Values["min_value"].(float64) != 15.0 {
		t.Errorf("expected min=15, got %v", temp.Values["min_value"])
	}
	if temp.Values["max_value"].(float64) != 35.0 {
		t.Errorf("expected max=35, got %v", temp.Values["max_value"])
	}
	if temp.Values["reading_count"].(int64) != 3 {
		t.Errorf("expected count=3, got %v", temp.Values["reading_count"])
	}
	expectedAvg := 25.0
	if avg := temp.Values["avg_value"].(float64); avg < expectedAvg-0.01 || avg > expectedAvg+0.01 {
		t.Errorf("expected avg~25, got %v", avg)
	}

	humidity := found["humidity"]
	if humidity.Values["reading_count"].(int64) != 1 {
		t.Errorf("expected humidity count=1, got %v", humidity.Values["reading_count"])
	}
}

func TestMonthlySensorStats_TransformEmpty(t *testing.T) {
	job := &MonthlySensorStats{TenantID: "t1"}
	results, err := job.Transform(context.Background(), nil)
	if err != nil {
		t.Fatalf("Transform: %v", err)
	}
	if len(results) != 0 {
		t.Errorf("expected 0 results, got %d", len(results))
	}
}

func TestAggregatorNames(t *testing.T) {
	tests := []struct {
		job      ETLJob
		name     string
		schedule string
	}{
		{&DailyYieldSummary{}, "daily_yield_summary", "24h"},
		{&WeeklySoilTrends{}, "weekly_soil_trends", "168h"},
		{&SeasonalCropPerformance{}, "seasonal_crop_performance", "720h"},
		{&MonthlySensorStats{}, "monthly_sensor_stats", "720h"},
	}

	for _, tt := range tests {
		if tt.job.Name() != tt.name {
			t.Errorf("expected Name()=%q, got %q", tt.name, tt.job.Name())
		}
		if tt.job.Schedule() != tt.schedule {
			t.Errorf("expected Schedule()=%q for %s, got %q", tt.schedule, tt.name, tt.job.Schedule())
		}
	}
}
