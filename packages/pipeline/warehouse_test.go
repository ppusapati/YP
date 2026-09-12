package pipeline

import (
	"math"
	"testing"
)

func TestBucketToTrunc(t *testing.T) {
	tests := []struct {
		bucket TimeBucket
		want   string
		err    bool
	}{
		{TimeBucket1Hour, "'hour'", false},
		{TimeBucket1Day, "'day'", false},
		{TimeBucket1Week, "'week'", false},
		{TimeBucket1Month, "'month'", false},
		{TimeBucket("invalid"), "", true},
	}

	for _, tt := range tests {
		t.Run(string(tt.bucket), func(t *testing.T) {
			got, err := bucketToTrunc(tt.bucket)
			if tt.err && err == nil {
				t.Error("expected error, got nil")
			}
			if !tt.err && err != nil {
				t.Errorf("unexpected error: %v", err)
			}
			if got != tt.want {
				t.Errorf("got %q, want %q", got, tt.want)
			}
		})
	}
}

func TestIsValidIdentifier(t *testing.T) {
	tests := []struct {
		input string
		valid bool
	}{
		{"sensor_readings", true},
		{"SensorReadings", true},
		{"table123", true},
		{"", false},
		{"drop table", false},
		{"table;--", false},
		{"table.name", false},
		{"table-name", false},
		{"table'name", false},
		{"123abc", true},
		{"_underscore", true},
	}

	for _, tt := range tests {
		t.Run(tt.input, func(t *testing.T) {
			got := isValidIdentifier(tt.input)
			if got != tt.valid {
				t.Errorf("isValidIdentifier(%q) = %v, want %v", tt.input, got, tt.valid)
			}
		})
	}
}

func TestLinearRegression(t *testing.T) {
	t.Run("perfect positive slope", func(t *testing.T) {
		xs := []float64{1, 2, 3, 4, 5}
		ys := []float64{2, 4, 6, 8, 10}
		slope, intercept, rSquared := linearRegression(xs, ys)

		if math.Abs(slope-2.0) > 0.001 {
			t.Errorf("slope = %f, want 2.0", slope)
		}
		if math.Abs(intercept-0.0) > 0.001 {
			t.Errorf("intercept = %f, want 0.0", intercept)
		}
		if math.Abs(rSquared-1.0) > 0.001 {
			t.Errorf("rSquared = %f, want 1.0", rSquared)
		}
	})

	t.Run("negative slope", func(t *testing.T) {
		xs := []float64{1, 2, 3, 4, 5}
		ys := []float64{10, 8, 6, 4, 2}
		slope, _, rSquared := linearRegression(xs, ys)

		if math.Abs(slope-(-2.0)) > 0.001 {
			t.Errorf("slope = %f, want -2.0", slope)
		}
		if math.Abs(rSquared-1.0) > 0.001 {
			t.Errorf("rSquared = %f, want 1.0", rSquared)
		}
	})

	t.Run("flat line", func(t *testing.T) {
		xs := []float64{1, 2, 3, 4, 5}
		ys := []float64{5, 5, 5, 5, 5}
		slope, intercept, _ := linearRegression(xs, ys)

		if math.Abs(slope) > 0.001 {
			t.Errorf("slope = %f, want 0.0", slope)
		}
		if math.Abs(intercept-5.0) > 0.001 {
			t.Errorf("intercept = %f, want 5.0", intercept)
		}
	})

	t.Run("single point", func(t *testing.T) {
		xs := []float64{1}
		ys := []float64{5}
		slope, _, rSquared := linearRegression(xs, ys)

		if slope != 0 {
			t.Errorf("slope = %f, want 0", slope)
		}
		if rSquared != 0 {
			t.Errorf("rSquared = %f, want 0", rSquared)
		}
	})

	t.Run("empty data", func(t *testing.T) {
		slope, intercept, rSquared := linearRegression(nil, nil)
		if slope != 0 || intercept != 0 || rSquared != 0 {
			t.Error("expected all zeros for empty data")
		}
	})

	t.Run("noisy data", func(t *testing.T) {
		xs := []float64{1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
		ys := []float64{2.1, 3.9, 6.2, 7.8, 10.1, 12.3, 13.8, 16.2, 17.9, 20.1}
		slope, _, rSquared := linearRegression(xs, ys)

		if slope < 1.5 || slope > 2.5 {
			t.Errorf("slope = %f, expected ~2.0", slope)
		}
		if rSquared < 0.95 {
			t.Errorf("rSquared = %f, expected > 0.95 for near-linear data", rSquared)
		}
	})
}

func TestTrendResult_Direction(t *testing.T) {
	tests := []struct {
		name      string
		slope     float64
		wantDir   string
	}{
		{"increasing", 0.5, "increasing"},
		{"decreasing", -0.5, "decreasing"},
		{"stable positive", 0.0001, "stable"},
		{"stable negative", -0.0001, "stable"},
		{"zero", 0, "stable"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			direction := "stable"
			if math.Abs(tt.slope) > 0.001 {
				if tt.slope > 0 {
					direction = "increasing"
				} else {
					direction = "decreasing"
				}
			}
			if direction != tt.wantDir {
				t.Errorf("direction = %q, want %q", direction, tt.wantDir)
			}
		})
	}
}

func TestTimeSeriesQuery_Fields(t *testing.T) {
	q := TimeSeriesQuery{
		TenantID:   "tenant-1",
		FieldID:    "field-1",
		SensorType: "temperature",
		Bucket:     TimeBucket1Hour,
	}

	if q.TenantID != "tenant-1" {
		t.Error("TenantID not set")
	}
	if q.Bucket != TimeBucket1Hour {
		t.Error("Bucket not set")
	}
}

func TestCrossFieldQuery_Validation(t *testing.T) {
	q := CrossFieldQuery{
		TenantID: "tenant-1",
		FieldIDs: []string{"f1", "f2", "f3"},
		Metric:   "temperature",
		Table:    "sensor_readings",
	}

	if len(q.FieldIDs) != 3 {
		t.Errorf("expected 3 field IDs, got %d", len(q.FieldIDs))
	}
	if !isValidIdentifier(q.Table) {
		t.Error("table name should be valid")
	}
	if !isValidIdentifier(q.Metric) {
		t.Error("metric name should be valid")
	}
}
