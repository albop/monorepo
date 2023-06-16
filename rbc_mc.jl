
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
        :i => (-Inf, Inf)
    )

    # calibrate some parameters


    α = 0.3
    β = 0.9
    γ = 4.0
    δ = 0.1
    
    ρ = 0.9

    calibration = (;α, β, γ, δ, ρ)


    NoLib.DoloModel(name, states, controls, process, calibration)

end

function transition(model::typeof(model), s::NamedTuple, x::NamedTuple, M::NamedTuple)
    
    (;δ, ρ) = model.calibration
    
    # Z = e.Z
    K = s.k * (1-δ) + x.i

    (;K,)  ## This is only the endogenous state

end


function transition(model::DoloModel{<:NoLib.MarkovChain}, s::State, x::NamedTuple)
    



end


model

