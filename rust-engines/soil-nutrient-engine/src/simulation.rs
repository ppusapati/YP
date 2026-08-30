use crate::diffusion::{apply_root_uptake, diffusion_step};
use crate::types::*;

pub fn simulate(config: &SimConfig, initial_grid: &SoilGrid, root_zone: &[(usize, usize)], uptake_rate: f64) -> SimulationResult {
    let mut grid = initial_grid.clone();
    let steps = (config.total_time_s / config.time_step_s) as usize;

    for _ in 0..steps {
        grid = diffusion_step(&grid, config);
        if !root_zone.is_empty() {
            apply_root_uptake(&mut grid, root_zone, uptake_rate);
        }
    }

    let total_mass: f64 = grid.data.iter().sum();
    SimulationResult {
        mean_concentration: grid.mean(),
        max_concentration: grid.max_val(),
        total_mass,
        width: grid.width,
        height: grid.height,
        final_concentrations: grid.data,
        steps_computed: steps,
    }
}

pub fn simulate_nutrient_profile(
    config: &SimConfig,
    profile: &NutrientProfile,
    root_zone: &[(usize, usize)],
    uptake_rate: f64,
) -> (SimulationResult, SimulationResult, SimulationResult) {
    let n_grid = SoilGrid::new(config.grid_width, config.grid_height, profile.nitrogen);
    let p_grid = SoilGrid::new(config.grid_width, config.grid_height, profile.phosphorus);
    let k_grid = SoilGrid::new(config.grid_width, config.grid_height, profile.potassium);

    let n_result = simulate(config, &n_grid, root_zone, uptake_rate);
    let p_result = simulate(config, &p_grid, root_zone, uptake_rate * 0.3);
    let k_result = simulate(config, &k_grid, root_zone, uptake_rate * 0.7);

    (n_result, p_result, k_result)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_simulate_basic() {
        let config = SimConfig {
            grid_width: 10, grid_height: 10,
            cell_size_m: 0.01, time_step_s: 0.5,
            diffusion_coeff: 1e-7, advection_vx: 0.0, advection_vy: 0.0,
            total_time_s: 5.0,
        };
        let grid = SoilGrid::new(10, 10, 50.0);
        let result = simulate(&config, &grid, &[], 0.0);
        assert_eq!(result.steps_computed, 10);
        assert!(result.mean_concentration > 0.0);
    }

    #[test]
    fn test_uptake_reduces_concentration() {
        let config = SimConfig {
            grid_width: 10, grid_height: 10,
            cell_size_m: 0.01, time_step_s: 0.5,
            diffusion_coeff: 1e-7, advection_vx: 0.0, advection_vy: 0.0,
            total_time_s: 10.0,
        };
        let grid = SoilGrid::new(10, 10, 50.0);
        let roots: Vec<(usize, usize)> = (3..7).flat_map(|x| (3..7).map(move |y| (x, y))).collect();
        let result = simulate(&config, &grid, &roots, 0.01);
        assert!(result.mean_concentration < 50.0);
    }
}
