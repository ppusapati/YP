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
}

impl Default for NutrientProfile {
    fn default() -> Self {
        Self { nitrogen: 50.0, phosphorus: 20.0, potassium: 30.0 }
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
