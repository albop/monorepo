# using DoloYAML
using NoLib: ×
using NoLib: transition, arbitrage
import NoLib: transition
import NoLib: arbitrage
using NoLib: GVector

using NoLib
using StaticArrays


model_mc = include("rbc_mc.jl")

@assert isbits(model_mc)


s = rand(model.states)
x = rand(model.controls)



S = transition(model, s, x);
NoLib.arbitrage(model,s,x,s,x)

dmodel = NoLib.discretize(model)



# initial point on the grid
s0 = NoLib.QP(
    (1, SVector(s.val[1])),
    s.val
    )
    
res = NoLib.τ(dmodel, s0, x.val)

[res...]


φ0 = NoLib.Policy(
    model.states,
    model.controls,
    u->x.val
)

s0 = NoLib.QP( (1,SVector(0.0)), SVector(-0.1, 0.0))


@time NoLib.F(dmodel, s0, x.val, φ0)


xx = GVector(dmodel.grid, [x.val for i=1:length(dmodel.grid)])
ssss = NoLib.enum(dmodel.grid)
[ssss...]


xx[1,1]

φ = NoLib.DFun(dmodel, xx; interp_mode=:linear)
NoLib.F(dmodel, s0, x.val, φ)


xx = NoLib.initial_guess(dmodel)
φ = NoLib.DFun(dmodel, xx; interp_mode=:cubic)

res = NoLib.F(dmodel, xx, φ)

L = NoLib.dF_2(dmodel, xx, φ)


@time NoLib.time_iteration(dmodel; verbose=false);

@time NoLib.time_iteration(dmodel; verbose=false, improve=true);


@time NoLib.time_iteration(dmodel; verbose=false, improve=true);
@time NoLib.time_iteration(dmodel; verbose=true, improve=false)

@time NoLib.time_iteration(dmodel; verbose=true);

wksp = NoLib.time_iteration_workspace(dmodel);

@time NoLib.time_iteration(dmodel,wksp; verbose=false);
@time NoLib.time_iteration(dmodel,wksp; verbose=false, improve=true);


@time NoLib.time_iteration(dmodel; verbose=false, improve=true);




model = include("examples/ymodels/rbc_iid.jl")
dmodel = NoLib.discretize(model)
@time NoLib.time_iteration(dmodel; verbose=true);
@time NoLib.time_iteration(dmodel; verbose=true, improve=true);




model = include("examples/ymodels/rbc_ar1.jl")
dmodel = NoLib.discretize(model)
@time NoLib.time_iteration(dmodel; verbose=false);
@time NoLib.time_iteration(dmodel; verbose=false, improve=true);


model = include("examples/ymodels/consumption_savings.jl")
dmodel = NoLib.discretize(model)
@time NoLib.time_iteration(dmodel; verbose=true);
@time NoLib.time_iteration(dmodel; verbose=false, improve=true, improve_wait=0);



model = yaml_import("examples/ymodels/consumption_savings_iid.yaml")
dmodel = NoLib.discretize(model)
@time NoLib.time_iteration(dmodel; verbose=true);
@time NoLib.time_iteration(dmodel; verbose=true, improve=true, improve_wait=5);
