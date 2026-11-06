CREATE OR REPLACE FUNCTION monitor.set_audit_fields() RETURNS trigger
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

ALTER TABLE monitor.monitors
    ADD COLUMN created_by TEXT NOT NULL DEFAULT 'system',
    ADD COLUMN updated_by TEXT NOT NULL DEFAULT 'system';

CREATE TRIGGER monitors_audit
    BEFORE INSERT OR UPDATE ON monitor.monitors
    FOR EACH ROW EXECUTE FUNCTION monitor.set_audit_fields();

ALTER TABLE monitor.incidents
    ADD COLUMN created_by TEXT NOT NULL DEFAULT 'system',
    ADD COLUMN updated_by TEXT NOT NULL DEFAULT 'system';

CREATE TRIGGER incidents_audit
    BEFORE INSERT OR UPDATE ON monitor.incidents
    FOR EACH ROW EXECUTE FUNCTION monitor.set_audit_fields();
