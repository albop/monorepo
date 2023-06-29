using NoLib
using NoLib: DoModel

filename = "DoloYAML/examples/models/rbc_mc.yaml"

model = NoLib.yaml_import(filename)

model.source.filename # TODO: put it in the model representation

@time NoLib.time_iteration(dmodel, wksp; verbose=false);

dmodel = NoLib.discretize(model)
wksp = NoLib.time_iteration_workspace(dmodel)
@time NoLib.time_iteration(dmodel, wksp; verbose=false);