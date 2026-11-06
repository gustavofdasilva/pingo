CREATE SCHEMA IF NOT EXISTS monitor;

CREATE TABLE monitor.monitors (
    id                    UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id            UUID        NOT NULL,
    name                  TEXT        NOT NULL,
    url                   TEXT        NOT NULL,
    type                  TEXT        NOT NULL DEFAULT 'website'
                          CHECK (type IN ('website', 'api')),
    method                TEXT        NOT NULL DEFAULT 'GET'
                          CHECK (method IN ('GET', 'HEAD', 'POST')),
    headers               JSONB       NOT NULL DEFAULT '{}'::jsonb,
    expected_status       INTEGER     NOT NULL DEFAULT 200
                          CHECK (expected_status BETWEEN 100 AND 599),

    keyword               TEXT,
    json_path             TEXT,
    json_expected_value   TEXT,

    interval_seconds      INTEGER     NOT NULL DEFAULT 300
                          CHECK (interval_seconds >= 30),
    timeout_ms            INTEGER     NOT NULL DEFAULT 10000
                          CHECK (timeout_ms BETWEEN 1000 AND 30000),
    failure_threshold     INTEGER     NOT NULL DEFAULT 3
                          CHECK (failure_threshold BETWEEN 1 AND 10),
    paused                BOOLEAN     NOT NULL DEFAULT false,
    next_check_at         TIMESTAMPTZ NOT NULL DEFAULT now(),

    current_state         TEXT        NOT NULL DEFAULT 'pending'
                          CHECK (current_state IN ('pending', 'up', 'down')),
    consecutive_failures  INTEGER     NOT NULL DEFAULT 0
                          CHECK (consecutive_failures >= 0),
    last_checked_at       TIMESTAMPTZ,
    last_state_change_at  TIMESTAMPTZ,

    created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT monitors_json_expected_needs_path
        CHECK (json_expected_value IS NULL OR json_path IS NOT NULL),
    CONSTRAINT monitors_json_path_only_api
        CHECK (json_path IS NULL OR type = 'api')
);

CREATE INDEX monitors_account_id_idx ON monitor.monitors (account_id);
CREATE INDEX monitors_next_check_at_idx ON monitor.monitors (next_check_at) WHERE NOT paused;

CREATE TABLE monitor.incidents (
    id                 UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    monitor_id         UUID        NOT NULL REFERENCES monitor.monitors (id) ON DELETE CASCADE,
    account_id         UUID        NOT NULL,
    started_at         TIMESTAMPTZ NOT NULL,
    resolved_at        TIMESTAMPTZ,
    cause              TEXT        NOT NULL,
    last_status_code   INTEGER,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT incidents_resolved_after_started
        CHECK (resolved_at IS NULL OR resolved_at >= started_at)
);

CREATE UNIQUE INDEX incidents_one_open_per_monitor
    ON monitor.incidents (monitor_id) WHERE resolved_at IS NULL;
CREATE INDEX incidents_account_started_idx ON monitor.incidents (account_id, started_at DESC);
CREATE INDEX incidents_monitor_started_idx ON monitor.incidents (monitor_id, started_at DESC);

CREATE TABLE monitor.outbox (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type    TEXT        NOT NULL,
    aggregate_id  UUID        NOT NULL,
    account_id    UUID        NOT NULL,
    payload       JSONB       NOT NULL,
    attempts      INTEGER     NOT NULL DEFAULT 0,
    last_error    TEXT,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    published_at  TIMESTAMPTZ
);


CREATE INDEX outbox_unpublished_idx ON monitor.outbox (created_at) WHERE published_at IS NULL;
