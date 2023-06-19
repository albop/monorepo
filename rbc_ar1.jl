using LabelledArrays

model = let 

    name = :rbc_ar1

    # states = NoLib.ProductSpace(
    #     NoLib.CartesianSpace(;
    #         :z=> (-90, 90)
    #     ),
    #     NoLib.CartesianSpace(;
    #         :k => ( 0.0, 1.0),
    #     )
    # )

    states = NoLib.CartesianSpace(;
            :z => (-90, 90),
            :k => ( 0.0, 1.0)
        )

    controls = NoLib.CartesianSpace(;
        :i => (0.0, 10.0),
        :n => (0.0, 1.5)
    )

    ρ = 0.9 
    Σ = @SMatrix [0.9 ;]

    process = NoLib.VAR1( (:z,), ρ, Σ )

    # calibrate some parameters

    α = 0.3
    β = 0.9
    γ = 4.0
    δ = 0.1
    
    ρ = 0.9
    n = 0.8

    χ = 0.5
    η = 2.0


    calibration = (;α, β, γ, δ, ρ, n, χ, η = 2.0, σ= 2.0)

    NoLib.YModel(name, states, controls, process, calibration)

end


import NoLib: transition

function transition(model::typeof(model), s::NamedTuple, x::NamedTuple, M::NamedTuple)
    
    (;δ, ρ) = model.calibration
    
    # Z = e.Z
    K = s.k * (1-δ) + x.i

    (;K,)  ## This is only the endogenous state

end

function intermediate(model::typeof(model),s::NamedTuple, x::NamedTuple)
    
    p = model.calibration

	y = exp(s.z)*(s.k^p.α)*(x.n^(1-p.α))
	w = (1-p.α)*y/x.n
	rk = p.α*y/s.k
	c = y - x.i
	return ( (; y, c, rk, w))

end


function arbitrage(model::typeof(model),s::NamedTuple, x::NamedTuple, S::NamedTuple, X::NamedTuple)

    p = model.calibration

	y = intermediate(model, s, x)
	Y = intermediate(model, S, X)
	res_1 = p.χ*(x.n^p.η)*(y.c^p.σ) - y.w
	res_2 = (p.β*(y.c/Y.c)^p.σ)*(1 - p.δ + Y.rk) - 1
    
    return ( (;res_1, res_2) )

end


model