using NoLib
using NoLib: τ



include("models/neoclassical.jl")


s0 = [enum(model.grid)...][3]

x0 = SVector(model.calibration.x...)

using ForwardDiff

ForwardDiff.jacobian(
    u-> sum( e[2] for (w,e) in  NoLib.τ(model, s0, u) ),
    x0
)

ForwardDiff.gradient
f = u-> sum( w for (w,e) in  NoLib.τ(model, s0, u) )

ForwardDiff.gradient(
    u-> sum( w for (w,e) in  NoLib.τ(model, s0, u) ),
    x0
)




ForwardDiff.gradient(
    u-> sum( w for (w,e) in  NoLib.τ_fit(model, s0, u) ),
    x0
)

s0 = [enum(model.grid)...][50]


ForwardDiff.jacobian(
    u-> sum( SVector(w, e[2]...) for (w,e) in  NoLib.τ_fit(model, s0, u) ),
    x0
)

import FiniteDiff

# FiniteDiff.finite_difference_jacobian(
#     u-> sum( SVector(w, e[2]...) for (w,e) in  NoLib.τ_fit(model, s0, u) ),
#     x0
# ) 

ForwardDiff.jacobian(
    u->SVector( (w for (w,e) in  NoLib.τ_fit(model, s0, u))... ),
    x0
)


ForwardDiff.jacobian(
    u->SVector( (e[2] for (w,e) in  NoLib.τ_fit(model, s0, u))... ),
    x0
)


G(μ, x, y)