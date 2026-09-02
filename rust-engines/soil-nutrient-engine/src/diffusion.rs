use crate::types::{SimConfig, SoilGrid};
use crate::soil_physics;

/// Run one explicit time-step of the advection-diffusion equation on a 2-D
/// grid.  When `water_content` and `porosity` grids are provided the
/// Millington-Quirk effective diffusion coefficient is used per-cell;
/// otherwise the constant `config.diffusion_coeff` is used (backward
/// compatible).
pub fn diffusion_step(grid: &SoilGrid, config: &SimConfig) -> SoilGrid {
    diffusion_step_full(grid, config, None, None, None)
}

/// Extended diffusion step that accepts optional per-cell soil physics grids.
///
/// * `water_content` -- volumetric water content (m^3/m^3) per cell
/// * `porosity`      -- total porosity (m^3/m^3) per cell
/// * `temperature`   -- soil temperature (deg C) per cell
///
/// When all three are `Some`, Millington-Quirk + Stokes-Einstein is applied
/// with the default NO3 free-water diffusion coefficient.  When any is `None`
/// the constant `config.diffusion_coeff` is used instead.
pub fn diffusion_step_full(
    grid: &SoilGrid,
    config: &SimConfig,
    water_content: Option<&SoilGrid>,
    porosity: Option<&SoilGrid>,
    temperature: Option<&SoilGrid>,
) -> SoilGrid {
    let w = grid.width;
    let h = grid.height;
    let mut next = SoilGrid::new(w, h, 0.0);

    let dx = config.cell_size_m;
    let dt = config.time_step_s;
    let vx = config.advection_vx;
    let vy = config.advection_vy;

    let use_mq = water_content.is_some() && porosity.is_some() && temperature.is_some();

    for y in 0..h {
        for x in 0..w {
            let c = grid.get(x, y);

            // Per-cell effective diffusion coefficient
            let d = if use_mq {
                let theta = water_content.unwrap().get(x, y);
                let phi = porosity.unwrap().get(x, y);
                let temp = temperature.unwrap().get(x, y);
                // nutrient_effective_diffusion returns m^2/day; config uses
                // seconds, so convert back: m^2/s = m^2/day / 86400
                soil_physics::nutrient_effective_diffusion("no3", theta, temp, phi)
                    / 86_400.0
            } else {
                config.diffusion_coeff
            };

            let r = d * dt / (dx * dx);

            let left = if x > 0 { grid.get(x - 1, y) } else { c };
            let right = if x + 1 < w { grid.get(x + 1, y) } else { c };
            let up = if y > 0 { grid.get(x, y - 1) } else { c };
            let down = if y + 1 < h { grid.get(x, y + 1) } else { c };

            // Diffusion (5-point stencil)
            let diffusion = r * (left + right + up + down - 4.0 * c);

            // Advection (upwind scheme)
            let adv_x = if vx >= 0.0 {
                -vx * dt / dx * (c - left)
            } else {
                -vx * dt / dx * (right - c)
            };

            let adv_y = if vy >= 0.0 {
                -vy * dt / dx * (c - up)
            } else {
                -vy * dt / dx * (down - c)
            };

            let new_val = (c + diffusion + adv_x + adv_y).max(0.0);
            next.set(x, y, new_val);
        }
    }

    next
}

pub fn apply_source(grid: &mut SoilGrid, x: usize, y: usize, amount: f64) {
    let current = grid.get(x, y);
    grid.set(x, y, current + amount);
}

pub fn apply_root_uptake(grid: &mut SoilGrid, root_zone: &[(usize, usize)], rate: f64) {
    for &(x, y) in root_zone {
        let current = grid.get(x, y);
        let uptake = (current * rate).min(current);
        grid.set(x, y, current - uptake);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_diffusion_conserves_mass_approx() {
        let config = SimConfig {
            grid_width: 20, grid_height: 20,
            cell_size_m: 0.01, time_step_s: 0.1,
            diffusion_coeff: 1e-6, advection_vx: 0.0, advection_vy: 0.0,
            total_time_s: 100.0,
        };
        let mut grid = SoilGrid::new(20, 20, 0.0);
        grid.set(10, 10, 100.0);
        let initial_mass: f64 = grid.data.iter().sum();

        let next = diffusion_step(&grid, &config);
        let final_mass: f64 = next.data.iter().sum();
        assert!((initial_mass - final_mass).abs() < 1e-6);
    }

    #[test]
    fn test_source_application() {
        let mut grid = SoilGrid::new(10, 10, 5.0);
        apply_source(&mut grid, 5, 5, 10.0);
        assert_eq!(grid.get(5, 5), 15.0);
    }
}
