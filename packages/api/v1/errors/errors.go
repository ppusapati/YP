package errors

// Status is a status error structure used by the errors package.
// This replaces the proto-generated type for compilation.
type Status struct {
	Code     int32             `json:"code"`
	Reason   string            `json:"reason"`
	Message  string            `json:"message"`
	Metadata map[string]string `json:"metadata,omitempty"`
}
