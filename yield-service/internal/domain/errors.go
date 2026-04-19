package domain

import "fmt"

// ErrYieldNotFound is returned when a yield cannot be located.
type ErrYieldNotFound struct{ UUID string }

func (e ErrYieldNotFound) Error() string {
	return fmt.Sprintf("yield not found: %s", e.UUID)
}

// ErrYieldNameExists is returned when a duplicate name is detected.
type ErrYieldNameExists struct{ Name string }

func (e ErrYieldNameExists) Error() string {
	return fmt.Sprintf("yield with name %q already exists", e.Name)
}
