package config

import (
	"context"
	"errors"
	"reflect"
	"sync"
	"time"

	"google.golang.org/grpc/keepalive"

	// init encoding
	"p9e.in/samavaya/packages/database/pgxpostgres"
	_ "p9e.in/samavaya/packages/encoding/json"
	_ "p9e.in/samavaya/packages/encoding/proto"
	_ "p9e.in/samavaya/packages/encoding/xml"
	_ "p9e.in/samavaya/packages/encoding/yaml"
	"p9e.in/samavaya/packages/p9log"
)

var _ Config = (*config)(nil)

var (
	// ErrNotFound is key not found.
	ErrNotFound = errors.New("key not found")
	// ErrTypeAssert is type assert error.
	ErrTypeAssert = errors.New("type assert error")
)

// Observer is config observer.
type Observer func(string, Value)

// Config is a config interface.
type Config interface {
	Load() error
	Scan(v interface{}) error
	Value(key string) Value
	Watch(key string, o Observer) error
	Close() error
}

type config struct {
	opts      options
	reader    Reader
	cached    sync.Map
	observers sync.Map

	// watchers are the per-source watchers started by Load, held so that
	// Close can stop them. Guarded because Close may be called from a
	// different goroutine than Load.
	mu       sync.Mutex
	watchers []Watcher
}

type GrpcServerConfig struct {
	Port            uint32
	KeepaliveParams keepalive.ServerParameters
	KeepalivePolicy keepalive.EnforcementPolicy
	DBContext       *pgxpostgres.DBContext
}

// New a config with options.
func New(opts ...Option) Config {
	o := options{
		decoder:  defaultDecoder,
		resolver: defaultResolver,
	}
	for _, opt := range opts {
		opt(&o)
	}
	return &config{
		opts:   o,
		reader: newReader(o),
	}
}

func (c *config) watch(w Watcher) {
	for {
		kvs, err := w.Next()
		if err != nil {
			if errors.Is(err, context.Canceled) {
				p9log.Infof("config watcher stopped: %v", err)
				return
			}
			// Logged before the pause, not after: this used to sleep first,
			// which delayed every report of a watch failure by a second for
			// no benefit. The pause is here so that a source failing
			// repeatedly does not spin.
			p9log.Errorf("failed to watch next config: %v", err)
			time.Sleep(time.Second)
			continue
		}
		if err := c.reader.Merge(kvs...); err != nil {
			p9log.Errorf("failed to merge next config: %v", err)
			continue
		}
		if err := c.reader.Resolve(); err != nil {
			p9log.Errorf("failed to resolve next config: %v", err)
			continue
		}
		c.cached.Range(func(key, value interface{}) bool {
			k := key.(string)
			v := value.(Value)
			if n, ok := c.reader.Value(k); ok && reflect.TypeOf(n.Load()) == reflect.TypeOf(v.Load()) && !reflect.DeepEqual(n.Load(), v.Load()) {
				v.Store(n.Load())
				if o, ok := c.observers.Load(k); ok {
					o.(Observer)(k, v)
				}
			}
			return true
		})
	}
}

func (c *config) Load() error {
	for _, src := range c.opts.sources {
		kvs, err := src.Load()
		if err != nil {
			return err
		}
		for _, v := range kvs {
			p9log.Debugf("config loaded: %s format: %s", v.Key, v.Format)
		}
		if err = c.reader.Merge(kvs...); err != nil {
			p9log.Errorf("failed to merge config source: %v", err)
			return err
		}

		// A source that cannot be watched is not a reason to fail Load.
		//
		// The config is already loaded and correct at this point; watching is
		// the extra that keeps it current. Returning an error here would take
		// a service that can run with static config and stop it from starting
		// at all — on a platform with no inotify, say, or with the descriptor
		// limit reached. Logged at warning so the degradation is visible
		// rather than assumed.
		w, err := src.Watch()
		if err != nil {
			p9log.Warnf("config source will not be watched, so changes to it "+
				"will not be picked up: %v", err)
			continue
		}
		c.mu.Lock()
		c.watchers = append(c.watchers, w)
		c.mu.Unlock()
		go c.watch(w)
	}
	if err := c.reader.Resolve(); err != nil {
		p9log.Errorf("failed to resolve config source: %v", err)
		return err
	}
	return nil
}

func (c *config) Value(key string) Value {
	if v, ok := c.cached.Load(key); ok {
		return v.(Value)
	}
	if v, ok := c.reader.Value(key); ok {
		c.cached.Store(key, v)
		return v
	}
	return &errValue{err: ErrNotFound}
}

func (c *config) Scan(v interface{}) error {
	data, err := c.reader.Source()
	if err != nil {
		return err
	}
	return unmarshalJSON(data, v)
}

func (c *config) Watch(key string, o Observer) error {
	if v := c.Value(key); v.Load() == nil {
		return ErrNotFound
	}
	c.observers.Store(key, o)
	return nil
}

// Close stops every watcher Load started.
//
// Each watcher's Next then returns a cancelled context, which is how the
// goroutines in watch end. Every watcher is stopped even if one fails, and the
// first failure is returned: leaving the rest running because an earlier one
// errored is how a test suite or a repeatedly-reloaded process runs out of
// file descriptors.
func (c *config) Close() error {
	c.mu.Lock()
	watchers := c.watchers
	c.watchers = nil
	c.mu.Unlock()

	var firstErr error
	for _, w := range watchers {
		if err := w.Stop(); err != nil && firstErr == nil {
			firstErr = err
		}
	}
	return firstErr
}
