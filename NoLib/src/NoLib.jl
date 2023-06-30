module NoLib

    # include("./stupid.jl")

    import Base: eltype
    # using LabelledArrays
    using StaticArrays
    using ForwardDiff
    using Printf
    using Formatting
    using Crayons.Box

    import LinearAlgebra: cross, norm, ×

    include("splines/splines.jl")
    using .splines: interp
    
    ⟂(a,b) = min(a,b)
    function ⫫(u,v)
        sq = sqrt(u^2+v^2)/2
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
    include("dev_L2.jl")
    include("algos/simul.jl")
    include("algos/results.jl")
    include("algos/time_iteration.jl")
    include("algos/time_iteration_accelerated.jl")
    include("algos/vfi.jl")
    include("utils.jl")


    include("../../DoModel/src/DoModel.jl")


    function yaml_import(filename)
        DoModel.DoloModel(filename)
    end

    export yaml_import, time_iteration, tabulate, discount_factor

    module build
        using NoLib: transition, arbitrage
        using NoLib: GSpace, CSpace
        export CSpace, GSpace, transition, arbitrage
    end


end # module

