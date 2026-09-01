package domain

import "fmt"

// ErrDiagnosisNotFound is returned when a diagnosis cannot be located.
type ErrDiagnosisNotFound struct{ ID string }

func (e ErrDiagnosisNotFound) Error() string {
	return fmt.Sprintf("diagnosis not found: %s", e.ID)
}

// ErrDiseaseNotFound is returned when a disease cannot be located.
type ErrDiseaseNotFound struct{ ID string }

func (e ErrDiseaseNotFound) Error() string {
	return fmt.Sprintf("disease not found: %s", e.ID)
}

// ErrTreatmentPlanNotFound is returned when a treatment plan cannot be located.
type ErrTreatmentPlanNotFound struct{ DiagnosisID string }

func (e ErrTreatmentPlanNotFound) Error() string {
	return fmt.Sprintf("treatment plan not found for diagnosis: %s", e.DiagnosisID)
}
