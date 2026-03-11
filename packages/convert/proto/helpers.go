package proto

import (
	"encoding/json"
	"time"

	"github.com/shopspring/decimal"
	"google.golang.org/protobuf/types/known/timestamppb"
)

// StringToPtr converts a string to *string. Returns nil for empty string.
func StringToPtr(s string) *string {
	if s == "" {
		return nil
	}
	return &s
}

// PtrToString converts *string to string. Returns empty string if nil.
func PtrToString(s *string) string {
	if s == nil {
		return ""
	}
	return *s
}

// Int32ToPtr converts int32 to *int32. Returns nil for zero.
func Int32ToPtr(v int32) *int32 {
	if v == 0 {
		return nil
	}
	return &v
}

// BoolToPtr converts bool to *bool.
func BoolToPtr(b bool) *bool {
	return &b
}

// ToBoolPtr converts bool to *bool. Alias for BoolToPtr.
func ToBoolPtr(b bool) *bool {
	return &b
}

// BoolPtrFromBool converts bool to *bool. Alias for BoolToPtr.
func BoolPtrFromBool(b bool) *bool {
	return &b
}

// BoolFromBoolPtr converts *bool to bool. Returns false if nil.
func BoolFromBoolPtr(b *bool) bool {
	if b == nil {
		return false
	}
	return *b
}

// ToStringPtr converts a string to *string. Alias for StringToPtr.
func ToStringPtr(s string) *string {
	return StringToPtr(s)
}

// ToTimePtr converts *timestamppb.Timestamp to *time.Time.
func ToTimePtr(ts *timestamppb.Timestamp) *time.Time {
	if ts == nil {
		return nil
	}
	t := ts.AsTime()
	return &t
}

// TimestampToTimePtr converts *timestamppb.Timestamp to *time.Time.
func TimestampToTimePtr(ts *timestamppb.Timestamp) *time.Time {
	return ToTimePtr(ts)
}

// TimestampToTime converts *timestamppb.Timestamp to time.Time.
func TimestampToTime(ts *timestamppb.Timestamp) time.Time {
	if ts == nil {
		return time.Time{}
	}
	return ts.AsTime()
}

// TimestampToPtr converts time.Time to *timestamppb.Timestamp.
func TimestampToPtr(t time.Time) *timestamppb.Timestamp {
	return timestamppb.New(t)
}

// StringToDecimal converts string to decimal.Decimal. Returns zero on parse failure.
func StringToDecimal(s string) decimal.Decimal {
	d, _ := decimal.NewFromString(s)
	return d
}

// ToDecimal converts string to decimal.Decimal. Alias for StringToDecimal.
func ToDecimal(s string) decimal.Decimal {
	return StringToDecimal(s)
}

// DecimalToString converts decimal.Decimal to string.
func DecimalToString(d decimal.Decimal) string {
	return d.String()
}

// ToInt32Ptr converts int32 to *int32. Returns nil for zero.
func ToInt32Ptr(v int32) *int32 {
	if v == 0 {
		return nil
	}
	return &v
}

// PtrToInt32 converts *int32 to int32. Returns 0 if nil.
func PtrToInt32(v *int32) int32 {
	if v == nil {
		return 0
	}
	return *v
}

// ToTime converts *timestamppb.Timestamp to time.Time. Returns zero time if nil.
func ToTime(ts *timestamppb.Timestamp) time.Time {
	if ts == nil {
		return time.Time{}
	}
	return ts.AsTime()
}

// PtrToBool converts *bool to bool. Returns false if nil.
func PtrToBool(b *bool) bool {
	if b == nil {
		return false
	}
	return *b
}

// ToInt32PtrFromString converts string to *int32. Returns nil for empty or invalid.
func ToInt32PtrFromString(s string) *int32 {
	if s == "" {
		return nil
	}
	d, err := decimal.NewFromString(s)
	if err != nil {
		return nil
	}
	v := int32(d.IntPart())
	return &v
}

// PtrToTimestamp converts *time.Time to *timestamppb.Timestamp. Returns nil if nil.
func PtrToTimestamp(t *time.Time) *timestamppb.Timestamp {
	if t == nil {
		return nil
	}
	return timestamppb.New(*t)
}

// FromTimePtr converts *time.Time to *timestamppb.Timestamp. Alias for PtrToTimestamp.
func FromTimePtr(t *time.Time) *timestamppb.Timestamp {
	return PtrToTimestamp(t)
}

// FromInt32Ptr converts *int32 to int32. Returns 0 if nil. Alias for PtrToInt32.
func FromInt32Ptr(v *int32) int32 {
	return PtrToInt32(v)
}

// BytesToMap converts JSON bytes to map[string]interface{}.
func BytesToMap(data []byte) map[string]interface{} {
	if data == nil || len(data) == 0 {
		return nil
	}
	result := make(map[string]interface{})
	if err := json.Unmarshal(data, &result); err != nil {
		return nil
	}
	return result
}

// MapToBytes converts a map to JSON bytes.
func MapToBytes(m map[string]interface{}) ([]byte, error) {
	if m == nil {
		return nil, nil
	}
	return json.Marshal(m)
}
