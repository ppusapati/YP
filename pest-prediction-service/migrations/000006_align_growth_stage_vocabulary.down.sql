-- Reverse of 000006: put the three renamed growth stages back.
--
-- BUDDING and RIPENING have no pre-migration equivalent. Rows holding either
-- are set to UNSPECIFIED rather than guessed into a neighbouring stage: the
-- old vocabulary genuinely could not express them, and inventing a stage here
-- would move a farmer-facing risk score on the way back down. UNSPECIFIED
-- scores as unstaged, which is what the old code did with them anyway.

UPDATE pest_predictions
SET growth_stage = CASE growth_stage
        WHEN 'GROWTH_STAGE_FRUIT_SET'  THEN 'GROWTH_STAGE_FRUITING'
        WHEN 'GROWTH_STAGE_MATURITY'   THEN 'GROWTH_STAGE_MATURATION'
        WHEN 'GROWTH_STAGE_SENESCENCE' THEN 'GROWTH_STAGE_HARVEST'
        WHEN 'GROWTH_STAGE_BUDDING'    THEN 'GROWTH_STAGE_UNSPECIFIED'
        WHEN 'GROWTH_STAGE_RIPENING'   THEN 'GROWTH_STAGE_UNSPECIFIED'
        ELSE growth_stage
    END
WHERE growth_stage IN (
    'GROWTH_STAGE_FRUIT_SET',
    'GROWTH_STAGE_MATURITY',
    'GROWTH_STAGE_SENESCENCE',
    'GROWTH_STAGE_BUDDING',
    'GROWTH_STAGE_RIPENING'
);
