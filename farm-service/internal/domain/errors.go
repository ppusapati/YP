// Package domain errors: named sentinel errors used by the application layer.
// Callers check errors using errors.Is / errors.As or by type-switching on
// the packages/errors types returned from the application service.
package domain

import "fmt"

// ErrFarmNotFound is returned when a farm cannot be located.
type ErrFarmNotFound struct{ UUID string }

func (e ErrFarmNotFound) Error() string { return fmt.Sprintf("farm not found: %s", e.UUID) }

// ErrFarmNameExists is returned when a duplicate farm name is detected.
type ErrFarmNameExists struct{ Name string }

func (e ErrFarmNameExists) Error() string {
	return fmt.Sprintf("farm with name %q already exists", e.Name)
}

// ErrNotAnOwner is returned when the from_user_id is not a registered farm owner.
type ErrNotAnOwner struct {
	FarmUUID string
	UserID   string
}

func (e ErrNotAnOwner) Error() string {
	return fmt.Sprintf("user %s is not an owner of farm %s", e.UserID, e.FarmUUID)
}

// ErrSameUser is returned when from_user and to_user are identical.
var ErrSameUser = fmt.Errorf("cannot transfer ownership to the same user")
