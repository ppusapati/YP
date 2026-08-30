use crate::types::*;

pub fn classify_zones(ndvi: &[f64], num_zones: usize) -> ZoneClassification {
    if ndvi.is_empty() {
        return ZoneClassification {
            zones: vec![],
            zone_boundaries: vec![],
        };
    }

    let mut sorted: Vec<f64> = ndvi.to_vec();
    sorted.sort_by(|a, b| a.partial_cmp(b).unwrap_or(std::cmp::Ordering::Equal));

    let boundaries: Vec<f64> = (1..num_zones)
        .map(|i| {
            let idx = (sorted.len() * i / num_zones).min(sorted.len() - 1);
            sorted[idx]
        })
        .collect();

    let zones = ndvi
        .iter()
        .map(|&v| {
            if num_zones <= 1 {
                ManagementZone::Medium
            } else if v < boundaries[0] {
                ManagementZone::Low
            } else if boundaries.len() > 1 && v >= boundaries[boundaries.len() - 1] {
                ManagementZone::High
            } else {
                ManagementZone::Medium
            }
        })
        .collect();

    ZoneClassification {
        zones,
        zone_boundaries: boundaries,
    }
}

pub fn zone_summary(
    grid: &FieldGrid,
    zones: &ZoneClassification,
    rates: &[f64],
) -> Vec<ZoneSummary> {
    let cell_area = grid.cell_area_ha();
    let mut summaries = vec![
        (ManagementZone::Low, Vec::new()),
        (ManagementZone::Medium, Vec::new()),
        (ManagementZone::High, Vec::new()),
    ];

    for (i, zone) in zones.zones.iter().enumerate() {
        let rate = rates.get(i).copied().unwrap_or(0.0);
        for (z, rates_vec) in &mut summaries {
            if z == zone {
                rates_vec.push(rate);
                break;
            }
        }
    }

    summaries
        .into_iter()
        .filter(|(_, rates)| !rates.is_empty())
        .map(|(zone, rates)| {
            let count = rates.len();
            let area = count as f64 * cell_area;
            let mean = rates.iter().sum::<f64>() / count as f64;
            let min = rates.iter().copied().fold(f64::INFINITY, f64::min);
            let max = rates.iter().copied().fold(f64::NEG_INFINITY, f64::max);
            let total = rates.iter().sum::<f64>() * cell_area;

            ZoneSummary {
                zone,
                cell_count: count,
                area_ha: area,
                mean_rate: mean,
                min_rate: min,
                max_rate: max,
                total_amount: total,
            }
        })
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_classify_zones() {
        let ndvi = vec![0.2, 0.3, 0.5, 0.6, 0.7, 0.8, 0.85, 0.9, 0.4, 0.1];
        let result = classify_zones(&ndvi, 3);
        assert_eq!(result.zones.len(), 10);
        assert!(result.zone_boundaries.len() == 2);
    }

    #[test]
    fn test_empty_ndvi() {
        let result = classify_zones(&[], 3);
        assert!(result.zones.is_empty());
    }

    #[test]
    fn test_zone_summary() {
        let grid = FieldGrid {
            field_id: "f1".into(),
            rows: 2,
            cols: 3,
            cell_size_m: 100.0,
            origin_lat: 17.0,
            origin_lon: 78.0,
        };
        let zones = ZoneClassification {
            zones: vec![
                ManagementZone::Low, ManagementZone::Low,
                ManagementZone::Medium, ManagementZone::Medium,
                ManagementZone::High, ManagementZone::High,
            ],
            zone_boundaries: vec![0.4, 0.7],
        };
        let rates = vec![150.0, 140.0, 120.0, 110.0, 80.0, 90.0];
        let summaries = zone_summary(&grid, &zones, &rates);
        assert_eq!(summaries.len(), 3);
        assert!(summaries[0].mean_rate > summaries[2].mean_rate);
    }
}
