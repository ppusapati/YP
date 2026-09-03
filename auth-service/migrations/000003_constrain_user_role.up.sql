-- Constrain the role column to the four defined roles.
-- Any rows with non-standard roles are normalised to 'viewer' first.
UPDATE users SET role = 'viewer'
 WHERE role NOT IN ('viewer', 'worker', 'manager', 'admin');

ALTER TABLE users
  ADD CONSTRAINT chk_users_role
  CHECK (role IN ('viewer', 'worker', 'manager', 'admin'));
