package modulith

import (
	"context"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"sort"

	"github.com/jackc/pgx/v5/pgxpool"
	"go.uber.org/zap"
	"p9e.in/samavaya/packages/database/migrate"
)

// RunAllMigrations discovers and runs migrations from every service directory.
// It looks for <serviceDir>/migrations/ directories relative to the given root.
func RunAllMigrations(ctx context.Context, pool *pgxpool.Pool, logger *zap.Logger, root string) error {
	entries, err := os.ReadDir(root)
	if err != nil {
		return fmt.Errorf("read root dir: %w", err)
	}

	var serviceDirs []string
	for _, e := range entries {
		if !e.IsDir() {
			continue
		}
		migDir := filepath.Join(root, e.Name(), "migrations")
		if info, err := os.Stat(migDir); err == nil && info.IsDir() {
			serviceDirs = append(serviceDirs, e.Name())
		}
	}
	sort.Strings(serviceDirs)

	for _, svc := range serviceDirs {
		migDir := filepath.Join(root, svc, "migrations")
		logger.Info("running migrations", zap.String("service", svc), zap.String("dir", migDir))
		if err := migrate.Up(ctx, pool, os.DirFS(migDir).(fs.FS), logger); err != nil {
			return fmt.Errorf("migrate %s: %w", svc, err)
		}
	}

	return nil
}
