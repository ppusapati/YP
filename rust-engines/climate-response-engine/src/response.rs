use crate::co2::co2_fertilization_factor;
use crate::temperature::*;
use crate::types::*;
use crate::water::*;

pub fn daily_response(
    climate: &DailyClimate,
    soil_moisture: f64,
    params: &ClimateParams,
) -> CropResponse {
    let tt = thermal_time(climate.temperature_mean, params);
    let temp_stress = temperature_stress_factor(climate.temperature_mean, params);
    let frost = frost_stress(climate.temperature_min, params);
    let heat = heat_stress(climate.temperature_max, params);
    let (new_moisture, water_stress) = water_balance_step(
        soil_moisture, climate.precipitation_mm, climate.et_reference_mm, params,
    );
    let di = drought_index(new_moisture, params);
    let co2 = co2_fertilization_factor(climate.co2_ppm, params);

    let combined = temp_stress * (1.0 - frost) * (1.0 - heat) * water_stress * co2;

    CropResponse {
        thermal_time: tt,
        growth_factor: combined.max(0.0),
        stress: StressFactors {
            temperature_stress: 1.0 - temp_stress,
            heat_stress: heat,
            frost_stress: frost,
            water_stress: 1.0 - water_stress,
            drought_index: di,
            co2_factor: co2,
            combined_stress: 1.0 - combined.max(0.0),
        },
        soil_moisture: new_moisture,
        cumulative_thermal_time: 0.0,
    }
}

pub fn simulate_season(
    climate_series: &[DailyClimate],
    params: &ClimateParams,
    initial_moisture: f64,
) -> SeasonResult {
    let mut moisture = initial_moisture;
    let mut cumulative_tt = 0.0;
    let mut daily_responses = Vec::with_capacity(climate_series.len());
    let mut stress_days = 0u32;
    let mut frost_events = 0u32;
    let mut heat_events = 0u32;
    let mut drought_days = 0u32;

    for climate in climate_series {
        let mut resp = daily_response(climate, moisture, params);
        cumulative_tt += resp.thermal_time;
        resp.cumulative_thermal_time = cumulative_tt;
        moisture = resp.soil_moisture;

        if resp.stress.combined_stress > 0.3 { stress_days += 1; }
        if resp.stress.frost_stress > 0.0 { frost_events += 1; }
        if resp.stress.heat_stress > 0.0 { heat_events += 1; }
        if resp.stress.drought_index > 0.3 { drought_days += 1; }

        daily_responses.push(resp);
    }

    let mean_growth = if daily_responses.is_empty() {
        0.0
    } else {
        daily_responses.iter().map(|r| r.growth_factor).sum::<f64>() / daily_responses.len() as f64
    };

    SeasonResult {
        daily_responses,
        total_thermal_time: cumulative_tt,
        mean_growth_factor: mean_growth,
        stress_days,
        frost_events,
        heat_events,
        drought_days,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_daily_response_optimal() {
        let climate = DailyClimate::default();
        let params = ClimateParams::default();
        let resp = daily_response(&climate, 0.30, &params);
        assert!(resp.growth_factor > 0.5);
        assert!(resp.thermal_time > 0.0);
    }

    #[test]
    fn test_season_simulation() {
        let params = ClimateParams::default();
        let climate: Vec<DailyClimate> = (0..90).map(|_| DailyClimate::default()).collect();
        let result = simulate_season(&climate, &params, 0.30);
        assert_eq!(result.daily_responses.len(), 90);
        assert!(result.total_thermal_time > 0.0);
        assert!(result.mean_growth_factor > 0.0);
    }
}
