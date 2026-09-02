use crate::biogeochemistry;
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

// ---------------------------------------------------------------------------
// Extended simulation with biogeochemistry
// ---------------------------------------------------------------------------

/// Per-cell nutrient state for the biogeochemistry-aware simulation.
#[derive(Debug, Clone)]
pub struct BiogeochemState {
    pub nh4: SoilGrid,
    pub no3: SoilGrid,
    pub organic_n: SoilGrid,
    pub organic_c: SoilGrid,
    pub phosphorus: SoilGrid,
    pub potassium: SoilGrid,
    pub water_content: SoilGrid,
    pub temperature: SoilGrid,
}

impl BiogeochemState {
    /// Initialise every grid from a `NutrientProfile` (uniform values).
    pub fn from_profile(profile: &NutrientProfile, w: usize, h: usize) -> Self {
        Self {
            nh4: SoilGrid::new(w, h, profile.nh4),
            no3: SoilGrid::new(w, h, profile.no3),
            organic_n: SoilGrid::new(w, h, profile.organic_n),
            organic_c: SoilGrid::new(w, h, profile.organic_c),
            phosphorus: SoilGrid::new(w, h, profile.phosphorus),
            potassium: SoilGrid::new(w, h, profile.potassium),
            water_content: SoilGrid::new(w, h, 0.25), // default VWC
            temperature: SoilGrid::new(w, h, 20.0),   // default 20 C
        }
    }
}

/// Run a combined diffusion + biogeochemistry simulation.
///
/// Each time-step:
///   1. Diffusion (existing 2-D stencil) for NO3, NH4, P, K
///   2. Biogeochemistry reactions (mineralization -> nitrification ->
///      denitrification -> root uptake -> P sorption) applied per cell
///
/// Returns the final `BiogeochemState`.
pub fn simulate_with_biogeochemistry(
    config: &SimConfig,
    profile: &NutrientProfile,
    soil_props: &SoilLayerProperties,
    root_density_grid: Option<&SoilGrid>,
) -> BiogeochemState {
    let w = config.grid_width;
    let h = config.grid_height;
    let steps = (config.total_time_s / config.time_step_s) as usize;
    let dt_days = config.time_step_s / 86_400.0; // seconds -> days

    let mut state = BiogeochemState::from_profile(profile, w, h);

    // Default uniform root density if none provided
    let default_roots = SoilGrid::new(w, h, 0.5);
    let roots = root_density_grid.unwrap_or(&default_roots);

    for _ in 0..steps {
        // --- Step 1: Diffusion for each mobile species ---
        state.no3 = diffusion_step(&state.no3, config);
        state.nh4 = diffusion_step(&state.nh4, config);
        state.phosphorus = diffusion_step(&state.phosphorus, config);
        state.potassium = diffusion_step(&state.potassium, config);

        // --- Step 2: Biogeochemistry per cell ---
        for y in 0..h {
            for x in 0..w {
                let nh4 = state.nh4.get(x, y);
                let no3 = state.no3.get(x, y);
                let org_n = state.organic_n.get(x, y);
                let org_c = state.organic_c.get(x, y);
                let p = state.phosphorus.get(x, y);
                let k = state.potassium.get(x, y);
                let temp = state.temperature.get(x, y);
                let theta = state.water_content.get(x, y);
                let rd = roots.get(x, y);

                let deltas = biogeochemistry::compute_reactions(
                    nh4, no3, org_n, org_c, p, k, temp, theta, rd, soil_props,
                );

                // Euler forward: C_new = C_old + dC/dt * dt
                state.nh4.set(x, y, (nh4 + deltas.d_nh4 * dt_days).max(0.0));
                state.no3.set(x, y, (no3 + deltas.d_no3 * dt_days).max(0.0));
                state.organic_n.set(x, y, (org_n + deltas.d_organic_n * dt_days).max(0.0));
                state.phosphorus.set(x, y, (p + deltas.d_phosphorus * dt_days).max(0.0));
                state.potassium.set(x, y, (k + deltas.d_potassium * dt_days).max(0.0));
            }
        }
    }

    state
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
