//! Training-time augmentation tuned for field photos.
//!
//! Phone photos of crops differ from lab images in ways a small dataset never
//! covers: harsh or low sun, colour casts from soil and sky, a hand or leaf in
//! front of the subject, camera shake, and cluttered backgrounds. Each
//! transform below targets one of those, and every sample gets a fresh but
//! reproducible draw per epoch (seeded from the config seed, the sample id,
//! and the epoch) so runs are repeatable.
//!
//! Transforms operate on the decoded RGB image before the resize + ImageNet
//! normalisation in `dataset`, so validation and inference preprocessing stay
//! byte-for-byte identical to training's un-augmented path.

use image::{DynamicImage, Rgb, RgbImage};
use rand::rngs::StdRng;
use rand::{Rng, SeedableRng};
use sha2::{Digest, Sha256};

use crate::config::AugmentationConfig;

/// Applies the configured augmentations with per-sample, per-epoch seeds.
#[derive(Debug, Clone)]
pub struct Augmenter {
    cfg: AugmentationConfig,
}

impl Augmenter {
    pub fn new(cfg: &AugmentationConfig) -> Self {
        Self { cfg: cfg.clone() }
    }

    pub fn config(&self) -> &AugmentationConfig {
        &self.cfg
    }

    fn rng_for(&self, key: &str, salt: u64) -> StdRng {
        let mut h = Sha256::new();
        h.update(self.cfg.seed.to_le_bytes());
        h.update(key.as_bytes());
        h.update(salt.to_le_bytes());
        let digest = h.finalize();
        StdRng::seed_from_u64(u64::from_le_bytes(digest[..8].try_into().unwrap()))
    }

    /// Augment one decoded image. `key` identifies the sample and `salt`
    /// (typically the epoch) varies the draw between passes.
    pub fn apply(&self, img: &DynamicImage, key: &str, salt: u64) -> RgbImage {
        let mut rng = self.rng_for(key, salt);
        let mut out = img.to_rgb8();
        let cfg = &self.cfg;

        // Geometry: crop → flips → rotation.
        let [lo, hi] = cfg.random_crop_scale;
        if hi > 0.0 && (lo < 1.0 || hi < 1.0) {
            let scale = rng.gen_range(lo.min(hi)..=hi.max(lo)).clamp(0.05, 1.0) as f32;
            out = random_resized_crop(&out, scale, &mut rng);
        }
        if cfg.horizontal_flip && rng.gen_bool(0.5) {
            out = image::imageops::flip_horizontal(&out);
        }
        if cfg.vertical_flip && rng.gen_bool(0.5) {
            out = image::imageops::flip_vertical(&out);
        }
        if cfg.rotation_limit > 0 && rng.gen_bool(0.5) {
            let limit = cfg.rotation_limit as f32;
            let deg = rng.gen_range(-limit..=limit);
            out = rotate(&out, deg);
        }

        // Lighting: brightness, contrast, gamma, white-balance / colour cast.
        let brightness = sample_range(&mut rng, cfg.brightness_range, 1.0);
        let contrast = sample_range(&mut rng, cfg.contrast_range, 1.0);
        let gamma = sample_range(&mut rng, cfg.gamma_range, 1.0);
        let cast = if cfg.color_cast > 0.0 {
            let c = cfg.color_cast as f32;
            [
                rng.gen_range(1.0 - c..=1.0 + c),
                rng.gen_range(1.0 - c..=1.0 + c),
                rng.gen_range(1.0 - c..=1.0 + c),
            ]
        } else {
            [1.0, 1.0, 1.0]
        };
        if brightness != 1.0 || contrast != 1.0 || gamma != 1.0 || cast != [1.0, 1.0, 1.0] {
            adjust_lighting(&mut out, brightness, contrast, gamma, cast);
        }

        // Background variation: uneven illumination outside a random ellipse
        // around the subject, as when the plant is lit differently from soil
        // or sky behind it.
        if cfg.background_prob > 0.0 && rng.gen_bool(cfg.background_prob.clamp(0.0, 1.0)) {
            let gain = rng.gen_range(0.55f32..=1.35);
            let desaturate = rng.gen_range(0.0f32..=0.6);
            shade_background(&mut out, gain, desaturate, &mut rng);
        }

        // Camera shake.
        if cfg.motion_blur_prob > 0.0 && rng.gen_bool(cfg.motion_blur_prob.clamp(0.0, 1.0)) {
            let max_len = cfg.motion_blur_max_len.max(3);
            let len = rng.gen_range(3..=max_len);
            let angle = rng.gen_range(0.0f32..std::f32::consts::PI);
            out = motion_blur(&out, len, angle);
        }

        // Occlusion by hands, other leaves, tools.
        if cfg.occlusion_prob > 0.0 && rng.gen_bool(cfg.occlusion_prob.clamp(0.0, 1.0)) {
            let patches = rng.gen_range(1..=cfg.occlusion_max_patches.max(1));
            for _ in 0..patches {
                let frac = rng.gen_range(0.02..=cfg.occlusion_max_frac.max(0.02));
                occlude(&mut out, frac, &mut rng);
            }
        }

        // Sensor noise.
        if cfg.noise_std > 0.0 {
            let sigma = rng.gen_range(0.0..=cfg.noise_std as f32) * 255.0;
            if sigma > 0.0 {
                add_noise(&mut out, sigma, &mut rng);
            }
        }

        out
    }
}

fn sample_range(rng: &mut StdRng, range: [f64; 2], neutral: f32) -> f32 {
    let (lo, hi) = (range[0].min(range[1]) as f32, range[0].max(range[1]) as f32);
    if hi <= 0.0 || (lo == neutral && hi == neutral) {
        return neutral;
    }
    rng.gen_range(lo..=hi)
}

/// Crop a random square-ish window covering `scale` of the shorter side.
pub fn random_resized_crop(img: &RgbImage, scale: f32, rng: &mut StdRng) -> RgbImage {
    let (w, h) = img.dimensions();
    if w < 2 || h < 2 || scale >= 1.0 {
        return img.clone();
    }
    // Mild aspect jitter (3:4 .. 4:3) around a square crop.
    let aspect = rng.gen_range(0.75f32..=1.3333);
    let base = (w.min(h) as f32 * scale).max(2.0);
    let cw = (base * aspect.sqrt()).round().clamp(2.0, w as f32) as u32;
    let ch = (base / aspect.sqrt()).round().clamp(2.0, h as f32) as u32;
    let x = if w > cw { rng.gen_range(0..=w - cw) } else { 0 };
    let y = if h > ch { rng.gen_range(0..=h - ch) } else { 0 };
    image::imageops::crop_imm(img, x, y, cw, ch).to_image()
}

/// Rotate about the centre with bilinear sampling; uncovered corners take the
/// image mean colour so they do not read as a black frame.
pub fn rotate(img: &RgbImage, degrees: f32) -> RgbImage {
    let (w, h) = img.dimensions();
    let theta = degrees.to_radians();
    let (sin, cos) = theta.sin_cos();
    let (cx, cy) = ((w as f32 - 1.0) / 2.0, (h as f32 - 1.0) / 2.0);
    let fill = mean_color(img);
    let mut out = RgbImage::new(w, h);
    for y in 0..h {
        for x in 0..w {
            let dx = x as f32 - cx;
            let dy = y as f32 - cy;
            let sx = cos * dx + sin * dy + cx;
            let sy = -sin * dx + cos * dy + cy;
            out.put_pixel(x, y, bilinear(img, sx, sy).unwrap_or(fill));
        }
    }
    out
}

fn bilinear(img: &RgbImage, x: f32, y: f32) -> Option<Rgb<u8>> {
    let (w, h) = img.dimensions();
    if x < 0.0 || y < 0.0 || x > (w - 1) as f32 || y > (h - 1) as f32 {
        return None;
    }
    let x0 = x.floor() as u32;
    let y0 = y.floor() as u32;
    let x1 = (x0 + 1).min(w - 1);
    let y1 = (y0 + 1).min(h - 1);
    let fx = x - x0 as f32;
    let fy = y - y0 as f32;
    let p00 = img.get_pixel(x0, y0);
    let p10 = img.get_pixel(x1, y0);
    let p01 = img.get_pixel(x0, y1);
    let p11 = img.get_pixel(x1, y1);
    let mut out = [0u8; 3];
    for c in 0..3 {
        let top = p00[c] as f32 * (1.0 - fx) + p10[c] as f32 * fx;
        let bottom = p01[c] as f32 * (1.0 - fx) + p11[c] as f32 * fx;
        out[c] = (top * (1.0 - fy) + bottom * fy).round().clamp(0.0, 255.0) as u8;
    }
    Some(Rgb(out))
}

pub fn mean_color(img: &RgbImage) -> Rgb<u8> {
    let n = (img.width() as u64 * img.height() as u64).max(1);
    let mut sum = [0u64; 3];
    for p in img.pixels() {
        for c in 0..3 {
            sum[c] += p[c] as u64;
        }
    }
    Rgb([(sum[0] / n) as u8, (sum[1] / n) as u8, (sum[2] / n) as u8])
}

/// Brightness, contrast (about mid-grey), gamma, and per-channel gain.
pub fn adjust_lighting(
    img: &mut RgbImage,
    brightness: f32,
    contrast: f32,
    gamma: f32,
    cast: [f32; 3],
) {
    let inv_gamma = 1.0 / gamma.max(1e-3);
    let lut: Vec<[u8; 3]> = (0..256)
        .map(|v| {
            let mut out = [0u8; 3];
            for c in 0..3 {
                let mut x = v as f32 / 255.0;
                x *= brightness * cast[c];
                x = (x - 0.5) * contrast + 0.5;
                x = x.clamp(0.0, 1.0).powf(inv_gamma);
                out[c] = (x * 255.0).round().clamp(0.0, 255.0) as u8;
            }
            out
        })
        .collect();
    for p in img.pixels_mut() {
        for c in 0..3 {
            p[c] = lut[p[c] as usize][c];
        }
    }
}

/// Re-light everything outside a random ellipse around the subject.
pub fn shade_background(img: &mut RgbImage, gain: f32, desaturate: f32, rng: &mut StdRng) {
    let (w, h) = img.dimensions();
    let cx = w as f32 * rng.gen_range(0.35f32..=0.65);
    let cy = h as f32 * rng.gen_range(0.35f32..=0.65);
    let rx = w as f32 * rng.gen_range(0.25f32..=0.45);
    let ry = h as f32 * rng.gen_range(0.25f32..=0.45);
    // Soft edge so the boundary does not become a learnable artefact.
    let feather = 0.25f32;
    for y in 0..h {
        for x in 0..w {
            let nx = (x as f32 - cx) / rx;
            let ny = (y as f32 - cy) / ry;
            let d = (nx * nx + ny * ny).sqrt();
            if d <= 1.0 {
                continue;
            }
            let t = ((d - 1.0) / feather).clamp(0.0, 1.0);
            let p = img.get_pixel_mut(x, y);
            let grey = 0.299 * p[0] as f32 + 0.587 * p[1] as f32 + 0.114 * p[2] as f32;
            for c in 0..3 {
                let v = p[c] as f32;
                let shaded = (v * (1.0 - desaturate) + grey * desaturate) * gain;
                p[c] = (v * (1.0 - t) + shaded * t).round().clamp(0.0, 255.0) as u8;
            }
        }
    }
}

/// Directional box blur along a line of `len` pixels at `angle` radians.
pub fn motion_blur(img: &RgbImage, len: u32, angle: f32) -> RgbImage {
    let (w, h) = img.dimensions();
    let len = len.max(1) as i32;
    let (sin, cos) = angle.sin_cos();
    let half = (len - 1) as f32 / 2.0;
    let offsets: Vec<(i32, i32)> = (0..len)
        .map(|i| {
            let t = i as f32 - half;
            ((t * cos).round() as i32, (t * sin).round() as i32)
        })
        .collect();
    let mut out = RgbImage::new(w, h);
    for y in 0..h as i32 {
        for x in 0..w as i32 {
            let mut acc = [0u32; 3];
            let mut n = 0u32;
            for (dx, dy) in &offsets {
                let sx = x + dx;
                let sy = y + dy;
                if sx >= 0 && sy >= 0 && sx < w as i32 && sy < h as i32 {
                    let p = img.get_pixel(sx as u32, sy as u32);
                    for c in 0..3 {
                        acc[c] += p[c] as u32;
                    }
                    n += 1;
                }
            }
            let n = n.max(1);
            out.put_pixel(
                x as u32,
                y as u32,
                Rgb([(acc[0] / n) as u8, (acc[1] / n) as u8, (acc[2] / n) as u8]),
            );
        }
    }
    out
}

/// Paint a rectangle covering roughly `area_frac` of the image with a flat
/// natural colour (skin / soil / leaf tones) or the image mean.
pub fn occlude(img: &mut RgbImage, area_frac: f64, rng: &mut StdRng) {
    let (w, h) = img.dimensions();
    if w < 2 || h < 2 {
        return;
    }
    let area = (w as f64 * h as f64 * area_frac.clamp(0.0, 1.0)).max(1.0);
    let aspect = rng.gen_range(0.5f64..=2.0);
    let pw = ((area * aspect).sqrt().round() as u32).clamp(1, w);
    let ph = ((area / aspect).sqrt().round() as u32).clamp(1, h);
    let x0 = rng.gen_range(0..=w - pw);
    let y0 = rng.gen_range(0..=h - ph);
    let palette: [[u8; 3]; 5] = [
        [196, 152, 120], // skin
        [110, 80, 50],   // soil
        [70, 110, 45],   // foliage
        [180, 180, 175], // tool / grey
        [40, 40, 40],    // shadow
    ];
    let color = if rng.gen_bool(0.25) {
        mean_color(img)
    } else {
        Rgb(palette[rng.gen_range(0..palette.len())])
    };
    for y in y0..y0 + ph {
        for x in x0..x0 + pw {
            img.put_pixel(x, y, color);
        }
    }
}

/// Add zero-mean Gaussian noise (Box–Muller) with the given sigma in 0..255.
pub fn add_noise(img: &mut RgbImage, sigma: f32, rng: &mut StdRng) {
    for p in img.pixels_mut() {
        for c in 0..3 {
            let u1: f32 = rng.gen_range(1e-6f32..1.0);
            let u2: f32 = rng.gen_range(0.0f32..1.0);
            let z = (-2.0 * u1.ln()).sqrt() * (2.0 * std::f32::consts::PI * u2).cos();
            p[c] = (p[c] as f32 + z * sigma).round().clamp(0.0, 255.0) as u8;
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn gradient(w: u32, h: u32) -> RgbImage {
        RgbImage::from_fn(w, h, |x, y| {
            Rgb([
                (x * 255 / w.max(1)) as u8,
                (y * 255 / h.max(1)) as u8,
                ((x + y) * 127 / (w + h).max(1)) as u8,
            ])
        })
    }

    fn full_config() -> AugmentationConfig {
        AugmentationConfig {
            horizontal_flip: true,
            vertical_flip: true,
            rotation_limit: 15,
            brightness_range: [0.7, 1.3],
            random_crop_scale: [0.7, 1.0],
            contrast_range: [0.8, 1.2],
            gamma_range: [0.8, 1.25],
            color_cast: 0.1,
            background_prob: 0.5,
            motion_blur_prob: 0.5,
            motion_blur_max_len: 9,
            occlusion_prob: 0.5,
            occlusion_max_patches: 2,
            occlusion_max_frac: 0.2,
            noise_std: 0.02,
            seed: 7,
        }
    }

    fn identity_config() -> AugmentationConfig {
        AugmentationConfig {
            horizontal_flip: false,
            vertical_flip: false,
            rotation_limit: 0,
            brightness_range: [1.0, 1.0],
            random_crop_scale: [1.0, 1.0],
            contrast_range: [1.0, 1.0],
            gamma_range: [1.0, 1.0],
            color_cast: 0.0,
            background_prob: 0.0,
            motion_blur_prob: 0.0,
            motion_blur_max_len: 0,
            occlusion_prob: 0.0,
            occlusion_max_patches: 0,
            occlusion_max_frac: 0.0,
            noise_std: 0.0,
            seed: 1,
        }
    }

    #[test]
    fn identity_config_leaves_pixels_untouched() {
        let img = gradient(40, 30);
        let aug = Augmenter::new(&identity_config());
        let out = aug.apply(&DynamicImage::ImageRgb8(img.clone()), "s1", 0);
        assert_eq!(out.dimensions(), (40, 30));
        assert_eq!(out.as_raw(), img.as_raw());
    }

    #[test]
    fn deterministic_per_sample_and_epoch() {
        let img = DynamicImage::ImageRgb8(gradient(64, 48));
        let aug = Augmenter::new(&full_config());
        let a = aug.apply(&img, "sample-a", 3);
        let b = aug.apply(&img, "sample-a", 3);
        assert_eq!(a.as_raw(), b.as_raw(), "same key+epoch must reproduce");

        let other_epoch = aug.apply(&img, "sample-a", 4);
        let other_sample = aug.apply(&img, "sample-b", 3);
        assert!(
            a.as_raw() != other_epoch.as_raw() || a.dimensions() != other_epoch.dimensions(),
            "different epoch should change the draw"
        );
        assert!(
            a.as_raw() != other_sample.as_raw() || a.dimensions() != other_sample.dimensions(),
            "different sample should change the draw"
        );
    }

    #[test]
    fn augmented_output_stays_valid_across_many_draws() {
        let img = DynamicImage::ImageRgb8(gradient(50, 70));
        let aug = Augmenter::new(&full_config());
        for epoch in 0..25 {
            let out = aug.apply(&img, "x", epoch);
            let (w, h) = out.dimensions();
            assert!(w >= 2 && h >= 2 && w <= 50 && h <= 70, "bad dims {w}x{h}");
        }
    }

    #[test]
    fn occlusion_paints_a_flat_patch() {
        let mut img = gradient(64, 64);
        let mut rng = StdRng::seed_from_u64(3);
        let before = img.clone();
        occlude(&mut img, 0.1, &mut rng);
        let changed = img
            .pixels()
            .zip(before.pixels())
            .filter(|(a, b)| a != b)
            .count();
        // ~10% of 4096 pixels, allowing for rounding of the rectangle.
        assert!((250..=600).contains(&changed), "changed {changed}");
    }

    #[test]
    fn motion_blur_reduces_horizontal_variation() {
        // Vertical stripes: horizontal blur must smooth them, vertical must not.
        let img = RgbImage::from_fn(32, 32, |x, _| {
            if x % 2 == 0 {
                Rgb([255, 255, 255])
            } else {
                Rgb([0, 0, 0])
            }
        });
        let variation = |im: &RgbImage| -> u64 {
            let mut v = 0u64;
            for y in 0..32 {
                for x in 1..32 {
                    v += (im.get_pixel(x, y)[0] as i64 - im.get_pixel(x - 1, y)[0] as i64)
                        .unsigned_abs();
                }
            }
            v
        };
        let horizontal = motion_blur(&img, 5, 0.0);
        let vertical = motion_blur(&img, 5, std::f32::consts::FRAC_PI_2);
        assert!(variation(&horizontal) < variation(&img) / 2);
        assert_eq!(variation(&vertical), variation(&img));
    }

    #[test]
    fn lighting_lut_brightens_and_casts() {
        let mut img = RgbImage::from_pixel(4, 4, Rgb([100, 100, 100]));
        adjust_lighting(&mut img, 1.2, 1.0, 1.0, [1.0, 1.0, 1.0]);
        assert_eq!(img.get_pixel(0, 0)[0], 120);
        let mut img = RgbImage::from_pixel(4, 4, Rgb([100, 100, 100]));
        adjust_lighting(&mut img, 1.0, 1.0, 1.0, [1.1, 1.0, 0.9]);
        let p = img.get_pixel(0, 0);
        assert!(p[0] > p[1] && p[1] > p[2]);
        // Contrast about mid-grey pushes dark darker and light lighter.
        let mut img = RgbImage::from_pixel(2, 1, Rgb([64, 192, 128]));
        adjust_lighting(&mut img, 1.0, 1.5, 1.0, [1.0, 1.0, 1.0]);
        let p = img.get_pixel(0, 0);
        assert!(p[0] < 64 && p[1] > 192 && (p[2] as i32 - 128).abs() <= 1);
    }

    #[test]
    fn rotation_keeps_size_and_fills_corners_with_mean() {
        let img = RgbImage::from_pixel(20, 20, Rgb([200, 100, 50]));
        let out = rotate(&img, 30.0);
        assert_eq!(out.dimensions(), (20, 20));
        // Uniform image rotated stays uniform (corner fill = mean = same colour).
        assert!(out.pixels().all(|p| *p == Rgb([200, 100, 50])));
        let out0 = rotate(&gradient(16, 16), 0.0);
        assert_eq!(out0.as_raw(), gradient(16, 16).as_raw());
    }

    #[test]
    fn crop_respects_scale() {
        let img = gradient(100, 80);
        let mut rng = StdRng::seed_from_u64(9);
        for _ in 0..20 {
            let out = random_resized_crop(&img, 0.5, &mut rng);
            let (w, h) = out.dimensions();
            assert!(w <= 100 && h <= 80 && w >= 30 && h >= 30, "{w}x{h}");
        }
        assert_eq!(
            random_resized_crop(&img, 1.0, &mut rng).dimensions(),
            (100, 80)
        );
    }

    #[test]
    fn background_shading_leaves_centre_alone() {
        let mut img = RgbImage::from_pixel(60, 60, Rgb([120, 160, 90]));
        let mut rng = StdRng::seed_from_u64(1);
        shade_background(&mut img, 0.6, 0.5, &mut rng);
        assert_eq!(*img.get_pixel(30, 30), Rgb([120, 160, 90]));
        assert_ne!(*img.get_pixel(0, 0), Rgb([120, 160, 90]));
    }
}
