package domain_test

import (
	"strings"
	"testing"

	fieldv1 "p9e.in/samavaya/agriculture/field-service/api/v1"
	pestv1 "p9e.in/samavaya/agriculture/pest-prediction-service/api/v1"
	"p9e.in/samavaya/agriculture/pest-prediction-service/internal/domain"
)

// agriculture.pest.v1.GrowthStage must stay identical to
// agriculture.field.v1.GrowthStage — names and numbers both.
//
// These two drifted apart and nothing noticed. field-service had BUDDING = 4,
// FLOWERING = 5, FRUIT_SET = 6, RIPENING = 7, MATURITY = 8, SENESCENCE = 9;
// this service had FLOWERING = 4, FRUITING = 5, MATURATION = 6, HARVEST = 7.
// Two separate failures fell out of that, and neither raised an error:
//
//   - By name: a stage in one list and not the other was dropped, and growth
//     stage is worth a quarter of the pest risk score, so the field was scored
//     as though its stage were unknown.
//   - By number: field's FLOWERING(5) is this service's old FRUITING(5), so
//     any path carrying the enum rather than its name decoded one stage as
//     another — silently, with a plausible score at the other end.
//
// The consumer logs a warning when it meets a stage it cannot read, but a
// warning is only seen by whoever is looking. This test is the part that
// fails, at build time, before either failure can reach a farmer.
//
// If this test fails, the two .proto files have diverged. Fix the protos and
// regenerate; do not relax the assertion.
func TestGrowthStageMatchesFieldService(t *testing.T) {
	// Compared through the generated name/number maps rather than a
	// hand-written list, so the test cannot go stale the way the vocabularies
	// did — adding a stage to either proto is picked up here automatically.
	if len(pestv1.GrowthStage_name) != len(fieldv1.GrowthStage_name) {
		t.Errorf("pest has %d growth stages, field has %d",
			len(pestv1.GrowthStage_name), len(fieldv1.GrowthStage_name))
	}

	for num, fieldName := range fieldv1.GrowthStage_name {
		pestName, ok := pestv1.GrowthStage_name[num]
		if !ok {
			t.Errorf("field has %s = %d; pest has no stage at %d", fieldName, num, num)
			continue
		}
		if pestName != fieldName {
			t.Errorf("stage %d is %s in field and %s in pest; a message carrying "+
				"the enum would decode as the wrong stage", num, fieldName, pestName)
		}
	}

	for num, pestName := range pestv1.GrowthStage_name {
		if _, ok := fieldv1.GrowthStage_name[num]; !ok {
			t.Errorf("pest has %s = %d; field has no stage at %d", pestName, num, num)
		}
	}
}

// Every proto stage must have a domain constant behind it, and it must be the
// proto name with the GROWTH_STAGE_ prefix removed — which is what the
// repository writes to the database and what the crop-assigned event carries.
//
// Without this, adding a stage to the proto and forgetting the domain constant
// would leave IsValid rejecting a stage the wire can express, and the consumer
// would score it as unstaged.
func TestEveryProtoStageHasADomainConstant(t *testing.T) {
	for num, protoName := range pestv1.GrowthStage_name {
		if num == 0 {
			continue // UNSPECIFIED maps to the empty domain value.
		}
		want := domain.GrowthStage(strings.TrimPrefix(protoName, "GROWTH_STAGE_"))
		if !want.IsValid() {
			t.Errorf("proto has %s but the domain does not recognise %q", protoName, want)
		}
	}
}

// And the reverse: a domain constant with no proto value behind it cannot be
// sent or stored coherently.
func TestEveryDomainStageHasAProtoValue(t *testing.T) {
	protoNames := map[string]bool{}
	for _, n := range pestv1.GrowthStage_name {
		protoNames[n] = true
	}

	for _, stage := range []domain.GrowthStage{
		domain.GrowthStageGermination,
		domain.GrowthStageSeedling,
		domain.GrowthStageVegetative,
		domain.GrowthStageBudding,
		domain.GrowthStageFlowering,
		domain.GrowthStageFruitSet,
		domain.GrowthStageRipening,
		domain.GrowthStageMaturity,
		domain.GrowthStageSenescence,
	} {
		if !protoNames["GROWTH_STAGE_"+string(stage)] {
			t.Errorf("domain has %q with no GROWTH_STAGE_%s in the proto", stage, stage)
		}
	}
}
