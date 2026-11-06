CREATE SCHEMA IF NOT EXISTS notify;

CREATE TABLE notify.channels (
    id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id   UUID        NOT NULL,
    type         TEXT        NOT NULL CHECK (type IN ('telegram', 'email', 'whatsapp')),
    name         TEXT        NOT NULL,
    target       TEXT        NOT NULL,
    enabled      BOOLEAN     NOT NULL DEFAULT true,
    verified_at  TIMESTAMPTZ,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT channels_unique_target UNIQUE (account_id, type, target)
);

CREATE INDEX channels_account_id_idx ON notify.channels (account_id);

CREATE TABLE notify.deliveries (
    id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id         UUID        NOT NULL,
    channel_id       UUID        NOT NULL REFERENCES notify.channels (id) ON DELETE CASCADE,
    account_id       UUID        NOT NULL,
    event_type       TEXT        NOT NULL,
    payload          JSONB       NOT NULL,
    status           TEXT        NOT NULL DEFAULT 'pending'
                     CHECK (status IN ('pending', 'sent', 'dead')),
    attempts         INTEGER     NOT NULL DEFAULT 0 CHECK (attempts >= 0),
    next_attempt_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_error       TEXT,
    sent_at          TIMESTAMPTZ,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT deliveries_unique_event_channel UNIQUE (event_id, channel_id)
);

CREATE INDEX deliveries_pending_idx ON notify.deliveries (next_attempt_at) WHERE status = 'pending';
CREATE INDEX deliveries_account_created_idx ON notify.deliveries (account_id, created_at DESC);
