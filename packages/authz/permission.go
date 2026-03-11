package authz

// Effect represents whether a permission grants or denies access
type Effect int32

const (
	Effect_UNSPECIFIED Effect = 0
	Effect_GRANT       Effect = 1
	Effect_DENY        Effect = 2
)

// Permission represents an authorization permission
type Permission struct {
	Namespace string // e.g., "user", "tenant", "billing"
	Resource  string // e.g., "profile", "settings", "invoice"
	Action    string // e.g., "read", "write", "delete"
	Effect    Effect // GRANT or DENY
}

// CheckPermissionResponse represents the result of a permission check
type CheckPermissionResponse struct {
	Allowed bool
	Effect  Effect
	Reason  string
}
