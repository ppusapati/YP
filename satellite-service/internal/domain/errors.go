package domain

import "fmt"

// ErrImageNotFound is returned when a satellite image cannot be located.
type ErrImageNotFound struct{ ID string }

func (e ErrImageNotFound) Error() string {
	return fmt.Sprintf("satellite image not found: %s", e.ID)
}

// ErrVegetationIndexNotFound is returned when a vegetation index record cannot be located.
type ErrVegetationIndexNotFound struct{ ID string }

func (e ErrVegetationIndexNotFound) Error() string {
	return fmt.Sprintf("vegetation index not found: %s", e.ID)
}

// ErrAlertNotFound is returned when a crop stress alert cannot be located.
type ErrAlertNotFound struct{ ID string }

func (e ErrAlertNotFound) Error() string {
	return fmt.Sprintf("crop stress alert not found: %s", e.ID)
}

// ErrTaskNotFound is returned when a satellite task cannot be located.
type ErrTaskNotFound struct{ ID string }

func (e ErrTaskNotFound) Error() string {
	return fmt.Sprintf("satellite task not found: %s", e.ID)
}
