using NoLib
const NL=NoLib

for filename in readdir("examples/ymodels", join=true)

    if !(filename[end-2:end]==".jl")
        continue
    end

    println("Importing $filename")
    model = include(filename)
    dmodel = NL.discretize(model)
    NoLib.time_iteration(dmodel; verbose=true)


end


using DoModel

local filename

for filename in readdir("examples/ymodels", join=true)

    if !(filename[length(filename)-3:length(filename)]=="yaml")
        continue
    end

    println("***********************")
    println("Importing $filename")
    println("***********************")

    model = DoModel.DoloModel(filename)
    show(model)
    dmodel = NL.discretize(model)
    NoLib.time_iteration(dmodel)

end


### compare rbc_iid.yaml
### and rbc_iid.jl


# n1 = DoModel.DoloModel("examples/ymodels/rbc_iid.yaml")
# d1 = NoLib.discretize(n1)
# sol1 = NoLib.time_iteration(d1; verbose=true)
# n2 = include("examples/ymodels/rbc_iid.jl")
# d2 = NoLib.discretize(n2)
# sol2 = NoLib.time_iteration(d2)

using NoLib

mod = include("examples/ymodels/rbc_ar1.jl")

ee = NoLib.discretize(mod)

NoLib.name(mod)