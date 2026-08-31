use crate::types::*;

pub fn compute_composite_risk(score: &FieldRiskScore) -> RiskSummary {
    let weights = RiskWeights::default();
    let weighted = score.temperature_risk * weights.temperature
        + score.water_risk * weights.water
        + score.pest_risk * weights.pest
        + score.disease_risk * weights.disease
        + score.nutrient_risk * weights.nutrient
        + score.growth_risk * weights.growth;

    let trend = if score.alerts.is_empty() {
        RiskTrend::Stable
    } else {
        let critical_count = score.alerts.iter()
            .filter(|a| a.severity >= AlertSeverity::Critical)
            .count();
        if critical_count >= 2 {
            RiskTrend::Deteriorating
        } else if critical_count == 1 {
            RiskTrend::Worsening
        } else {
            RiskTrend::Stable
        }
    };

    let level = if weighted > 0.75 {
        AlertSeverity::Emergency
    } else if weighted > 0.5 {
        AlertSeverity::Critical
    } else if weighted > 0.25 {
        AlertSeverity::Warning
    } else {
        AlertSeverity::Info
    };

    RiskSummary {
        composite_score: weighted,
        level,
        trend,
        dominant_risk: dominant_category(score),
        alert_count: score.alerts.len() as u32,
        critical_alert_count: score.alerts.iter()
            .filter(|a| a.severity >= AlertSeverity::Critical)
            .count() as u32,
    }
}

fn dominant_category(score: &FieldRiskScore) -> AlertCategory {
    let risks = [
        (score.temperature_risk, AlertCategory::Temperature),
        (score.water_risk, AlertCategory::Water),
        (score.pest_risk, AlertCategory::Pest),
        (score.disease_risk, AlertCategory::Disease),
        (score.nutrient_risk, AlertCategory::Nutrient),
        (score.growth_risk, AlertCategory::Growth),
    ];
    risks.iter()
        .max_by(|a, b| a.0.partial_cmp(&b.0).unwrap_or(std::cmp::Ordering::Equal))
        .map(|(_, cat)| *cat)
        .unwrap_or(AlertCategory::Temperature)
}

pub fn batch_evaluate_priority(scores: &mut [FieldRiskScore]) {
    scores.sort_by(|a, b| {
        b.overall_risk.partial_cmp(&a.overall_risk).unwrap_or(std::cmp::Ordering::Equal)
    });
}

#[derive(Debug, Clone)]
pub struct RiskWeights {
    pub temperature: f64,
    pub water: f64,
    pub pest: f64,
    pub disease: f64,
    pub nutrient: f64,
    pub growth: f64,
}

impl Default for RiskWeights {
    fn default() -> Self {
        Self {
            temperature: 0.15,
            water: 0.20,
            pest: 0.20,
            disease: 0.20,
            nutrient: 0.10,
            growth: 0.15,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum RiskTrend {
    Improving,
    Stable,
    Worsening,
    Deteriorating,
}

#[derive(Debug, Clone)]
pub struct RiskSummary {
    pub composite_score: f64,
    pub level: AlertSeverity,
    pub trend: RiskTrend,
    pub dominant_risk: AlertCategory,
    pub alert_count: u32,
    pub critical_alert_count: u32,
}

#[cfg(test)]
mod tests {
    use super::*;
    use chrono::Utc;

    fn make_score(temp: f64, water: f64, pest: f64) -> FieldRiskScore {
        FieldRiskScore {
            field_id: "f1".into(),
            farm_id: "farm1".into(),
            overall_risk: temp.max(water).max(pest),
            temperature_risk: temp,
            water_risk: water,
            pest_risk: pest,
            disease_risk: 0.0,
            nutrient_risk: 0.0,
            growth_risk: 0.0,
            alerts: vec![],
            evaluated_at: Utc::now(),
        }
    }

    #[test]
    fn test_composite_low() {
        let score = make_score(0.1, 0.1, 0.0);
        let summary = compute_composite_risk(&score);
        assert!(summary.composite_score < 0.25);
        assert_eq!(summary.level, AlertSeverity::Info);
    }

    #[test]
    fn test_composite_high() {
        let score = make_score(0.8, 0.9, 0.7);
        let summary = compute_composite_risk(&score);
        assert!(summary.composite_score > 0.25);
    }

    #[test]
    fn test_batch_priority() {
        let mut scores = vec![
            make_score(0.1, 0.1, 0.0),
            make_score(0.9, 0.8, 0.7),
            make_score(0.5, 0.3, 0.2),
        ];
        batch_evaluate_priority(&mut scores);
        assert!(scores[0].overall_risk >= scores[1].overall_risk);
        assert!(scores[1].overall_risk >= scores[2].overall_risk);
    }

    #[test]
    fn test_dominant_category() {
        let score = make_score(0.1, 0.8, 0.3);
        assert_eq!(dominant_category(&score), AlertCategory::Water);
    }
}
