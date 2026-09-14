package featureflags

import (
	"encoding/json"
	"fmt"

	"gopkg.in/yaml.v3"
)

// On-disk shapes for flag configuration.
//
// The types in flags.go are what evaluation works with. These are what people
// actually write, which is not the same thing:
//
//   - A map keyed by flag name reads better than a list of objects each
//     repeating `name:`, and both spellings are accepted here.
//   - `type` can be left out. A flag with variants is multivariate, one with
//     `kill_switch: true` is a kill switch, one with a rollout percentage is a
//     percentage rollout, and anything else is boolean. Requiring the author to
//     restate what the shape already says is a way of collecting typos.
//   - `targeting` and `targeting_rules` mean the same thing; a variant's
//     identifier may be `key` or `name`.
//
// This forgiveness is not decorative. The configuration shipped in
// configs/feature-flags.yaml was written in the map shape, without `type`,
// using `targeting` and variant `name` — and so could not be loaded at all.
// A feature-flag file that silently fails to parse is worse than no file,
// because the flags then evaluate as "not found", which reads as "off", which
// looks exactly like a deliberate decision.

// rawVariant accepts either spelling of a variant's identifier.
type rawVariant struct {
	Key         string                 `json:"key" yaml:"key"`
	Name        string                 `json:"name" yaml:"name"`
	Description string                 `json:"description" yaml:"description"`
	Weight      int                    `json:"weight" yaml:"weight"`
	Payload     map[string]interface{} `json:"payload" yaml:"payload"`
}

func (r rawVariant) variant() Variant {
	key := r.Key
	if key == "" {
		key = r.Name
	}
	return Variant{
		Key:         key,
		Description: r.Description,
		Weight:      r.Weight,
		Payload:     r.Payload,
	}
}

// rawFlag is one flag as written in a configuration file.
type rawFlag struct {
	Name              string          `json:"name" yaml:"name"`
	Description       string          `json:"description" yaml:"description"`
	Type              FlagType        `json:"type" yaml:"type"`
	Enabled           bool            `json:"enabled" yaml:"enabled"`
	RolloutPercentage int             `json:"rollout_percentage" yaml:"rollout_percentage"`
	Variants          []rawVariant    `json:"variants" yaml:"variants"`
	TargetingRules    []TargetingRule `json:"targeting_rules" yaml:"targeting_rules"`
	Targeting         []TargetingRule `json:"targeting" yaml:"targeting"`
	KillSwitch        bool            `json:"kill_switch" yaml:"kill_switch"`
	DefaultVariant    string          `json:"default_variant" yaml:"default_variant"`
	Tags              []string        `json:"tags" yaml:"tags"`

	// Tenants pins the flag for named tenants regardless of rollout or
	// targeting. See tenant.go for why this cannot be expressed with a
	// targeting rule.
	//
	// `tenants` keys by tenant id, which is the readable form. Flag itself
	// serialises the same thing as a `tenant_overrides` list, so that spelling
	// is accepted too — otherwise a config round-tripped through the Go type
	// would silently lose every override on the way back in.
	Tenants         map[string]rawTenantOverride `json:"tenants" yaml:"tenants"`
	TenantOverrides []TenantOverride             `json:"tenant_overrides" yaml:"tenant_overrides"`
}

// flag converts the on-disk shape into the evaluated one, inferring whatever
// was left implicit.
func (r rawFlag) flag() Flag {
	variants := make([]Variant, 0, len(r.Variants))
	for _, v := range r.Variants {
		variants = append(variants, v.variant())
	}

	rules := r.TargetingRules
	if len(rules) == 0 {
		rules = r.Targeting
	}

	typ := r.Type
	if typ == "" {
		switch {
		case r.KillSwitch:
			typ = FlagTypeKillSwitch
		case len(variants) > 0:
			typ = FlagTypeMultivariate
		case r.RolloutPercentage > 0:
			typ = FlagTypePercentage
		default:
			typ = FlagTypeBoolean
		}
	}

	f := Flag{
		Name:              r.Name,
		Description:       r.Description,
		Type:              typ,
		Enabled:           r.Enabled,
		RolloutPercentage: r.RolloutPercentage,
		Variants:          variants,
		TargetingRules:    rules,
		DefaultVariant:    r.DefaultVariant,
		Tags:              r.Tags,
	}

	for _, o := range r.TenantOverrides {
		if o.FlagName == "" {
			o.FlagName = r.Name
		}
		f.TenantOverrides = append(f.TenantOverrides, o)
	}
	for tenantID, o := range r.Tenants {
		f.TenantOverrides = append(f.TenantOverrides, o.override(tenantID, r.Name))
	}
	sortOverrides(f.TenantOverrides)
	return f
}

// rawFlagSet accepts a flag collection written either as a list or as a map
// keyed by flag name.
type rawFlagSet []rawFlag

// UnmarshalYAML accepts both shapes.
func (s *rawFlagSet) UnmarshalYAML(node *yaml.Node) error {
	switch node.Kind {
	case yaml.SequenceNode:
		var list []rawFlag
		if err := node.Decode(&list); err != nil {
			return err
		}
		*s = list
		return nil

	case yaml.MappingNode:
		// Decoded pairwise rather than into a map so that the declaration
		// order in the file survives; a map would reorder them and make the
		// diff of a generated listing churn for no reason.
		if len(node.Content)%2 != 0 {
			return fmt.Errorf("featureflags: malformed flag mapping")
		}
		list := make([]rawFlag, 0, len(node.Content)/2)
		for i := 0; i < len(node.Content); i += 2 {
			var name string
			if err := node.Content[i].Decode(&name); err != nil {
				return fmt.Errorf("featureflags: flag name at index %d: %w", i/2, err)
			}
			var f rawFlag
			if err := node.Content[i+1].Decode(&f); err != nil {
				return fmt.Errorf("featureflags: flag %q: %w", name, err)
			}
			if f.Name == "" {
				f.Name = name
			}
			list = append(list, f)
		}
		*s = list
		return nil

	default:
		return fmt.Errorf("featureflags: flags must be a list or a map, got %v", node.Kind)
	}
}

// UnmarshalJSON accepts both shapes.
func (s *rawFlagSet) UnmarshalJSON(data []byte) error {
	var list []rawFlag
	if err := json.Unmarshal(data, &list); err == nil {
		*s = list
		return nil
	}

	var byName map[string]rawFlag
	if err := json.Unmarshal(data, &byName); err != nil {
		return fmt.Errorf("featureflags: flags must be a list or an object: %w", err)
	}
	// JSON objects have no defined order, so this is sorted by name to keep
	// repeated loads of the same file identical.
	names := make([]string, 0, len(byName))
	for name := range byName {
		names = append(names, name)
	}
	sortStrings(names)

	list = make([]rawFlag, 0, len(byName))
	for _, name := range names {
		f := byName[name]
		if f.Name == "" {
			f.Name = name
		}
		list = append(list, f)
	}
	*s = list
	return nil
}

// rawConfig is the top level of a configuration file.
type rawConfig struct {
	Flags rawFlagSet `json:"flags" yaml:"flags"`
}

func (r rawConfig) config() *FlagConfig {
	flags := make([]Flag, 0, len(r.Flags))
	for _, f := range r.Flags {
		flags = append(flags, f.flag())
	}
	return &FlagConfig{Flags: flags}
}
