using NoLib: ⟂,⫫

using Plots

xvec = range(-1, 1; length=100)

a = 0.1
uvec = (u->⟂(a, u)).(xvec)
uvec_F = (u->⫫(a, u)).(xvec)

pl = plot(xvec, uvec)
plot!(pl, xvec, uvec_F)


a = 0.05
uvec = (u->⟂(a, u)).(xvec)
uvec_F = (u->⫫(a, u)).(xvec)

pl2 = plot(xvec, uvec)
plot!(pl2, xvec, uvec_F)


a = 0.0
uvec = (u->⟂(a, u)).(xvec)
uvec_F = (u->⫫(a, u)).(xvec)

pl2 = plot(xvec, uvec)
plot!(pl2, xvec, uvec_F)

contour

pythonplot()

x = range(-1,1;length=1000)
y = range(-1,1;length=1000)
z = @. ⟂(x', y)
pl1 = contour(x, y, z, levels=[-0.1, 0.0, 0.1])


x = range(-1,1;length=101)
y = range(-1,1;length=101)
z = @. ⫫(x', y)
contour!(pl1, x, y, z, levels=[-0.1, 0.0, 0.1])



using Plots; pythonplot()

f(x, y) = (3x + y^2) * abs(sin(x) + cos(y))

x = range(0, 5, length=100)
y = range(0, 3, length=50)
z = @. f(x', y)
contour(x, y, z)