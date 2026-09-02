use crate::ode::{StateVec, integrate};
use crate::types::*;
use crate::wofost::*;
use crate::phenology;

pub fn simulate(
    params: &CropParams,
    weather_series: &[DailyWeather],
    initial_soil_moisture: f64,
    days: u32,
) -> SimulationResult {
    let y0: StateVec = vec![0.5, 0.01, 0.0, 0.05, initial_soil_moisture];

    let actual_days = days.min(weather_series.len() as u32);

    let mut daily_states = Vec::with_capacity(actual_days as usize);
    let mut current_state = y0;

    // Phenology state (if full phenology model is enabled)
    let mut pheno_state = params
        .phenology
        .as_ref()
        .map(|_| phenology::PhenologyState::default());

    // Cumulative organ biomasses
    let mut biomass_root = 0.0_f64;
    let mut biomass_leaf = 0.0_f64;
    let mut biomass_stem = 0.0_f64;
    let mut biomass_storage = 0.0_f64;

    for day in 0..actual_days {
        let weather = &weather_series[day as usize];
        let prev_biomass = current_state[IDX_BIOMASS];

        // Compute phenology-adjusted GDD if enabled
        let phenology_gdd = match (&params.phenology, pheno_state.as_mut()) {
            (Some(pheno_params), Some(ps)) => {
                let t_min = weather.temp_min();
                let t_max = weather.temp_max();
                let doy = ((pheno_params.sowing_day_of_year + day) % 365) + 1;

                let (new_ps, effective_gdd) = phenology::step_phenology(
                    ps,
                    t_min,
                    t_max,
                    params.t_base,
                    params.t_opt,
                    pheno_params,
                    doy,
                );
                *ps = new_ps;
                Some(effective_gdd)
            }
            _ => None,
        };

        let pheno_gdd = phenology_gdd;
        let f = |t: f64, y: &StateVec| -> StateVec {
            growth_derivatives(t, y, params, weather, pheno_gdd)
        };

        let trajectory = integrate(&f, &current_state, 0.0, 1.0, 0.25);
        current_state = trajectory.last().unwrap().1.clone();

        // Override DVS from phenology model if active
        let dvs = if let Some(ref ps) = pheno_state {
            let pheno_params = params.phenology.as_ref().unwrap();
            let pheno_dvs = ps.to_dvs(&pheno_params.stage_thresholds);
            current_state[IDX_DVS] = pheno_dvs;
            pheno_dvs
        } else {
            current_state[IDX_DVS]
        };

        let lai = current_state[IDX_LAI];

        // Partition daily biomass increment into organs
        let daily_growth = (current_state[IDX_BIOMASS] - prev_biomass).max(0.0);
        let (dr, dl, ds, dst) = partition_biomass(dvs, daily_growth, &params.partition);
        biomass_root += dr;
        biomass_leaf += dl;
        biomass_stem += ds;
        biomass_storage += dst;

        // Determine growth stage
        let stage = if let Some(ref ps) = pheno_state {
            ps.current_stage.to_growth_stage()
        } else {
            GrowthStage::from_dvs(dvs)
        };

        daily_states.push(SimulationState {
            day,
            biomass: current_state[IDX_BIOMASS],
            lai,
            dvs,
            root_depth: current_state[IDX_ROOT_DEPTH],
            soil_moisture: current_state[IDX_SOIL_MOISTURE],
            stage,
            canopy_height: (lai * 15.0).min(150.0),
            water_demand: 0.004
                * weather.temperature.max(0.0)
                * (1.0 - (-0.6 * lai).exp()),
            biomass_root,
            biomass_leaf,
            biomass_stem,
            biomass_storage,
        });

        if dvs >= 2.0 {
            break;
        }
    }

    let final_biomass = daily_states.last().map(|s| s.biomass).unwrap_or(0.0);
    let days_to_maturity = daily_states.len() as u32;

    SimulationResult {
        daily_states,
        final_biomass,
        estimated_yield: final_biomass * params.harvest_index,
        days_to_maturity,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_simulate_basic() {
        let params = CropParams::default();
        let weather: Vec<DailyWeather> = (0..120)
            .map(|_| DailyWeather::default())
            .collect();
        let result = simulate(&params, &weather, 60.0, 120);
        assert!(!result.daily_states.is_empty());
        assert!(result.final_biomass > 0.0);
        assert!(result.estimated_yield > 0.0);
    }

    #[test]
    fn test_biomass_increases() {
        let params = CropParams::default();
        let weather: Vec<DailyWeather> = (0..30)
            .map(|_| DailyWeather::default())
            .collect();
        let result = simulate(&params, &weather, 60.0, 30);
        let first = result.daily_states.first().unwrap().biomass;
        let last = result.daily_states.last().unwrap().biomass;
        assert!(last > first);
    }

    #[test]
    fn test_simulate_with_phenology() {
        let mut params = CropParams::default();
        params.phenology = Some(PhenologyParams::default());
        let weather: Vec<DailyWeather> = (0..120)
            .map(|_| DailyWeather {
                t_min: Some(15.0),
                t_max: Some(30.0),
                ..Default::default()
            })
            .collect();
        let result = simulate(&params, &weather, 60.0, 120);
        assert!(!result.daily_states.is_empty());
        assert!(result.final_biomass > 0.0);
    }

    #[test]
    fn test_organ_partitioning_tracked() {
        let params = CropParams::default();
        let weather: Vec<DailyWeather> = (0..60)
            .map(|_| DailyWeather::default())
            .collect();
        let result = simulate(&params, &weather, 60.0, 60);
        let last = result.daily_states.last().unwrap();
        let organ_sum = last.biomass_root
            + last.biomass_leaf
            + last.biomass_stem
            + last.biomass_storage;
        assert!(organ_sum > 0.0, "organs should accumulate biomass");
    }
}
