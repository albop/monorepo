using NoLib
using FiniteDiff

include("models/rbc.jl")

sol = NoLib.time_iteration(model, verbose=false, improve=false)

@time sol = NoLib.time_iteration(model, verbose=false, improve=true);

# Steady-state values
x0 = GVector(model.grid, [Iterators.repeated(SVector(model.calibration.x), length(model.grid))...])
# Residuals
r0 = NoLib.F(model, x0, x0)


function error(J1::Matrix, J2::Matrix)
    return maximum(abs.(J1 .- J2))
end

function jacobian_check(model::DModel, x0::GArray)
    # Implemented version (automatic differentiation)
    J1_0 = convert(Matrix, NoLib.dF_1(model, x0, x0))
    J2_0 = convert(Matrix, NoLib.dF_2(model, x0, x0))

    # Compare to numerical differentiation
    x  = copy(NoLib.ravel(x0))
    J1 = FiniteDiff.finite_difference_jacobian(u -> NoLib.ravel(NoLib.F(model, NoLib.unravel(x0, u), x0)), x)
    J2 = FiniteDiff.finite_difference_jacobian(u -> NoLib.ravel(NoLib.F(model, x0, NoLib.unravel(x0, u))), x)
    return error(J1, J1_0), error(J2, J2_0)
end

println(jacobian_check(model, x0))

# Hetag