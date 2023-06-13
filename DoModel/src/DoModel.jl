module DoModel


    import DoloYAML

    const Dolo = DoloYAML

    import NoLib
    import NoLib: transition, arbitrage
    using StaticArrays
    using NoLib: CartesianSpace, GridSpace, ×, SSGrid, CGrid, LVectorLike
    using LabelledArrays

    struct DoloModel{A,B,C,DM,N} <: NoLib.AModel{A,B,C,N}
        calibration::A
        domain::B
        transition::C
        source::DM
    end


    struct DoloDModel{A,B,C,D,DM,N} <: NoLib.ADModel{A,B,C,D,N}
        calibration::A
        domain::B
        grid::C
        transition::D
        source::DM
    end



    function DoloModel(filename)

        source = Dolo.yaml_import(filename)


        m = SLVector(; (v=>source.calibration.flat[v] for v in source.symbols[:exogenous])...) 
        s = SLVector(; (v=>source.calibration.flat[v] for v in source.symbols[:states])...) 
        x = SLVector(; (v=>source.calibration.flat[v] for v in source.symbols[:controls])...) 
        p = SLVector(; (v=>source.calibration.flat[v] for v in source.symbols[:parameters])...) 

        calibration = (;m, s, x, p,)

        p1,q1=size(source.exogenous.values)
        p2,q2=size(source.exogenous.transitions)

        Q = SMatrix{p1,q1}(source.exogenous.values)
        points = [Q[i,:] for i=1:size(Q,1)]

        P = SMatrix{p2,q2}(source.exogenous.transitions)

        (;states, min, max) = source.domain.endo

        aargs = (states[i]=>(min[i],max[i]) for i in eachindex(states))

        cspace = CartesianSpace(; aargs... )

        domain = GridSpace( points  ) × cspace

        name = try
            Symbol(source.data[:name].value)
        catch e
            :anonymous
        end

        return DoloModel{ typeof(calibration), typeof(domain), typeof(P), typeof(source), Val(name)}(calibration, domain, P, source)
        # transition
    end

    function transition(model::DoloDModel, m::SLArray, s::SLArray, x::SLArray, M::SLArray, p)


        S = Dolo.transition(model.source, SVector(m...), SVector(s...), SVector(x...), SVector(M...), SVector(p...))

        return LVectorLike(model.calibration.s, S)

    end

    function arbitrage(model::DoloDModel, m::SLArray, s::SLArray, x::SLArray, M::SLArray, S::SLArray, X::SLArray, p)

        r = Dolo.arbitrage(model.source, SVector(m...), SVector(s...), SVector(x...), SVector(M...), SVector(S...), SVector(X...), SVector(p...))

        return LVectorLike(model.calibration.x, r)
        
    end


    function DoloDModel(filename)

        source = Dolo.yaml_import(filename)


        m = SLVector(; (v=>source.calibration.flat[v] for v in source.symbols[:exogenous])...) 
        s = SLVector(; (v=>source.calibration.flat[v] for v in source.symbols[:states])...) 
        x = SLVector(; (v=>source.calibration.flat[v] for v in source.symbols[:controls])...) 
        p = SLVector(; (v=>source.calibration.flat[v] for v in source.symbols[:parameters])...) 

        calibration = (;m, s, x, p,)

        p1,q1=size(source.exogenous.values)
        p2,q2=size(source.exogenous.transitions)

        Q = SMatrix{p1,q1}(source.exogenous.values)
        points = [Q[i,:] for i=1:size(Q,1)]

        P = SMatrix{p2,q2}(source.exogenous.transitions)

        (;states, min, max) = source.domain.endo
        aargs = (states[i]=>(min[i],max[i]) for i in eachindex(states))
        gpsce = GridSpace( points  )
        cspace = CartesianSpace(; aargs... )

        domain = GridSpace( points  ) × cspace

        name = try
            Symbol(source.data[:name].value)
        catch e
            :anonymous
        end


        pg,dp = Dolo.discretize(source)
        
        egrid = pg.endo

        exo = SSGrid( [Q[i,:] for i=1:size(Q,1)] )
        
        args = ( tuple( ((a,b,c)  for (a,b,c) in zip(egrid.min, egrid.max, egrid.n))... ) ) 

        endo = CGrid( args )

        grid = exo × endo


        return DoloDModel{ typeof(calibration), typeof(domain), typeof(grid), typeof(P), typeof(source), Val(name)}(calibration, domain, grid, P, source)
        # transition
    end

    function recalibrate(model::DoloDModel; args...)
        # TODO: check that the following are updated
        # - exogenous
        # - transition
        # - grid
        source = model.source
        calib = Dolo.get_calibration(model.source; args...)
        domain = Dolo.get_domain(model.source; calibration=calib)
        m = SLVector(; (v=>calib.flat[v] for v in source.symbols[:exogenous])...) 
        s = SLVector(; (v=>calib.flat[v] for v in source.symbols[:states])...) 
        x = SLVector(; (v=>calib.flat[v] for v in source.symbols[:controls])...) 
        p = SLVector(; (v=>calib.flat[v] for v in source.symbols[:parameters])...) 
        calibration = (;m, s, x, p,)
        grid = model.grid
        P = model.transition
        name = NoLib.name(model)
        return DoloDModel{ typeof(calibration), typeof(domain), typeof(grid), typeof(P), typeof(source), Val(name)}(calibration, domain, grid, model.transition, model.source)
    end

end # module DoloModel
