package domain

import "fmt"

// ErrFieldNotFound is returned when a field cannot be located.
type ErrFieldNotFound struct{ UUID string }

func (e ErrFieldNotFound) Error() string { return fmt.Sprintf("field not found: %s", e.UUID) }

// ErrFieldNameExists is returned when a duplicate field name exists in the same farm.
type ErrFieldNameExists struct {
Name   string
FarmID string
}

func (e ErrFieldNameExists) Error() string {
return fmt.Sprintf("field with name %q already exists in farm %s", e.Name, e.FarmID)
}

// ErrFarmNotFound is returned when the referenced farm does not exist.
type ErrFarmNotFound struct{ UUID string }

func (e ErrFarmNotFound) Error() string { return fmt.Sprintf("farm not found: %s", e.UUID) }
