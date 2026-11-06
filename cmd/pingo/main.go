package main

import (
	"context"
	"fmt"
	"log/slog"
	"os"
	"os/signal"
	"pingo/internal/auth"
	"pingo/internal/billing"
	"pingo/internal/checker"
	"pingo/internal/monitor"
	"pingo/internal/notify"
	"pingo/internal/platform/config"
	db "pingo/internal/platform/database"
	"pingo/internal/webhook"
	"syscall"
)

func main() {
	if err := run(); err != nil {
		slog.Error("pingo stopped", "err", err)
		os.Exit(1)
	}
}
func run() error {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	slog.SetDefault(slog.New(slog.NewJSONHandler(os.Stdout, nil)))

	cfg, err := config.Load()
	if err != nil {
		panic(fmt.Sprintf("[PANIC] error to load config: %v", err))
	}
	cfg.Log()

	if err := db.Migrate(cfg.DB.URL(),
		auth.Migrations,
		billing.Migrations,
		checker.Migrations,
		monitor.Migrations,
		notify.Migrations,
		webhook.Migrations,
	); err != nil {
		panic(fmt.Sprintf("[PANIC] error to migrate: %v", err))
	}
	slog.Info("migrations OK")

	pool, err := db.Connect(ctx, cfg.DB)
	if err != nil {
		panic(fmt.Sprintf("[PANIC] error to connect to database: %v", err))
	}
	slog.Info("database connected")
	defer pool.Close()

	return nil
}
