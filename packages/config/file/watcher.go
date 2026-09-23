package file

import (
	"context"
	"os"
	"path/filepath"

	"github.com/fsnotify/fsnotify"

	"p9e.in/samavaya/packages/config"
)

var _ config.Watcher = (*watcher)(nil)

// watcher reports a file source's contents whenever the file changes.
//
// The whole of this file used to be commented out, behind a `newWatcher` in
// file.go that returned "not implemented" — so `config.Watch(key, observer)`
// stored the observer and nothing ever called it. A caller registering a
// callback got no error and no callback.
type watcher struct {
	f  *file
	fw *fsnotify.Watcher

	ctx    context.Context
	cancel context.CancelFunc
}

func newWatcher(f *file) (config.Watcher, error) {
	fw, err := fsnotify.NewWatcher()
	if err != nil {
		return nil, err
	}

	// Watch the directory rather than the file.
	//
	// fsnotify follows the inode, not the path. Almost every editor and every
	// config-management tool — Kubernetes ConfigMap projection included —
	// replaces a file by writing a new one and renaming it over the old,
	// which leaves the watch attached to an inode nothing will ever write to
	// again. The first change is then reported and no change after it ever is,
	// which is worse than not watching at all: it looks like it works.
	//
	// Watching the containing directory survives that, because the directory's
	// inode does not change.
	target := f.path
	fi, err := os.Stat(target)
	if err != nil {
		fw.Close()
		return nil, err
	}
	if !fi.IsDir() {
		target = filepath.Dir(target)
	}
	if err := fw.Add(target); err != nil {
		fw.Close()
		return nil, err
	}

	ctx, cancel := context.WithCancel(context.Background())
	return &watcher{f: f, fw: fw, ctx: ctx, cancel: cancel}, nil
}

// Next blocks until the watched file changes, then returns its new contents.
//
// It returns ctx.Err() after Stop, which is how config.watch knows to end its
// goroutine rather than log and retry for ever.
func (w *watcher) Next() ([]*config.KeyValue, error) {
	for {
		select {
		case <-w.ctx.Done():
			return nil, w.ctx.Err()

		case event, ok := <-w.fw.Events:
			if !ok {
				return nil, context.Canceled
			}

			// Op is a bitmask, so it has to be tested with Has rather than
			// compared. A rename arrives as Rename|Create on some platforms
			// and an equality check misses it — which is exactly the write
			// pattern this watcher exists to catch.
			if !event.Has(fsnotify.Write) && !event.Has(fsnotify.Create) &&
				!event.Has(fsnotify.Rename) {
				continue
			}

			// Watching a directory means hearing about every file in it. A
			// source pointed at one file only cares about that file.
			if !w.relevant(event.Name) {
				continue
			}

			kvs, err := w.f.Load()
			if err != nil {
				// A rename in progress can leave the path momentarily absent.
				// Waiting for the next event is better than reporting an
				// error the caller can only log, because another event is
				// already on its way.
				if os.IsNotExist(err) {
					continue
				}
				return nil, err
			}
			return kvs, nil

		case err, ok := <-w.fw.Errors:
			if !ok {
				return nil, context.Canceled
			}
			return nil, err
		}
	}
}

// relevant reports whether an event about name concerns this source.
func (w *watcher) relevant(name string) bool {
	fi, err := os.Stat(w.f.path)
	if err != nil {
		// The source path itself is gone; let Load decide what that means.
		return true
	}
	if fi.IsDir() {
		// A directory source loads every file in it, so any of them matters —
		// except the hidden ones Load skips.
		return !isHidden(filepath.Base(name))
	}
	return filepath.Clean(name) == filepath.Clean(w.f.path)
}

func isHidden(base string) bool {
	return len(base) > 0 && base[0] == '.'
}

func (w *watcher) Stop() error {
	w.cancel()
	return w.fw.Close()
}
