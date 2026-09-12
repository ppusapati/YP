package featureflags

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"sync"

	"github.com/fsnotify/fsnotify"
	"gopkg.in/yaml.v3"
)

// FlagConfig is the top-level configuration structure for feature flag definitions.
type FlagConfig struct {
	// Flags is the list of feature flag definitions.
	Flags []Flag `json:"flags" yaml:"flags"`
}

// Validate checks the flag configuration for errors.
func (c *FlagConfig) Validate() error {
	seen := make(map[string]struct{}, len(c.Flags))
	for i, f := range c.Flags {
		if f.Name == "" {
			return fmt.Errorf("featureflags: flag at index %d has empty name", i)
		}
		if _, exists := seen[f.Name]; exists {
			return fmt.Errorf("featureflags: duplicate flag name %q", f.Name)
		}
		seen[f.Name] = struct{}{}

		switch f.Type {
		case FlagTypeBoolean, FlagTypeKillSwitch:
			// No additional validation required.
		case FlagTypePercentage:
			if f.RolloutPercentage < 0 || f.RolloutPercentage > 100 {
				return fmt.Errorf("featureflags: flag %q has invalid rollout_percentage %d (must be 0-100)", f.Name, f.RolloutPercentage)
			}
		case FlagTypeMultivariate:
			if len(f.Variants) == 0 {
				return fmt.Errorf("featureflags: multivariate flag %q has no variants", f.Name)
			}
			variantKeys := make(map[string]struct{}, len(f.Variants))
			for _, v := range f.Variants {
				if v.Key == "" {
					return fmt.Errorf("featureflags: flag %q has a variant with empty key", f.Name)
				}
				if _, exists := variantKeys[v.Key]; exists {
					return fmt.Errorf("featureflags: flag %q has duplicate variant key %q", f.Name, v.Key)
				}
				variantKeys[v.Key] = struct{}{}
			}
		case "":
			return fmt.Errorf("featureflags: flag %q has empty type", f.Name)
		default:
			return fmt.Errorf("featureflags: flag %q has unknown type %q", f.Name, f.Type)
		}

		for j, rule := range f.TargetingRules {
			if rule.Attribute == "" {
				return fmt.Errorf("featureflags: flag %q targeting rule %d has empty attribute", f.Name, j)
			}
			switch rule.Operator {
			case "eq", "neq", "in", "not_in", "contains":
				// Valid operators.
			default:
				return fmt.Errorf("featureflags: flag %q targeting rule %d has unknown operator %q", f.Name, j, rule.Operator)
			}
			if len(rule.Values) == 0 {
				return fmt.Errorf("featureflags: flag %q targeting rule %d has no values", f.Name, j)
			}
		}
	}
	return nil
}

// LoadFlags loads a flag configuration from the given file path. The file
// format is detected from the extension (.json, .yaml, .yml).
func LoadFlags(path string) (*FlagConfig, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("featureflags: read config %s: %w", path, err)
	}

	return ParseFlags(data, path)
}

// ParseFlags parses flag configuration from raw bytes. The path is used only
// to determine the format from its extension.
func ParseFlags(data []byte, path string) (*FlagConfig, error) {
	var config FlagConfig
	ext := strings.ToLower(filepath.Ext(path))

	switch ext {
	case ".json":
		if err := json.Unmarshal(data, &config); err != nil {
			return nil, fmt.Errorf("featureflags: parse JSON from %s: %w", path, err)
		}
	case ".yaml", ".yml":
		if err := yaml.Unmarshal(data, &config); err != nil {
			return nil, fmt.Errorf("featureflags: parse YAML from %s: %w", path, err)
		}
	default:
		return nil, fmt.Errorf("featureflags: unsupported config format %q (use .json, .yaml, or .yml)", ext)
	}

	if err := config.Validate(); err != nil {
		return nil, err
	}

	return &config, nil
}

// LoadFlagsFromEnv loads flag overrides from environment variables. Environment
// variables follow the pattern FF_<FLAG_NAME>=<enabled|disabled>. For example,
// FF_ML_MODEL_V2=enabled enables the ml_model_v2 flag. This is intended to
// overlay on top of file-based configuration.
func LoadFlagsFromEnv(config *FlagConfig) {
	flagsByName := make(map[string]*Flag, len(config.Flags))
	for i := range config.Flags {
		flagsByName[config.Flags[i].Name] = &config.Flags[i]
	}

	for _, env := range os.Environ() {
		if !strings.HasPrefix(env, "FF_") {
			continue
		}
		parts := strings.SplitN(env, "=", 2)
		if len(parts) != 2 {
			continue
		}
		// Convert FF_MY_FLAG to my_flag.
		flagName := strings.ToLower(strings.TrimPrefix(parts[0], "FF_"))
		value := strings.ToLower(parts[1])

		if f, ok := flagsByName[flagName]; ok {
			switch value {
			case "enabled", "true", "1", "on":
				f.Enabled = true
			case "disabled", "false", "0", "off":
				f.Enabled = false
			}
		}
	}
}

// FileWatcher watches a flag configuration file for changes and reloads flags
// into the InMemoryFlagService when the file is modified.
type FileWatcher struct {
	mu       sync.Mutex
	path     string
	service  *InMemoryFlagService
	watcher  *fsnotify.Watcher
	stopCh   chan struct{}
	onChange func(flags []Flag) // optional callback after reload
}

// FileWatcherOption configures the FileWatcher.
type FileWatcherOption func(*FileWatcher)

// WithOnChange sets a callback that is invoked after a successful reload.
func WithOnChange(fn func(flags []Flag)) FileWatcherOption {
	return func(w *FileWatcher) {
		w.onChange = fn
	}
}

// NewFileWatcher creates a new file watcher that reloads flags into the
// provided service when the configuration file changes.
func NewFileWatcher(path string, service *InMemoryFlagService, opts ...FileWatcherOption) (*FileWatcher, error) {
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		return nil, fmt.Errorf("featureflags: create file watcher: %w", err)
	}

	fw := &FileWatcher{
		path:    path,
		service: service,
		watcher: watcher,
		stopCh:  make(chan struct{}),
	}
	for _, opt := range opts {
		opt(fw)
	}

	// Watch the directory containing the file, not the file itself, because
	// many editors perform atomic saves by writing to a temporary file and
	// renaming, which removes the original inode.
	dir := filepath.Dir(path)
	if err := watcher.Add(dir); err != nil {
		watcher.Close()
		return nil, fmt.Errorf("featureflags: watch directory %s: %w", dir, err)
	}

	go fw.run()

	return fw, nil
}

// run processes file system events in a loop.
func (fw *FileWatcher) run() {
	for {
		select {
		case event, ok := <-fw.watcher.Events:
			if !ok {
				return
			}
			// Only react to writes and creates for the target file.
			if filepath.Clean(event.Name) != filepath.Clean(fw.path) {
				continue
			}
			if event.Op&(fsnotify.Write|fsnotify.Create) == 0 {
				continue
			}
			fw.reload()
		case _, ok := <-fw.watcher.Errors:
			if !ok {
				return
			}
			// Errors are logged but do not stop the watcher.
		case <-fw.stopCh:
			return
		}
	}
}

// reload reads the config file and updates the flag service.
func (fw *FileWatcher) reload() {
	fw.mu.Lock()
	defer fw.mu.Unlock()

	config, err := LoadFlags(fw.path)
	if err != nil {
		// Silently ignore reload errors to avoid breaking on partial writes.
		return
	}

	LoadFlagsFromEnv(config)
	fw.service.ReplaceAll(config.Flags)

	if fw.onChange != nil {
		fw.onChange(config.Flags)
	}
}

// Stop stops the file watcher and releases resources.
func (fw *FileWatcher) Stop() error {
	close(fw.stopCh)
	return fw.watcher.Close()
}
