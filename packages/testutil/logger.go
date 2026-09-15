package testutil

import (
	"sync"

	"p9e.in/samavaya/packages/p9log"
)

// Loggers for tests.
//
// These exist in one place because the alternative already failed. Every
// service test package had defined its own two-line `nopLogger` implementing
// only `Log`. When p9log.Logger gained Debug, Info, Warn and Error, all of them
// stopped satisfying the interface at once — and because the breakage is in a
// _test.go file, nothing that builds the services noticed. Seventeen test
// packages stopped compiling, and therefore stopped running, while `go test
// ./...` reported "[build failed]" in a wall of output nobody was reading.
//
// A shared implementation means the next widening of the interface is one edit
// rather than seventeen, and a compile error in code that is actually built.

// NopLogger discards everything. It satisfies p9log.Logger and is the right
// choice for a test that does not care what was logged.
type NopLogger struct{}

// Log discards the entry.
func (NopLogger) Log(_ p9log.Level, _ ...interface{}) error { return nil }

// Debug discards the entry.
func (NopLogger) Debug(_ ...interface{}) {}

// Info discards the entry.
func (NopLogger) Info(_ ...interface{}) {}

// Warn discards the entry.
func (NopLogger) Warn(_ ...interface{}) {}

// Error discards the entry.
func (NopLogger) Error(_ ...interface{}) {}

// Compile-time proof. Without this, a future widening of p9log.Logger would
// again be caught only by whichever test happened to pass a logger somewhere.
var _ p9log.Logger = NopLogger{}

// LogEntry is one captured log line.
type LogEntry struct {
	Level   p9log.Level
	Keyvals []interface{}
}

// RecordingLogger keeps what was logged, for the tests where the logging is
// the behaviour under test — that an error was reported rather than swallowed,
// say. Safe for concurrent use, because handlers under test often log from more
// than one goroutine and a plain slice append would make such a test flaky
// under -race for reasons unrelated to the code.
type RecordingLogger struct {
	mu      sync.Mutex
	entries []LogEntry
}

// NewRecordingLogger returns an empty recording logger.
func NewRecordingLogger() *RecordingLogger { return &RecordingLogger{} }

// Log records the entry.
func (l *RecordingLogger) Log(level p9log.Level, keyvals ...interface{}) error {
	l.mu.Lock()
	defer l.mu.Unlock()
	l.entries = append(l.entries, LogEntry{Level: level, Keyvals: keyvals})
	return nil
}

// Debug records at debug level.
func (l *RecordingLogger) Debug(keyvals ...interface{}) { _ = l.Log(p9log.LevelDebug, keyvals...) }

// Info records at info level.
func (l *RecordingLogger) Info(keyvals ...interface{}) { _ = l.Log(p9log.LevelInfo, keyvals...) }

// Warn records at warn level.
func (l *RecordingLogger) Warn(keyvals ...interface{}) { _ = l.Log(p9log.LevelWarn, keyvals...) }

// Error records at error level.
func (l *RecordingLogger) Error(keyvals ...interface{}) { _ = l.Log(p9log.LevelError, keyvals...) }

// Entries returns a copy of everything logged so far.
func (l *RecordingLogger) Entries() []LogEntry {
	l.mu.Lock()
	defer l.mu.Unlock()
	out := make([]LogEntry, len(l.entries))
	copy(out, l.entries)
	return out
}

// Reset discards everything logged so far.
func (l *RecordingLogger) Reset() {
	l.mu.Lock()
	defer l.mu.Unlock()
	l.entries = nil
}

var _ p9log.Logger = (*RecordingLogger)(nil)
