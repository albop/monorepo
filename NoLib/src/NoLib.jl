module NoLib

    import Base: eltype
    # using LabelledArrays
    using StaticArrays
    using ForwardDiff
    
    import LinearAlgebra: cross, norm, ×

    include("splines/splines.jl")
    using .splines: interp
    
    ⟂(a,b) = min(a,b)
    function ⫫(u,v)
        sq = sqrt(u^2+v^2)
        p =   (v<Inf ? (u+v-sq)/2 : u)
        return p
    end


    #   #, SDiagonal(J_u), SDiagonal(J_v)
    #     # J_u = (v<Inf ? (1.0 - u[i]./sq[i])/2 : 1) for i=1:d )
    #     # J_v = (v<Inf ? (1.0 - v[i]./sq[i])/2 : 0) for i=1:d )
    
    #     return p  #, SDiagonal(J_u), SDiagonal(J_v)
    # end

    import Base: getindex

    # import LabelledArrays: merge

    # TODO
    converged(sol::NamedTuple) = (sol.message == "Convergence")


    # # type piracy
    # function merge(a::SLArray, b::NamedTuple)
    #     @assert issubset(keys(b), keys(a))
    #     SLVector( (merge(NamedTuple(a), b)) )
    # end


    struct QP{A,B}
        loc::A
        val::B
    end

    import Base: show
    
    show(io::IO, x::QP) = print(io,"QP(;loc=$(x.loc), val=$(x.val))")
    
    macro I(v)
        :(($v).index)
    end

    macro V(v)
        :(($v)[2])
    end

    

    include("misc.jl")
    include("space.jl")
    include("grids.jl")
    include("processes.jl")
    include("garray.jl")
    include("model.jl")
    include("funs.jl")
    include("simul.jl")
    include("time_iteration_log.jl")
    include("time_iteration.jl")
    include("time_iteration_accelerated.jl")
    include("vfi.jl")
    include("utils.jl")


    # WIP heterogenous agents
    # include("hetag.jl")
    # include("hetag_ss.jl")
    # include("jac.jl")
    # include("gauss_elim.jl")


    module build
        using NoLib: transition, arbitrage
        using NoLib: GSpace, CSpace
        export CSpace, GSpace, transition, arbitrage
    end


end # module

