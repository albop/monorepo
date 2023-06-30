using NoLib
const Dolo=NoLib
using StaticArrays


model = yaml_import("examples/ymodels/consumption_savings_iid.yaml");
@time sol = time_iteration(model, verbose=false);



@time res = NoLib.vfi(model, verbose=false);

@time res = NoLib.vfi(model, verbose=true, improve=true);

@time res = NoLib.vfi(model, verbose=true, improve=true, improve_wait=5);

res = NoLib.vfi(model, verbose=true, improve=true, interpolation=:cubic);
res

res = NoLib.vfi(model, verbose=true, improve=true, interpolation=:linear);
res

fun(x; y...) = x + length(y)

fun(0.3; a=3.0)
fun(0.3;)
fun(0.3)

tab = tabulate(model, res.drv, :w)

plot(tab[V=:w], tab[V=:value])
import NoLib.DoModel.DoloYAML

methods(NoLib.DoModel.DoloYAML.felicity)

s0 = NoLib.draw(model.states)
x = SVector(0.1)

NoLib.reward(dmodel, s0, x)


res = NoLib.vfi(dmodel)

nx = NoLib.initial_guess(dmodel)
nv = NoLib.GArray(dmodel.grid, [1.0 for i=1:length(dmodel.grid)])
φ = NoLib.DFun(dmodel, nx)
φv = NoLib.DFun(dmodel.grid, nv)


NoLib.bounds(dmodel, s0, )
NoLib.Q(dmodel, s0, x, φv)

NoLib.Bellman_eval(dmodel, nx, φv)



dmodel = NoLib.discretize(model)

res= NoLib.vfi(dmodel; verbose=true, improve=true, trace=true);

trace = res.trace

using Plots

pl = plot()
for n=1:length(trace.data)
    if mod(n,1)==0
        x = trace.data[n].v.values
        plot!(pl, [e for e in x.data])
    end
end
pl

pl = plot()
for n=1:length(trace.data)
    if mod(n,10)==0
        x = trace.data[n].x
        plot!(pl, [e[1] for e in x.data])
    end
end
pl


@time nx, nv, trace = NoLib.vfi(dmodel; verbose=true, improve=true, trace=true);


@time NoLib.time_iteration(dmodel);

@time NoLib.time_iteration(dmodel);

# plot([e[1] for e in nx.data])


# plotting the decision rule
# inspecting iterations

using Plots
tab = NoLib.tabulate(model, φ, :w)
plot(tab[V=:w], tab[V=:w]; ylims=(0, 2))
plot!(tab[V=:w], tab[V=:c])


@time sol = NoLib.time_iteration(model, verbose=false, trace=true);
pl = plot(tab[V=:w], tab[V=:w]; ylims=(0, 2), label="c=w")
for (i,φ) in enumerate(sol.trace.data)
    if mod(i,10)==0
        tab = NoLib.tabulate(model, φ, :w)
        pl = plot!(tab[V=:w], tab[V=:c]; label="$i")
    end
end
pl

