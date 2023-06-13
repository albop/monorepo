a = 4

import DoloYAML

model = DoloYAML.yaml_import("DoloYAML/examples/models/rbc.yaml")


using NoLib
import Dolo

import DoModel

dolo_model = Dolo.yaml_import("NoLib/examples/models/rbc_mc.yaml")


n_model = DoModel.DoloDModel("NoLib/examples/models/rbc_mc.yaml")

@time Dolo.time_iteration(dolo_model);
@time NoLib.time_iteration(n_model);