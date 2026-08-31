package domain

import "fmt"

// ErrDiagnosisNotFound is returned when a diagnosis cannot be located.
type ErrDiagnosisNotFound struct{ UUID string }

func (e ErrDiagnosisNotFound) Error() string {
	return fmt.Sprintf("diagnosis not found: %s", e.UUID)
}

// ErrDiagnosisNameExists is returned when a duplicate name is detected.
type ErrDiagnosisNameExists struct{ Name string }

func (e ErrDiagnosisNameExists) Error() string {
	return fmt.Sprintf("diagnosis with name %q already exists", e.Name)
}
