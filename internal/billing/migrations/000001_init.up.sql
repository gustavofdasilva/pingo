CREATE SCHEMA IF NOT EXISTS billing;

CREATE TABLE billing.subscriptions (
    id                        UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id                UUID        NOT NULL,
    plan                      TEXT        NOT NULL CHECK (plan IN ('pro', 'team')),
    status                    TEXT        NOT NULL
                              CHECK (status IN ('active', 'past_due', 'canceled')),
    provider                  TEXT        NOT NULL,
    provider_customer_id      TEXT,
    provider_subscription_id  TEXT        NOT NULL,
    current_period_end        TIMESTAMPTZ,
    canceled_at               TIMESTAMPTZ,
    created_at                TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at                TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT subscriptions_provider_unique UNIQUE (provider, provider_subscription_id)
);

CREATE UNIQUE INDEX subscriptions_one_current_per_account
    ON billing.subscriptions (account_id) WHERE status IN ('active', 'past_due');
CREATE INDEX subscriptions_account_id_idx ON billing.subscriptions (account_id);

CREATE TABLE billing.payments (
    id                   UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id           UUID        NOT NULL,
    subscription_id      UUID        REFERENCES billing.subscriptions (id),
    amount_cents         BIGINT      NOT NULL CHECK (amount_cents > 0),
    currency             CHAR(3)     NOT NULL DEFAULT 'BRL',
    method               TEXT        NOT NULL CHECK (method IN ('pix', 'credit_card')),
    status               TEXT        NOT NULL DEFAULT 'pending'
                         CHECK (status IN ('pending', 'paid', 'failed', 'refunded')),
    provider             TEXT        NOT NULL,
    provider_payment_id  TEXT        NOT NULL,
    paid_at              TIMESTAMPTZ,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT payments_provider_unique UNIQUE (provider, provider_payment_id)
);

CREATE INDEX payments_account_created_idx ON billing.payments (account_id, created_at DESC);

CREATE TABLE billing.provider_events (
    provider     TEXT        NOT NULL,
    event_id     TEXT        NOT NULL,
    event_type   TEXT        NOT NULL,
    received_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

    PRIMARY KEY (provider, event_id)
);
