//! Variable-rate prescription maps, with a per-zone explanation of each rate.

use crate::proto;
use crate::yield_predict::attribution_proto;
use prescription_engine::prescribe::*;
use prescription_engine::types::*;
use std::time::Instant;
use yield_prediction_engine::shapley_exact;

/// Cells sampled as the reference a zone's rate is compared against.
///
/// The reference is the field's own cells, which is the comparison a
/// variable-rate map is actually making: not "versus some training set" but
/// "versus the rest of this field".
const REFERENCE_CELLS: usize = 32;

/// Explain why one zone's rate differs from the field average.
///
/// Seven inputs means every coalition can be enumerated, so these attributions
/// are exact rather than sampled — no residual, no seed.
fn zone_attribution(
    kind: PrescriptionType,
    map: &PrescriptionMap,
    input: &ZoneInput,
    requirements: &CropRequirements,
    zone: ManagementZone,
    unit: &str,
) -> Option<proto::AttributionSummary> {
    let cells: Vec<usize> = (0..map.rates.len())
        .filter(|&i| map.zones.zones.get(i) == Some(&zone))
        .collect();
    if cells.is_empty() {
        return None;
    }

    // Explain the cell most typical of the zone rather than an extreme one.
    let mean = cells.iter().map(|&i| map.rates[i]).sum::<f64>() / cells.len() as f64;
    let representative = *cells
        .iter()
        .min_by(|&&a, &&b| {
            (map.rates[a] - mean)
                .abs()
                .partial_cmp(&(map.rates[b] - mean).abs())
                .unwrap_or(std::cmp::Ordering::Equal)
        })
        .expect("the zone has at least one cell");

    let stride = (map.rates.len() / REFERENCE_CELLS).max(1);
    let reference: Vec<Vec<f64>> = (0..map.rates.len())
        .step_by(stride)
        .take(REFERENCE_CELLS)
        .map(|i| CellInputs::at(input, i).to_vec())
        .collect();

    let boundaries = map.zones.zone_boundaries.clone();
    let requirements = requirements.clone();
    let rate = move |values: &[f64]| {
        cell_rate(
            kind,
            &CellInputs::from_slice(values),
            &requirements,
            &boundaries,
        )
    };
    let names: Vec<String> = CELL_INPUT_NAMES.iter().map(|s| s.to_string()).collect();

    match shapley_exact(
        &rate,
        &CellInputs::at(input, representative).to_vec(),
        &reference,
        &names,
    ) {
        Ok(report) => Some(attribution_proto(&report, 1.0, unit)),
        Err(e) => {
            tracing::debug!(?kind, error = %e, "prescription zone not attributed");
            None
        }
    }
}

pub struct PrescriptionEngine;

impl PrescriptionEngine {
    pub fn new() -> Self {
        Self
    }

    pub fn generate_prescription(
        &self,
        req: &proto::GeneratePrescriptionRequest,
    ) -> proto::GeneratePrescriptionResponse {
        let start = Instant::now();

        let grid_proto = req.grid.as_ref().expect("grid required");
        let input_proto = req.zone_input.as_ref().expect("zone_input required");
        let crop_proto = req
            .crop_requirements
            .as_ref()
            .expect("crop_requirements required");

        let grid = FieldGrid {
            field_id: req.field_id.clone(),
            rows: grid_proto.rows as usize,
            cols: grid_proto.cols as usize,
            cell_size_m: grid_proto.cell_size_m,
            origin_lat: grid_proto.origin_lat,
            origin_lon: grid_proto.origin_lon,
        };

        let input = ZoneInput {
            ndvi: input_proto.ndvi.clone(),
            soil_nitrogen: input_proto.soil_nitrogen.clone(),
            soil_phosphorus: input_proto.soil_phosphorus.clone(),
            soil_potassium: input_proto.soil_potassium.clone(),
            soil_ph: input_proto.soil_ph.clone(),
            soil_moisture: input_proto.soil_moisture.clone(),
            soil_organic_matter: input_proto.soil_organic_matter.clone(),
        };

        let requirements = CropRequirements {
            crop_type: crop_proto.crop_type.clone(),
            target_yield_kg_ha: crop_proto.target_yield_kg_ha,
            nitrogen_kg_ha: crop_proto.nitrogen_kg_ha,
            phosphorus_kg_ha: crop_proto.phosphorus_kg_ha,
            potassium_kg_ha: crop_proto.potassium_kg_ha,
            optimal_ph_low: crop_proto.optimal_ph_low,
            optimal_ph_high: crop_proto.optimal_ph_high,
            water_requirement_mm: crop_proto.water_requirement_mm,
            seed_rate_per_ha: crop_proto.seed_rate_per_ha,
        };

        let bundle = generate_prescription_bundle(&grid, &input, &requirements);

        let prescriptions = bundle
            .prescriptions
            .iter()
            .map(|p| {
                let zone_summaries = p
                    .zone_summaries
                    .iter()
                    .map(|z| proto::PrescriptionZoneSummary {
                        zone: z.zone.label().to_string(),
                        cell_count: z.cell_count as i32,
                        area_ha: z.area_ha,
                        mean_rate: z.mean_rate,
                        min_rate: z.min_rate,
                        max_rate: z.max_rate,
                        total_amount: z.total_amount,
                        attribution: zone_attribution(
                            p.prescription_type,
                            p,
                            &input,
                            &requirements,
                            z.zone,
                            &p.unit,
                        ),
                    })
                    .collect();

                proto::PrescriptionMapResult {
                    prescription_type: p.prescription_type.label().to_string(),
                    rates: p.rates.clone(),
                    unit: p.unit.clone(),
                    total_amount: p.total_amount,
                    zone_summaries,
                }
            })
            .collect();

        proto::GeneratePrescriptionResponse {
            request_id: req.request_id.clone(),
            field_id: req.field_id.clone(),
            prescriptions,
            estimated_cost_savings_pct: bundle.estimated_cost_savings_pct,
            estimated_yield_gain_pct: bundle.estimated_yield_gain_pct,
            processing_time_ms: start.elapsed().as_millis() as i64,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Inputs that vary across the field, so zones are real and there is
    /// something for attribution to find.
    fn varied_zone_input(n: usize) -> proto::PrescriptionZoneInput {
        proto::PrescriptionZoneInput {
            ndvi: (0..n).map(|i| 0.25 + (i % 9) as f64 * 0.06).collect(),
            soil_nitrogen: (0..n).map(|i| 15.0 + (i % 7) as f64 * 12.0).collect(),
            soil_phosphorus: (0..n).map(|i| 8.0 + (i % 5) as f64 * 5.0).collect(),
            soil_potassium: (0..n).map(|i| 70.0 + (i % 6) as f64 * 18.0).collect(),
            soil_ph: (0..n).map(|i| 5.2 + (i % 8) as f64 * 0.25).collect(),
            soil_moisture: (0..n).map(|i| 0.12 + (i % 6) as f64 * 0.05).collect(),
            soil_organic_matter: (0..n).map(|i| 1.2 + (i % 5) as f64 * 0.7).collect(),
        }
    }

    #[test]
    fn every_zone_explains_its_own_rate() {
        let engine = PrescriptionEngine::new();
        let (rows, cols) = (6, 6);
        let n = (rows * cols) as usize;

        let response = engine.generate_prescription(&proto::GeneratePrescriptionRequest {
            request_id: "rx-attrib".to_string(),
            field_id: "field-1".to_string(),
            grid: Some(make_grid(rows, cols)),
            zone_input: Some(varied_zone_input(n)),
            crop_requirements: Some(make_crop_requirements()),
            prescription_types: vec![],
        });

        let fertilizer = response
            .prescriptions
            .iter()
            .find(|p| p.prescription_type.starts_with("Fertilizer"))
            .expect("a fertilizer map is always generated");
        assert!(
            fertilizer.zone_summaries.len() >= 2,
            "the field should zone"
        );

        for zone in &fertilizer.zone_summaries {
            let a = zone
                .attribution
                .as_ref()
                .unwrap_or_else(|| panic!("zone {} carries no attribution", zone.zone));

            assert_eq!(a.method, "shapley-exact");
            assert_eq!(a.units, fertilizer.unit);
            assert_eq!(a.features.len(), 7);
            // Enumerating every coalition leaves nothing unexplained.
            assert!(
                a.residual.abs() < 1e-9,
                "zone {} residual {}",
                zone.zone,
                a.residual
            );
            let total: f64 = a.features.iter().map(|f| f.contribution).sum();
            assert!((total - (a.prediction - a.baseline)).abs() < 1e-9);
            assert!(!a.summary.is_empty());
            // Every zone is compared against the same field average.
            assert!(
                (a.baseline
                    - fertilizer.zone_summaries[0]
                        .attribution
                        .as_ref()
                        .unwrap()
                        .baseline)
                    .abs()
                    < 1e-9
            );
        }

        // The low-growth zone is fertilised hardest, and NDVI is part of why.
        let low = fertilizer
            .zone_summaries
            .iter()
            .find(|z| z.zone.starts_with("Low"))
            .expect("a low zone exists");
        let ndvi = low
            .attribution
            .as_ref()
            .unwrap()
            .features
            .iter()
            .find(|f| f.feature == "ndvi")
            .unwrap();
        assert!(
            ndvi.contribution > 0.0,
            "a low-NDVI zone should be pushed up by NDVI, got {}",
            ndvi.contribution
        );
    }

    #[test]
    fn a_uniform_field_attributes_nothing_to_anything() {
        let engine = PrescriptionEngine::new();
        let n = 16;
        let response = engine.generate_prescription(&proto::GeneratePrescriptionRequest {
            request_id: "rx-flat".to_string(),
            field_id: "field-flat".to_string(),
            grid: Some(make_grid(4, 4)),
            zone_input: Some(make_zone_input(n)),
            crop_requirements: Some(make_crop_requirements()),
            prescription_types: vec![],
        });

        // Every cell is identical, so no input can explain a difference that
        // does not exist. The contributions must be zero, not noise.
        for p in &response.prescriptions {
            for z in &p.zone_summaries {
                let a = z.attribution.as_ref().unwrap();
                for f in &a.features {
                    assert!(
                        f.contribution.abs() < 1e-9,
                        "{} {} contributed {} on a uniform field",
                        p.prescription_type,
                        f.feature,
                        f.contribution
                    );
                }
                assert!(a.summary.contains("typical"), "{}", a.summary);
            }
        }
    }

    #[test]
    fn prescription_engine_constructs() {
        let _engine = PrescriptionEngine::new();
    }

    fn make_grid(rows: i32, cols: i32) -> proto::PrescriptionGrid {
        proto::PrescriptionGrid {
            rows,
            cols,
            cell_size_m: 10.0,
            origin_lat: 40.0,
            origin_lon: -89.0,
        }
    }

    fn make_zone_input(n: usize) -> proto::PrescriptionZoneInput {
        proto::PrescriptionZoneInput {
            ndvi: vec![0.65; n],
            soil_nitrogen: vec![30.0; n],
            soil_phosphorus: vec![15.0; n],
            soil_potassium: vec![120.0; n],
            soil_ph: vec![6.5; n],
            soil_moisture: vec![0.28; n],
            soil_organic_matter: vec![3.5; n],
        }
    }

    fn make_crop_requirements() -> proto::PrescriptionCropRequirements {
        proto::PrescriptionCropRequirements {
            crop_type: "corn".to_string(),
            target_yield_kg_ha: 10000.0,
            nitrogen_kg_ha: 180.0,
            phosphorus_kg_ha: 40.0,
            potassium_kg_ha: 60.0,
            optimal_ph_low: 6.0,
            optimal_ph_high: 7.0,
            water_requirement_mm: 500.0,
            seed_rate_per_ha: 80000.0,
        }
    }

    #[test]
    fn generate_prescription_small_grid() {
        let engine = PrescriptionEngine::new();
        let rows = 4;
        let cols = 4;
        let n = (rows * cols) as usize;

        let req = proto::GeneratePrescriptionRequest {
            request_id: "rx-001".to_string(),
            field_id: "field-p".to_string(),
            grid: Some(make_grid(rows, cols)),
            zone_input: Some(make_zone_input(n)),
            crop_requirements: Some(make_crop_requirements()),
            prescription_types: vec!["FERTILIZER".to_string()],
        };
        let resp = engine.generate_prescription(&req);
        assert_eq!(resp.request_id, "rx-001");
        assert_eq!(resp.field_id, "field-p");
        assert!(resp.processing_time_ms >= 0);
        assert!(resp.estimated_cost_savings_pct.is_finite());
        assert!(resp.estimated_yield_gain_pct.is_finite());
    }

    #[test]
    fn generate_prescription_preserves_ids() {
        let engine = PrescriptionEngine::new();
        let n = 4usize;
        let req = proto::GeneratePrescriptionRequest {
            request_id: "preserve-id".to_string(),
            field_id: "field-q".to_string(),
            grid: Some(make_grid(2, 2)),
            zone_input: Some(make_zone_input(n)),
            crop_requirements: Some(make_crop_requirements()),
            prescription_types: vec![],
        };
        let resp = engine.generate_prescription(&req);
        assert_eq!(resp.request_id, "preserve-id");
        assert_eq!(resp.field_id, "field-q");
    }

    #[test]
    fn generate_prescription_produces_prescriptions() {
        let engine = PrescriptionEngine::new();
        let rows = 3;
        let cols = 3;
        let n = (rows * cols) as usize;

        let req = proto::GeneratePrescriptionRequest {
            request_id: "rx-002".to_string(),
            field_id: "field-r".to_string(),
            grid: Some(make_grid(rows, cols)),
            zone_input: Some(make_zone_input(n)),
            crop_requirements: Some(make_crop_requirements()),
            prescription_types: vec![],
        };
        let resp = engine.generate_prescription(&req);
        // Should produce at least one prescription map
        assert!(!resp.prescriptions.is_empty());
        for p in &resp.prescriptions {
            assert!(!p.prescription_type.is_empty());
            assert!(!p.unit.is_empty());
        }
    }
}
