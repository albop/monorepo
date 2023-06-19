function arbitrage(model::YModel, s::SVector, x::SVector, S::SVector, X::SVector)
    ss = NamedTuple{variables(model.states)}(s)
    xx = NamedTuple{variables(model.controls)}(x)
    SS = NamedTuple{variables(model.states)}(S)
    XX = NamedTuple{variables(model.controls)}(X)    
    res = arbitrage(model, ss, xx, SS, XX)
    return SVector(res...)
end

function arbitrage(model::YModel, s::NamedTuple{(:loc,:val)}, x::NamedTuple{(:loc,:val)}, S::NamedTuple{(:loc,:val)}, X::NamedTuple{(:loc,:val)})
    arbitrage(model, s.val, x.val, S.val, X.val)
end


function transition(model)
end


function transition(model::YModel, s::SVector, x::SVector, M::SVector)
    
    ss = NamedTuple{variables(model.states)}(s)
    xx = NamedTuple{variables(model.controls)}(x)
    MM = NamedTuple{variables(model.exogenous)}(M)

    SS = transition(model,ss,xx,MM)
    return SVector(SS...)
end



#####
##### IID shocks
#####


function transition(model::YModel{<:MvNormal}, s::SVector, x::SVector)
    
    transition(model, s, x, rand(model.exogenous))

end


function transition(model::YModel{<:MvNormal}, s::NamedTuple, x::NamedTuple)
    
    ss = s.val
    xx = x.val
    transition(model, ss, xx)

end


#####
##### Markov Chains
#####


function transition(model::YModel{<:MarkovChain}, s::SVector, x::SVector, M::SVector)
    ss = NamedTuple{variables(model.states)}(s)
    xx = NamedTuple{variables(model.controls)}(x)
    MM = NamedTuple{variables(model.exogenous)}(M)
    transition(model, ss, xx, MM)
end


function transition(model::YModel{<:MarkovChain}, s::NamedTuple, xx::NamedTuple)
    
    # m = get_exo(model, s)
    
    # M___ = rand(model.exogenous, m)
    # M = NamedTuple{variables(model.exogenous)}(M___)

    
    i = s.loc[1] # i loc
    
    j = 2    
    # M_v = model.exogenous.Q[j]   # vector of exogenous values
    v = NamedTuple{variables(model.states)}(s.val)
    M_v = NamedTuple{variables(model.exogenous)}(model.exogenous.Q[j] )
    x = NamedTuple{variables(model.controls)}(xx.val)

    S_e =  transition(model, v, x, M_v)        # vector of endogenous values
    
    S = merge(M_v, S_e)

    return (;loc=(j,SVector(S_e...)),  val=S)


end


function transition(model::YModel{<:MarkovChain}, s::NamedTuple, x::SVector)
    
    i,v = s.loc # i loc
    # s = s.val

    j = 2    
    M_v = model.exogenous.Q[j]   # vector of exogenous values

    S_e =  transition(model, v, x, M_v)        # vector of endogenous values
    
    S = merge(M_v, S_e)

    return (;loc=(j,S_e),  val=S)


end

#####
##### VAR1 Models
#####



# extracts name of exogenous states

function get_exo(model, s::NamedTuple)
    exonames = variables(model.exogenous)
    vals = tuple( (getfield(s, n) for n in exonames)... )
    return NamedTuple{exonames}(vals)
end

function get_exo(model, s::SVector)
    snames = variables(model.states)
    vals = get_exo(model, NamedTuple{snames}(s))
    return SVector(vals...)
end


function transition(model::YModel{<:VAR1}, s::NamedTuple, x::NamedTuple)
    
    m = get_exo(model, s)
    
    M = rand(model.exogenous, m)
    S_ = transition(model, s, x, M)

    S = merge(M, S_)

    return S

end

function transition(model::YModel{<:VAR1}, s::NamedTuple{(:loc,:val)}, x::NamedTuple{(:loc,:val)})
    
    ss = NamedTuple{variables(model.states)}(s.val)
    xx = NamedTuple{variables(model.controls)}(x.val)
    SS = transition(model, ss, xx)
    S = SVector(SS...)
    (;loc=S, val=S)

end

function transition(model::YModel{<:VAR1}, ss::SVector, xx::SVector)
    
    _s = variables(model.states)
    _x = variables(model.controls)

    s = NamedTuple{_s}(ss)
    x = NamedTuple{_x}(xx)

    res = transition(model, s, x)

    SVector(res...)

end
