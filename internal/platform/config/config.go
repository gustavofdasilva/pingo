package config

import (
	"fmt"
	"log/slog"

	"github.com/caarlos0/env/v11"

	db "pingo/internal/platform/database"
)

type Config struct {
	Env string `env:"APP_ENV" envDefault:"development"`

	DB db.Config
}

func (c Config) IsDevelopment() bool {
	return c.Env == "development"
}

func (c Config) Log() {
	slog.Info("config loaded", "env", c.Env, "db_host", c.DB.Host, "db_port", c.DB.Port, "db_user", c.DB.User, "db_name", c.DB.Name, "db_sslmode", c.DB.SSLMode)
}

func Load() (Config, error) {
	cfg, err := env.ParseAs[Config]()
	if err != nil {
		return Config{}, fmt.Errorf("config: %w", err)
	}
	return cfg, nil
}
