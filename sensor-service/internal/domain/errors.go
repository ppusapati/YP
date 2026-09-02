package domain

import "fmt"

// ErrSensorNotFound is returned when a sensor cannot be located.
type ErrSensorNotFound struct{ ID string }

func (e ErrSensorNotFound) Error() string {
	return fmt.Sprintf("sensor not found: %s", e.ID)
}

// ErrSensorNameExists is returned when a duplicate name is detected.
type ErrSensorNameExists struct{ Name string }

func (e ErrSensorNameExists) Error() string {
	return fmt.Sprintf("sensor with name %q already exists", e.Name)
}
