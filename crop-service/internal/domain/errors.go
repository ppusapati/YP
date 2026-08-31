package domain

import "fmt"

// ErrCropNotFound is returned when a crop cannot be located.
type ErrCropNotFound struct{ UUID string }

func (e ErrCropNotFound) Error() string {
	return fmt.Sprintf("crop not found: %s", e.UUID)
}

// ErrCropNameExists is returned when a duplicate name is detected.
type ErrCropNameExists struct{ Name string }

func (e ErrCropNameExists) Error() string {
	return fmt.Sprintf("crop with name %q already exists", e.Name)
}
