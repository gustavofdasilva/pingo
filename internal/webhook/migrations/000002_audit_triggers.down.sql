DROP TRIGGER IF EXISTS endpoints_audit ON webhook.endpoints;
ALTER TABLE webhook.endpoints DROP COLUMN IF EXISTS created_by, DROP COLUMN IF EXISTS updated_by;

DROP TRIGGER IF EXISTS deliveries_audit ON webhook.deliveries;
ALTER TABLE webhook.deliveries DROP COLUMN IF EXISTS created_by, DROP COLUMN IF EXISTS updated_by;

DROP FUNCTION IF EXISTS webhook.set_audit_fields();
