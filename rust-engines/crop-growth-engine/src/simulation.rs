use crate::ode::{StateVec, integrate};
use crate::types::*;
use crate::wofost::*;

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

    for day in 0..actual_days {
        let weather = &weather_series[day as usize];

        let f = |t: f64, y: &StateVec| -> StateVec {
            growth_derivatives(t, y, params, weather)
        };

        let trajectory = integrate(&f, &current_state, 0.0, 1.0, 0.25);
        current_state = trajectory.last().unwrap().1.clone();

        let dvs = current_state[IDX_DVS];
        let lai = current_state[IDX_LAI];

        daily_states.push(SimulationState {
            day,
            biomass: current_state[IDX_BIOMASS],
            lai,
            dvs,
            root_depth: current_state[IDX_ROOT_DEPTH],
            soil_moisture: current_state[IDX_SOIL_MOISTURE],
            stage: GrowthStage::from_dvs(dvs),
            canopy_height: (lai * 15.0).min(150.0),
            water_demand: 0.004 * weather.temperature.max(0.0) * (1.0 - (-0.6 * lai).exp()),
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
}
