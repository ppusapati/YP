module NutrientDiffusion

using DifferentialEquations
using LinearAlgebra
using Statistics

export SoilLayer, SoilProfile, NutrientState, BoundaryConditions,
       solve_nutrient_transport, diffusion_coefficient, advection_velocity,
       nutrient_uptake_root, mineralization_rate, nitrification_rate,
       denitrification_rate, create_uniform_profile

# ---------------------------------------------------------------------------
# Data structures
# ---------------------------------------------------------------------------

"""
    SoilLayer

Physical and chemical properties of a single soil layer.
"""
struct SoilLayer
    depth_m::Float64              # Layer depth (m)
    thickness_m::Float64          # Layer thickness (m)
    clay_pct::Float64             # Clay content (%)
    sand_pct::Float64             # Sand content (%)
    organic_matter_pct::Float64   # Organic matter (%)
    bulk_density::Float64         # Bulk density (g/cm^3 = Mg/m^3)
    porosity::Float64             # Total porosity (m^3/m^3)
    field_capacity::Float64       # Field capacity (m^3/m^3)
    wilting_point::Float64        # Permanent wilting point (m^3/m^3)
    hydraulic_conductivity::Float64 # Saturated hydraulic conductivity (m/day)
    ph::Float64                   # Soil pH
    cec::Float64                  # Cation exchange capacity (cmol/kg)
end

function SoilLayer(;
    depth_m              = 0.15,
    thickness_m          = 0.10,
    clay_pct             = 25.0,
    sand_pct             = 40.0,
    organic_matter_pct   = 3.0,
    bulk_density         = 1.35,
    porosity             = 0.48,
    field_capacity       = 0.30,
    wilting_point        = 0.12,
    hydraulic_conductivity = 0.5,
    ph                   = 6.5,
    cec                  = 20.0
)
    SoilLayer(depth_m, thickness_m, clay_pct, sand_pct, organic_matter_pct,
              bulk_density, porosity, field_capacity, wilting_point,
              hydraulic_conductivity, ph, cec)
end

"""
    SoilProfile

A vertical column of soil layers.
"""
struct SoilProfile
    layers::Vector{SoilLayer}
    n_layers::Int
    total_depth_m::Float64
end

function SoilProfile(layers::Vector{SoilLayer})
    total = sum(l.thickness_m for l in layers)
    SoilProfile(layers, length(layers), total)
end

"""
    create_uniform_profile(n_layers, total_depth; kwargs...) -> SoilProfile

Create a uniform soil profile with equal layer thickness.
"""
function create_uniform_profile(n_layers::Int, total_depth::Float64; kwargs...)
    dz = total_depth / n_layers
    layers = SoilLayer[]
    for i in 1:n_layers
        depth = (i - 0.5) * dz
        push!(layers, SoilLayer(; depth_m=depth, thickness_m=dz, kwargs...))
    end
    return SoilProfile(layers)
end

"""
    NutrientState

Concentration profiles for N, P, K and water content at each depth node.
All concentrations in mg/kg (ppm dry soil) unless otherwise noted.
"""
mutable struct NutrientState
    nitrogen_no3::Vector{Float64}       # NO3-N concentration (mg/kg) per layer
    nitrogen_nh4::Vector{Float64}       # NH4-N concentration (mg/kg) per layer
    phosphorus::Vector{Float64}         # Available P (mg/kg) per layer
    potassium::Vector{Float64}          # Available K (mg/kg) per layer
    water_content::Vector{Float64}      # Volumetric water content (m^3/m^3) per layer
    organic_nitrogen::Vector{Float64}   # Organic N pool (mg/kg) per layer
    temperature::Vector{Float64}        # Soil temperature (degC) per layer
end

function NutrientState(n_layers::Int;
    no3      = fill(15.0, n_layers),
    nh4      = fill(5.0, n_layers),
    phos     = fill(20.0, n_layers),
    pot      = fill(150.0, n_layers),
    water    = fill(0.25, n_layers),
    org_n    = fill(200.0, n_layers),
    temp     = fill(20.0, n_layers)
)
    NutrientState(copy(no3), copy(nh4), copy(phos), copy(pot),
                  copy(water), copy(org_n), copy(temp))
end

"""
    BoundaryConditions

Top and bottom boundary conditions for the transport equations.
"""
struct BoundaryConditions
    # Top boundary (surface)
    surface_no3_flux::Float64        # NO3 input from fertiliser/rain (mg/m^2/day)
    surface_nh4_flux::Float64        # NH4 input (mg/m^2/day)
    surface_p_flux::Float64          # P input (mg/m^2/day)
    surface_k_flux::Float64          # K input (mg/m^2/day)
    surface_water_flux::Float64      # Net water input at surface (m/day)

    # Bottom boundary
    bottom_drainage_rate::Float64    # Free drainage (m/day)

    # Root uptake profile (normalised, sums to 1)
    root_density_profile::Vector{Float64}
end

function BoundaryConditions(n_layers::Int;
    surface_no3_flux    = 0.0,
    surface_nh4_flux    = 0.0,
    surface_p_flux      = 0.0,
    surface_k_flux      = 0.0,
    surface_water_flux  = 0.001,
    bottom_drainage_rate = 0.0005,
    root_density_profile = nothing
)
    if root_density_profile === nothing
        # Exponential root distribution
        rd = [exp(-3.0 * i / n_layers) for i in 1:n_layers]
        rd ./= sum(rd)
    else
        rd = root_density_profile
    end
    BoundaryConditions(surface_no3_flux, surface_nh4_flux, surface_p_flux,
                       surface_k_flux, surface_water_flux, bottom_drainage_rate, rd)
end

# ---------------------------------------------------------------------------
# Physical / biogeochemical process functions
# ---------------------------------------------------------------------------

"""
    diffusion_coefficient(nutrient_type, water_content, temperature; tortuosity_model=:millington_quirk) -> Float64

Effective diffusion coefficient for a nutrient in soil (m^2/day).

Uses the Millington-Quirk tortuosity model:
    D_eff = D_0 * theta^(10/3) / porosity^2

where D_0 is the diffusion coefficient in free water.
"""
function diffusion_coefficient(nutrient_type::Symbol, water_content::Float64,
                                temperature::Float64;
                                porosity::Float64 = 0.45)::Float64
    # Diffusion coefficients in free water at 25 degC (m^2/s)
    d0_table = Dict(
        :no3  => 1.902e-9,
        :nh4  => 1.957e-9,
        :h2po4 => 0.891e-9,
        :k    => 1.960e-9,
        :phosphorus => 0.891e-9,
        :potassium  => 1.960e-9,
        :nitrogen   => 1.902e-9
    )

    d0 = get(d0_table, nutrient_type, 1.5e-9)

    # Temperature adjustment (Stokes-Einstein): D ~ T / viscosity
    # Approximate: D(T) = D(25) * (T + 273.15) / (25 + 273.15) * viscosity_ratio
    # Simplified: ~2% increase per degC
    temp_factor = exp(0.02 * (temperature - 25.0))

    # Millington-Quirk tortuosity
    theta = max(water_content, 0.01)
    tortuosity = theta^(10.0 / 3.0) / (porosity^2)

    # Convert m^2/s to m^2/day
    d_eff = d0 * temp_factor * tortuosity * 86400.0

    return d_eff
end

"""
    advection_velocity(hydraulic_conductivity, water_content_gradient, water_content) -> Float64

Pore water velocity for advective nutrient transport (m/day).
Uses Darcy's law: q = -K * dH/dz, then v = q / theta.

`water_content_gradient` is dtheta/dz (1/m), positive downward.
"""
function advection_velocity(hydraulic_conductivity::Float64,
                             water_content_gradient::Float64,
                             water_content::Float64)::Float64
    theta = max(water_content, 0.01)
    # Simplified: assume hydraulic gradient ~ gravity + matric gradient
    # Unit gradient (gravity only) gives q = K_unsat
    # For unsaturated flow: K_unsat approx K_sat * (theta/porosity)^3
    k_unsat = hydraulic_conductivity * (theta / 0.45)^3
    q = k_unsat * (1.0 + water_content_gradient)  # 1.0 = gravitational component
    v = q / theta
    return v  # m/day, positive downward
end

"""
    nutrient_uptake_root(root_density, concentration, michaelis_constant, max_uptake) -> Float64

Michaelis-Menten kinetics for active root nutrient uptake.

    uptake = V_max * C / (K_m + C) * root_density

Returns uptake rate (mg/kg/day).
"""
function nutrient_uptake_root(root_density::Float64, concentration::Float64,
                               michaelis_constant::Float64,
                               max_uptake::Float64)::Float64
    if concentration <= 0.0
        return 0.0
    end
    return max_uptake * concentration / (michaelis_constant + concentration) * root_density
end

"""
    mineralization_rate(organic_matter_pct, temperature, moisture;
                         potential_rate=0.01) -> Float64

Organic N mineralization rate (mg N/kg/day).
First-order kinetics modulated by temperature and moisture factors.

    rate = k_pot * OM * f(T) * f(theta)
"""
function mineralization_rate(organic_matter_pct::Float64, temperature::Float64,
                              moisture::Float64;
                              potential_rate::Float64 = 0.01,
                              field_capacity::Float64 = 0.30)::Float64
    # Temperature factor (Q10 model)
    # Q10 = 2.0, reference temperature 25 degC
    f_temp = 2.0^((temperature - 25.0) / 10.0)
    f_temp = max(0.0, f_temp)

    # Moisture factor (optimum at field capacity, declines for wet and dry)
    relative_moisture = moisture / field_capacity
    if relative_moisture <= 0.0
        f_moist = 0.0
    elseif relative_moisture <= 1.0
        # Linear increase to field capacity
        f_moist = relative_moisture
    elseif relative_moisture <= 1.5
        # Slight decline above field capacity (anaerobic inhibition)
        f_moist = 1.0 - 0.5 * (relative_moisture - 1.0) / 0.5
    else
        f_moist = 0.5  # Saturated conditions
    end

    # Organic N pool: ~5% of OM is N
    organic_n_pool = organic_matter_pct * 10000.0 * 0.05  # mg/kg

    rate = potential_rate * organic_n_pool * f_temp * f_moist / 100.0
    return max(0.0, rate)
end

"""
    nitrification_rate(ammonium, temperature, moisture, ph;
                        max_rate=5.0) -> Float64

Nitrification rate: NH4+ -> NO3- (mg N/kg/day).
Modulated by substrate concentration, temperature, moisture, and pH.
"""
function nitrification_rate(ammonium::Float64, temperature::Float64,
                             moisture::Float64, ph::Float64;
                             max_rate::Float64 = 5.0,
                             field_capacity::Float64 = 0.30)::Float64
    if ammonium <= 0.0
        return 0.0
    end

    # Substrate limitation (Michaelis-Menten)
    km_nh4 = 10.0  # mg/kg
    f_substrate = ammonium / (km_nh4 + ammonium)

    # Temperature factor (optimum at ~30degC, zero below 5 and above 50)
    if temperature < 5.0 || temperature > 50.0
        f_temp = 0.0
    elseif temperature <= 30.0
        f_temp = (temperature - 5.0) / 25.0
    else
        f_temp = (50.0 - temperature) / 20.0
    end
    f_temp = max(0.0, f_temp)

    # Moisture factor (optimum at 60% of field capacity)
    wfps = moisture / field_capacity  # Water-filled pore space proxy
    if wfps <= 0.2
        f_moist = 0.0
    elseif wfps <= 0.6
        f_moist = (wfps - 0.2) / 0.4
    elseif wfps <= 1.0
        f_moist = 1.0
    else
        # Decline under waterlogged conditions (O2 limitation)
        f_moist = max(0.0, 1.0 - (wfps - 1.0) / 0.5)
    end

    # pH factor (optimum at pH 7-8, declines below 5 and above 9)
    if ph < 4.0
        f_ph = 0.0
    elseif ph < 6.0
        f_ph = (ph - 4.0) / 2.0
    elseif ph <= 8.0
        f_ph = 1.0
    elseif ph <= 9.5
        f_ph = (9.5 - ph) / 1.5
    else
        f_ph = 0.0
    end

    rate = max_rate * f_substrate * f_temp * f_moist * f_ph
    return max(0.0, rate)
end

"""
    denitrification_rate(nitrate, temperature, moisture;
                          max_rate=3.0) -> Float64

Denitrification rate: NO3- -> N2O/N2 (mg N/kg/day).
Occurs under anaerobic (waterlogged) conditions.
"""
function denitrification_rate(nitrate::Float64, temperature::Float64,
                               moisture::Float64;
                               max_rate::Float64 = 3.0,
                               field_capacity::Float64 = 0.30,
                               porosity::Float64 = 0.45)::Float64
    if nitrate <= 0.0
        return 0.0
    end

    # Substrate limitation
    km_no3 = 5.0  # mg/kg
    f_substrate = nitrate / (km_no3 + nitrate)

    # Temperature factor (Q10 = 2.5)
    if temperature < 2.0
        f_temp = 0.0
    else
        f_temp = 2.5^((temperature - 25.0) / 10.0)
        f_temp = max(0.0, f_temp)
    end

    # Moisture factor: denitrification significant only when WFPS > 60%
    wfps = moisture / porosity
    if wfps < 0.60
        f_moist = 0.0
    elseif wfps < 0.80
        f_moist = (wfps - 0.60) / 0.20
    else
        f_moist = 1.0
    end

    rate = max_rate * f_substrate * f_temp * f_moist
    return max(0.0, rate)
end

# ---------------------------------------------------------------------------
# Phosphorus sorption
# ---------------------------------------------------------------------------

"""
    phosphorus_sorption(p_solution, clay_pct, ph; kf=0.5, n_f=0.7) -> Float64

Freundlich isotherm for phosphorus sorption:
    S = Kf * C^(1/n)

Returns sorbed P (mg/kg).
"""
function phosphorus_sorption(p_solution::Float64, clay_pct::Float64,
                              ph::Float64;
                              kf::Float64 = 0.5, n_f::Float64 = 0.7)::Float64
    if p_solution <= 0.0
        return 0.0
    end
    # Adjust Kf by clay content and pH
    kf_adj = kf * (clay_pct / 25.0) * (1.0 + 0.1 * (7.0 - ph))
    kf_adj = max(0.01, kf_adj)
    return kf_adj * p_solution^(1.0 / n_f)
end

# ---------------------------------------------------------------------------
# Main transport solver
# ---------------------------------------------------------------------------

"""
    solve_nutrient_transport(profile, initial, bc, duration_days, dt_hours) -> Vector{NutrientState}

Solve coupled advection-diffusion equations for N (NO3, NH4), P, and K
transport through the soil profile with biogeochemical source/sink terms.

Uses DifferentialEquations.jl with a method-of-lines spatial discretisation
(finite differences) coupled to an ODE solver.

Returns a vector of NutrientState snapshots at daily intervals.
"""
function solve_nutrient_transport(profile::SoilProfile,
                                   initial::NutrientState,
                                   bc::BoundaryConditions,
                                   duration_days::Float64,
                                   dt_hours::Float64 = 1.0)

    nl = profile.n_layers
    # State vector layout (flattened):
    # [no3_1..no3_nl, nh4_1..nh4_nl, p_1..p_nl, k_1..k_nl, water_1..water_nl, orgN_1..orgN_nl]
    n_vars = 6
    n_total = n_vars * nl

    function pack_state(ns::NutrientState)::Vector{Float64}
        return vcat(ns.nitrogen_no3, ns.nitrogen_nh4, ns.phosphorus,
                    ns.potassium, ns.water_content, ns.organic_nitrogen)
    end

    function unpack_state(u::Vector{Float64}, temps::Vector{Float64})::NutrientState
        NutrientState(
            u[1:nl],
            u[nl+1:2nl],
            u[2nl+1:3nl],
            u[3nl+1:4nl],
            u[4nl+1:5nl],
            u[5nl+1:6nl],
            copy(temps)
        )
    end

    u0 = pack_state(initial)

    # Pre-compute layer spacings
    dz = [profile.layers[i].thickness_m for i in 1:nl]

    function transport_rhs!(du, u, p, t)
        # Extract species
        no3  = @view u[1:nl]
        nh4  = @view u[nl+1:2nl]
        phos = @view u[2nl+1:3nl]
        pot  = @view u[3nl+1:4nl]
        theta = @view u[4nl+1:5nl]
        org_n = @view u[5nl+1:6nl]

        # du views
        dno3  = @view du[1:nl]
        dnh4  = @view du[nl+1:2nl]
        dphos = @view du[2nl+1:3nl]
        dpot  = @view du[3nl+1:4nl]
        dtheta = @view du[4nl+1:5nl]
        dorg_n = @view du[5nl+1:6nl]

        for i in 1:nl
            layer = profile.layers[i]
            temp_i = initial.temperature[i]  # Assume constant T for simplicity
            theta_i = max(theta[i], 0.01)
            dz_i = dz[i]

            # ---- Biogeochemical reactions ----

            # Mineralization: organic N -> NH4
            miner = mineralization_rate(org_n[i] / 100.0, temp_i, theta_i;
                                         field_capacity=layer.field_capacity)

            # Nitrification: NH4 -> NO3
            nitrif = nitrification_rate(max(0.0, nh4[i]), temp_i, theta_i, layer.ph;
                                         field_capacity=layer.field_capacity)

            # Denitrification: NO3 -> N2 (loss)
            denitrif = denitrification_rate(max(0.0, no3[i]), temp_i, theta_i;
                                             field_capacity=layer.field_capacity,
                                             porosity=layer.porosity)

            # Root uptake
            rd_i = bc.root_density_profile[i]
            uptake_no3 = nutrient_uptake_root(rd_i, max(0.0, no3[i]), 5.0, 8.0)
            uptake_nh4 = nutrient_uptake_root(rd_i, max(0.0, nh4[i]), 3.0, 4.0)
            uptake_p   = nutrient_uptake_root(rd_i, max(0.0, phos[i]), 0.5, 1.5)
            uptake_k   = nutrient_uptake_root(rd_i, max(0.0, pot[i]), 2.0, 5.0)

            # ---- Diffusion (central differences) ----

            # NO3 diffusion
            d_no3 = diffusion_coefficient(:no3, theta_i, temp_i;
                                           porosity=layer.porosity)
            # NH4 diffusion (slower, often adsorbed)
            d_nh4 = diffusion_coefficient(:nh4, theta_i, temp_i;
                                           porosity=layer.porosity) * 0.3  # Retardation

            d_p = diffusion_coefficient(:phosphorus, theta_i, temp_i;
                                         porosity=layer.porosity) * 0.1   # Strongly sorbed

            d_k = diffusion_coefficient(:potassium, theta_i, temp_i;
                                         porosity=layer.porosity) * 0.5

            # Second derivative (diffusion term): d2C/dz2
            function laplacian(c::AbstractVector, idx::Int, d_coeff::Float64)
                if idx == 1
                    # Top boundary: flux boundary
                    c_above = c[1]  # Neumann (zero gradient, flux handled separately)
                    c_below = c[2]
                elseif idx == nl
                    # Bottom boundary: zero gradient
                    c_above = c[nl-1]
                    c_below = c[nl]
                else
                    c_above = c[idx-1]
                    c_below = c[idx+1]
                end
                dz_eff = (dz_i + (idx < nl ? dz[min(idx+1, nl)] : dz_i)) / 2.0
                return d_coeff * (c_above - 2.0 * c[idx] + c_below) / (dz_eff^2)
            end

            # Advection term: v * dC/dz (upwind scheme)
            theta_grad = 0.0
            if i > 1 && i < nl
                theta_grad = (theta[i+1] - theta[i-1]) / (dz[i-1] + dz_i)
            end
            v_water = advection_velocity(layer.hydraulic_conductivity,
                                          theta_grad, theta_i)

            function advection(c::AbstractVector, idx::Int, vel::Float64)
                if vel >= 0.0  # Downward flow, upwind from above
                    c_up = idx > 1 ? c[idx-1] : c[idx]
                    return -vel * (c[idx] - c_up) / dz_i
                else  # Upward flow, upwind from below
                    c_down = idx < nl ? c[idx+1] : c[idx]
                    return -vel * (c_down - c[idx]) / dz_i
                end
            end

            # ---- Assemble RHS ----

            # NO3
            dno3[i] = laplacian(no3, i, d_no3) +
                       advection(no3, i, v_water) +
                       nitrif - denitrif - uptake_no3

            # NH4
            dnh4[i] = laplacian(nh4, i, d_nh4) +
                       advection(nh4, i, v_water * 0.1) +  # NH4 less mobile
                       miner - nitrif - uptake_nh4

            # P (strongly sorbed, slow transport)
            dphos[i] = laplacian(phos, i, d_p) - uptake_p

            # K
            dpot[i] = laplacian(pot, i, d_k) +
                       advection(pot, i, v_water * 0.3) - uptake_k

            # Water content (simplified: infiltration/drainage)
            if i == 1
                inflow = bc.surface_water_flux / dz_i
            else
                # Gravity drainage from layer above
                theta_above = max(theta[i-1], 0.01)
                k_above = profile.layers[i-1].hydraulic_conductivity *
                          (theta_above / profile.layers[i-1].porosity)^3
                inflow = k_above / dz_i
            end
            if i == nl
                outflow = bc.bottom_drainage_rate / dz_i
            else
                k_i = layer.hydraulic_conductivity * (theta_i / layer.porosity)^3
                outflow = k_i / dz_i
            end
            # ET extraction proportional to root density
            et_extract = 0.004 * rd_i / dz_i  # ~4 mm/day distributed by roots

            dtheta[i] = inflow - outflow - et_extract
            # Clamp water content rate to prevent going below wilting or above saturation
            if theta_i <= layer.wilting_point + 0.001 && dtheta[i] < 0.0
                dtheta[i] = 0.0
            end
            if theta_i >= layer.porosity - 0.001 && dtheta[i] > 0.0
                dtheta[i] = 0.0
            end

            # Organic N pool (slow decline from mineralization)
            dorg_n[i] = -miner * 0.1  # Fraction of mineralised N from organic pool

            # Surface boundary fluxes (top layer only)
            if i == 1
                bulk_vol = layer.bulk_density * 1e6 * dz_i  # g/m^2 in layer
                dno3[i] += bc.surface_no3_flux / bulk_vol * 1e3
                dnh4[i] += bc.surface_nh4_flux / bulk_vol * 1e3
                dphos[i] += bc.surface_p_flux / bulk_vol * 1e3
                dpot[i] += bc.surface_k_flux / bulk_vol * 1e3
            end
        end
    end

    tspan = (0.0, duration_days)
    prob = ODEProblem(transport_rhs!, u0, tspan)

    # Use a stiff solver since advection-diffusion can be stiff
    dt_days = dt_hours / 24.0
    sol = solve(prob, Rosenbrock23();
                reltol=1e-4, abstol=1e-6,
                saveat=1.0,  # Save daily
                dtmax=dt_days)

    # Convert solution to NutrientState snapshots
    results = NutrientState[]
    for u in sol.u
        # Clamp non-negative
        u_clamped = max.(u, 0.0)
        push!(results, unpack_state(u_clamped, initial.temperature))
    end

    return results
end

end # module NutrientDiffusion
