use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum PrescriptionType {
    Fertilizer,
    Irrigation,
    Seeding,
    Pesticide,
    Liming,
}

impl PrescriptionType {
    pub fn label(&self) -> &'static str {
        match self {
            Self::Fertilizer => "Fertilizer Application",
            Self::Irrigation => "Irrigation Schedule",
            Self::Seeding => "Variable Rate Seeding",
            Self::Pesticide => "Targeted Pesticide",
            Self::Liming => "Soil Liming",
        }
    }

    pub fn unit(&self) -> &'static str {
        match self {
            Self::Fertilizer => "kg/ha",
            Self::Irrigation => "mm",
            Self::Seeding => "seeds/ha",
            Self::Pesticide => "L/ha",
            Self::Liming => "kg/ha",
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FieldGrid {
    pub field_id: String,
    pub rows: usize,
    pub cols: usize,
    pub cell_size_m: f64,
    pub origin_lat: f64,
    pub origin_lon: f64,
}

impl FieldGrid {
    pub fn cell_count(&self) -> usize {
        self.rows * self.cols
    }

    pub fn cell_area_ha(&self) -> f64 {
        (self.cell_size_m * self.cell_size_m) / 10_000.0
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ZoneInput {
    pub ndvi: Vec<f64>,
    pub soil_nitrogen: Vec<f64>,
    pub soil_phosphorus: Vec<f64>,
    pub soil_potassium: Vec<f64>,
    pub soil_ph: Vec<f64>,
    pub soil_moisture: Vec<f64>,
    pub soil_organic_matter: Vec<f64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CropRequirements {
    pub crop_type: String,
    pub target_yield_kg_ha: f64,
    pub nitrogen_kg_ha: f64,
    pub phosphorus_kg_ha: f64,
    pub potassium_kg_ha: f64,
    pub optimal_ph_low: f64,
    pub optimal_ph_high: f64,
    pub water_requirement_mm: f64,
    pub seed_rate_per_ha: f64,
}

impl Default for CropRequirements {
    fn default() -> Self {
        Self {
            crop_type: "wheat".into(),
            target_yield_kg_ha: 4000.0,
            nitrogen_kg_ha: 120.0,
            phosphorus_kg_ha: 40.0,
            potassium_kg_ha: 60.0,
            optimal_ph_low: 6.0,
            optimal_ph_high: 7.5,
            water_requirement_mm: 450.0,
            seed_rate_per_ha: 150_000.0,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum ManagementZone {
    Low,
    Medium,
    High,
}

impl ManagementZone {
    pub fn label(&self) -> &'static str {
        match self {
            Self::Low => "Low Productivity",
            Self::Medium => "Medium Productivity",
            Self::High => "High Productivity",
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ZoneClassification {
    pub zones: Vec<ManagementZone>,
    pub zone_boundaries: Vec<f64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PrescriptionMap {
    pub field_id: String,
    pub prescription_type: PrescriptionType,
    pub grid: FieldGrid,
    pub zones: ZoneClassification,
    pub rates: Vec<f64>,
    pub unit: String,
    pub total_amount: f64,
    pub zone_summaries: Vec<ZoneSummary>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ZoneSummary {
    pub zone: ManagementZone,
    pub cell_count: usize,
    pub area_ha: f64,
    pub mean_rate: f64,
    pub min_rate: f64,
    pub max_rate: f64,
    pub total_amount: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PrescriptionBundle {
    pub field_id: String,
    pub crop_type: String,
    pub prescriptions: Vec<PrescriptionMap>,
    pub estimated_cost_savings_pct: f64,
    pub estimated_yield_gain_pct: f64,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_field_grid() {
        let grid = FieldGrid {
            field_id: "f1".into(),
            rows: 10,
            cols: 20,
            cell_size_m: 10.0,
            origin_lat: 17.0,
            origin_lon: 78.0,
        };
        assert_eq!(grid.cell_count(), 200);
        assert!((grid.cell_area_ha() - 0.01).abs() < 1e-6);
    }

    #[test]
    fn test_prescription_type_unit() {
        assert_eq!(PrescriptionType::Fertilizer.unit(), "kg/ha");
        assert_eq!(PrescriptionType::Irrigation.unit(), "mm");
    }
}
