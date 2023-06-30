using NoLib
const Dolo=NoLib


model = NoLib.yaml_import("examples/ymodels/rbc_iid.yaml");
@time sol = NoLib.time_iteration(model, verbose=false, engine=:cpu);


dmodel = NoLib.discretize(model)
sol = NoLib.time_iteration(dmodel; verbose=true, interp_mode=:cubic)


import Dolo
modolo = Dolo.yaml_import("examples/ymodels/rbc_iid.yaml")
Dolo.time_iteration(modolo)


using NoLib: QP
s0 = NoLib.calibrated(QP, model, :states)

sim = NoLib.tabulate(model, sol.dr, :k)

plot(sim[V=:k], sim[V=:i])

using Plots

model = include("examples/ymodels/rbc_iid.jl")
dmodel = NoLib.discretize(model)
NoLib.time_iteration(dmodel; verbose=true)

# import Dolo

using NoLib

dolo_model = NoLib.yaml_import("examples/ymodels/rbc_mc.yaml")
res = NoLib.time_iteration(dolo_model, verbose=true, improve=true);
res = NoLib.time_iteration(dolo_model, verbose=true, improve=true, trace=true, T=2);

