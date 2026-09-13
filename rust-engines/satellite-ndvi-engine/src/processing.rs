//! Product processing level, sensor identification, and cross-sensor
//! harmonization of vegetation indices.

use crate::raster::RasterBand;

/// Radiometric processing level of a satellite product.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ProcessingLevel {
    /// Sentinel-2 top-of-atmosphere reflectance.
    L1C,
    /// Sentinel-2 bottom-of-atmosphere (surface) reflectance.
    L2A,
    /// Landsat Level-1 terrain-corrected (top-of-atmosphere).
    L1TP,
    /// Landsat Collection 2 Level-2 surface reflectance.
    L2SP,
    /// Any other product explicitly labelled as surface reflectance.
    SurfaceReflectance,
    /// Any other product explicitly labelled as top-of-atmosphere.
    TopOfAtmosphere,
    Unknown,
}

impl ProcessingLevel {
    /// Parse common product-level labels (case-insensitive).
    pub fn parse(label: &str) -> Self {
        let l = label
            .trim()
            .to_ascii_uppercase()
            .replace(['-', '_', ' '], "");
        match l.as_str() {
            "L1C" | "LEVEL1C" | "S2MSI1C" => Self::L1C,
            "L2A" | "LEVEL2A" | "S2MSI2A" => Self::L2A,
            "L1TP" | "L1GT" | "L1GS" | "LEVEL1" => Self::L1TP,
            "L2SP" | "L2SR" | "LEVEL2" => Self::L2SP,
            "SR" | "BOA" | "SURFACEREFLECTANCE" | "BOTTOMOFATMOSPHERE" => Self::SurfaceReflectance,
            "TOA" | "TOPOFATMOSPHERE" => Self::TopOfAtmosphere,
            _ => Self::Unknown,
        }
    }

    /// Whether the product has been atmospherically corrected.
    pub fn is_surface_reflectance(&self) -> bool {
        matches!(self, Self::L2A | Self::L2SP | Self::SurfaceReflectance)
    }

    /// Human-readable advisory for products that should not be used for
    /// quantitative index comparison without correction.
    pub fn advisory(&self) -> Option<&'static str> {
        match self {
            Self::L1C | Self::TopOfAtmosphere => Some(
                "top-of-atmosphere reflectance: indices are not atmospherically corrected; prefer L2A/L2SP products for time-series comparison",
            ),
            Self::L1TP => Some(
                "Landsat Level-1 product: not atmospherically corrected; prefer Collection 2 Level-2 (L2SP) surface reflectance",
            ),
            Self::Unknown => Some("processing level unknown: treat index values as uncalibrated"),
            _ => None,
        }
    }

    pub fn as_str(&self) -> &'static str {
        match self {
            Self::L1C => "L1C",
            Self::L2A => "L2A",
            Self::L1TP => "L1TP",
            Self::L2SP => "L2SP",
            Self::SurfaceReflectance => "SR",
            Self::TopOfAtmosphere => "TOA",
            Self::Unknown => "UNKNOWN",
        }
    }
}

/// Imaging sensor family.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Sensor {
    Sentinel2,
    Landsat8,
    Landsat9,
    PlanetScope,
    Uav,
    Unknown,
}

impl Sensor {
    pub fn parse(label: &str) -> Self {
        let l = label
            .trim()
            .to_ascii_uppercase()
            .replace(['-', '_', ' '], "");
        match l.as_str() {
            "SENTINEL2" | "S2" | "S2A" | "S2B" | "MSI" => Self::Sentinel2,
            "LANDSAT8" | "L8" | "LC08" | "OLI" => Self::Landsat8,
            "LANDSAT9" | "L9" | "LC09" | "OLI2" => Self::Landsat9,
            "LANDSAT" => Self::Landsat8,
            "PLANETSCOPE" | "PLANET" | "PS" | "PSB" => Self::PlanetScope,
            "UAV" | "DRONE" => Self::Uav,
            _ => Self::Unknown,
        }
    }

    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Sentinel2 => "SENTINEL2",
            Self::Landsat8 => "LANDSAT8",
            Self::Landsat9 => "LANDSAT9",
            Self::PlanetScope => "PLANETSCOPE",
            Self::Uav => "UAV",
            Self::Unknown => "UNKNOWN",
        }
    }
}

/// Linear transform `y = intercept + slope * x` mapping a sensor's NDVI onto
/// the Sentinel-2 MSI scale so mixed-sensor series are comparable.
///
/// Landsat-8 OLI coefficients follow the OLS fit of Roy et al. (2016),
/// *Remote Sensing of Environment* 185. Landsat-9 OLI-2 is radiometrically
/// near-identical to OLI. PlanetScope and UAV cameras vary per instrument and
/// are passed through unchanged until a per-sensor calibration exists.
pub fn ndvi_harmonization_coefficients(sensor: Sensor) -> (f64, f64) {
    match sensor {
        Sensor::Landsat8 | Sensor::Landsat9 => (0.0149, 0.9723),
        _ => (0.0, 1.0),
    }
}

/// Harmonize a single NDVI value onto the Sentinel-2 scale.
pub fn harmonize_ndvi(value: f64, sensor: Sensor) -> f64 {
    if value.is_nan() {
        return value;
    }
    let (b0, b1) = ndvi_harmonization_coefficients(sensor);
    (b0 + b1 * value).clamp(-1.0, 1.0)
}

/// Harmonize a whole NDVI band, preserving nodata pixels.
pub fn harmonize_ndvi_band(band: &RasterBand, sensor: Sensor) -> RasterBand {
    let (b0, b1) = ndvi_harmonization_coefficients(sensor);
    let mut data = band.data.clone();
    for r in 0..band.rows() {
        for c in 0..band.cols() {
            if !band.is_nodata(r, c) {
                data[[r, c]] = (b0 + b1 * data[[r, c]]).clamp(-1.0, 1.0);
            }
        }
    }
    RasterBand::new(data, band.nodata_value)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_levels() {
        assert_eq!(ProcessingLevel::parse("L2A"), ProcessingLevel::L2A);
        assert_eq!(ProcessingLevel::parse("s2msi1c"), ProcessingLevel::L1C);
        assert_eq!(ProcessingLevel::parse("Level-2"), ProcessingLevel::L2SP);
        assert_eq!(ProcessingLevel::parse("L1TP"), ProcessingLevel::L1TP);
        assert_eq!(
            ProcessingLevel::parse("surface reflectance"),
            ProcessingLevel::SurfaceReflectance
        );
        assert_eq!(ProcessingLevel::parse("whatever"), ProcessingLevel::Unknown);
        assert_eq!(ProcessingLevel::parse(""), ProcessingLevel::Unknown);
    }

    #[test]
    fn test_surface_reflectance_and_advisory() {
        assert!(ProcessingLevel::L2A.is_surface_reflectance());
        assert!(ProcessingLevel::L2SP.is_surface_reflectance());
        assert!(!ProcessingLevel::L1C.is_surface_reflectance());
        assert!(ProcessingLevel::L2A.advisory().is_none());
        assert!(ProcessingLevel::L1C.advisory().is_some());
        assert!(ProcessingLevel::Unknown.advisory().is_some());
    }

    #[test]
    fn test_parse_sensor() {
        assert_eq!(Sensor::parse("LC08"), Sensor::Landsat8);
        assert_eq!(Sensor::parse("sentinel-2"), Sensor::Sentinel2);
        assert_eq!(Sensor::parse("drone"), Sensor::Uav);
        assert_eq!(Sensor::parse("landsat9"), Sensor::Landsat9);
        assert_eq!(Sensor::parse("??"), Sensor::Unknown);
    }

    #[test]
    fn test_harmonize_landsat_to_s2() {
        let v = harmonize_ndvi(0.5, Sensor::Landsat8);
        assert!((v - (0.0149 + 0.9723 * 0.5)).abs() < 1e-12);
        assert_eq!(harmonize_ndvi(0.5, Sensor::Sentinel2), 0.5);
        assert_eq!(harmonize_ndvi(0.5, Sensor::Uav), 0.5);
        assert!((harmonize_ndvi(1.0, Sensor::Landsat8) - 0.9872).abs() < 1e-12);
        assert!(harmonize_ndvi(f64::NAN, Sensor::Landsat8).is_nan());
    }

    #[test]
    fn test_harmonize_band_preserves_nodata() {
        let band = RasterBand::from_vec(vec![0.5, -9999.0], 1, 2, Some(-9999.0)).unwrap();
        let out = harmonize_ndvi_band(&band, Sensor::Landsat8);
        assert!((out.data[[0, 0]] - 0.50105).abs() < 1e-9);
        assert!(out.is_nodata(0, 1));
    }
}
