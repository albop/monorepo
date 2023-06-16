
using NoLib


include("models/neoclassical.jl")

NoLib.time_iteration(model, verbose=true, improve=false)

using BlockDiagonals

i0 = 3
s0_ = [NoLib.enum(model.grid)...][i0]
s0 = [NoLib.enum(model.grid)...][i0]
m0 = s0[2:end]
φ = GVector(model.grid, [Iterators.repeated(SVector(model.calibration.x), length(model.grid))...])
x0 = φ[3]

s0
x0

S = [NoLib.τ(model, s0, x0)...][1][2]



r = NoLib.F(model, φ, φ)
reshape(r.data,2,100)





function check_alloc(model, s0, x0, φ)
    r = NoLib.F(model, s0, x0, φ)
    t = sum(r)
    return nothing
end

check_alloc(model, s0, x0, φ)

@time check_alloc(model, s0, x0, φ)

using BenchmarkTools
function check_alloc_2(model, x, φ)
    r = NoLib.F(model,x, φ)
    for i=1:1000
    r = NoLib.F(model,x, φ)
    end
    t = sum(sum(r))
    return nothing
end
check_alloc_2(model, φ, φ)
@time check_alloc_2(model, φ, φ)
@benchmark check_alloc_2(model, φ, φ)


function check_alloc_3(out, model, x, φ)
    for i = 1:1000
        NoLib.F!(out,model,x, φ)
    end
    t = sum(sum(out))
    return nothing
end

out = deepcopy(φ)
check_alloc_3(out, model, φ, φ)
@benchmark check_alloc_3(out, model, φ, φ)



function check_alloc_4(model, x, φ)
    r = NoLib.F(model,x, φ)
    t = sum(sum(e[1] for e in r))
    return nothing
end

check_alloc_4( model, φ, φ)
@benchmark check_alloc_4( model, φ, φ)


NoLib.F(model, )


### Solve the model
res = NoLib.time_iteration(model;improve=false)

### Plot decision rule
φ = res.solution

using Plots
using NoLib: iti

xvec = [e[1] for e in model.grid[2,:]]
yvec = [e[1] for e in φ[2,:]]
plot(xvec, yvec)

# improve the plot....



## Rewriting time_iteration

### Check SGrid, CGrid, PGrid objects

using NoLib: SGrid, CGrid, PGrid, ×

### Check GArray object

### GArray objects represent a vector of points, matching the geometry of the grid
### Create constant initial guess
using Garray
x0 = ...

### Compare On-grid and off-grid indexing (cf interp.jl)
x0[]
x0()

### Check the transition iterator $\tau$

### Write the optimality function `F(model, s, x, x0::GArray)` where s is a grid point, x a controls and  x0 a vector of controls


### Vectorize the optimality function `F(model, x1, x0)`

### Given x1, compute the derivative w.r.t. x0. Solve for the optimal x1 given x0.

### Compute the derivative w.r.t. x1. Make an improvement step.

### Write a time iteration method with an improvement option.


