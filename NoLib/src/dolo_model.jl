struct YModel{C,A,B,D,N} <: AModel
    states::A         # must be exo \times endo
    controls::B
    exogenous::C
    calibration::D

end 

YModel(N,A,B,C,D) = YModel{typeof(C),typeof(A),typeof(B),typeof(D),N}(A,B,C,D)

name(::YModel{C,A,B,D,N}) where C where A where B where D where N = N



get_states(model::YModel) = variables(model.states)
get_controls(model::YModel) = variables(model.controls)
# get_endo_states(model::Dolo)
# get_exo_states(model::Dolo)

discretize(cc::CartesianSpace; n=10) = CGrid( tuple(( (cc.min[i],cc.max[i], n) for i=1:length(cc.min))...) )


function Base.show(io::IO, m::YModel) 
    println("Model")
    println("* name: ", name(m))
    println("* states: ", join(get_states(m), ", "))
    println("* controls: ", join(get_controls(m), ", "))
    println("* exogenous: ", m.exogenous)
end

function Base.show(io::IO, m::ADModel) 
    println("Discretized Model")
    println("* name = ", name(m))
end


struct DYModel{M, G, D} <: ADModel
    model::M
    grid::G
    dproc::D
end

name(dm::DYModel) = name(dm.model)

function discretize(model::YModel{<:MvNormal})
    dist = discretize(model.exogenous)
    grid = discretize(model.states)
    return DYModel(model, grid, dist)
end

function discretize(model::YModel{<:VAR1})
    dvar = discretize(model.exogenous)
    exo_grid = SGrid(dvar.Q)
    endo_grid = discretize(model.states)
    grid = exo_grid × endo_grid
    return DYModel(model, grid, dvar)
end

function discretize(model::YModel{<:MarkovChain})
    dvar = (model.exogenous)
    exo_grid = SGrid(dvar.Q)
    endo_grid = discretize(model.states.spaces[2])
    grid = exo_grid × endo_grid
    return DYModel(model, grid, dvar)
end