
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

State = Any



function transition(model::NoLib.DoloModel{<:NoLib.MarkovChain}, s::NamedTuple, x::NamedTuple)
    
    # m = get_exo(model, s)
    
    # M___ = rand(model.exogenous, m)
    # M = NamedTuple{NoLib.variables(model.exogenous)}(M___)

    
    i = s.loc[1] # i loc
    v = s.val

    j = 2    
    # M_v = model.exogenous.Q[j]   # vector of exogenous values
    M_v = NamedTuple{NoLib.variables(model.exogenous)}(model.exogenous.Q[j] )
    S_e =  transition(model, v, x, M_v)        # vector of endogenous values
    
    S = merge(M_v, S_e)

    return (;loc=(j,SVector(S_e...)),  val=S)


end


function transition(model::NoLib.DoloModel{<:NoLib.MarkovChain}, s::State, x::SVector)
    
    i,v = s.loc # i loc
    # s = s.val

    j = 2    
    M_v = model.exogenous.Q[j]   # vector of exogenous values

    print(v,x, M_v)
    print("#########")
    S_e =  transition(model, v, x, M_v)        # vector of endogenous values
    
    S = merge(M_v, S_e)

    return (;loc=(j,S_e),  val=S)


end


model