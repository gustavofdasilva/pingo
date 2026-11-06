package auth

import (
	"embed"
	db "pingo/internal/platform/database"
)

//go:embed migrations/*.sql
var migrationFiles embed.FS

var Migrations = db.MigrationSet{Schema: "auth", Files: migrationFiles, Dir: "migrations"}
