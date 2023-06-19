# using DoloYAML
using NoLib: ×
using NoLib: transition, arbitrage
import NoLib: transition
import NoLib: arbitrage

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

#######
# iid #
#######

model = model_iid

s = rand(model.states)
x = rand(model.controls)

# e = rand(model.exogenous)

NoLib.transition(model, s, x)   # basic transition function

dmodel = NoLib.discretize(model)

res = NoLib.τ(dmodel, s, x.val)

[res...]



# for i in dmodel.grid
#     println(i)
# end

# for i in NoLib.enum(dmodel.grid)
#     println(i)
# end



#######
# ar1 #
#######

model = include("rbc_ar1.jl")

s = rand(model.states)
x = rand(model.controls)

transition(model, s, x)
NoLib.arbitrage(model,s,x,s,x)

# do I need a special locator type?

dmodel =  NoLib.discretize(model_ar1)

s0 = (;
    loc = (1, SVector(s.val[1])),
    val = s.val
)

res = NoLib.τ(dmodel, s0, x.val)

[res...]



#######
# mc  #
#######

model = include("rbc_mc.jl")

s = rand(model.states)
x = rand(model.controls)

S = transition(model, s, x);

dmodel = NoLib.discretize(model)

res = NoLib.τ(dmodel, s, x.val)

[res...]


NoLib.arbitrage(model,s,x,s,x)


function test(dmodel, s, x)

    sum( w*S for (w,(_,S)) in NoLib.τ(dmodel, s, x.val) )

end

@time test(dmodel, s, x)







s0 = (;loc=(1,SVector(0.0)), val=(;z=-0.1, k=0.0))
# s0 = (;loc=(1,SVector(0.0)), val=SVector(-0.1,0.0))

# x = rand(model.controls)


x = NamedTuple{(:i,)}(0.1)

transition(model, s0, x)


import NoLib: Policy


φ = Policy(model.states, model.controls, x->SVector(x[1], x[1]-x[2]))

(pol::Policy)(s) = (pol.fun(s))


NoLib.discretize(model.exogenous)
NoLib.discretize(model)

model.exogenous

mc = NoLib.discretize(model.exogenous)




sn = (:a, :b)
sv = SVector( 0.2, 40.2 )
