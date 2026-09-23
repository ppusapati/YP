-- ============================================================================
-- Align growth_stage with agriculture.field.v1.GrowthStage
--
-- This service had FLOWERING = 4, FRUITING = 5, MATURATION = 6, HARVEST = 7
-- against field-service's BUDDING = 4, FLOWERING = 5, FRUIT_SET = 6,
-- RIPENING = 7, MATURITY = 8, SENESCENCE = 9. Growth stage is worth a quarter
-- of the pest risk score, and field-service is where a farmer actually records
-- it, so this service adopted field's list — names and numbers both.
--
-- Three stored values change name. The mapping keeps the ordering and the
-- scoring band each stage had:
--
--   FRUITING   -> FRUIT_SET    (20 points, unchanged)
--   MATURATION -> MATURITY     (10 points, unchanged)
--   HARVEST    -> SENESCENCE   (5 points, unchanged)
--
-- HARVEST -> SENESCENCE deserves a word: harvest is an operation, senescence
-- is the plant dying back, and they are not the same idea. But field's list
-- has no HARVEST, its last two stages are MATURITY and SENESCENCE, and this
-- service already treated MATURATION and HARVEST as the final two in that
-- order. Mapping to SENESCENCE preserves both the sequence and the score; the
-- alternative, folding HARVEST into MATURITY, would have collapsed two
-- distinct stored values into one and lost data.
--
-- BUDDING and RIPENING are new here and no stored row can hold them yet: they
-- only arrive once field-service sends one. Before this migration such a stage
-- was not recognised and scored as unstaged.
--
-- The column is TEXT with no CHECK constraint, so this is a data rewrite only.
-- Rows are stored in the prefixed form (GROWTH_STAGE_<NAME>) — see
-- growthStageToDB in the repository.
-- ============================================================================

UPDATE pest_predictions
SET growth_stage = CASE growth_stage
        WHEN 'GROWTH_STAGE_FRUITING'   THEN 'GROWTH_STAGE_FRUIT_SET'
        WHEN 'GROWTH_STAGE_MATURATION' THEN 'GROWTH_STAGE_MATURITY'
        WHEN 'GROWTH_STAGE_HARVEST'    THEN 'GROWTH_STAGE_SENESCENCE'
        ELSE growth_stage
    END
WHERE growth_stage IN (
    'GROWTH_STAGE_FRUITING',
    'GROWTH_STAGE_MATURATION',
    'GROWTH_STAGE_HARVEST'
);
