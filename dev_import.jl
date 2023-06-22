using DoloYAML
using DoModel
using NoLib
using StaticArrays

filename = "DoloYAML/examples/models/rbc_mc.yaml"
# _m = DoloYAML.yaml_import()


@time model = DoModel.DoloModel(filename)

s = NoLib.rand(model.states)
x = NoLib.rand(model.controls)

s = SVector(0.2, 0.2, 0.4)
x = SVector(0.1, 0.2) #NoLib.QP(SVector(0.1, 0.2), SVector(0.1, 0.3))
e = SVector(0.43, 0.3)

s0 = NoLib.QP((1,SVector(0.4)), SVector(0.2, 0.3, 0.4))
@time NoLib.transition(model, s,x, e)

dmodel = NoLib.discretize(model)
sol = NoLib.time_iteration(dmodel)

φ = sol.dr
s0 = (1, SVector(0.4))
sim = NoLib.simulate(model, φ, s0)


using Plots
plot(sim[V=:c])

wksp = NoLib.time_iteration_workspace(dmodel)
@time NoLib.time_iteration(dmodel, wksp, verbose=false);


s0 = (1,SVector(0.4))
a,b,c,d = NoLib.simulate(model, φ, s0)



filename = "DoloYAML/examples/models/rbc_iid.yaml"

model = DoModel.DoloModel(filename)

rand(model.exogenous)

# s = NoLib.rand(model.states)
# x = NoLib.rand(model.controls)

s = SVector(0.2, 0.2)
x = SVector(0.1, 0.2) #NoLib.QP(SVector(0.1, 0.2), SVector(0.1, 0.3))
e = SVector(0.43)

@time NoLib.transition(model, s, x, e)

@time NoLib.transition(model, s, x)


@time NoLib.arbitrage(model, s, x, s, x)

dmodel = NoLib.discretize(model)
@time sol =  NoLib.time_iteration(dmodel, verbose=true);

@time sim = NoLib.simulate(model, sol.dr, s)

using Plots

plot(sim[V=:n])





filename = "DoloYAML/examples/models/rbc_ar1.yaml"

model = DoModel.DoloModel(filename)
model.exogenous

dmodel = NoLib.discretize(model)

sol =  NoLib.time_iteration(dmodel)


s0 = NoLib.QP((1, SVector(0.5)),SVector(0.031, 0.5))
sim = NoLib.simulate(dmodel, sol.dr, s0)

plot(sim[V=:n])


model_nl = include("rbc_ar1.jl")
dmodel_nl  = NoLib.discretize(model_nl)
@benchmark NoLib.time_iteration(dmodel_nl)

model_nl.calibration
model.calibration

model_nl.exogenous