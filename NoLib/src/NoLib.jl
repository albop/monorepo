module NoLib

    import Base: eltype
    using LabelledArrays
    using StaticArrays
    using ForwardDiff
    
    import LinearAlgebra: cross, norm, ×

    include("splines/splines.jl")
    using .splines: interp
    
    ⟂(a,b) = min(a,b)
    # ⟂ᶠ(a,b)

    import Base: getindex

    import LabelledArrays: merge

    # TODO
    converged(sol::NamedTuple) = (sol.message == "Convergence")


    # type piracy
    function merge(a::SLArray, b::NamedTuple)
        @assert issubset(keys(b), keys(a))
        SLVector( (merge(NamedTuple(a), b)) )
    end


    
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
    include("time_iteration.jl")

    include("time_iteration_accelerated.jl")
    include("vfi.jl")


    # WIP heterogenous agents
    # include("hetag.jl")
    # include("hetag_ss.jl")
    # include("jac.jl")
    # include("gauss_elim.jl")

end # module

