using NoLib: CSpace, GSpace, CGrid, variables, SGrid, ProductSpace, ProductGrid, discretize, ×, Space
import NoLib: discretize

import DoModel

model = DoModel.DoloModel("examples/ymodels/rbc_mc.yaml")

# dm = discretize(model; endo=Dict(:n=>[10]))

dm= DoModel.discretize(model; endo=Dict(:n=>12))
dm.grid
dm= DoModel.discretize(model)
dm.grid



model = DoModel.DoloModel("examples/ymodels/rbc_iid.yaml")
dm= DoModel.discretize(model; endo=Dict(:n=>12))
dm.grid
dm= DoModel.discretize(model; endo=Dict(:n=>[11,13]))
dm.grid
dm= DoModel.discretize(model)
dm.grid



model = DoModel.DoloModel("examples/ymodels/rbc_ar1.yaml")
dm = discretize(model; exo=Dict(:n=>7), endo=Dict(:n=>[10]))
dm.grid
dm = DoModel.discretize(model)
dm.grid


