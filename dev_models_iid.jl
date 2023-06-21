# using DoloYAML
using NoLib: ×
using NoLib: transition, arbitrage
import NoLib: transition
import NoLib: arbitrage
using NoLib: GVector

using NoLib
using StaticArrays

model = include("rbc_iid.jl")

@assert isbits(model_iid)



#######
# iid #
#######

s = rand(model.states)
x = rand(model.controls)

# e = rand(model.exogenous)

NoLib.transition(model, s, x)   # basic transition function
NoLib.arbitrage(model,s,x,s,x)


dmodel = NoLib.discretize(model)

res = NoLib.τ(dmodel, s, x.val)

[res...]

φ = NoLib.Policy(
    model.states,
    model.controls,
    u->x.val
)


@time NoLib.F(dmodel, s, x.val, φ)


# for i in dmodel.grid
#     println(i)
# end

# for i in NoLib.enum(dmodel.grid)
#     println(i)
# end

xx = GVector(dmodel.grid, [x.val for i=1:length(dmodel.grid)])
ssss = NoLib.enum(dmodel.grid)
[ssss...]

xx = NoLib.initial_guess(dmodel)



φ = NoLib.DFun(dmodel, xx; interp_mode=:linear)

r0 = NoLib.F(dmodel, xx, φ)

@time NoLib.time_iteration(dmodel; verbose=false);


