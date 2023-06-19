
model = let 

    name = :rbc_iid


    states = NoLib.CartesianSpace(;
        :z => (-0.1, 1.0),
        :k => ( 0.0, 1.0)
    )

    controls = NoLib.CartesianSpace(;
        :i => (0.0, 10.0),
        :n => (0.0, 1.5)
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
    n = 0.
    χ = 0.5


    calibration = (;α, β, γ, δ, ρ, n, χ, η = 2.0, σ=2.0)

    NoLib.YModel(name, states, controls, process, calibration)

end;

import NoLib: transition
function transition(model::typeof(model), s::NamedTuple, x::NamedTuple, e::NamedTuple)
    
    (;δ, ρ) = model.calibration
    
    Z = s.z * ρ + e.ϵ
    K = s.k * (1-δ) + x.i

    (;Z, K)

end


function intermediate(model::typeof(model),s::NamedTuple, x::NamedTuple)
    
    p = model.calibration

	y = exp(s.z)*(s.k^p.α)*(x.n^(1-p.α))
	w = (1-p.α)*y/x.n
	rk = p.α*y/s.k
	c = y - x.i
	return ( (; y, c, rk, w))

end


function arbitrage(model::typeof(model), s::NamedTuple, x::NamedTuple,  S::NamedTuple, X::NamedTuple)

    p = model.calibration

	y = intermediate(model, s, x)
	Y = intermediate(model, S, X)
	res_1 = p.χ*(x.n^p.η)*(y.c^p.σ) - y.w
	res_2 = (p.β*(y.c/Y.c)^p.σ)*(1 - p.δ + Y.rk) - 1
    
    return ( (;res_1, res_2) )

end


model

# function simulate(model::NoLib.YModel{:NoLib.MvNormal}, s::SVector, φ; T=100)
#     sim = [s]
#     for t=1:T
#         s = simulate(model, s, φ(s))
#         push!(sim, s)
#     end
#     return s
# end

