

struct DoloModel{C,A,B,D,N} <: AModel
    states::A         # must be exo \times endo
    controls::B
    exogenous::C
    calibration::D

end 

DoloModel(N,A,B,C,D) = DoloModel{typeof(C),typeof(A),typeof(B),typeof(D),N}(A,B,C,D)

name(::DoloModel{C,A,B,D,N}) where C where A where B where D where N = N


get_states(model::DoloModel) = variables(model.states)
get_controls(model::DoloModel) = variables(model.controls)
# get_endo_states(model::Dolo)
# get_exo_states(model::Dolo)

discretize(cc::CartesianSpace; n=10) = CGrid( tuple(( (cc.min[i],cc.max[i], n) for i=1:length(cc.min))...) )


function Base.show(io::IO, m::DoloModel) 
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


struct GModel{M, G, D} <: ADModel
    model::M
    grid::G
    dproc::D
end

function discretize(model::DoloModel{<:MvNormal}) where A where B where C<:MvNormal where D
    dist = discretize(model.exogenous)
    grid = discretize(model.states)
    return GModel(model, grid, dist)
end

# function discretize(model::DoloModel{<:VAR1}) where A where B where C<:VAR1 where D
#     mc = discretize(model.exogenous)
#     endo_grid = discretize(model.states)
#     grid = NoLib.SSGrid(mc.Q) × 
# end