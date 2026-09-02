use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SimConfig {
    pub grid_width: usize,
    pub grid_height: usize,
    pub cell_size_m: f64,
    pub time_step_s: f64,
    pub total_time_s: f64,
    pub diffusion_coeff: f64,
    pub advection_vx: f64,
    pub advection_vy: f64,
}

impl Default for SimConfig {
    fn default() -> Self {
        Self {
            grid_width: 50,
            grid_height: 50,
            cell_size_m: 0.02,
            time_step_s: 1.0,
            total_time_s: 3600.0,
            diffusion_coeff: 1e-9,
            advection_vx: 0.0,
            advection_vy: -1e-6,
            }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NutrientProfile {
    pub nitrogen: f64,
    pub phosphorus: f64,
    pub potassium: f64,
    /// NH4-N concentration (mg/kg). Split from the aggregate `nitrogen` field
    /// so biogeochemistry can track ammonium and nitrate separately.
    #[serde(default = "default_nh4")]
    pub nh4: f64,
    /// NO3-N concentration (mg/kg).
    #[serde(default = "default_no3")]
    pub no3: f64,
    /// Organic nitrogen pool (mg/kg).
    #[serde(default = "default_organic_n")]
    pub organic_n: f64,
    /// Organic carbon pool (mg/kg).
    #[serde(default = "default_organic_c")]
    pub organic_c: f64,
    /// Soil pH.
    #[serde(default = "default_ph")]
    pub ph: f64,
}

fn default_nh4() -> f64 { 5.0 }
fn default_no3() -> f64 { 15.0 }
fn default_organic_n() -> f64 { 200.0 }
fn default_organic_c() -> f64 { 20_000.0 }
fn default_ph() -> f64 { 6.5 }

impl Default for NutrientProfile {
    fn default() -> Self {
        Self {
            nitrogen: 50.0,
            phosphorus: 20.0,
            potassium: 30.0,
            nh4: default_nh4(),
            no3: default_no3(),
            organic_n: default_organic_n(),
            organic_c: default_organic_c(),
            ph: default_ph(),
        }
    }
}

/// Physical and chemical properties of a soil layer, used by the
/// biogeochemistry and soil-physics modules.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SoilLayerProperties {
    /// Clay mass fraction (0-1).
    pub clay_fraction: f64,
    /// Total porosity (m^3/m^3).
    pub porosity: f64,
    /// Field capacity (m^3/m^3).
    pub field_capacity: f64,
    /// Saturated hydraulic conductivity (m/day).
    pub k_sat: f64,
    /// Soil pH.
    pub ph: f64,
}

impl Default for SoilLayerProperties {
    fn default() -> Self {
        Self {
            clay_fraction: 0.25,
            porosity: 0.45,
            field_capacity: 0.30,
            k_sat: 0.5,
            ph: 6.5,
        }
    }
}

impl SoilLayerProperties {
    /// Freundlich K_f for phosphorus sorption, adjusted by clay and pH
    /// (matches the Julia `phosphorus_sorption` helper).
    pub fn kf_phosphorus(&self) -> f64 {
        let kf_base = 0.5;
        let kf_adj = kf_base * (self.clay_fraction / 0.25) * (1.0 + 0.1 * (7.0 - self.ph));
        f64::max(0.01, kf_adj)
    }
}

#[derive(Debug, Clone)]
pub struct SoilGrid {
    pub width: usize,
    pub height: usize,
    pub data: Vec<f64>,
}

impl SoilGrid {
    pub fn new(width: usize, height: usize, initial: f64) -> Self {
        Self { width, height, data: vec![initial; width * height] }
    }

    #[inline]
    pub fn get(&self, x: usize, y: usize) -> f64 {
        self.data[y * self.width + x]
    }

    #[inline]
    pub fn set(&mut self, x: usize, y: usize, val: f64) {
        self.data[y * self.width + x] = val;
    }

    pub fn mean(&self) -> f64 {
        let sum: f64 = self.data.iter().sum();
        sum / self.data.len() as f64
    }

    pub fn max_val(&self) -> f64 {
        self.data.iter().cloned().fold(f64::NEG_INFINITY, f64::max)
    }

    pub fn min_val(&self) -> f64 {
        self.data.iter().cloned().fold(f64::INFINITY, f64::min)
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SimulationResult {
    pub final_concentrations: Vec<f64>,
    pub width: usize,
    pub height: usize,
    pub mean_concentration: f64,
    pub max_concentration: f64,
    pub total_mass: f64,
    pub steps_computed: usize,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_soil_grid() {
        let mut grid = SoilGrid::new(10, 10, 5.0);
        assert_eq!(grid.get(3, 4), 5.0);
        grid.set(3, 4, 10.0);
        assert_eq!(grid.get(3, 4), 10.0);
        assert!((grid.mean() - 5.05).abs() < 0.01);
    }
}
