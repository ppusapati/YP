use crate::types::*;
use crate::zoning::*;

/// One cell's measured inputs, in the order [`CELL_INPUT_NAMES`] names them.
///
/// Rates are computed per cell from these seven numbers plus the field's zone
/// boundaries, which is what makes a rate attributable: the same function can
/// be asked what this cell would have received with one input changed.
#[derive(Debug, Clone, Copy, Default, PartialEq)]
pub struct CellInputs {
    pub ndvi: f64,
    pub nitrogen: f64,
    pub phosphorus: f64,
    pub potassium: f64,
    pub ph: f64,
    pub moisture: f64,
    pub organic_matter: f64,
}

/// Names of [`CellInputs`] fields, in `to_vec` order.
pub const CELL_INPUT_NAMES: [&str; 7] = [
    "ndvi",
    "soil_nitrogen",
    "soil_phosphorus",
    "soil_potassium",
    "soil_ph",
    "soil_moisture",
    "soil_organic_matter",
];

impl CellInputs {
    /// Read cell `i` out of a field's inputs. Missing series read as zero,
    /// which is what the rules already assume for an unmeasured layer.
    pub fn at(input: &ZoneInput, i: usize) -> Self {
        let get = |v: &Vec<f64>| v.get(i).copied().unwrap_or(0.0);
        Self {
            ndvi: get(&input.ndvi),
            nitrogen: get(&input.soil_nitrogen),
            phosphorus: get(&input.soil_phosphorus),
            potassium: get(&input.soil_potassium),
            ph: get(&input.soil_ph),
            moisture: get(&input.soil_moisture),
            organic_matter: get(&input.soil_organic_matter),
        }
    }

    pub fn to_vec(&self) -> Vec<f64> {
        vec![
            self.ndvi,
            self.nitrogen,
            self.phosphorus,
            self.potassium,
            self.ph,
            self.moisture,
            self.organic_matter,
        ]
    }

    pub fn from_slice(v: &[f64]) -> Self {
        let get = |i: usize| v.get(i).copied().unwrap_or(0.0);
        Self {
            ndvi: get(0),
            nitrogen: get(1),
            phosphorus: get(2),
            potassium: get(3),
            ph: get(4),
            moisture: get(5),
            organic_matter: get(6),
        }
    }
}

/// The rate one cell receives, given the field's zone boundaries.
///
/// NDVI enters only through the zone it puts the cell in, which is why the
/// boundaries are passed rather than the zone itself: changing NDVI has to be
/// able to move the cell between zones, or attributing a rate to NDVI would
/// always come back as zero.
pub fn cell_rate(
    kind: PrescriptionType,
    cell: &CellInputs,
    requirements: &CropRequirements,
    boundaries: &[f64],
) -> f64 {
    let zone = zone_for(cell.ndvi, boundaries);
    match kind {
        PrescriptionType::Fertilizer => {
            let n_deficit = (requirements.nitrogen_kg_ha - cell.nitrogen).max(0.0);
            let p_deficit = (requirements.phosphorus_kg_ha - cell.phosphorus).max(0.0);
            let k_deficit = (requirements.potassium_kg_ha - cell.potassium).max(0.0);
            let ndvi_factor = match zone {
                ManagementZone::Low => 1.2,
                ManagementZone::Medium => 1.0,
                ManagementZone::High => 0.8,
            };
            (n_deficit + p_deficit * 0.5 + k_deficit * 0.3) * ndvi_factor
        }
        PrescriptionType::Irrigation => {
            let moisture_deficit = (0.35 - cell.moisture).max(0.0);
            let base_rate = requirements.water_requirement_mm / 10.0;
            let zone_factor = match zone {
                ManagementZone::Low => 0.8,
                ManagementZone::Medium => 1.0,
                ManagementZone::High => 1.2,
            };
            (base_rate * (1.0 + moisture_deficit * 5.0) * zone_factor)
                .min(requirements.water_requirement_mm * 0.2)
        }
        PrescriptionType::Seeding => {
            let om_factor = (cell.organic_matter / 3.0).clamp(0.7, 1.2);
            let zone_factor = match zone {
                ManagementZone::High => 1.15,
                ManagementZone::Medium => 1.0,
                ManagementZone::Low => 0.85,
            };
            requirements.seed_rate_per_ha * zone_factor * om_factor
        }
        PrescriptionType::Liming => {
            if cell.ph >= requirements.optimal_ph_low {
                return 0.0;
            }
            ((requirements.optimal_ph_low - cell.ph) * 1500.0).min(5000.0)
        }
        // No agronomic rule has been written for variable-rate pesticide, and
        // no prescription of this type is generated. Zero says "nothing
        // prescribed" rather than inventing a rate.
        PrescriptionType::Pesticide => 0.0,
    }
}

/// Rates for every cell of a field.
fn field_rates(
    kind: PrescriptionType,
    input: &ZoneInput,
    requirements: &CropRequirements,
    zones: &ZoneClassification,
) -> Vec<f64> {
    (0..input.ndvi.len())
        .map(|i| {
            cell_rate(
                kind,
                &CellInputs::at(input, i),
                requirements,
                &zones.zone_boundaries,
            )
        })
        .collect()
}

pub fn generate_fertilizer_prescription(
    grid: &FieldGrid,
    input: &ZoneInput,
    requirements: &CropRequirements,
) -> PrescriptionMap {
    let zones = classify_zones(&input.ndvi, 3);

    let rates = field_rates(PrescriptionType::Fertilizer, input, requirements, &zones);

    let summaries = zone_summary(grid, &zones, &rates);
    let total = rates.iter().sum::<f64>() * grid.cell_area_ha();

    PrescriptionMap {
        field_id: grid.field_id.clone(),
        prescription_type: PrescriptionType::Fertilizer,
        grid: grid.clone(),
        zones,
        rates,
        unit: PrescriptionType::Fertilizer.unit().into(),
        total_amount: total,
        zone_summaries: summaries,
    }
}

pub fn generate_irrigation_prescription(
    grid: &FieldGrid,
    input: &ZoneInput,
    requirements: &CropRequirements,
) -> PrescriptionMap {
    let zones = classify_zones(&input.ndvi, 3);

    let rates = field_rates(PrescriptionType::Irrigation, input, requirements, &zones);

    let summaries = zone_summary(grid, &zones, &rates);
    let total = rates.iter().sum::<f64>() * grid.cell_area_ha();

    PrescriptionMap {
        field_id: grid.field_id.clone(),
        prescription_type: PrescriptionType::Irrigation,
        grid: grid.clone(),
        zones,
        rates,
        unit: PrescriptionType::Irrigation.unit().into(),
        total_amount: total,
        zone_summaries: summaries,
    }
}

pub fn generate_seeding_prescription(
    grid: &FieldGrid,
    input: &ZoneInput,
    requirements: &CropRequirements,
) -> PrescriptionMap {
    let zones = classify_zones(&input.ndvi, 3);

    let rates = field_rates(PrescriptionType::Seeding, input, requirements, &zones);

    let summaries = zone_summary(grid, &zones, &rates);
    let total = rates.iter().sum::<f64>() * grid.cell_area_ha();

    PrescriptionMap {
        field_id: grid.field_id.clone(),
        prescription_type: PrescriptionType::Seeding,
        grid: grid.clone(),
        zones,
        rates,
        unit: PrescriptionType::Seeding.unit().into(),
        total_amount: total,
        zone_summaries: summaries,
    }
}

pub fn generate_liming_prescription(
    grid: &FieldGrid,
    input: &ZoneInput,
    requirements: &CropRequirements,
) -> PrescriptionMap {
    let zones = classify_zones(&input.ndvi, 3);

    let rates = field_rates(PrescriptionType::Liming, input, requirements, &zones);

    let summaries = zone_summary(grid, &zones, &rates);
    let total = rates.iter().sum::<f64>() * grid.cell_area_ha();

    PrescriptionMap {
        field_id: grid.field_id.clone(),
        prescription_type: PrescriptionType::Liming,
        grid: grid.clone(),
        zones,
        rates,
        unit: PrescriptionType::Liming.unit().into(),
        total_amount: total,
        zone_summaries: summaries,
    }
}

pub fn generate_prescription_bundle(
    grid: &FieldGrid,
    input: &ZoneInput,
    requirements: &CropRequirements,
) -> PrescriptionBundle {
    let fertilizer = generate_fertilizer_prescription(grid, input, requirements);
    let irrigation = generate_irrigation_prescription(grid, input, requirements);
    let seeding = generate_seeding_prescription(grid, input, requirements);
    let liming = generate_liming_prescription(grid, input, requirements);

    let uniform_fert_total =
        requirements.nitrogen_kg_ha * grid.cell_count() as f64 * grid.cell_area_ha();
    let vra_fert_total = fertilizer.total_amount;
    let cost_savings = if uniform_fert_total > 0.0 {
        ((uniform_fert_total - vra_fert_total) / uniform_fert_total * 100.0).max(0.0)
    } else {
        0.0
    };

    PrescriptionBundle {
        field_id: grid.field_id.clone(),
        crop_type: requirements.crop_type.clone(),
        prescriptions: vec![fertilizer, irrigation, seeding, liming],
        estimated_cost_savings_pct: cost_savings,
        estimated_yield_gain_pct: cost_savings * 0.3,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn test_grid() -> FieldGrid {
        FieldGrid {
            field_id: "f1".into(),
            rows: 3,
            cols: 3,
            cell_size_m: 100.0,
            origin_lat: 17.0,
            origin_lon: 78.0,
        }
    }

    fn test_input() -> ZoneInput {
        ZoneInput {
            ndvi: vec![0.3, 0.4, 0.5, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85],
            soil_nitrogen: vec![60.0, 70.0, 80.0, 90.0, 95.0, 100.0, 105.0, 110.0, 115.0],
            soil_phosphorus: vec![15.0, 18.0, 20.0, 22.0, 25.0, 28.0, 30.0, 32.0, 35.0],
            soil_potassium: vec![30.0, 35.0, 40.0, 42.0, 45.0, 48.0, 50.0, 52.0, 55.0],
            soil_ph: vec![5.2, 5.5, 5.8, 6.0, 6.2, 6.5, 6.8, 7.0, 7.2],
            soil_moisture: vec![0.15, 0.18, 0.22, 0.25, 0.28, 0.30, 0.32, 0.33, 0.35],
            soil_organic_matter: vec![1.5, 1.8, 2.0, 2.2, 2.5, 2.8, 3.0, 3.2, 3.5],
        }
    }

    #[test]
    fn test_fertilizer_prescription() {
        let grid = test_grid();
        let input = test_input();
        let req = CropRequirements::default();
        let result = generate_fertilizer_prescription(&grid, &input, &req);
        assert_eq!(result.rates.len(), 9);
        assert!(result.total_amount > 0.0);
        assert!(result.rates[0] > result.rates[8]);
    }

    #[test]
    fn test_irrigation_prescription() {
        let grid = test_grid();
        let input = test_input();
        let req = CropRequirements::default();
        let result = generate_irrigation_prescription(&grid, &input, &req);
        assert_eq!(result.rates.len(), 9);
        assert!(result.rates.iter().all(|r| *r >= 0.0));
    }

    #[test]
    fn test_liming_only_low_ph() {
        let grid = test_grid();
        let input = test_input();
        let req = CropRequirements::default();
        let result = generate_liming_prescription(&grid, &input, &req);
        let non_zero: Vec<&f64> = result.rates.iter().filter(|r| **r > 0.0).collect();
        let zero: Vec<&f64> = result.rates.iter().filter(|r| **r == 0.0).collect();
        assert!(!non_zero.is_empty());
        assert!(!zero.is_empty());
    }

    #[test]
    fn test_prescription_bundle() {
        let grid = test_grid();
        let input = test_input();
        let req = CropRequirements::default();
        let bundle = generate_prescription_bundle(&grid, &input, &req);
        assert_eq!(bundle.prescriptions.len(), 4);
        assert!(bundle.estimated_cost_savings_pct >= 0.0);
    }
}

#[cfg(test)]
mod cell_tests {
    use super::*;

    fn grid(rows: usize, cols: usize) -> FieldGrid {
        FieldGrid {
            field_id: "f1".into(),
            rows,
            cols,
            cell_size_m: 10.0,
            origin_lat: 18.5,
            origin_lon: 78.4,
        }
    }

    fn varied_input(n: usize) -> ZoneInput {
        ZoneInput {
            ndvi: (0..n).map(|i| 0.3 + (i % 9) as f64 * 0.05).collect(),
            soil_nitrogen: (0..n).map(|i| 20.0 + (i % 7) as f64 * 10.0).collect(),
            soil_phosphorus: (0..n).map(|i| 10.0 + (i % 5) as f64 * 4.0).collect(),
            soil_potassium: (0..n).map(|i| 80.0 + (i % 6) as f64 * 15.0).collect(),
            soil_ph: (0..n).map(|i| 5.4 + (i % 8) as f64 * 0.2).collect(),
            soil_moisture: (0..n).map(|i| 0.15 + (i % 6) as f64 * 0.04).collect(),
            soil_organic_matter: (0..n).map(|i| 1.5 + (i % 5) as f64 * 0.6).collect(),
        }
    }

    fn requirements() -> CropRequirements {
        CropRequirements {
            crop_type: "wheat".into(),
            target_yield_kg_ha: 4500.0,
            nitrogen_kg_ha: 120.0,
            phosphorus_kg_ha: 40.0,
            potassium_kg_ha: 60.0,
            optimal_ph_low: 6.2,
            optimal_ph_high: 7.5,
            water_requirement_mm: 450.0,
            seed_rate_per_ha: 110.0,
        }
    }

    /// The extracted per-cell function must reproduce the maps exactly, or
    /// attributions would explain a different rule than the one prescribing.
    #[test]
    fn cell_rate_reproduces_every_generated_map() {
        let n = 36;
        let (g, input, req) = (grid(6, 6), varied_input(n), requirements());

        for (kind, map) in [
            (
                PrescriptionType::Fertilizer,
                generate_fertilizer_prescription(&g, &input, &req),
            ),
            (
                PrescriptionType::Irrigation,
                generate_irrigation_prescription(&g, &input, &req),
            ),
            (
                PrescriptionType::Seeding,
                generate_seeding_prescription(&g, &input, &req),
            ),
            (
                PrescriptionType::Liming,
                generate_liming_prescription(&g, &input, &req),
            ),
        ] {
            for i in 0..n {
                let direct = cell_rate(
                    kind,
                    &CellInputs::at(&input, i),
                    &req,
                    &map.zones.zone_boundaries,
                );
                assert!(
                    (direct - map.rates[i]).abs() < 1e-12,
                    "{kind:?} cell {i}: {direct} vs {}",
                    map.rates[i]
                );
            }
            // A map where every cell is identical would pass vacuously.
            let spread = map.rates.iter().cloned().fold(f64::MIN, f64::max)
                - map.rates.iter().cloned().fold(f64::MAX, f64::min);
            assert!(spread > 0.0, "{kind:?} produced a uniform map");
        }
    }

    #[test]
    fn ndvi_acts_by_moving_a_cell_between_zones() {
        let req = requirements();
        let boundaries = vec![0.4, 0.6];
        let cell = CellInputs {
            ndvi: 0.5,
            nitrogen: 40.0,
            phosphorus: 10.0,
            potassium: 30.0,
            ph: 6.5,
            moisture: 0.2,
            organic_matter: 3.0,
        };

        let medium = cell_rate(PrescriptionType::Fertilizer, &cell, &req, &boundaries);
        let low = cell_rate(
            PrescriptionType::Fertilizer,
            &CellInputs { ndvi: 0.1, ..cell },
            &req,
            &boundaries,
        );
        let high = cell_rate(
            PrescriptionType::Fertilizer,
            &CellInputs { ndvi: 0.9, ..cell },
            &req,
            &boundaries,
        );

        // A poorly growing zone is pushed harder, a strong one eased off.
        assert!(low > medium && medium > high, "{low} {medium} {high}");
        assert!((low / medium - 1.2).abs() < 1e-9);
        assert!((high / medium - 0.8).abs() < 1e-9);
    }

    #[test]
    fn cell_inputs_round_trip_through_a_vector() {
        let input = varied_input(10);
        let cell = CellInputs::at(&input, 3);
        assert_eq!(cell.to_vec().len(), CELL_INPUT_NAMES.len());
        assert_eq!(CellInputs::from_slice(&cell.to_vec()), cell);

        // Reading past the end is not an error; the rules already treat a
        // missing layer as zero.
        let short = ZoneInput {
            ndvi: vec![0.5],
            ..varied_input(0)
        };
        let cell = CellInputs::at(&short, 0);
        assert_eq!(cell.ndvi, 0.5);
        assert_eq!(cell.nitrogen, 0.0);
        // Short vectors are truncated to seven values.
        assert_eq!(CellInputs::from_slice(&[1.0, 2.0]).phosphorus, 0.0);
    }

    #[test]
    fn liming_stops_at_the_target_ph() {
        let req = requirements();
        let cell = |ph| CellInputs {
            ph,
            ..Default::default()
        };
        assert_eq!(
            cell_rate(PrescriptionType::Liming, &cell(6.5), &req, &[]),
            0.0
        );
        assert!(cell_rate(PrescriptionType::Liming, &cell(5.0), &req, &[]) > 0.0);
        // And is capped, so a wild pH reading cannot prescribe a mountain.
        assert_eq!(
            cell_rate(PrescriptionType::Liming, &cell(-50.0), &req, &[]),
            5000.0
        );
    }

    #[test]
    fn pesticide_has_no_rule_and_prescribes_nothing() {
        let cell = CellInputs {
            ndvi: 0.5,
            ..Default::default()
        };
        assert_eq!(
            cell_rate(PrescriptionType::Pesticide, &cell, &requirements(), &[0.4]),
            0.0
        );
    }
}
