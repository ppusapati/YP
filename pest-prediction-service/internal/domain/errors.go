package domain

import "fmt"

// ErrPestNotFound is returned when a pest cannot be located.
type ErrPestNotFound struct{ ID string }

func (e ErrPestNotFound) Error() string {
	return fmt.Sprintf("pest not found: %s", e.ID)
}

// ErrPestNameExists is returned when a duplicate name is detected.
type ErrPestNameExists struct{ Name string }

func (e ErrPestNameExists) Error() string {
	return fmt.Sprintf("pest with name %q already exists", e.Name)
}

// ErrPredictionNotFound is returned when a prediction cannot be located.
type ErrPredictionNotFound struct{ ID string }

func (e ErrPredictionNotFound) Error() string {
	return fmt.Sprintf("prediction not found: %s", e.ID)
}

// ErrAlertNotFound is returned when an alert cannot be located.
type ErrAlertNotFound struct{ ID string }

func (e ErrAlertNotFound) Error() string {
	return fmt.Sprintf("alert not found: %s", e.ID)
}

// ErrSpeciesNotFound is returned when a pest species cannot be located.
type ErrSpeciesNotFound struct{ ID string }

func (e ErrSpeciesNotFound) Error() string {
	return fmt.Sprintf("pest species not found: %s", e.ID)
}

// ErrRiskMapNotFound is returned when a risk map cannot be located.
type ErrRiskMapNotFound struct {
	PestSpeciesID string
	Region        string
}

func (e ErrRiskMapNotFound) Error() string {
	return fmt.Sprintf("risk map not found for species %s in region %s", e.PestSpeciesID, e.Region)
}
