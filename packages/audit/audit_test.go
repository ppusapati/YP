package audit

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestIsMutation(t *testing.T) {
	tests := []struct {
		procedure string
		want      bool
	}{
		{"/farm.v1.FarmService/CreateFarm", true},
		{"/farm.v1.FarmService/UpdateFarm", true},
		{"/farm.v1.FarmService/DeleteFarm", true},
		{"/farm.v1.FarmService/RemoveField", true},
		{"/farm.v1.FarmService/SetIrrigation", true},
		{"/farm.v1.FarmService/UpsertSensor", true},
		{"/farm.v1.FarmService/PatchField", true},
		{"/farm.v1.FarmService/ArchiveFarm", true},
		{"/farm.v1.FarmService/GetFarm", false},
		{"/farm.v1.FarmService/ListFarms", false},
		{"/farm.v1.FarmService/SearchFields", false},
		{"", false},
		{"/bad", false},
	}

	for _, tt := range tests {
		t.Run(tt.procedure, func(t *testing.T) {
			got := isMutation(tt.procedure)
			assert.Equal(t, tt.want, got, "isMutation(%q)", tt.procedure)
		})
	}
}

func TestExtractAction(t *testing.T) {
	tests := []struct {
		procedure string
		want      string
	}{
		{"/farm.v1.FarmService/CreateFarm", "Create"},
		{"/field.v1.FieldService/UpdateField", "Update"},
		{"/sensor.v1.SensorService/DeleteReading", "Delete"},
		{"/farm.v1.FarmService/GetFarm", "GetFarm"},
		{"", "Unknown"},
	}

	for _, tt := range tests {
		t.Run(tt.procedure, func(t *testing.T) {
			got := extractAction(tt.procedure)
			assert.Equal(t, tt.want, got)
		})
	}
}

func TestExtractResource(t *testing.T) {
	tests := []struct {
		procedure string
		want      string
	}{
		{"/farm.v1.FarmService/CreateFarm", "Farm"},
		{"/field.v1.FieldService/UpdateFieldBoundary", "FieldBoundary"},
		{"/sensor.v1.SensorService/DeleteReading", "Reading"},
		{"/farm.v1.FarmService/GetFarm", "GetFarm"},
		{"", "Unknown"},
	}

	for _, tt := range tests {
		t.Run(tt.procedure, func(t *testing.T) {
			got := extractResource(tt.procedure)
			assert.Equal(t, tt.want, got)
		})
	}
}

func TestAuditEntryDefaults(t *testing.T) {
	entry := AuditEntry{
		UserID:   "user-1",
		TenantID: "tenant-1",
		Action:   "Create",
		Resource: "Farm",
		Result:   "success",
	}

	assert.Empty(t, entry.ID, "ID should not be set before logging")
	assert.True(t, entry.Timestamp.IsZero(), "Timestamp should be zero before logging")
	assert.Equal(t, "success", entry.Result)
}

func TestWithRetention(t *testing.T) {
	l := &PostgresAuditLogger{
		retention: 0,
	}
	WithRetention(30 * 24 * 60 * 60 * 1e9)(l) // 30 days in nanoseconds
	assert.NotZero(t, l.retention)
}

func TestWithTableName(t *testing.T) {
	l := &PostgresAuditLogger{}
	WithTableName("custom_audit")(l)
	assert.Equal(t, "custom_audit", l.tableName)
}
