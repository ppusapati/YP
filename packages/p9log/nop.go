package p9log

// nopLogger is a logger that discards all output.
type nopLogger struct{}

var _ Logger = (*nopLogger)(nil)

func (n *nopLogger) Log(level Level, keyvals ...interface{}) error { return nil }
func (n *nopLogger) Debug(keyvals ...interface{})                  {}
func (n *nopLogger) Info(keyvals ...interface{})                   {}
func (n *nopLogger) Warn(keyvals ...interface{})                   {}
func (n *nopLogger) Error(keyvals ...interface{})                  {}

// NewNopLogger returns a logger that discards all log output.
func NewNopLogger() Logger {
	return &nopLogger{}
}

// NoOp returns a no-op logger that discards all log output.
// It is an alias for NewNopLogger.
func NoOp() Logger {
	return &nopLogger{}
}
