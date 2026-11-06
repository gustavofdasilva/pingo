DROP TRIGGER IF EXISTS monitors_audit ON monitor.monitors;
ALTER TABLE monitor.monitors DROP COLUMN IF EXISTS created_by, DROP COLUMN IF EXISTS updated_by;

DROP TRIGGER IF EXISTS incidents_audit ON monitor.incidents;
ALTER TABLE monitor.incidents DROP COLUMN IF EXISTS created_by, DROP COLUMN IF EXISTS updated_by;

DROP FUNCTION IF EXISTS monitor.set_audit_fields();
