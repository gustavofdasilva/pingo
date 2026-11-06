package notify

import (
	"embed"
	db "pingo/internal/platform/database"
)

//go:embed migrations/*.sql
var migrationFiles embed.FS

var Migrations = db.MigrationSet{Schema: "notify", Files: migrationFiles, Dir: "migrations"}
