
import DoModel
using NoLib

model = DoModel.DoloModel("examples/ymodels/rbc_iid.yaml")
dmodel = NoLib.discretize(model)
sol = NoLib.time_iteration(dmodel; verbose=true, interp_mode=:cubic)

using NoLib: QP
s0 = NoLib.calibrated(QP, model, :states)

sim = NoLib.tabulate(model, sol.dr, :k)

plot(sim[V=:k], sim[V=:i])

using Plots

model = include("examples/ymodels/rbc_iid.jl")
dmodel = NoLib.discretize(model)
NoLib.time_iteration(dmodel; verbose=true)

import Dolo

import DoModel

dolo_model = Dolo.yaml_import("NoLib/examples/models/rbc_mc.yaml")


n_model = DoModel.DoloDModel("NoLib/examples/models/rbc_mc.yaml")

@time Dolo.time_iteration(dolo_model);
@time NoLib.time_iteration(n_model);