CREATE SCHEMA IF NOT EXISTS webhook;

CREATE TABLE webhook.endpoints (
    id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id       UUID        NOT NULL,
    url              TEXT        NOT NULL,
    description      TEXT,
    secret           TEXT        NOT NULL,
    enabled          BOOLEAN     NOT NULL DEFAULT true,
    disabled_reason  TEXT,
    failing_since    TIMESTAMPTZ,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON COLUMN webhook.endpoints.secret IS
    'Segredo do HMAC, criptografado pela aplicação antes de salvar (nunca em texto puro).';
COMMENT ON COLUMN webhook.endpoints.failing_since IS
    'Início da sequência atual de falhas. Usado para desativar o endpoint depois de alguns dias falhando.';

CREATE INDEX endpoints_account_id_idx ON webhook.endpoints (account_id);

CREATE TABLE webhook.deliveries (
    id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id          UUID        NOT NULL,
    endpoint_id       UUID        NOT NULL REFERENCES webhook.endpoints (id) ON DELETE CASCADE,
    account_id        UUID        NOT NULL,
    event_type        TEXT        NOT NULL,
    payload           JSONB       NOT NULL,
    status            TEXT        NOT NULL DEFAULT 'pending'
                      CHECK (status IN ('pending', 'delivered', 'dead')),
    attempts          INTEGER     NOT NULL DEFAULT 0 CHECK (attempts >= 0),
    next_attempt_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_status_code  INTEGER,
    last_error        TEXT,
    delivered_at      TIMESTAMPTZ,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT deliveries_unique_event_endpoint UNIQUE (event_id, endpoint_id)
);

CREATE INDEX deliveries_pending_idx ON webhook.deliveries (next_attempt_at) WHERE status = 'pending';
CREATE INDEX deliveries_endpoint_created_idx ON webhook.deliveries (endpoint_id, created_at DESC);
CREATE INDEX deliveries_dead_idx ON webhook.deliveries (account_id, created_at DESC) WHERE status = 'dead';

CREATE TABLE webhook.attempts (
    id                     BIGINT      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    delivery_id            UUID        NOT NULL REFERENCES webhook.deliveries (id) ON DELETE CASCADE,
    attempted_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    status_code            INTEGER,
    response_ms            INTEGER     CHECK (response_ms >= 0),
    response_body_excerpt  TEXT,
    error                  TEXT
);

CREATE INDEX attempts_delivery_idx ON webhook.attempts (delivery_id, attempted_at DESC);
