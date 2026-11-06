DROP TRIGGER IF EXISTS channels_audit ON notify.channels;
ALTER TABLE notify.channels DROP COLUMN IF EXISTS created_by, DROP COLUMN IF EXISTS updated_by;

DROP TRIGGER IF EXISTS deliveries_audit ON notify.deliveries;
ALTER TABLE notify.deliveries DROP COLUMN IF EXISTS created_by, DROP COLUMN IF EXISTS updated_by;

DROP FUNCTION IF EXISTS notify.set_audit_fields();
