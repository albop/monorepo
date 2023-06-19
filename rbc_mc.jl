import NoLib: transition

model = let 

    name = :rbc_mc

    P = @SMatrix [0.9 0.1; 0.1 0.9]
    Q = SVector( SVector(-0.01), SVector(0.01) )
    process = NoLib.MarkovChain( (:z,), P, Q )

    states = NoLib.ProductSpace(
        NoLib.GridSpace((:z,), Q),
        NoLib.CartesianSpace(;
            :k => ( 0.0, 1.0),
        )
    )
    controls = NoLib.CartesianSpace(;
        :i => (0.0, 10.0),
        :n => (0.0, 1.5)
    )

    # calibrate some parameters


    α = 0.3
    β = 0.9
    γ = 4.0
    δ = 0.1
    
    ρ = 0.9
    χ = 0.5
    n = 0.8

    calibration = (;α, β, γ, δ, ρ,χ, n, η = 2.0, σ = 2.0)


    NoLib.YModel(name, states, controls, process, calibration)

end

function NoLib.transition(model::typeof(model), s::NamedTuple, x::NamedTuple, M::NamedTuple)
    
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


function arbitrage(model::typeof(model), s::NamedTuple, x::NamedTuple, S::NamedTuple, X::NamedTuple)

    p = model.calibration

	y = intermediate(model, s, x)
	Y = intermediate(model, S, X)
	res_1 = p.χ*(x.n^p.η)*(y.c^p.σ) - y.w
	res_2 = (p.β*(y.c/Y.c)^p.σ)*(1 - p.δ + Y.rk) - 1
    
    return ( (;res_1, res_2) )

end



model