package domain

import "fmt"

// ErrYieldNotFound is returned when a yield entity cannot be located.
type ErrYieldNotFound struct{ ID string }

func (e ErrYieldNotFound) Error() string {
	return fmt.Sprintf("yield not found: %s", e.ID)
}

// ErrPredictionNotFound is returned when a prediction cannot be located.
type ErrPredictionNotFound struct{ ID string }

func (e ErrPredictionNotFound) Error() string {
	return fmt.Sprintf("prediction not found: %s", e.ID)
}

// ErrHarvestPlanNotFound is returned when a harvest plan cannot be located.
type ErrHarvestPlanNotFound struct{ ID string }

func (e ErrHarvestPlanNotFound) Error() string {
	return fmt.Sprintf("harvest plan not found: %s", e.ID)
}

// ErrYieldRecordNotFound is returned when no yield records match the criteria.
type ErrYieldRecordNotFound struct{ Detail string }

func (e ErrYieldRecordNotFound) Error() string {
	return fmt.Sprintf("yield record not found: %s", e.Detail)
}
