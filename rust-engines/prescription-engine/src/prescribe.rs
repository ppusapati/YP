use crate::types::*;
use crate::zoning::*;

pub fn generate_fertilizer_prescription(
    grid: &FieldGrid,
    input: &ZoneInput,
    requirements: &CropRequirements,
) -> PrescriptionMap {
    let zones = classify_zones(&input.ndvi, 3);

    let rates: Vec<f64> = (0..input.ndvi.len())
        .map(|i| {
            let n_deficit = (requirements.nitrogen_kg_ha - input.soil_nitrogen[i]).max(0.0);
            let p_deficit = (requirements.phosphorus_kg_ha - input.soil_phosphorus[i]).max(0.0);
            let k_deficit = (requirements.potassium_kg_ha - input.soil_potassium[i]).max(0.0);

            let ndvi_factor = match zones.zones[i] {
                ManagementZone::Low => 1.2,
                ManagementZone::Medium => 1.0,
                ManagementZone::High => 0.8,
            };

            (n_deficit + p_deficit * 0.5 + k_deficit * 0.3) * ndvi_factor
        })
        .collect();

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

    let rates: Vec<f64> = (0..input.ndvi.len())
        .map(|i| {
            let moisture_deficit = (0.35 - input.soil_moisture[i]).max(0.0);
            let base_rate = requirements.water_requirement_mm / 10.0;

            let zone_factor = match zones.zones[i] {
                ManagementZone::Low => 0.8,
                ManagementZone::Medium => 1.0,
                ManagementZone::High => 1.2,
            };

            (base_rate * (1.0 + moisture_deficit * 5.0) * zone_factor).min(requirements.water_requirement_mm * 0.2)
        })
        .collect();

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

    let rates: Vec<f64> = (0..input.ndvi.len())
        .map(|i| {
            let om_factor = (input.soil_organic_matter[i] / 3.0).min(1.2).max(0.7);

            let zone_factor = match zones.zones[i] {
                ManagementZone::High => 1.15,
                ManagementZone::Medium => 1.0,
                ManagementZone::Low => 0.85,
            };

            requirements.seed_rate_per_ha * zone_factor * om_factor
        })
        .collect();

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

    let rates: Vec<f64> = (0..input.ndvi.len())
        .map(|i| {
            let ph = input.soil_ph[i];
            if ph >= requirements.optimal_ph_low {
                return 0.0;
            }
            let ph_deficit = requirements.optimal_ph_low - ph;
            (ph_deficit * 1500.0).min(5000.0)
        })
        .collect();

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

    let uniform_fert_total = requirements.nitrogen_kg_ha * grid.cell_count() as f64 * grid.cell_area_ha();
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
