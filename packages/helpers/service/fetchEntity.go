package helpers_service

import (
	"context"
	"fmt"

	"p9e.in/samavaya/packages/models"
)

func fetchEntity[T models.Entity](
	ctx context.Context,
	id string,
	repoGetByIDFunc func(context.Context, string) (T, error),
) (T, error) {
	var entity T
	var err error

	if id != "" {
		entity, err = repoGetByIDFunc(ctx, id)
	} else {
		err = fmt.Errorf("missing valid identifier (ID)")
	}

	return entity, err
}
