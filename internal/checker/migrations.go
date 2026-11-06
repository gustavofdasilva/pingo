package checker

import (
	"embed"
	db "pingo/internal/platform/database"
)

//go:embed migrations/*.sql
var migrationFiles embed.FS

var Migrations = db.MigrationSet{Schema: "checker", Files: migrationFiles, Dir: "migrations"}
