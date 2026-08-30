use crate::proto;
use prescription_engine::prescribe::*;
use prescription_engine::types::*;
use std::time::Instant;

pub struct PrescriptionEngine;

impl PrescriptionEngine {
    pub fn new() -> Self {
        Self
    }

    pub fn generate_prescription(&self, req: &proto::GeneratePrescriptionRequest) -> proto::GeneratePrescriptionResponse {
        let start = Instant::now();

        let grid_proto = req.grid.as_ref().expect("grid required");
        let input_proto = req.zone_input.as_ref().expect("zone_input required");
        let crop_proto = req.crop_requirements.as_ref().expect("crop_requirements required");

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

        let prescriptions = bundle.prescriptions.iter().map(|p| {
            let zone_summaries = p.zone_summaries.iter().map(|z| proto::PrescriptionZoneSummary {
                zone: z.zone.label().to_string(),
                cell_count: z.cell_count as i32,
                area_ha: z.area_ha,
                mean_rate: z.mean_rate,
                min_rate: z.min_rate,
                max_rate: z.max_rate,
                total_amount: z.total_amount,
            }).collect();

            proto::PrescriptionMapResult {
                prescription_type: p.prescription_type.label().to_string(),
                rates: p.rates.clone(),
                unit: p.unit.clone(),
                total_amount: p.total_amount,
                zone_summaries,
            }
        }).collect();

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
