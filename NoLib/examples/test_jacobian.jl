include("models/consumption_savings_ayiagari.jl")

# y0 = NoLib.find_equilibrium(model)
# or
y0 = SVector(49.0)

model = recalibrate(model; K=y0[1])

sol = NoLib.time_iteration(model; improve=true)
x0 = sol.solution
μ0 = NoLib.ergodic_distribution(model, x0)
z0 = SVector(model.calibration.z...)
p0 = SVector(NoLib.projection(model, y0, z0)...)


## Derivatives of: F

@time r, J_1, J_2, U, V = F = NoLib.F(model, x0, x0, p0, p0; diff=true);

# renormalize to get: r, I , T, U, V

r = J_1 \ r     # GVector  (GArray{G,SVector})
T = J_1 \ J_2   # Operator: GVector->GVector
T.M_ij[:] *= (-1.0)  # !!!!
U = J_1 \ U     # GMatrix (GArray{G,SMatrix})
V = J_1 \ V     # GMatrix (GArray{G,SMatrix})


## Derivatives of: G

# TODO: slowwwww.

@time μ1, G_μ, G_x, G_p = G = NoLib.G(model, μ0, x0, p0; diff=true)

# μ1: GDist ( (GArray{G,Float64}))
# G_μ: LinearOperator GDist->GDist 
# G_x: Matrix (  operates on flatten vectors  ) # todo, should be operator
# G_p: Matrix (  operates on flatten vectors  ) # todo, should probably be GMatrix

G_μ*μ0  # == μ1
G_x*x0 # same dim as - μ0
G_p*p0 # same dim as - μ0


## Derivatives of A:
a, A_μ, A_x,  A_y = A = equilibrium(model, μ0, x0, y0; diff=true)

# import Main.Temp: LinearOperator
# import Main.Temp: *

A_x*x0  # GVector->SVector
A_μ*μ0   # GDist->SVector
A_y*y0  # SVector->SVector

## Derivatives of P:

p, P_y, P_z = P = projection(model, y0, z0; diff=true)

P_y*y0
P_z*z0



# TEST
K = 100
# dy_vals = [SVector(y0*0.0001) for k=1:K]
# @time NoLib.J(F, G, A, P, dy_vals);

J = (;F, G, A, P)



# the following is very slow, because of slow G._x * ... 

@time Rk, Tk, Sk = NoLib.J_forward(A, G, T, U, V, P, K);

@time Wk, Xk = NoLib.J_backward(A, G, P, Rk, K);

@time J_x, J_μ1, J_μ2 = NoLib.jacobian_matrices(Tk, Wk, Xk, K);