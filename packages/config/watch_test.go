package config_test

import (
	"os"
	"path/filepath"
	"testing"
	"time"

	"p9e.in/samavaya/packages/config"
	"p9e.in/samavaya/packages/config/file"
)

// These exercise the real thing: a real file on disk, a real fsnotify watcher
// and a real observer callback. A fake source would not have caught either of
// the defects below, both of which live in the gap between the API and the
// filesystem.
//
// Before this, config.Watch(key, observer) stored the observer and returned
// nil, the file source's Watch returned "not implemented", and Load never
// called it. A caller registering a callback got no error and no callback.

const settleTimeout = 5 * time.Second

func writeConfig(t *testing.T, path, body string) {
	t.Helper()
	if err := os.WriteFile(path, []byte(body), 0o600); err != nil {
		t.Fatalf("write %s: %v", path, err)
	}
}

// loadedConfig returns a config over a single JSON file in a fresh temp dir.
func loadedConfig(t *testing.T, body string) (config.Config, string) {
	t.Helper()

	dir := t.TempDir()
	path := filepath.Join(dir, "config.json")
	writeConfig(t, path, body)

	c := config.New(config.WithSource(file.NewSource(path)))
	if err := c.Load(); err != nil {
		t.Fatalf("Load: %v", err)
	}
	t.Cleanup(func() { _ = c.Close() })

	return c, path
}

// observe registers an observer and returns a channel carrying the values it
// is called with.
//
// Buffered, because the observer runs on the watch goroutine: an unbuffered
// send would block that goroutine if a test stopped reading, and a blocked
// watch goroutine would then hang Close.
func observe(t *testing.T, c config.Config, key string) <-chan string {
	t.Helper()

	got := make(chan string, 8)
	err := c.Watch(key, func(k string, v config.Value) {
		s, err := v.String()
		if err != nil {
			t.Errorf("observer got a non-string for %q: %v", k, err)
			return
		}
		got <- s
	})
	if err != nil {
		t.Fatalf("Watch(%q): %v", key, err)
	}
	return got
}

func awaitValue(t *testing.T, got <-chan string, want string) {
	t.Helper()

	deadline := time.After(settleTimeout)
	for {
		select {
		case v := <-got:
			if v == want {
				return
			}
			// Not the value we are waiting for yet. A single save can produce
			// several filesystem events, so intermediate notifications are
			// normal rather than a failure.
			t.Logf("observer saw %q, still waiting for %q", v, want)
		case <-deadline:
			t.Fatalf("no observer call with %q within %s", want, settleTimeout)
		}
	}
}

// The point of the whole package: changing the file calls the observer.
func TestObserverFiresWhenTheFileChanges(t *testing.T) {
	c, path := loadedConfig(t, `{"greeting":"hello"}`)
	got := observe(t, c, "greeting")

	writeConfig(t, path, `{"greeting":"goodbye"}`)

	awaitValue(t, got, "goodbye")
}

// An atomic replace — write a temporary file, rename it over the target — must
// be picked up.
//
// This is the case worth having a test for. fsnotify follows the inode, not
// the path, so a watch added on the file itself stays attached to the old
// inode after a rename and never reports anything again. Every editor that
// saves safely does this, and so does a Kubernetes ConfigMap update. The
// failure is silent and it is the second change that disappears, not the
// first, so a test that only writes in place would pass against the broken
// version.
func TestObserverSurvivesAnAtomicReplace(t *testing.T) {
	c, path := loadedConfig(t, `{"greeting":"hello"}`)
	got := observe(t, c, "greeting")

	// First change in place, so the watch is known to be working before the
	// rename is the thing under test.
	writeConfig(t, path, `{"greeting":"first"}`)
	awaitValue(t, got, "first")

	tmp := path + ".tmp"
	writeConfig(t, tmp, `{"greeting":"replaced"}`)
	if err := os.Rename(tmp, path); err != nil {
		t.Fatalf("rename: %v", err)
	}

	awaitValue(t, got, "replaced")
}

// A second change must arrive too. One notification and then silence is the
// signature of a watch left on a dead inode.
func TestSuccessiveChangesAreAllReported(t *testing.T) {
	c, path := loadedConfig(t, `{"greeting":"hello"}`)
	got := observe(t, c, "greeting")

	for _, want := range []string{"one", "two", "three"} {
		writeConfig(t, path, `{"greeting":"`+want+`"}`)
		awaitValue(t, got, want)
	}
}

// Value reflects the new contents even with no observer registered. The
// observer is a notification; the stored value is the config.
func TestValueIsUpdatedWithoutAnObserver(t *testing.T) {
	c, path := loadedConfig(t, `{"greeting":"hello"}`)

	// Read it once so the key is cached — that is the path the watch loop
	// refreshes.
	if v, err := c.Value("greeting").String(); err != nil || v != "hello" {
		t.Fatalf("initial Value = %q, %v", v, err)
	}

	writeConfig(t, path, `{"greeting":"goodbye"}`)

	deadline := time.After(settleTimeout)
	for {
		if v, _ := c.Value("greeting").String(); v == "goodbye" {
			return
		}
		select {
		case <-deadline:
			v, _ := c.Value("greeting").String()
			t.Fatalf("Value stayed %q after the file changed", v)
		case <-time.After(20 * time.Millisecond):
		}
	}
}

// Close stops the watcher, so later changes do not fire the observer.
//
// Without this the goroutine outlives the config and keeps a file descriptor:
// a process that reloads config, or a test suite that builds one per case,
// runs out of them.
func TestCloseStopsTheWatcher(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "config.json")
	writeConfig(t, path, `{"greeting":"hello"}`)

	c := config.New(config.WithSource(file.NewSource(path)))
	if err := c.Load(); err != nil {
		t.Fatalf("Load: %v", err)
	}
	got := observe(t, c, "greeting")

	// Prove the watch is live before closing it, so that a pass here cannot
	// come from the watch never having worked.
	writeConfig(t, path, `{"greeting":"before-close"}`)
	awaitValue(t, got, "before-close")

	if err := c.Close(); err != nil {
		t.Fatalf("Close: %v", err)
	}

	// Drain anything already queued from before the close.
	for len(got) > 0 {
		<-got
	}

	writeConfig(t, path, `{"greeting":"after-close"}`)

	select {
	case v := <-got:
		t.Errorf("observer fired with %q after Close", v)
	case <-time.After(500 * time.Millisecond):
	}
}

// Close is safe to call twice: the second call finds no watchers rather than
// stopping a closed one.
func TestCloseIsIdempotent(t *testing.T) {
	c, _ := loadedConfig(t, `{"greeting":"hello"}`)

	if err := c.Close(); err != nil {
		t.Fatalf("first Close: %v", err)
	}
	if err := c.Close(); err != nil {
		t.Errorf("second Close: %v", err)
	}
}

// Watching a directory picks up a change to any file in it.
func TestADirectorySourceIsWatched(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "config.json")
	writeConfig(t, path, `{"greeting":"hello"}`)

	c := config.New(config.WithSource(file.NewSource(dir)))
	if err := c.Load(); err != nil {
		t.Fatalf("Load: %v", err)
	}
	t.Cleanup(func() { _ = c.Close() })

	got := observe(t, c, "greeting")
	writeConfig(t, path, `{"greeting":"goodbye"}`)
	awaitValue(t, got, "goodbye")
}

// Watch on a key that does not exist reports it rather than storing an
// observer that can never fire.
func TestWatchingAnAbsentKeyIsAnError(t *testing.T) {
	c, _ := loadedConfig(t, `{"greeting":"hello"}`)

	if err := c.Watch("nope", func(string, config.Value) {}); err == nil {
		t.Error("Watch on an unknown key returned nil")
	}
}
