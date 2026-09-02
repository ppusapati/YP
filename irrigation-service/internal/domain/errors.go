package domain

import "fmt"

// ErrIrrigationNotFound is returned when a irrigation cannot be located.
type ErrIrrigationNotFound struct{ ID string }

func (e ErrIrrigationNotFound) Error() string {
	return fmt.Sprintf("irrigation not found: %s", e.ID)
}

// ErrIrrigationNameExists is returned when a duplicate name is detected.
type ErrIrrigationNameExists struct{ Name string }

func (e ErrIrrigationNameExists) Error() string {
	return fmt.Sprintf("irrigation with name %q already exists", e.Name)
}
