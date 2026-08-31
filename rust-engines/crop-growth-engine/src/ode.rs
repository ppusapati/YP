pub type StateVec = Vec<f64>;

pub fn rk4_step<F>(f: &F, t: f64, y: &StateVec, dt: f64) -> StateVec
where
    F: Fn(f64, &StateVec) -> StateVec,
{
    let k1 = f(t, y);
    let y2: StateVec = y.iter().zip(&k1).map(|(yi, ki)| yi + 0.5 * dt * ki).collect();
    let k2 = f(t + 0.5 * dt, &y2);
    let y3: StateVec = y.iter().zip(&k2).map(|(yi, ki)| yi + 0.5 * dt * ki).collect();
    let k3 = f(t + 0.5 * dt, &y3);
    let y4: StateVec = y.iter().zip(&k3).map(|(yi, ki)| yi + dt * ki).collect();
    let k4 = f(t + dt, &y4);

    y.iter()
        .zip(&k1)
        .zip(&k2)
        .zip(&k3)
        .zip(&k4)
        .map(|((((yi, k1i), k2i), k3i), k4i)| {
            yi + dt / 6.0 * (k1i + 2.0 * k2i + 2.0 * k3i + k4i)
        })
        .collect()
}

pub fn integrate<F>(
    f: &F,
    y0: &StateVec,
    t_start: f64,
    t_end: f64,
    dt: f64,
) -> Vec<(f64, StateVec)>
where
    F: Fn(f64, &StateVec) -> StateVec,
{
    let mut t = t_start;
    let mut y = y0.clone();
    let mut trajectory = vec![(t, y.clone())];

    while t < t_end - dt * 0.5 {
        y = rk4_step(f, t, &y, dt);
        t += dt;
        for val in y.iter_mut() {
            if *val < 0.0 { *val = 0.0; }
        }
        trajectory.push((t, y.clone()));
    }
    trajectory
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_exponential_growth() {
        let f = |_t: f64, y: &StateVec| -> StateVec { vec![y[0]] };
        let y0 = vec![1.0];
        let result = integrate(&f, &y0, 0.0, 1.0, 0.01);
        let final_val = result.last().unwrap().1[0];
        assert!((final_val - std::f64::consts::E).abs() < 0.01);
    }
}
