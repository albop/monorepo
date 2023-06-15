# using DoloYAML

using NoLib
using StaticArrays

model = let 

    name = :rbc

    states = NoLib.CartesianSpace(;
        :k => ( 0.0, 1.0),
        :z => (-0.1, 1.0)
    )

    controls = NoLib.CartesianSpace(;
        :i => (-Inf, Inf)
    )

    
    Σ = @SMatrix [0.9 ;]
    process = NoLib.MvNormal( (:ϵ,), Σ )

    # calibrate some parameters

    α = 0.3
    β = 0.9
    γ = 4.0

    calibration = (;α, β, γ)

    NoLib.DoloModel(name, states, controls, process, calibration)

end;


@assert isbits(model)

@time NoLib.get_states(model)
@time NoLib.get_controls(model)

NoLib.discretize(model)

import NoLib: Policy


φ = Policy(model.states, model.controls, x->SVector(x[1], x[1]-x[2]))

(pol::Policy)(s) = (pol.fun(s))

model = let 

    states = NoLib.CartesianSpace(;
        :k => ( 0.0, 1.0),
        :z => (-0.1, 1.0)
    )

    controls = NoLib.CartesianSpace(;
        :i => (-Inf, Inf)
    )

    ρ = 0.9 
    Σ = @SMatrix [0.9 ;]
    process = NoLib.VAR1( (:ϵ,), ρ, Σ )

    # calibrate some parameters

    α = 0.3
    β = 0.9
    γ = 4.0

    calibration = (;α, β, γ)

    NoLib.DoloModel(states, controls, process, calibration)

end

NoLib.discretize(model.exogenous)
NoLib.discretize(model)

model.exogenous

mc = NoLib.discretize(model.exogenous)

