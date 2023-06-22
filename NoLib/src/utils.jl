function tabulate(model::YModel; kwargs...)
    dis = NoLib.discretize(model.states)
end



function calibrated_values(model::YModel, group)
    if group==:states
        vars = variables(model.states)
    elseif group==:controls
        vars = variables(model.controls)
    elseif group==:exogenous
        vars = variables(model.exogenous)
    else
        error("Unknown group '$(group)'.")
    end
    SVector( (get(model.calibration,v,NaN) for v in vars)... )
end

function calibrated_values(model::YModel)
    states = calibrated_values(model, :states)
    controls = calibrated_values(model, :controls)
    exogenous = calibrated_values(model, :exogenous)
    (;states, controls, exogenous)
end

function get_QP(space, loc::QP)
    return QP
end

function get_QP(space, loc)
    val = space[loc]
    return QP(loc, val)
end

using AxisArrays

function simulate(model::YModel, φ, s0; T=100)
    # s0 = calibrated_values(model)
    s = NoLib.get_QP(model.states, s0)
    x = φ(s)
    sim = [(s,x)]
    for t=1:T
        sn = transition(model, s, x)
        xn = φ(sn)
        push!(sim, (sn, xn))
        s = sn
        x = xn
    end
    arr = [SVector(e[1].val..., e[2]...) for e in sim]
    vars = tuple(variables(model.states)..., variables(model.controls)...)
    return AxisArray(
        hcat((e for e in arr)...)',
        T = 0:T,
        V = [vars...],
    )
end

function simulate(dmodel::DYModel{M,G,P}, φ, s0; T=100) where M where G where P<:MarkovChain

    # s0 = calibrated_values(model)
    # s = NoLib.get_QP(dmodel.model.states, s0)
    s = s0
    # return "HI"
    x = φ(s)
    sim = [(s,x)]
    for t=1:T

        # super inefficient
        options = tuple( τ(dmodel, s, x)... )
        weights = tuple( (e[1] for e in options) ...)
        i = sample(weights)
        sn = options[i][2]
        xn = φ(sn)
        push!(sim, (sn, xn))
        s = sn
        x = xn
    end
    arr = [SVector(e[1].val..., e[2]...) for e in sim]
    vars = tuple(variables(dmodel.model.states)..., variables(dmodel.model.controls)...)
    return AxisArray(
        hcat((e for e in arr)...)',
        T = 0:T,
        V = [vars...],
    )
end