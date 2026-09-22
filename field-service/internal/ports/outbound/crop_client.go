package outbound

import "context"

// CropClient is the secondary port for calling crop-service.
type CropClient interface {
	// CropName returns the crop's display name and whether the crop exists.
	//
	// Name and existence together, from one call, because the lookup that
	// answers "does this crop exist" already returns the whole crop. It used
	// to return only a bool and throw the rest away, which left every
	// consumer of the crop-assigned event holding an opaque id where a crop
	// name belongs — and pest-prediction stamps that value onto a farmer-
	// facing prediction.
	CropName(ctx context.Context, uuid, tenantID string) (name string, found bool, err error)
}
