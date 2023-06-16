import NoLib
using NoLib: SSGrid, CGrid, GArray, iti, enum, ×, GridDomain, CartesianDomain
using StaticArrays

P = @SMatrix [0.9 0.1; 0.1 0.9]
Q = @SMatrix [-0.1; 0.1]

exo = SSGrid( [Q[i,:] for i=1:size(Q,1)] )
endo = CGrid( ((0.1, 5.0, 100),) )
grid = exo × endo

ga = GArray(grid, [SVector(0.2, 0.1) for i=1:length(grid)])


gg = GridDomain([SVector(1.0), SVector(2.0), SVector(2.5)])
cc = CartesianDomain((10,), (0.0,), (10.0,))

dom = gg × cc

dis = NoLib.discretize(dom; n=[20])

values = [e.^2 for e in dis]

import Base: ^

(^)(dom::NoLib.ProductDomain, tp::Val{:exo}) = dom.grid_A
(^)(dom::NoLib.ProductDomain, tp::Val{:endo}) = dom.grid_B

ga = GArray(dis, values)

fun = NoLib.DFun(dom, ga)

using Adapt
Adapt.@adapt_structure NoLib.DFun

using CUDA
Adapt.adapt(CuArray, fun)

####
####
####


function test_noalloc(exo)
    s = sum(exo)
    t = sum(s)

    if t < -100000.0
        return "HI"
    end
end

@time test_noalloc(exo)  # custom iterator
@time test_noalloc(endo)  # custom iterator
@time test_noalloc(grid)  # custom iterator



@time test_noalloc(ga)

# @time test(exo, false) # native iterator


[endo...]
[exo...]

[grid...]

###

import NoLib

import NoLib: PGrid

# function G(g, i::Int, j::Int)
#     (g.g1[i][1], g.g2[j][1])
# end

# function GG(g::PGrid, i::Int, j::Int) 
#     e = SVector(g.g1[i]...,g.g2[j]...)
#     # if  t < -10000.0
#     #     println("HO")
#     # end
#     # (g.g1[i][1],g.g2[j][1])
#     # SVector(1.0, 2.0)
# end

# function GGG(g::PGrid{SGrid{d1}, CGrid{d2}, d}, i::Int, j::Int) where d where d1 where d2
#     e = SVector{d,Float64}(g.g1[i][1],g.g2[j][1])
#     # if  t < -10000.0
#     #     println("HO")
#     # end
#     # (g.g1[i][1],g.g2[j][1])
#     # SVector(1.0, 2.0)
# end

import NoLib: getit

function test_eachindex(g)

    s = sum(g[2] for g in enum(g))
    t = sum(s)

    #  return t
    if t < -100000.0
        return "HI"
    end
end

@time test_eachindex(grid)

@code_warntype test_eachindex(grid)



import NoLib




@time test_noalloc_enum(grid)

@allocated test_noalloc_enum(grid)


function test_iterate(ga)
    z0 = zero(eltype(ga))
    for e in ga.data
        z0 += e
    end
    t = sum(z0)
    if t<0.000
        println(" HIe")
    end
end

(@allocated test_iterate(ga, res)) == 0

import NoLib

function test_iterate_2(ga, res)
    z0 = zero(eltype(ga))
    for e in (ga)
        z0 += e
    end
    res[1] = z0
    return
end

(@allocated test_iterate_2(ga, res)) == 0




rr = [exo[1]]
function test_enum_exo(ga, rr)
    z0 = ga[1]
    for e in NoLib.iti(ga)
        z0 += e[2]
    end
    rr[1] = z0
    return
end
test_enum_exo(exo, rr)
@assert (@allocated test_enum_exo(exo, rr))==0


rr = [endo[1]]
function test_enum_endo(ga, rr)
    z0 = ga[1]
    for e in NoLib.iti(ga)
        z0 += e[2]
    end
    rr[1] = z0
    return
end
test_enum_endo(endo, rr)
@assert (@allocated test_enum_endo(endo, rr))==0



rr = [grid[1]]
function test_enum(ga, rr)
    z0 = ga[1]
    for e in NoLib.iti(ga)
        el = SVector(e[2][1]..., e[2][2]...)
        z0 += el
    end
    rr[1] = z0
    return
end
@time test_enum(grid, rr);