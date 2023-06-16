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
        :i => (0, 10)
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

    calibration = (;α, β, γ, δ, ρ)

    NoLib.DoloModel(name, states, controls, process, calibration)

end


import NoLib: transition

function transition(model::typeof(model), s::NamedTuple, x::NamedTuple, M::NamedTuple)
    
    (;δ, ρ) = model.calibration
    
    # Z = e.Z
    K = s.k * (1-δ) + x.i

    (;K,)  ## This is only the endogenous state

end


# extracts name of exogenous states

function get_exo(model, s::NamedTuple)
    exonames = NoLib.variables(model.exogenous)
    vals = tuple( (getfield(s, n) for n in exonames)... )
    return NamedTuple{exonames}(vals)
end

function get_exo(model, s::SVector)
    snames = NoLib.variables(model.states)
    vals = get_exo(model, NamedTuple{snames}(s))
    return SVector(vals...)
end


function transition(model::NoLib.DoloModel{<:NoLib.VAR1}, s::NamedTuple, x::NamedTuple)
    
    m = get_exo(model, s)
    
    M = rand(model.exogenous, m)
    S_ = transition(model, s, x, M)

    S = merge(M, S_)

    return S

end



function transition(model::NoLib.DoloModel{<:NoLib.VAR1}, ss::SVector, xx::SVector)
    
    _s = NoLib.variables(model.states)
    _x = NoLib.variables(model.controls)

    s = NamedTuple{_s}(ss)
    x = NamedTuple{_x}(xx)

    res = transition(model, s, x)

    SVector(res...)

end

model