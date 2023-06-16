using NoLib

import Dolo


module Temp

    import Dolo
    import NoLib
    import NoLib: transition, arbitrage
    using StaticArrays
    using NoLib: CartesianSpace, GridSpace, ×, SSGrid, CGrid, LVectorLike
    using LabelledArrays

    struct DoModel{A,B,C,DM,N} <: NoLib.AModel{A,B,C,N}
        calibration::A
        domain::B
        transition::C
        source::DM
    end


    struct DoDModel{A,B,C,D,DM,N} <: NoLib.ADModel{A,B,C,D,N}
        calibration::A
        domain::B
        grid::C
        transition::D
        source::DM
    end

    

    function DoModel(filename)

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

        (;states, min, max) = source.domain

        aargs = (states[i]=>(min[i],max[i]) for i in eachindex(states))

        cspace = CartesianSpace(; aargs... )

        domain = GridSpace( points  ) × cspace

        name = try
            Symbol(source.data[:name].value)
        catch e
            :anonymous
        end

        return DoModel{ typeof(calibration), typeof(domain), typeof(P), typeof(source), Val(name)}(calibration, domain, P, source)
        # transition
    end

    function transition(model::DoDModel, m::SLArray, s::SLArray, x::SLArray, M::SLArray, p)


        S = Dolo.transition(model.source, SVector(m...), SVector(s...), SVector(x...), SVector(M...), SVector(p...))

        return LVectorLike(model.calibration.s, S)

    end
    
    function arbitrage(model::DoDModel, m::SLArray, s::SLArray, x::SLArray, M::SLArray, S::SLArray, X::SLArray, p)

        r = Dolo.arbitrage(model.source, SVector(m...), SVector(s...), SVector(x...), SVector(M...), SVector(S...), SVector(X...), SVector(p...))

        return LVectorLike(model.calibration.x, r)
        
    end


    function DoDModel(filename)

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

        (;states, min, max) = source.domain
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


        return DoDModel{ typeof(calibration), typeof(domain), typeof(grid), typeof(P), typeof(source), Val(name)}(calibration, domain, grid, P, source)
        # transition
    end

    function recalibrate(model::DoDModel; args...)
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
        return DoDModel{ typeof(calibration), typeof(domain), typeof(grid), typeof(P), typeof(source), Val(name)}(calibration, domain, grid, model.transition, model.source)
    end

end

import Main.Temp
import Main.Temp: transition, arbitrage

@time domodel = Main.Temp.DoDModel("examples/models/rbc_mc.yaml");
nolibmodel = include("models/rbc.jl")
dolomodel = Dolo.Model("examples/models/rbc_mc.yaml")


@time sol_dolo = Dolo.time_iteration(dolomodel, verbose=true);

@time sol_donolib_l = NoLib.time_iteration(domodel; improve=false, verbose=false, interp_mode=:linear);
@time sol_nolib_l = NoLib.time_iteration(nolibmodel; improve=false, verbose=true, interp_mode=:linear);

@time sol_donolib_c = NoLib.time_iteration(domodel; improve=false, verbose=true, interp_mode=:cubic);
@time sol_nolib_c = NoLib.time_iteration(nolibmodel; improve=false, verbose=true, interp_mode=:cubic);



@time sol_dolo_i = Dolo.improved_time_iteration(dolomodel, verbose=false);
@time sol_donolib_l = NoLib.time_iteration(domodel; improve=true, verbose=false, interp_mode=:linear);
@time sol_nolib_l = NoLib.time_iteration(nolibmodel; improve=true, verbose=false, interp_mode=:linear);

# @time sol_donolib_c = NoLib.time_iteration(domodel; improve=false, verbose=true, interp_mode=:cubic);
# @time sol_nolib_c = NoLib.time_iteration(nolibmodel; improve=true, verbose=true, interp_mode=:cubic);

using Plots

φ_d = sol_dolo.dr

φ_l = sol_nolib_l.dr
φ_c = sol_nolib_c.dr



kvec = range(model.domain.spaces[2].min[1], model.domain.spaces[2].max[1];length=1000)

kg = [s[2] for s in model.grid]

v_l = [φ_l(2,SVector(s[2])) for s in model.grid]
v_c = [φ_c(2,SVector(s[2])) for s in model.grid]

vals_l = [φ_l(2,SVector(k)) for k in kvec]
vals_c = [φ_c(2,SVector(k)) for k in kvec]


using Plots

pl = plot()
scatter!(pl, kg, [v[1] for v in v_l])
scatter!(pl, kg, [v[1] for v in v_c])
plot!(pl, kvec, [v[1] for v in vals_l])
plot!(pl, kvec, [v[1] for v in vals_c])




vals_d = [φ_d(2,SVector(s[2])) for (i,s) in NoLib.enum(model.grid)]

vals_l = [φ_l(2,SVector(s[2])) for (i,s) in NoLib.enum(model.grid)]
vals_c = [φ_c(2,SVector(s[2])) for (i,s) in NoLib.enum(model.grid)]