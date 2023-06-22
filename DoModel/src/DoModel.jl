module DoModel


    import DoloYAML

    const Dolo = DoloYAML

    import NoLib
    import NoLib: transition, arbitrage
    using StaticArrays
    using NoLib: CartesianSpace, GridSpace, ×, SGrid, CGrid




    function DoloModel(filename)

        source = Dolo.yaml_import(filename)


        m = (; (v=>source.calibration.flat[v] for v in source.symbols[:exogenous])...) 
        s = (; (v=>source.calibration.flat[v] for v in source.symbols[:states])...) 
        x = (; (v=>source.calibration.flat[v] for v in source.symbols[:controls])...) 
        p = (; (v=>source.calibration.flat[v] for v in source.symbols[:parameters])...) 

        calibration = merge(m, s, x, p,)

        if typeof(source.exogenous) <: Dolo.DiscreteMarkovProcess
            p1,q1=size(source.exogenous.values)
            p2,q2=size(source.exogenous.transitions)
    
            Q = SMatrix{p1,q1}(source.exogenous.values)
            points = SVector( tuple((Q[i,:] for i=1:size(Q,1))...) )

            P = SMatrix{p2,q2}(source.exogenous.transitions)

            (;states, min, max) = source.domain.endo

            aargs = (states[i]=>(min[i],max[i]) for i in eachindex(states))
            cspace = CartesianSpace(; aargs... )
            exo_vars = tuple(source.symbols[:exogenous]...)
            states = GridSpace(exo_vars, points  ) × cspace
            exogenous = NoLib.MarkovChain(exo_vars, P, points)

        elseif typeof(source.exogenous) <: Dolo.MvNormal

            (;states, min, max) = source.domain.endo
            aargs = (states[i]=>(min[i],max[i]) for i in eachindex(states))
            states = CartesianSpace(; aargs... )
            exo_vars = tuple(source.symbols[:exogenous]...)
            exogenous = NoLib.MvNormal(exo_vars, source.exogenous.μ, source.exogenous.Σ)
            # exogenous = NoLib.MvNormal(source.exogenous.μ, source.exogenous.Σ) # TODO

        elseif typeof(source.exogenous) <: Dolo.VAR1
            
            exo_vars = tuple(source.symbols[:exogenous]...)
            # TODO: assert R diag(r)
            ρ = source.exogenous.R[1,1]
            Σ = source.exogenous.Σ
            p = size(Σ,1)


            (;states, min, max) = source.domain.endo

            aargs = (states[i]=>(min[i],max[i]) for i in eachindex(states))
            cspace = CartesianSpace(; aargs... )
            exo_vars = tuple(source.symbols[:exogenous]...)
            keys =  Dict(k=>(-Inf,Inf) for k in exo_vars )
            exo_domain = CartesianSpace(; keys... )

            min = tuple(exo_domain.min..., cspace.min...)
            max = tuple(exo_domain.max..., cspace.max...)
            names = tuple(NoLib.variables(exo_domain)..., NoLib.variables(cspace)...)
            states = NoLib.CartesianSpace{length(names), names}(min, max)
            exogenous = NoLib.VAR1(exo_vars, ρ, SMatrix{p,p,Float64,p*p}(Σ))


        end

            controls = NoLib.CartesianSpace(;
                Dict(k=>[-Inf, Inf] for k in source.symbols[:controls])...
            )

        name = try
            Symbol(source.data[:name].value)
        catch e
            :anonymous
        end

        # return (states, controls, exogenous)

        return NoLib.YModel(name, states, controls, exogenous, calibration, source)


        # return DoloModel{ typeof(calibration), typeof(domain), typeof(P), typeof(source), Val(name)}(calibration, domain, P, source)
        # transition
    end

    # only for VAR and MC


    function transition(model::NoLib.YModel{MOD,B,C,D,E,sS}, s::NamedTuple, x::NamedTuple, M::NamedTuple) where B where C where D where E where sS<:DoloYAML.Model where MOD<:Union{<:NoLib.MarkovChain,<:NoLib.VAR1}

        svars = (NoLib.variables(model.states))
        exo = (NoLib.variables(model.exogenous))
        endo = tuple( (v for v in svars if !(v in exo))...)
        controls = NoLib.variables(model.controls)

        mm = SVector( (s[i] for i in exo)... )
        ss = SVector( (s[i] for i in endo)... )
        xx = SVector( (x[i] for i in controls)... )
        MM = SVector( (M[i] for i in exo)... )

        # p = SVector(model.source.calibration[:parameters]...)
        p = model.source.parameters
        S = Dolo.transition(model.source, mm, ss, xx, MM, p)

        return NamedTuple{endo}(S...)

    end

    # function transition(model::NoLib.YModel{MOD,B,C,D,E,sS}, s::SVector, x::SVector, M::SVector) where B where C where D where E where sS<:DoloYAML.Model where MOD<:Union{<:NoLib.MarkovChain,<:NoLib.VAR1}

    #     d = length(NoLib.variables(model.exogenous))
    #     n = length(NoLib.variables(model.states))

    #     mm = SVector( (s[i] for i=1:d)... )
    #     ss = SVector( (s[i] for i=(d+1):n)... )
        
    #     # p = SVector(model.source.calibration[:parameters]...)
    #     p = model.source.parameters

    #     S = Dolo.transition(model.source, mm, ss, x, M, p)

    #     return S

    # end

    function arbitrage(model::NoLib.YModel{A,B,C,D,E,sS}, s::SVector, x::SVector, S::SVector, X::SVector) where A where B where C where D where E where sS<:DoloYAML.Model

        d = length(NoLib.variables(model.exogenous))
        n = length(NoLib.variables(model.states))
        mm = SVector( (s[i] for i=1:d)... )
        ss = SVector( (s[i] for i=(d+1):n)... )
        
        MM = SVector( (S[i] for i=1:d)...)
        SS = SVector( (S[i] for i=(d+1):n)...)
        
        p = model.source.parameters

        res = Dolo.arbitrage(model.source, mm, ss, x, MM, SS, X, p)

        return SVector(res...)
    
    end

    function transition(model::NoLib.YModel{<:NoLib.MvNormal,B,C,D,E,sS}, s::SVector, x::SVector, M::SVector) where B where C where D where E where sS<:DoloYAML.Model

        p = model.source.parameters
        M_ = M # this argument is ignored
        S = Dolo.transition(model.source, M_, s, x, M, p)

        return S

    end


    function arbitrage(model::NoLib.YModel{<:NoLib.MvNormal,B,C,D,E,sS}, s::SVector, x::SVector, S::SVector, X::SVector)  where B where C where D where E where sS<:DoloYAML.Model

        # TODO: currently we don't allow for iid shocks in Euler equations
        # TODO: warning

        d = length(NoLib.variables(model.exogenous))
        n = length(NoLib.variables(model.states))
        m0 = zero(SVector{d,Float64})

        p = model.source.parameters

        res = Dolo.arbitrage(model.source, m0, s, x, m0, S, X, p)

        return SVector(res...)
    
    end



end # module DoloModel

