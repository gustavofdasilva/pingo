package db

import (
	"errors"
	"fmt"
	"io/fs"
	"net/url"

	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/pgx/v5"
	"github.com/golang-migrate/migrate/v4/source/iofs"
)

type MigrationSet struct {
	Schema string
	Files  fs.FS
	Dir    string
}

func Migrate(databaseURL string, sets ...MigrationSet) error {
	for _, set := range sets {
		if err := migrateSet(databaseURL, set); err != nil {
			return fmt.Errorf("db: migrate %s: %w", set.Schema, err)
		}
	}
	return nil
}

func migrateSet(databaseURL string, set MigrationSet) (err error) {
	src, err := iofs.New(set.Files, set.Dir)
	if err != nil {
		return fmt.Errorf("open source: %w", err)
	}

	target, err := migrationURL(databaseURL, set.Schema)
	if err != nil {
		return err
	}

	m, err := migrate.NewWithSourceInstance("iofs", src, target)
	if err != nil {
		return fmt.Errorf("init: %w", err)
	}
	defer func() {
		srcErr, dbErr := m.Close()
		err = errors.Join(err, srcErr, dbErr)
	}()

	if err := m.Up(); err != nil && !errors.Is(err, migrate.ErrNoChange) {
		return fmt.Errorf("up: %w", err)
	}
	return nil
}

func migrationURL(databaseURL, schema string) (string, error) {
	u, err := url.Parse(databaseURL)
	if err != nil {
		return "", fmt.Errorf("parse url: %w", err)
	}
	u.Scheme = "pgx5"
	q := u.Query()
	q.Set("x-migrations-table", schema+"_schema_migrations")
	u.RawQuery = q.Encode()
	return u.String(), nil
}
