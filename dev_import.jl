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

@time NoLib.transition(model, s,x, e)

@time NoLib.arbitrage(model, s,x,s,x)

dmodel = NoLib.discretize(model)
@time NoLib.time_iteration(dmodel, verbose=true);

wksp = NoLib.time_iteration_workspace(dmodel)
@time NoLib.time_iteration(dmodel, wksp, verbose=false);


dmodel = NoLib.discretize(model)

@time NoLib.time_iteration(dmodel; improve=true,verbose=true);
@time NoLib.time_iteration(dmodel; improve=true,verbose=false);