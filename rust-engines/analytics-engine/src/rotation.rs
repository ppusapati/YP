use crate::types::*;

pub fn analyze_rotation(records: &[SeasonRecord]) -> Option<RotationScore> {
    if records.len() < 3 {
        return None;
    }

    let mut sorted: Vec<&SeasonRecord> = records.iter().collect();
    sorted.sort_by_key(|r| r.year);

    let rotation_pattern: Vec<String> = sorted.iter().map(|r| r.crop_type.clone()).collect();
    let unique_crops: std::collections::HashSet<&str> =
        rotation_pattern.iter().map(|s| s.as_str()).collect();
    let diversity = unique_crops.len() as f64 / rotation_pattern.len() as f64;

    let yields: Vec<f64> = sorted
        .iter()
        .filter_map(|r| r.yield_kg_per_ha)
        .collect();
    let mean_yield = if yields.is_empty() {
        0.0
    } else {
        yields.iter().sum::<f64>() / yields.len() as f64
    };

    let stress_vals: Vec<f64> = sorted.iter().map(|r| r.stress_days as f64).collect();
    let mean_stress = stress_vals.iter().sum::<f64>() / stress_vals.len() as f64;

    let has_legume = rotation_pattern.iter().any(|c| {
        let lower = c.to_lowercase();
        lower.contains("soy") || lower.contains("bean") || lower.contains("pea")
            || lower.contains("lentil") || lower.contains("chickpea") || lower.contains("groundnut")
    });

    let consecutive_same = consecutive_same_crop(&rotation_pattern);

    let mut effectiveness = diversity * 40.0;
    if has_legume {
        effectiveness += 20.0;
    }
    if consecutive_same <= 1 {
        effectiveness += 20.0;
    } else if consecutive_same == 2 {
        effectiveness += 10.0;
    }

    let yield_impact = if yields.len() >= 2 {
        let first_half = &yields[..yields.len() / 2];
        let second_half = &yields[yields.len() / 2..];
        let avg_first = first_half.iter().sum::<f64>() / first_half.len() as f64;
        let avg_second = second_half.iter().sum::<f64>() / second_half.len() as f64;
        if avg_first > 0.0 {
            ((avg_second - avg_first) / avg_first) * 100.0
        } else {
            0.0
        }
    } else {
        0.0
    };

    let stress_impact = if stress_vals.len() >= 2 {
        let first_half = &stress_vals[..stress_vals.len() / 2];
        let second_half = &stress_vals[stress_vals.len() / 2..];
        let avg_first = first_half.iter().sum::<f64>() / first_half.len() as f64;
        let avg_second = second_half.iter().sum::<f64>() / second_half.len() as f64;
        if avg_first > 0.0 {
            ((avg_first - avg_second) / avg_first) * 100.0
        } else {
            0.0
        }
    } else {
        0.0
    };

    effectiveness = (effectiveness + yield_impact.max(0.0).min(20.0)).min(100.0).max(0.0);

    let recommendation = if effectiveness > 70.0 {
        "Excellent rotation pattern. Continue current practice.".into()
    } else if effectiveness > 40.0 {
        if !has_legume {
            "Consider adding a legume crop to the rotation for nitrogen fixation.".into()
        } else if consecutive_same > 2 {
            "Avoid planting the same crop consecutively to break pest and disease cycles.".into()
        } else {
            "Good rotation. Consider diversifying with cover crops between seasons.".into()
        }
    } else {
        "Rotation needs improvement. Increase crop diversity and include legumes.".into()
    };

    Some(RotationScore {
        rotation_pattern,
        effectiveness_score: effectiveness,
        yield_impact_pct: yield_impact,
        stress_reduction_pct: stress_impact,
        recommendation,
    })
}

fn consecutive_same_crop(pattern: &[String]) -> usize {
    let mut max_consecutive = 0;
    let mut current = 0;

    for i in 1..pattern.len() {
        if pattern[i] == pattern[i - 1] {
            current += 1;
            max_consecutive = max_consecutive.max(current);
        } else {
            current = 0;
        }
    }

    max_consecutive
}

#[cfg(test)]
mod tests {
    use super::*;
    use chrono::NaiveDate;

    fn make_record(year: i32, crop: &str, yield_val: f64, stress: u32) -> SeasonRecord {
        SeasonRecord {
            field_id: "f1".into(),
            farm_id: "farm1".into(),
            crop_type: crop.into(),
            season: "kharif".into(),
            year,
            planting_date: NaiveDate::from_ymd_opt(year, 6, 1).unwrap(),
            harvest_date: Some(NaiveDate::from_ymd_opt(year, 11, 1).unwrap()),
            yield_kg_per_ha: Some(yield_val),
            target_yield_kg_per_ha: Some(4000.0),
            stress_days: stress,
            frost_events: 0,
            heat_events: 0,
            drought_days: 0,
            total_precipitation_mm: 800.0,
            mean_temperature: 28.0,
            mean_ndvi: 0.65,
            peak_ndvi: 0.8,
            total_thermal_time: 1500.0,
            interventions: vec![],
        }
    }

    #[test]
    fn test_good_rotation() {
        let records = vec![
            make_record(2022, "Rice", 3500.0, 10),
            make_record(2023, "Soybean", 2000.0, 5),
            make_record(2024, "Wheat", 3800.0, 8),
            make_record(2025, "Soybean", 2200.0, 4),
        ];
        let score = analyze_rotation(&records).unwrap();
        assert!(score.effectiveness_score > 50.0);
    }

    #[test]
    fn test_monoculture() {
        let records = vec![
            make_record(2022, "Rice", 3500.0, 10),
            make_record(2023, "Rice", 3200.0, 15),
            make_record(2024, "Rice", 2900.0, 20),
        ];
        let score = analyze_rotation(&records).unwrap();
        assert!(score.effectiveness_score < 50.0);
    }

    #[test]
    fn test_insufficient_data() {
        let records = vec![make_record(2024, "Rice", 3500.0, 10)];
        assert!(analyze_rotation(&records).is_none());
    }
}
