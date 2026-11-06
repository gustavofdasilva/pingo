package webhook

import (
	"embed"
	db "pingo/internal/platform/database"
)

//go:embed migrations/*.sql
var migrationFiles embed.FS

var Migrations = db.MigrationSet{Schema: "webhook", Files: migrationFiles, Dir: "migrations"}
