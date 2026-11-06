CREATE SCHEMA IF NOT EXISTS checker;

CREATE TABLE checker.results (
    id           BIGINT      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    monitor_id   UUID        NOT NULL,
    account_id   UUID        NOT NULL,
    checked_at   TIMESTAMPTZ NOT NULL,
    success      BOOLEAN     NOT NULL,
    status_code  INTEGER,
    response_ms  INTEGER     CHECK (response_ms >= 0),
    error        TEXT
);

CREATE INDEX results_monitor_checked_idx ON checker.results (monitor_id, checked_at DESC);

CREATE TABLE checker.daily_stats (
    monitor_id            UUID        NOT NULL,
    date                  DATE        NOT NULL,
    account_id            UUID        NOT NULL,
    checks_total          INTEGER     NOT NULL DEFAULT 0 CHECK (checks_total >= 0),
    checks_failed         INTEGER     NOT NULL DEFAULT 0 CHECK (checks_failed >= 0),
    checks_with_response  INTEGER     NOT NULL DEFAULT 0 CHECK (checks_with_response >= 0),
    response_ms_sum       BIGINT      NOT NULL DEFAULT 0 CHECK (response_ms_sum >= 0),
    last_checked_at       TIMESTAMPTZ NOT NULL,

    PRIMARY KEY (monitor_id, date),
    CONSTRAINT daily_stats_failed_le_total CHECK (checks_failed <= checks_total)
);

CREATE INDEX daily_stats_account_date_idx ON checker.daily_stats (account_id, date DESC);
