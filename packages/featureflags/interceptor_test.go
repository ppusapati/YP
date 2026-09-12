package featureflags

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"

	"p9e.in/samavaya/packages/p9context"
)

func TestWithFlagService_FromContext(t *testing.T) {
	svc := NewInMemoryFlagService()
	svc.SetFlag(Flag{Name: "test", Type: FlagTypeBoolean, Enabled: true})

	ctx := WithFlagService(context.Background(), svc)
	got := FromContext(ctx)

	assert.NotNil(t, got)
	assert.True(t, got.IsEnabled(ctx, "test", Attributes{}))
}

func TestFromContext_NoService(t *testing.T) {
	ctx := context.Background()
	got := FromContext(ctx)
	assert.Nil(t, got)
}

func TestIsEnabledFromContext(t *testing.T) {
	svc := NewInMemoryFlagService()
	svc.SetFlag(Flag{Name: "ctx_flag", Type: FlagTypeBoolean, Enabled: true})

	ctx := WithFlagService(context.Background(), svc)
	ctx = context.WithValue(ctx, flagAttributesContextKey{}, Attributes{"user_id": "u1"})

	assert.True(t, IsEnabledFromContext(ctx, "ctx_flag"))
	assert.False(t, IsEnabledFromContext(ctx, "nonexistent"))
}

func TestIsEnabledFromContext_NoService(t *testing.T) {
	ctx := context.Background()
	assert.False(t, IsEnabledFromContext(ctx, "any_flag"))
}

func TestGetVariantFromContext(t *testing.T) {
	svc := NewInMemoryFlagService()
	svc.SetFlag(Flag{
		Name:    "multi",
		Type:    FlagTypeMultivariate,
		Enabled: true,
		Variants: []Variant{
			{Key: "a", Weight: 100},
		},
	})

	ctx := WithFlagService(context.Background(), svc)
	ctx = context.WithValue(ctx, flagAttributesContextKey{}, Attributes{"user_id": "u1"})

	result := GetVariantFromContext(ctx, "multi")
	assert.True(t, result.Enabled)
	assert.Equal(t, "a", result.VariantKey)
}

func TestGetVariantFromContext_NoService(t *testing.T) {
	result := GetVariantFromContext(context.Background(), "any")
	assert.False(t, result.Enabled)
	assert.Equal(t, "no_flag_service_in_context", result.Reason)
}

func TestContextAttributes(t *testing.T) {
	attrs := Attributes{"key": "value"}
	ctx := context.WithValue(context.Background(), flagAttributesContextKey{}, attrs)

	got := ContextAttributes(ctx)
	assert.Equal(t, "value", got["key"])
}

func TestContextAttributes_None(t *testing.T) {
	attrs := ContextAttributes(context.Background())
	assert.Nil(t, attrs)
}

func TestExtractAttributes_WithUserContext(t *testing.T) {
	ctx := p9context.NewUserContext(context.Background(), p9context.UserContext{
		UserID:    "user_42",
		TenantID:  "tenant_1",
		CompanyID: "company_1",
		BranchID:  "branch_1",
		Role:      "admin",
	})

	attrs := extractAttributes(ctx)

	assert.Equal(t, "user_42", attrs["user_id"])
	assert.Equal(t, "tenant_1", attrs["tenant_id"])
	assert.Equal(t, "company_1", attrs["company_id"])
	assert.Equal(t, "branch_1", attrs["branch_id"])
	assert.Equal(t, "admin", attrs["user_role"])
}

func TestExtractAttributes_EmptyContext(t *testing.T) {
	attrs := extractAttributes(context.Background())
	assert.Empty(t, attrs)
}

func TestExtractAttributes_PartialUserContext(t *testing.T) {
	ctx := p9context.NewUserContext(context.Background(), p9context.UserContext{
		UserID:   "user_42",
		TenantID: "tenant_1",
	})

	attrs := extractAttributes(ctx)

	assert.Equal(t, "user_42", attrs["user_id"])
	assert.Equal(t, "tenant_1", attrs["tenant_id"])
	_, hasCompany := attrs["company_id"]
	assert.False(t, hasCompany)
}
