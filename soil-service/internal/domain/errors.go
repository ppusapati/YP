package domain

import "fmt"

// ErrSoilNotFound is returned when a soil cannot be located.
type ErrSoilNotFound struct{ UUID string }

func (e ErrSoilNotFound) Error() string {
	return fmt.Sprintf("soil not found: %s", e.UUID)
}

// ErrSoilNameExists is returned when a duplicate name is detected.
type ErrSoilNameExists struct{ Name string }

func (e ErrSoilNameExists) Error() string {
	return fmt.Sprintf("soil with name %q already exists", e.Name)
}
