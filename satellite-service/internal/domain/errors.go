package domain

import "fmt"

// ErrSatelliteNotFound is returned when a satellite cannot be located.
type ErrSatelliteNotFound struct{ UUID string }

func (e ErrSatelliteNotFound) Error() string {
	return fmt.Sprintf("satellite not found: %s", e.UUID)
}

// ErrSatelliteNameExists is returned when a duplicate name is detected.
type ErrSatelliteNameExists struct{ Name string }

func (e ErrSatelliteNameExists) Error() string {
	return fmt.Sprintf("satellite with name %q already exists", e.Name)
}
