# using DoloYAML
using NoLib: ×

import NoLib: transition
import NoLib: arbitrage
using NoLib: GVector

using NoLib
using StaticArrays


model = include("examples/ymodels/neoclassical.jl")

dmodel = NoLib.discretize(model)

x0 = NoLib.calibrated(dmodel.model, :controls)
xx = NoLib.GVector(dmodel.grid, [x0 for s in dmodel.grid])
states = dmodel.model.states
φ = NoLib.DFun(states, xx)


sol = NoLib.time_iteration(dmodel, verbose=false, improve=true)




################
# neoclassical #
################

model = include("NoLib/examples/models/neoclassical.jl")
dmodel = NoLib.discretize(model)

sol = NoLib.time_iteration(dmodel, verbose=false, improve=true)

s0 = NoLib.QP( (1,SVector(model.calibration.k)), SVector(0.1, 0.2) )
sim = NoLib.simulate(dmodel, sol.dr, s0)

plot(sim[V=:k])


#######
# ar1 #
#######

model = include("rbc_ar1.jl")

s = rand(model.states)
x = rand(model.controls)

transition(model, s, x)
NoLib.arbitrage(model,s,x,s,x)

# do I need a special locator type?

dmodel =  NoLib.discretize(model)


# initial point on the grid
s0 = NoLib.QP(
    (1, SVector(s.val[1])),
    s.val
)

res = NoLib.τ(dmodel, s0, x.val)

[res...]


φ = NoLib.Policy(
    model.states,
    model.controls,
    u->x.val
)


NoLib.F(dmodel, s0, x.val, φ)

dmodel.grid[3]

xx = GVector(dmodel.grid, [x.val for i=1:length(dmodel.grid)])
ssss = NoLib.enum(dmodel.grid)
[ssss...]




# NoLib.initial_guess(model, (;:hi=3))

xx = NoLib.initial_guess(dmodel)

φ = NoLib.DFun(dmodel, xx; interp_mode=:linear)

r0 = NoLib.F(dmodel, xx, φ)

@time NoLib.time_iteration(dmodel);


##

model = include("NoLib/examples/consumption_savings.jl")

s = rand(model.states)
x = rand(model.controls)