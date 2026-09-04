package interceptors

import "testing"

func TestRoleAtLeast(t *testing.T) {
	tests := []struct {
		user     Role
		required Role
		want     bool
	}{
		{RoleAdmin, RoleAdmin, true},
		{RoleAdmin, RoleManager, true},
		{RoleAdmin, RoleWorker, true},
		{RoleAdmin, RoleViewer, true},
		{RoleManager, RoleAdmin, false},
		{RoleManager, RoleManager, true},
		{RoleManager, RoleWorker, true},
		{RoleManager, RoleViewer, true},
		{RoleWorker, RoleAdmin, false},
		{RoleWorker, RoleManager, false},
		{RoleWorker, RoleWorker, true},
		{RoleWorker, RoleViewer, true},
		{RoleViewer, RoleAdmin, false},
		{RoleViewer, RoleManager, false},
		{RoleViewer, RoleWorker, false},
		{RoleViewer, RoleViewer, true},
		{"unknown", RoleViewer, false},
		{RoleViewer, "unknown", false},
		{"", RoleViewer, false},
	}
	for _, tt := range tests {
		got := RoleAtLeast(tt.user, tt.required)
		if got != tt.want {
			t.Errorf("RoleAtLeast(%q, %q) = %v, want %v", tt.user, tt.required, got, tt.want)
		}
	}
}

func TestInferRoleFromVerb(t *testing.T) {
	tests := []struct {
		procedure string
		want      Role
	}{
		{"/agriculture.farm.v1.FarmService/DeleteFarm", RoleManager},
		{"/agriculture.farm.v1.FarmService/TransferOwnership", RoleManager},
		{"/agriculture.farm.v1.FarmService/RemoveFieldsFromUnit", RoleManager},
		{"/agriculture.farm.v1.FarmService/CreateFarm", RoleWorker},
		{"/agriculture.farm.v1.FarmService/UpdateFarm", RoleWorker},
		{"/agriculture.farm.v1.FarmService/SetFarmBoundary", RoleWorker},
		{"/agriculture.farm.v1.FarmService/AssignFieldsToUnit", RoleWorker},
		{"/agriculture.commerce.v1.CommerceService/PlaceOrder", RoleWorker},
		{"/agriculture.commerce.v1.CommerceService/CancelListing", RoleWorker},
		{"/agriculture.satellite.v1.SatelliteService/RequestImagery", RoleWorker},
		{"/agriculture.farm.v1.FarmService/GetFarm", RoleViewer},
		{"/agriculture.farm.v1.FarmService/ListFarms", RoleViewer},
		{"/agriculture.satellite.v1.SatelliteService/ComputeVegetationIndex", RoleViewer},
		{"/agriculture.satellite.v1.SatelliteService/DetectCropStress", RoleViewer},
		{"noslash", RoleViewer},
	}
	for _, tt := range tests {
		got := inferRoleFromVerb(tt.procedure, RoleViewer)
		if got != tt.want {
			t.Errorf("inferRoleFromVerb(%q) = %v, want %v", tt.procedure, got, tt.want)
		}
	}
}

func TestResolveRoleExplicitOverride(t *testing.T) {
	cfg := &authzConfig{
		procedureRoles: map[string]Role{
			"/agriculture.farm.v1.FarmService/GetFarm": RoleManager,
		},
		defaultRole: RoleViewer,
	}
	got := cfg.resolveRole("/agriculture.farm.v1.FarmService/GetFarm")
	if got != RoleManager {
		t.Errorf("explicit override: got %v, want %v", got, RoleManager)
	}

	got = cfg.resolveRole("/agriculture.farm.v1.FarmService/DeleteFarm")
	if got != RoleManager {
		t.Errorf("verb-inferred: got %v, want %v", got, RoleManager)
	}
}
