using NoLib

# track memalloc

model = include("rbc_iid.jl")

dmodel = NoLib.discretize(model)

wksp = NoLib.time_iteration_workspace(dmodel)
@time NoLib.time_iteration(dmodel, wksp; verbose=false);

wksp = NoLib.time_iteration_workspace(dmodel)
@time NoLib.time_iteration(dmodel, wksp; verbose=false, improve=true);

wksp = NoLib.time_iteration_workspace(dmodel)
@time NoLib.time_iteration(dmodel, wksp; verbose=false, T=50);
@time NoLib.time_iteration(dmodel, wksp; verbose=false, improve=true);


s0 = [NoLib.enum(dmodel.grid)...][1]

s0 = SVector(0.3, 0.8)
ss = NoLib.QP(s0, s0)
xx = SVector(0.4, 0.8)
φ = NoLib.DFun(
    dmodel,
    NoLib.initial_guess(dmodel)
)
xn = deepcopy(φ.values)

function f(dmodel, s, x, φ, xn)

    # res = φ(s)
    NoLib.fit!(φ, xn)
    nothing
    # sum(res)
    # res = NoLib.transition(dmodel.model, s.val, x)
    # sum(res)
    
end

@time f(dmodel, ss, xx, φ, xn);


a = s0.val
b = xx
c = dmodel.dproc.Q[1]

@code_warntype NoLib.transition(dmodel.model, a, b, c)

t = (;k=3.0, z=2.0)

@code_warntype NoLib.reorder(dmodel.model.states, t)




xx0 = deepcopy(φ.values)

@time NoLib.F!(xx0, dmodel,xxx, φ)


@time NoLib.F!(xx0, dmodel,xxx, φ)



vars = (:a,:b, :c,:d)
t = (;k=3, z=2)

NoLib.variables(model.states)

function ff(a,b)
    s = sum(NoLib.reorder(a.states,b))
end

@time ff(model, t)


@time NoLib.reorder(model, t)





# 
model = include("NoLib/examples/models/consumption_savings.jl")
isbits(model)


dmodel = NoLib.discretize(model)
wksp = NoLib.time_iteration_workspace(dmodel);
@time sol =  NoLib.time_iteration(dmodel, wksp; verbose=false);

wksp = NoLib.time_iteration_workspace(dmodel);
@time sol =  NoLib.time_iteration(dmodel, wksp; verbose=false);
# @time sol =  NoLib.time_iteration(dmodel; verbose=true, improve=true);


s0 = rand(model.states)

function g(dmodel, s0, xx, φ)
    r = φ(s0.loc)
    sum(r)
end


@time g(dmodel, s0, xx, φ)