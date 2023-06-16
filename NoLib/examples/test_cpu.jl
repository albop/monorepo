using Adapt
using KernelAbstractions


include("neoclassical_model.jl")

@time NoLib.time_iteration(model);



φ0 = GVector(model.grid, [Iterators.repeated(SVector(model.calibration.x), length(model.grid))...])



r0 = NoLib.F(model, φ0, φ0)

J = NoLib.dF_1(model, φ0, φ0)

L2 = M_ij, S_ij = NoLib.compute_L_2(model, φ0, φ0)
M_ij .= J .\ M_ij

@benchmark dx =  NoLib.invert(r0, L2; K=1000)


@time dx =  NoLib.invert(r0, L2; K=1000);



using NoLib: ravel, unravel
n = length(dx)*length(eltype(dx))
fun = u->(ravel(NoLib.apply_L_2(L2, unravel(dx, u))))
lm = LinearMap(
    fun,
    n,
    n
)

mat = Matrix(lm)
dxx = ravel(dx)
rrr = ravel(r0)

using LinearAlgebra: I

(I-mat)*dxx - rrr  ### CA marche!


# L = LinearMaps.LinearMap(u)






