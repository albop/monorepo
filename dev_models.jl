# using DoloYAML
using NoLib: ×
using NoLib: transition

using NoLib
using StaticArrays

model_ar1 = include("rbc_ar1.jl")
model_iid = include("rbc_iid.jl")
model_mc = include("rbc_mc.jl")

@assert isbits(model_ar1)
@assert isbits(model_iid)
@assert isbits(model_mc)


models = [model_ar1, model_iid, model_mc]

for model in models
    display(model)
end



model = model_iid

s = rand(model.states)
x = rand(model.controls)
e = rand(model.exogenous)

NoLib.transition(model, s, x, e)
NoLib.transition(model, s, x)


model = model_ar1
s = rand(model.states)
x = rand(model.controls)




transition(model, s, x)



@time NoLib.get_states(model)
@time NoLib.get_controls(model)


dmodel_ar1 = NoLib.discretize(model_ar1)



model_mc = include("rbc_mc.jl")
model = model_mc



import NoLib: Policy


φ = Policy(model.states, model.controls, x->SVector(x[1], x[1]-x[2]))

(pol::Policy)(s) = (pol.fun(s))


NoLib.discretize(model.exogenous)
NoLib.discretize(model)

model.exogenous

mc = NoLib.discretize(model.exogenous)




sn = (:a, :b)
sv = SVector( 0.2, 40.2 )
