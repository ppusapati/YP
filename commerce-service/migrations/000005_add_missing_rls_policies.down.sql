-- ============================================================================
-- Commerce Service: Drop DELETE policy on orders
-- ============================================================================

DROP POLICY IF EXISTS orders_delete_policy ON orders;
