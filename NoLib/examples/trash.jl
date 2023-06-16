

@time J = NoLib.residual(model, μ0, x0, y0; diff=true)


####
####  simple steady-state solver
####

fun(y) = NoLib.resid(model, y; diff=false)
@time da_fn = FiniteDiff.finite_difference_jacobian(fun, y0)


@time dx, dμ, da = NoLib.Lres(J, SVector(1.0))

(da[1], da_fn[1])



ε = 1e-3
dx0, dμ0, da0 = NoLib.resid(model, y0; return_all=true)
dx1, dμ1, da1 = NoLib.resid(model, y0 .+ ε, return_all=true)

ddx = (dx1-dx0)*(1/ε)
ddμ = (dμ1-dμ0)*(1/ε)
dda = (da1-da0)*(1/ε)


maximum(abs, NoLib.ravel((dx - ddx)))
maximum(abs, NoLib.ravel((dμ - ddμ)))
maximum(abs, da - dda)

using Plots


#### So far so good


μ = μ0
y = y0
x = x0
z = z0
p = p0


@time μ1, G_μ, G_x, G_p = NoLib.G(model, μ, x, p; diff=true);

@time G_x*x0

convert(Matrix, G_x)














v0 = NoLib.ravel(μ0, x0, y0)

@time r0 = NoLib.residual(model, v0; diff=false)
J0 = NoLib.residual(model, v0; diff=true)



# sum(n1[1:600])

spy(J0)


J0\r0


v1 = v0 - J0\r0

using Plots


yvec = [SVector(e) for e in range(20, 60;length=20)]
avec = [NoLib.resid(model, y) for y in yvec]


plot([e[1] for e in yvec], [e[1] for e in avec])


f(u) = NoLib.resid(model, SVector(u))[1]




using Roots
result = find_zero(f, (40.0,42.0), Bisection())



K0 = 40.0

K0 = result
y0 = SVector(K0)
z0 = SVector(model.calibration.z...)
p0 = projection(model, y0, z0)

model = recalibrate(model; K=result)

## "Steady-state" values

sol = NoLib.time_iteration(model; verbose=false, improve=false)
x0 = sol.solution   # GVector


μ0 = NoLib.ergodic_distribution(model, sol.solution)   # GDist


v0 = NoLib.ravel(μ0, x0, y0)





y0 = SVector(38.0)
# y0 = SVector(logs[end][1])
r_, J = NoLib.resid(model, y0; diff=true)
dx, dμ, da, ff, ll= Lres(J, SVector(1.0))

plot(ff)
plot(ll)

ε = 1e-3
dx0, dμ0, da0 = NoLib.resid(model, y0; return_all=true)
dx1, dμ1, da1 = NoLib.resid(model, y0 .+ ε, return_all=true)

ddx = (dx1-dx0)*(1/ε)
ddμ = (dμ1-dμ0)*(1/ε)
dda = (da1-da0)*(1/ε)




plot([e[2] for e in dx[2,:]])
plot!([e[2] for e in ddx[2,:]])







ppp = projection(model, y0, z0; diff=true)


J.A._y

dy0 = SVector(1.0)

dx, dμ, da = Lres(J, dy0)

plot([e[1] for e in x0[1,:]])
plot!([e[1] for e in (x0+dx)[1,:]])

plot([e[1] for e in (dx)[1,:]])
plot!([e[1] for e in (dx*0)[1,:]])


sum([i*(μ0)[i] for i=1:length(μ0)])

# sum([i*(μ0+ddμ)[i] for i=1:length(μ0)])

dy
@show J.A._μ* (J.G._x*dx )
@show J.A._μ* (J.G._y*dy )
@show J.A._μ* (J.G._x*dx + J.G._y*dy)



plot(μ0[1,:])
plot!(μ0[1,:] + ddμ[1,:])

plot(μ0[2,:])
plot!(μ0[2,:] + ddμ[2,:])
plot(μ0[3,:])
plot!(μ0[3,:] + ddμ[3,:])



x_ = range(30, 50; length=100)
y_ = r0[end] .+ (x_.-K0).*da
x_ = [x_...]
y_ = [y_...]

pl = plot(xlims=(30,50), ylims=(-1,1))
 
scatter!(pl, [K0], [r0[end]])
scatter!(pl, [result], [0.0])
plot!(pl, x_, y_)
plot!(pl,[e[1] for e in yvec], [e[1] for e in avec])
plot!(pl,[e[1] for e in yvec], [e[1] for e in avec]*0)
pl



v0 = NoLib.ravel(μ0, x0, y0)

r0 = NoLib.residual(model, v0; diff=false)
J0 = NoLib.residual(model, v0; diff=true)

# J0[1,1:600] .= 1.0

function baby_newton(y0)

    logs = []
    for i=1:5
        r0, J = NoLib.resid(model, y0; diff=true)


        println(y0, " : ", r0)
        dx, dμ, da = Lres(J, SVector(1.0))
        push!(logs, (y0, r0, da))

        y0 = y0 - r0./da

    end
    return logs
end

logs = baby_newton(SVector(38.0))


x_ = range(30, 50; length=100)
x_ = [x_...]
y_ = [y_...]

pl = plot(xlims=(30,50), ylims=(-2,2))
scatter!(pl, [e[1][1] for e in logs], [e[2][1] for e in logs])
for i in 1:length(logs)
    da = logs[i][3]
    y_ = logs[i][2][end] .+ (x_.-logs[i][1]).*da
    plot!(pl, x_, y_)
end
plot!(pl,[e[1] for e in yvec], [e[1] for e in avec])
plot!(pl,[e[1] for e in yvec], [e[1] for e in avec]*0)
pl





using Plots

spy(abs.(J0).!=0.0)

res_1 = ((J_1, J_2, U),(G_μ, G_x, G_y),(A_μ, A_x,  A_y)) = residual(model, μ0, x0, y0; diff=true)
res_2 = ((J_1, J_2, U),(G_μ, G_x, G_y),(A_μ, A_x,  A_y)) = residual(model, v0; diff=true, return_res=true)


rm = [[convert(Matrix, e) for e in l] for l in res]

# function residual(y)

#     z = SVector(model.calibration.z...)
#     p = projection(model, y, z)

#     sol = NoLib.time_iteration(model; verbose=false, improve=false)
#     x = sol.solution
#     μ = NoLib.ergodic_distribution(model, sol.solution)   # GDist

#     equilibrium(model, μ, x, y; diff=true)

# end


## Derivatives of: F

@time r, J_1, J_2, U, V = NoLib.F(model, x0, x0, p0, p0; diff=true);

# renormalize to get: r, I , T, U, V

r = J_1 \ r     # GVector  (GArray{G,SVector})
T = J_1 \ J_2   # Operator: GVector->GVector
U = J_1 \ U     # GMatrix (GArray{G,SMatrix})
V = J_1 \ V     # GMatrix (GArray{G,SMatrix})


## Derivatives of: G

# TODO: slowwwww.

μ1, G_μ, G_x, G_p = NoLib.G(model, μ0, x0, p0; diff=true)

# μ1: GDist ( (GArray{G,Float64}))
# G_μ: LinearOperator GDist->GDist 
# G_x: Matrix (  operates on flatten vectors  ) # todo, should be operator
# G_p: Matrix (  operates on flatten vectors  ) # todo, should probably be GMatrix

G_μ*μ0  # == μ1
G_x*x0 # same dim as - μ0
G_p*p0 # same dim as - μ0


## Derivatives of A:
a, A_μ, A_x,  A_y = equilibrium(model, μ0, x0, y0; diff=true)
a, (r_μ,A_μ), (r_x,A_x),  (r_y,A_y) = equilibrium(model, μ0, x0, y0; diff=true)

a, r_μ, r_x, r_y = equilibrium(model, μ0, x0, y0; diff=true)


# import Main.Temp: LinearOperator
# import Main.Temp: *

A_x*x0  # GVector->SVector
A_μ*μ0   # GDist->SVector
A_y*y0  # SVector->SVector

## Derivatives of P:

p, P_y, P_z = projection(model, y0, z0; diff=true)

P_y*y0
P_z*z0



# TEST
K = 100
# dy_vals = [SVector(y0*0.0001) for k=1:K]
# @time NoLib.J(F, G, A, P, dy_vals);

@time Rk, Tk, Sk = NoLib.J_forward(A, G, T, U, V, P, K);
@time Wk, Xk = NoLib.J_backward(A, G, P, Rk, K);
@time J_x, J_μ1, J_μ2 = NoLib.jacobian_matrixes(Tk, Wk, Xk, K);

NoLib.GArray(U.grid, [e*p0 for e in U.data])

function check(p0, T, U, V, A_x;K=200)

    U1 = NoLib.GArray(U.grid, [e*p0 for e in U.data])
    V1 = NoLib.GArray(V.grid, [e*p0 for e in V.data])

    # Vs = [U1]
    Vs = [A_x*U1]
    # Gs = [A_μ*A]

    E = V1 + T*U1

    for i=1:K
        push!(Vs, A_x*E)
        E = T*E
    end

    return Vs

end


@time Vs =  check(p0, T, U, V, A_x);



(u -> G_p*u).([p0, p0])
