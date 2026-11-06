CREATE OR REPLACE FUNCTION billing.set_audit_fields() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
    actor TEXT := coalesce(nullif(current_setting('app.actor', true), ''), 'system');
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := actor;
        NEW.updated_by := actor;
        NEW.updated_at := NEW.created_at;
        RETURN NEW;
    END IF;

    IF NEW IS NOT DISTINCT FROM OLD THEN
        RETURN NEW;
    END IF;

    NEW.created_at := OLD.created_at;
    NEW.created_by := OLD.created_by;
    NEW.updated_at := now();
    NEW.updated_by := actor;
    RETURN NEW;
END;
$$;

ALTER TABLE billing.subscriptions
    ADD COLUMN created_by TEXT NOT NULL DEFAULT 'system',
    ADD COLUMN updated_by TEXT NOT NULL DEFAULT 'system';

CREATE TRIGGER subscriptions_audit
    BEFORE INSERT OR UPDATE ON billing.subscriptions
    FOR EACH ROW EXECUTE FUNCTION billing.set_audit_fields();

ALTER TABLE billing.payments
    ADD COLUMN created_by TEXT NOT NULL DEFAULT 'system',
    ADD COLUMN updated_by TEXT NOT NULL DEFAULT 'system';

CREATE TRIGGER payments_audit
    BEFORE INSERT OR UPDATE ON billing.payments
    FOR EACH ROW EXECUTE FUNCTION billing.set_audit_fields();
