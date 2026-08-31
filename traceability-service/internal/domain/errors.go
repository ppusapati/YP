package domain

import "fmt"

// ErrTraceabilityNotFound is returned when a traceability cannot be located.
type ErrTraceabilityNotFound struct{ UUID string }

func (e ErrTraceabilityNotFound) Error() string {
	return fmt.Sprintf("traceability not found: %s", e.UUID)
}

// ErrTraceabilityNameExists is returned when a duplicate name is detected.
type ErrTraceabilityNameExists struct{ Name string }

func (e ErrTraceabilityNameExists) Error() string {
	return fmt.Sprintf("traceability with name %q already exists", e.Name)
}
