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

            

        p1,q1=size(source.exogenous.values)
        p2,q2=size(source.exogenous.transitions)

        Q = SMatrix{p1,q1}(source.exogenous.values)
        points = SVector( (Q[i,:] for i=1:size(Q,1))... )

        P = SMatrix{p2,q2}(source.exogenous.transitions)

        (;states, min, max) = source.domain.endo

        aargs = (states[i]=>(min[i],max[i]) for i in eachindex(states))

        cspace = CartesianSpace(; aargs... )
        
        exo_vars = tuple(source.symbols[:exogenous]...)
        
        states = GridSpace(exo_vars, points  ) × cspace
        
        exogenous = NoLib.MarkovChain(exo_vars, P, points)

        controls = NoLib.CartesianSpace(;
            Dict(k=>[-Inf, Inf] for k in source.symbols[:controls])...
        )
        name = try
            Symbol(source.data[:name].value)
        catch e
            :anonymous
        end

        return NoLib.YModel(name, states, controls, exogenous, calibration, source)


        # return DoloModel{ typeof(calibration), typeof(domain), typeof(P), typeof(source), Val(name)}(calibration, domain, P, source)
        # transition
    end

    # only for VAR and MC

    function transition(model::NoLib.YModel{<:NoLib.MarkovChain,B,C,D,E,sS}, s::SVector, x::SVector, M::SVector) where A where B where C where D where E where sS<:DoloYAML.Model

        d = length(NoLib.variables(model.exogenous))
        n = length(NoLib.variables(model.states))

        mm = SVector( (s[i] for i=1:d)... )
        ss = SVector( (s[i] for i=(d+1):n)... )
        
        # p = SVector(model.source.calibration[:parameters]...)
        p = model.source.parameters

        S = Dolo.transition(model.source, mm, ss, x, M, p)

        return S

    end

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

    # function arbitrage(model::NoLib.YModel{A,B,C,D,E,sS}, s::NamedTuple, x::NamedTuple, S::NamedTuple, X::NamedTuple) where A where B where C where D where E where sS<:DoloYAML.Model


    #     d = length(NoLib.variables(model.exogenous))
    #     endo_vars = tuple( (k for (i,k) in enumerate(NoLib.variables(model.states)) if i>d )...)

    #     m_ = tuple( (s[k] for k in NoLib.variables(model.exogenous) )...)
    #     s_ = tuple( (s[k] for (i,k) in enumerate(NoLib.variables(model.states)) if i>d )...)
    #     x_ = tuple( (x[k] for k in NoLib.variables(model.controls) )...)
    #     M_ = tuple( (S[k] for k in NoLib.variables(model.exogenous) )...)
    #     S_ = tuple( (S[k] for (i,k) in enumerate(NoLib.variables(model.states)) if i>d )...)
    #     X_ = tuple( (X[k] for k in NoLib.variables(model.controls) )...)

    #     p = model.source.calibration[:parameters]


    #     r = Dolo.arbitrage(model.source, SVector(m_...), SVector(s_...), SVector(x_...), SVector(M_...), SVector(S_...), SVector(X_...), SVector(p...))

    #     return SVector(r)
        
    # end


    # function DoloDModel(filename)

    #     source = Dolo.yaml_import(filename)


    #     m = SLVector(; (v=>source.calibration.flat[v] for v in source.symbols[:exogenous])...) 
    #     s = SLVector(; (v=>source.calibration.flat[v] for v in source.symbols[:states])...) 
    #     x = SLVector(; (v=>source.calibration.flat[v] for v in source.symbols[:controls])...) 
    #     p = SLVector(; (v=>source.calibration.flat[v] for v in source.symbols[:parameters])...) 

    #     calibration = (;m, s, x, p,)

    #     p1,q1=size(source.exogenous.values)
    #     p2,q2=size(source.exogenous.transitions)

    #     Q = SMatrix{p1,q1}(source.exogenous.values)
    #     points = [Q[i,:] for i=1:size(Q,1)]

    #     P = SMatrix{p2,q2}(source.exogenous.transitions)

    #     (;states, min, max) = source.domain.endo
    #     aargs = (states[i]=>(min[i],max[i]) for i in eachindex(states))
    #     gpsce = GridSpace( points  )
    #     cspace = CartesianSpace(; aargs... )

    #     domain = GridSpace( points  ) × cspace

    #     name = try
    #         Symbol(source.data[:name].value)
    #     catch e
    #         :anonymous
    #     end


    #     pg,dp = Dolo.discretize(source)
        
    #     egrid = pg.endo

    #     exo = SSGrid( [Q[i,:] for i=1:size(Q,1)] )
        
    #     args = ( tuple( ((a,b,c)  for (a,b,c) in zip(egrid.min, egrid.max, egrid.n))... ) ) 

    #     endo = CGrid( args )

    #     grid = exo × endo


    #     return DoloDModel{ typeof(calibration), typeof(domain), typeof(grid), typeof(P), typeof(source), Val(name)}(calibration, domain, grid, P, source)
    #     # transition
    # end

    # function recalibrate(model::DoloDModel; args...)
    #     # TODO: check that the following are updated
    #     # - exogenous
    #     # - transition
    #     # - grid
    #     source = model.source
    #     calib = Dolo.get_calibration(model.source; args...)
    #     domain = Dolo.get_domain(model.source; calibration=calib)
    #     m = SLVector(; (v=>calib.flat[v] for v in source.symbols[:exogenous])...) 
    #     s = SLVector(; (v=>calib.flat[v] for v in source.symbols[:states])...) 
    #     x = SLVector(; (v=>calib.flat[v] for v in source.symbols[:controls])...) 
    #     p = SLVector(; (v=>calib.flat[v] for v in source.symbols[:parameters])...) 
    #     calibration = (;m, s, x, p,)
    #     grid = model.grid
    #     P = model.transition
    #     name = NoLib.name(model)
    #     return DoloDModel{ typeof(calibration), typeof(domain), typeof(grid), typeof(P), typeof(source), Val(name)}(calibration, domain, grid, model.transition, model.source)
    # end

end # module DoloModel
