using NoLib

include("models/neoclassical.jl")


@time nx, nv = NoLib.vfi(model; improve=false, verbose=true)

@time nx, nv = NoLib.vfi(model; improve=true, verbose=true)

using Plots

kv = [e[1] for e in model.grid[1,:]]
plot(kv,[e[1] for e in nx[1,:]])
plot!(kv,[e[1] for e in nx[2,:]])
plot!(kv,kv*model.calibration.p.δ)
scatter!(model.calibration.s, model.calibration.x)


plot(kv,[e[1] for e in nv[1,:]])
plot!(kv,[e[1] for e in nv[2,:]])


fobj = u->-Q(model, m, s, SVector(u...), φv)

using ForwardDiff

ForwardDiff.hessian(fobj, x)