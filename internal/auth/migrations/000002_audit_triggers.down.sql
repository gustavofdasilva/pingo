DROP TRIGGER IF EXISTS accounts_audit ON auth.accounts;
ALTER TABLE auth.accounts DROP COLUMN IF EXISTS created_by, DROP COLUMN IF EXISTS updated_by;

DROP TRIGGER IF EXISTS users_audit ON auth.users;
ALTER TABLE auth.users DROP COLUMN IF EXISTS created_by, DROP COLUMN IF EXISTS updated_by;

DROP FUNCTION IF EXISTS auth.set_audit_fields();
