# using DoloYAML
using NoLib: ×
using NoLib: transition, arbitrage
import NoLib: transition
import NoLib: arbitrage
using NoLib: GVector

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

model_iid = include("rbc_iid.jl")

s = rand(model.states)
x = rand(model.controls)

# e = rand(model.exogenous)

NoLib.transition(model, s, x)   # basic transition function
NoLib.arbitrage(model,s,x,s,x)

dmodel = NoLib.discretize(model)

res = NoLib.τ(dmodel, s, x.val)

[res...]

φ = NoLib.Policy(
    model.states,
    model.controls,
    u->x.val
)


@time NoLib.F(dmodel, s, x.val, φ)


# for i in dmodel.grid
#     println(i)
# end

# for i in NoLib.enum(dmodel.grid)
#     println(i)
# end

xx = GVector(dmodel.grid, [x.val for i=1:length(dmodel.grid)])
ssss = NoLib.enum(dmodel.grid)
[ssss...]


xx = NoLib.initial_guess(dmodel)
φ = NoLib.GVector(dmodel.grid, xx)

r0 = NoLib.F(dmodel, xx, φ)

NoLib.time_iteration(dmodel)



#######
# ar1 #
#######

model = include("rbc_ar1.jl")

s = rand(model.states)
x = rand(model.controls)

transition(model, s, x)
NoLib.arbitrage(model,s,x,s,x)

# do I need a special locator type?

dmodel =  NoLib.discretize(model)


# initial point on the grid
s0 = NoLib.QP(
    (1, SVector(s.val[1])),
    s.val
)

res = NoLib.τ(dmodel, s0, x.val)

[res...]


φ = NoLib.Policy(
    model.states,
    model.controls,
    u->x.val
)


NoLib.F(dmodel, s0, x.val, φ)

dmodel.grid[3]

xx = GVector(dmodel.grid, [x.val for i=1:length(dmodel.grid)])
ssss = NoLib.enum(dmodel.grid)
[ssss...]




# NoLib.initial_guess(model, (;:hi=3))

xx = NoLib.initial_guess(dmodel)
φ = NoLib.GVector(dmodel.grid, xx)

r0 = NoLib.F(dmodel, xx, φ)

NoLib.time_iteration(dmodel)

#######
# mc  #
#######

model = include("rbc_mc.jl")

s = rand(model.states)
x = rand(model.controls)



S = transition(model, s, x);
NoLib.arbitrage(model,s,x,s,x)

dmodel = NoLib.discretize(model)



# initial point on the grid
s0 = NoLib.QP(
    (1, SVector(s.val[1])),
    s.val
    )
    
res = NoLib.τ(dmodel, s0, x.val)

[res...]


φ0 = NoLib.Policy(
    model.states,
    model.controls,
    u->x.val
)

s0 = NoLib.QP( (1,SVector(0.0)), SVector(-0.1, 0.0))


@time NoLib.F(dmodel, s0, x.val, φ0)


xx = GVector(dmodel.grid, [x.val for i=1:length(dmodel.grid)])
ssss = NoLib.enum(dmodel.grid)
[ssss...]


xx[1,1]

φ = NoLib.DFun(dmodel, xx; interp_mode=:linear)
NoLib.F(dmodel, s0, x.val, φ)


NoLib.initial_guess(model, sd)

xx = NoLib.initial_guess(dmodel)
φ = NoLib.DFun(dmodel, xx; interp_mode=:cubic)



res = NoLib.F(dmodel, xx, φ)


wksp = NoLib.time_iteration_workspace(dmodel);
@time NoLib.time_iteration(dmodel,wksp; verbose=false);
@time NoLib.time_iteration(dmodel,wksp; verbose=false, improve=true);
