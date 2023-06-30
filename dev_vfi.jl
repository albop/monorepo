using NoLib
const Dolo=NoLib


model = NoLib.yaml_import("examples/ymodels/consumption_savings_iid.yaml");
@time sol = NoLib.time_iteration(model, verbose=false);

s0 = NoLib.draw(model.states)

NoLib.bounds(model, s0)


dmodel = NoLib.discretize(model)

NoLib.vfi(dmodel)




φ = sol.dr

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

