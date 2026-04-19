package domain

import "fmt"

// ErrPestNotFound is returned when a pest cannot be located.
type ErrPestNotFound struct{ UUID string }

func (e ErrPestNotFound) Error() string {
	return fmt.Sprintf("pest not found: %s", e.UUID)
}

// ErrPestNameExists is returned when a duplicate name is detected.
type ErrPestNameExists struct{ Name string }

func (e ErrPestNameExists) Error() string {
	return fmt.Sprintf("pest with name %q already exists", e.Name)
}
