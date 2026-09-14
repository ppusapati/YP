//! Assemble the yield training set from field-season records.
//!
//! Yield is recorded per field per season; weather arrives daily; NDVI arrives
//! per satellite pass. Training needs one row per field-season with the weather
//! already aggregated and the NDVI already reduced to its peak, which is a join
//! and a fold rather than anything clever — but it is a join with enough edge
//! cases to be worth doing in one place and testing.
//!
//! Those edge cases are where a training set quietly goes wrong. A field-season
//! with no weather is not a row with zero rainfall; it is a row that should not
//! be there, because the model would learn that no rain is compatible with a
//! good harvest. Observations from the wrong season are worse still, and a
//! field whose harvest was recorded before the season ended will be missing its
//! late weather entirely.
//!
//! The joining and folding here are pure, so they can be tested without a
//! database. Reading the source rows is left to the caller.

use std::collections::BTreeMap;

use serde::{Deserialize, Serialize};

/// One recorded harvest: what the model is asked to predict.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct YieldRecord {
    pub field_id: String,
    pub season: String,
    pub crop: String,
    pub yield_kg_ha: f64,
    /// Inclusive season bounds as `YYYY-MM-DD`; observations outside them
    /// belong to a different season and must not be folded in.
    pub season_start: String,
    pub season_end: String,
    #[serde(default)]
    pub nitrogen_applied_kg_ha: f64,
    #[serde(default)]
    pub irrigation_mm: f64,
    #[serde(default)]
    pub plant_population_per_ha: f64,
    #[serde(default)]
    pub planting_day: f64,
    #[serde(default)]
    pub pest_control_effectiveness: f64,
    #[serde(default)]
    pub organic_matter_pct: f64,
    #[serde(default)]
    pub ph: f64,
    #[serde(default)]
    pub nitrogen_kg_ha: f64,
    #[serde(default)]
    pub phosphorus_kg_ha: f64,
    #[serde(default)]
    pub potassium_kg_ha: f64,
    #[serde(default)]
    pub water_holding_capacity_mm_m: f64,
    #[serde(default)]
    pub compaction_index: f64,
    #[serde(default)]
    pub prior_yield_mean_kg_ha: f64,
}

/// One day of weather at a field.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct WeatherDay {
    pub field_id: String,
    /// `YYYY-MM-DD`.
    pub date: String,
    pub temperature_c: f64,
    pub precipitation_mm: f64,
    #[serde(default)]
    pub humidity_pct: f64,
    #[serde(default)]
    pub solar_radiation_mj_m2: f64,
}

/// One NDVI reading from a satellite pass.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct NdviReading {
    pub field_id: String,
    /// `YYYY-MM-DD`.
    pub date: String,
    pub ndvi: f64,
}

/// Weather folded down to the season.
#[derive(Debug, Clone, Copy, PartialEq, Default)]
pub struct SeasonWeather {
    pub days: usize,
    pub avg_temperature_c: f64,
    pub total_precipitation_mm: f64,
    pub avg_humidity_pct: f64,
    pub avg_solar_radiation: f64,
    pub growing_degree_days: f64,
    pub frost_days: f64,
    pub heat_stress_days: f64,
}

/// Base temperature for growing-degree days, in Celsius.
///
/// Ten degrees is the usual base for the warm-season cereals this platform
/// mostly serves; below it, growth is close enough to stopped that counting the
/// day would overstate accumulated heat.
pub const GDD_BASE_C: f64 = 10.0;

/// Below this, frost damage is a real risk rather than merely a cold night.
pub const FROST_C: f64 = 0.0;

/// Above this, heat starts costing yield in most cereals.
pub const HEAT_STRESS_C: f64 = 35.0;

/// Minimum days of weather before a field-season is worth training on.
///
/// A season covered by a handful of readings is not a season; its "total
/// rainfall" is whatever happened to be recorded, and a model fitted on it
/// learns that dry seasons produce good harvests.
pub const MIN_WEATHER_DAYS: usize = 30;

/// Why a field-season was left out.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Excluded {
    pub field_id: String,
    pub season: String,
    pub reason: String,
}

/// What one assembly run produced.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct AssemblyReport {
    pub rows: usize,
    pub excluded: Vec<Excluded>,
}

/// Fold a field's weather down to the season it belongs to.
pub fn season_weather(days: &[&WeatherDay]) -> SeasonWeather {
    if days.is_empty() {
        return SeasonWeather::default();
    }
    let n = days.len() as f64;
    let mut w = SeasonWeather {
        days: days.len(),
        ..Default::default()
    };
    for d in days {
        w.avg_temperature_c += d.temperature_c;
        w.total_precipitation_mm += d.precipitation_mm;
        w.avg_humidity_pct += d.humidity_pct;
        w.avg_solar_radiation += d.solar_radiation_mj_m2;
        if d.temperature_c > GDD_BASE_C {
            w.growing_degree_days += d.temperature_c - GDD_BASE_C;
        }
        if d.temperature_c <= FROST_C {
            w.frost_days += 1.0;
        }
        if d.temperature_c >= HEAT_STRESS_C {
            w.heat_stress_days += 1.0;
        }
    }
    w.avg_temperature_c /= n;
    w.avg_humidity_pct /= n;
    w.avg_solar_radiation /= n;
    w
}

/// Whether a date falls inside a season, comparing `YYYY-MM-DD` as text.
///
/// ISO dates sort the same as they order, so string comparison is correct here
/// and avoids parsing several thousand dates per run.
fn within(date: &str, start: &str, end: &str) -> bool {
    date >= start && date <= end
}

/// Column order the trainer expects. `crop_code` is resolved by the caller,
/// which is what knows the crop table.
pub const COLUMNS: [&str; 23] = [
    "field_id",
    "season",
    "crop_code",
    "avg_temperature_c",
    "total_precipitation_mm",
    "solar_radiation_mj_m2_day",
    "growing_degree_days",
    "frost_days",
    "heat_stress_days",
    "relative_humidity_pct",
    "organic_matter_pct",
    "ph",
    "nitrogen_kg_ha",
    "phosphorus_kg_ha",
    "potassium_kg_ha",
    "water_holding_capacity_mm_m",
    "compaction_index",
    "planting_day",
    "plant_population_per_ha",
    "nitrogen_applied_kg_ha",
    "irrigation_mm",
    "pest_control_effectiveness",
    "ndvi_peak",
];

/// The target column, appended last.
pub const TARGET_COLUMN: &str = "yield_kg_ha";

/// Join harvests to their weather and imagery and write one CSV row each.
///
/// `crop_code` maps a crop name to the numeric code the model was trained
/// with; a crop it does not know is excluded rather than coded as something
/// else.
pub fn assemble(
    yields: &[YieldRecord],
    weather: &[WeatherDay],
    ndvi: &[NdviReading],
    crop_code: impl Fn(&str) -> Option<f64>,
) -> (String, AssemblyReport) {
    // Index once; the alternative is a scan per harvest.
    let mut weather_by_field: BTreeMap<&str, Vec<&WeatherDay>> = BTreeMap::new();
    for d in weather {
        weather_by_field.entry(d.field_id.as_str()).or_default().push(d);
    }
    let mut ndvi_by_field: BTreeMap<&str, Vec<&NdviReading>> = BTreeMap::new();
    for r in ndvi {
        ndvi_by_field.entry(r.field_id.as_str()).or_default().push(r);
    }

    let mut out = String::new();
    out.push_str(&COLUMNS.join(","));
    out.push(',');
    out.push_str(TARGET_COLUMN);
    out.push('\n');

    let mut report = AssemblyReport::default();
    let exclude = |rec: &YieldRecord, reason: &str, report: &mut AssemblyReport| {
        report.excluded.push(Excluded {
            field_id: rec.field_id.clone(),
            season: rec.season.clone(),
            reason: reason.to_string(),
        });
    };

    for rec in yields {
        if !rec.yield_kg_ha.is_finite() || rec.yield_kg_ha <= 0.0 {
            exclude(rec, "no recorded yield to learn from", &mut report);
            continue;
        }
        let Some(code) = crop_code(&rec.crop) else {
            exclude(
                rec,
                &format!("crop {:?} is not in the model's crop table", rec.crop),
                &mut report,
            );
            continue;
        };

        let days: Vec<&WeatherDay> = weather_by_field
            .get(rec.field_id.as_str())
            .map(|days| {
                days.iter()
                    .filter(|d| within(&d.date, &rec.season_start, &rec.season_end))
                    .copied()
                    .collect()
            })
            .unwrap_or_default();

        if days.len() < MIN_WEATHER_DAYS {
            exclude(
                rec,
                &format!(
                    "only {} days of weather in season, need {}",
                    days.len(),
                    MIN_WEATHER_DAYS
                ),
                &mut report,
            );
            continue;
        }
        let w = season_weather(&days);

        // NDVI is optional: plenty of seasons have no usable pass, and zero is
        // a meaningful "no imagery" value the model is already trained to see.
        let ndvi_peak = ndvi_by_field
            .get(rec.field_id.as_str())
            .and_then(|readings| {
                readings
                    .iter()
                    .filter(|r| within(&r.date, &rec.season_start, &rec.season_end))
                    .map(|r| r.ndvi)
                    .filter(|v| v.is_finite())
                    .fold(None::<f64>, |best, v| Some(best.map_or(v, |b| b.max(v))))
            })
            .unwrap_or(0.0);

        let values: Vec<String> = vec![
            rec.field_id.clone(),
            rec.season.clone(),
            code.to_string(),
            format!("{:.4}", w.avg_temperature_c),
            format!("{:.4}", w.total_precipitation_mm),
            format!("{:.4}", w.avg_solar_radiation),
            format!("{:.4}", w.growing_degree_days),
            format!("{:.0}", w.frost_days),
            format!("{:.0}", w.heat_stress_days),
            format!("{:.4}", w.avg_humidity_pct),
            format!("{:.4}", rec.organic_matter_pct),
            format!("{:.4}", rec.ph),
            format!("{:.4}", rec.nitrogen_kg_ha),
            format!("{:.4}", rec.phosphorus_kg_ha),
            format!("{:.4}", rec.potassium_kg_ha),
            format!("{:.4}", rec.water_holding_capacity_mm_m),
            format!("{:.4}", rec.compaction_index),
            format!("{:.0}", rec.planting_day),
            format!("{:.4}", rec.plant_population_per_ha),
            format!("{:.4}", rec.nitrogen_applied_kg_ha),
            format!("{:.4}", rec.irrigation_mm),
            format!("{:.4}", rec.pest_control_effectiveness),
            format!("{:.4}", ndvi_peak),
            format!("{:.4}", rec.yield_kg_ha),
        ];
        out.push_str(&values.join(","));
        out.push('\n');
        report.rows += 1;
    }

    (out, report)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn harvest(field: &str, yield_kg: f64) -> YieldRecord {
        YieldRecord {
            field_id: field.to_string(),
            season: "2026-kharif".to_string(),
            crop: "wheat".to_string(),
            yield_kg_ha: yield_kg,
            season_start: "2026-06-01".to_string(),
            season_end: "2026-10-31".to_string(),
            nitrogen_applied_kg_ha: 120.0,
            irrigation_mm: 200.0,
            plant_population_per_ha: 250_000.0,
            planting_day: 152.0,
            pest_control_effectiveness: 0.8,
            organic_matter_pct: 2.5,
            ph: 6.5,
            nitrogen_kg_ha: 40.0,
            phosphorus_kg_ha: 20.0,
            potassium_kg_ha: 60.0,
            water_holding_capacity_mm_m: 140.0,
            compaction_index: 0.2,
            prior_yield_mean_kg_ha: 3800.0,
        }
    }

    /// `count` days of weather inside the season, starting in June.
    fn season_days(field: &str, count: usize, temp: f64, rain: f64) -> Vec<WeatherDay> {
        (0..count)
            .map(|i| WeatherDay {
                field_id: field.to_string(),
                // June has 30 days, so this rolls into July and stays in season.
                date: if i < 30 {
                    format!("2026-06-{:02}", i + 1)
                } else {
                    format!("2026-07-{:02}", i - 29)
                },
                temperature_c: temp,
                precipitation_mm: rain,
                humidity_pct: 70.0,
                solar_radiation_mj_m2: 18.0,
            })
            .collect()
    }

    fn wheat(crop: &str) -> Option<f64> {
        match crop {
            "wheat" => Some(1.0),
            "rice" => Some(2.0),
            _ => None,
        }
    }

    #[test]
    fn a_complete_field_season_becomes_one_row() {
        let weather = season_days("f1", 40, 25.0, 5.0);
        let ndvi = vec![
            NdviReading { field_id: "f1".into(), date: "2026-07-15".into(), ndvi: 0.62 },
            NdviReading { field_id: "f1".into(), date: "2026-08-01".into(), ndvi: 0.81 },
        ];

        let (csv, report) = assemble(&[harvest("f1", 4200.0)], &weather, &ndvi, wheat);
        assert_eq!(report.rows, 1);
        assert!(report.excluded.is_empty());

        let lines: Vec<&str> = csv.lines().collect();
        assert_eq!(lines.len(), 2);
        assert!(lines[0].ends_with(TARGET_COLUMN));
        assert_eq!(lines[0].split(',').count(), COLUMNS.len() + 1);

        let cols: Vec<&str> = lines[1].split(',').collect();
        assert_eq!(cols.len(), COLUMNS.len() + 1);
        assert_eq!(cols[0], "f1");
        // 40 days at 5mm.
        assert_eq!(cols[4], "200.0000");
        // The peak, not the last or the mean.
        assert_eq!(cols[COLUMNS.len() - 1], "0.8100");
        assert_eq!(cols[COLUMNS.len()], "4200.0000");
    }

    #[test]
    fn a_season_with_too_little_weather_is_left_out() {
        // Five days of readings do not describe a season, and a model fitted on
        // their "total rainfall" learns that dry seasons produce good harvests.
        let (csv, report) = assemble(&[harvest("f1", 4200.0)], &season_days("f1", 5, 25.0, 5.0), &[], wheat);
        assert_eq!(report.rows, 0);
        assert_eq!(csv.lines().count(), 1, "header only");
        assert_eq!(report.excluded.len(), 1);
        assert!(report.excluded[0].reason.contains("5 days"), "{:?}", report.excluded[0]);
    }

    #[test]
    fn weather_from_another_season_is_not_folded_in() {
        let mut weather = season_days("f1", 40, 25.0, 5.0);
        // A downpour after harvest must not count towards this season.
        weather.push(WeatherDay {
            field_id: "f1".into(),
            date: "2026-12-25".into(),
            temperature_c: 25.0,
            precipitation_mm: 900.0,
            humidity_pct: 90.0,
            solar_radiation_mj_m2: 5.0,
        });

        let (csv, _) = assemble(&[harvest("f1", 4200.0)], &weather, &[], wheat);
        let cols: Vec<&str> = csv.lines().nth(1).unwrap().split(',').collect();
        assert_eq!(cols[4], "200.0000", "out-of-season rain leaked in");
    }

    #[test]
    fn another_fields_weather_is_not_borrowed() {
        let mut weather = season_days("f1", 40, 25.0, 5.0);
        weather.extend(season_days("f2", 40, 5.0, 100.0));

        let (csv, report) = assemble(&[harvest("f1", 4200.0)], &weather, &[], wheat);
        assert_eq!(report.rows, 1);
        let cols: Vec<&str> = csv.lines().nth(1).unwrap().split(',').collect();
        assert_eq!(cols[3], "25.0000", "f2's weather leaked in");
        assert_eq!(cols[4], "200.0000");
    }

    #[test]
    fn missing_imagery_is_recorded_as_none_rather_than_dropping_the_row() {
        // Plenty of seasons have no usable satellite pass; the model is
        // already trained to read zero as "no imagery".
        let (csv, report) = assemble(&[harvest("f1", 4200.0)], &season_days("f1", 40, 25.0, 5.0), &[], wheat);
        assert_eq!(report.rows, 1);
        let cols: Vec<&str> = csv.lines().nth(1).unwrap().split(',').collect();
        assert_eq!(cols[COLUMNS.len() - 1], "0.0000");
    }

    #[test]
    fn a_crop_the_model_does_not_know_is_excluded_not_guessed() {
        let mut rec = harvest("f1", 4200.0);
        rec.crop = "dragonfruit".into();
        let (_, report) = assemble(&[rec], &season_days("f1", 40, 25.0, 5.0), &[], wheat);
        assert_eq!(report.rows, 0);
        assert!(report.excluded[0].reason.contains("dragonfruit"));
    }

    #[test]
    fn harvests_with_no_yield_are_excluded() {
        for bad in [0.0, -5.0, f64::NAN] {
            let (_, report) = assemble(
                &[harvest("f1", bad)],
                &season_days("f1", 40, 25.0, 5.0),
                &[],
                wheat,
            );
            assert_eq!(report.rows, 0, "yield {bad} should be excluded");
            assert!(report.excluded[0].reason.contains("no recorded yield"));
        }
    }

    #[test]
    fn season_weather_counts_heat_frost_and_growing_degrees() {
        let days = vec![
            WeatherDay { field_id: "f".into(), date: "2026-06-01".into(), temperature_c: -2.0, precipitation_mm: 0.0, humidity_pct: 50.0, solar_radiation_mj_m2: 10.0 },
            WeatherDay { field_id: "f".into(), date: "2026-06-02".into(), temperature_c: 20.0, precipitation_mm: 10.0, humidity_pct: 60.0, solar_radiation_mj_m2: 20.0 },
            WeatherDay { field_id: "f".into(), date: "2026-06-03".into(), temperature_c: 38.0, precipitation_mm: 0.0, humidity_pct: 40.0, solar_radiation_mj_m2: 25.0 },
        ];
        let refs: Vec<&WeatherDay> = days.iter().collect();
        let w = season_weather(&refs);

        assert_eq!(w.days, 3);
        assert_eq!(w.frost_days, 1.0);
        assert_eq!(w.heat_stress_days, 1.0);
        // Only days above the base contribute: (20-10) + (38-10).
        assert!((w.growing_degree_days - 38.0).abs() < 1e-9);
        assert!((w.total_precipitation_mm - 10.0).abs() < 1e-9);
        assert!((w.avg_temperature_c - 56.0 / 3.0).abs() < 1e-9);

        // An empty season folds to zeros rather than dividing by zero.
        assert_eq!(season_weather(&[]), SeasonWeather::default());
    }

    #[test]
    fn the_header_matches_what_the_trainer_reads() {
        // The trainer looks columns up by name, so a rename here silently
        // turns a feature into zeros rather than failing.
        let (csv, _) = assemble(&[harvest("f1", 4200.0)], &season_days("f1", 40, 25.0, 5.0), &[], wheat);
        let header = csv.lines().next().unwrap();
        for name in [
            "avg_temperature_c",
            "total_precipitation_mm",
            "growing_degree_days",
            "nitrogen_applied_kg_ha",
            "ndvi_peak",
            TARGET_COLUMN,
        ] {
            assert!(header.contains(name), "header is missing {name}");
        }
    }
}
