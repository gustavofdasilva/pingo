DROP TRIGGER IF EXISTS subscriptions_audit ON billing.subscriptions;
ALTER TABLE billing.subscriptions DROP COLUMN IF EXISTS created_by, DROP COLUMN IF EXISTS updated_by;

DROP TRIGGER IF EXISTS payments_audit ON billing.payments;
ALTER TABLE billing.payments DROP COLUMN IF EXISTS created_by, DROP COLUMN IF EXISTS updated_by;

DROP FUNCTION IF EXISTS billing.set_audit_fields();
