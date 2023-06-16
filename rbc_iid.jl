
model = let 

    name = :rbc_iid


    states = NoLib.CartesianSpace(;
        :z => (-0.1, 1.0),
        :k => ( 0.0, 1.0)
    )

    controls = NoLib.CartesianSpace(;
        :i => (0.0, 10.0)
    )

    
    Σ = @SMatrix [0.9 ;]
    process = NoLib.MvNormal( (:ϵ,), Σ )

    # Σ = @SMatrix [0.9 0.0 ; 0.0 0.1]
    # process = NoLib.MvNormal( (:ϵ,:η), Σ )

    # calibrate some parameters

    α = 0.3
    β = 0.9
    γ = 4.0
    δ = 0.1
    
    ρ = 0.9

    calibration = (;α, β, γ, δ, ρ)

    NoLib.DoloModel(name, states, controls, process, calibration)

end;

import NoLib: transition
function transition(model::typeof(model), s::NamedTuple, x::NamedTuple, e::NamedTuple)
    
    (;δ, ρ) = model.calibration
    
    Z = s.z * ρ + e.ϵ
    K = s.k * (1-δ) + x.i

    (;Z, K)

end


function transition(model::NoLib.DoloModel{<:NoLib.MvNormal}, ss::SVector, xx::SVector, ee::SVector)
    
    _s = NoLib.variables(model.states)
    _x = NoLib.variables(model.controls)
    _e = NoLib.variables(model.exogenous)

    s = NamedTuple{_s}(ss)
    x = NamedTuple{_x}(xx)
    e = NamedTuple{_e}(ee)

    res = transition(model, s, x, e)

    SVector(res...)

end

function transition(model::NoLib.DoloModel{<:NoLib.MvNormal}, s::SVector, x::SVector)
    
    transition(model, s, x, rand(model.exogenous))

end

model

# function simulate(model::NoLib.DoloModel{:NoLib.MvNormal}, s::SVector, φ; T=100)
#     sim = [s]
#     for t=1:T
#         s = simulate(model, s, φ(s))
#         push!(sim, s)
#     end
#     return s
# end

