using StaticArrays: SVector
using NoLib: SSGrid, CGrid, ×, GArray, enum
using Test

# here we check that all iterators work in the same way

Q = [SVector(-0.1), SVector(0.0), SVector(0.1)] 

grid = SSGrid(Q) × CGrid(((0.00,4.0,5),))

points = [grid...]  ## last first

@assert sum(points .!= [grid[n] for n in 1:length(grid)])==0 ## last first

values = [e for e in points]

ga = GArray(grid, values)

@assert sum(points .!= [ga...])==0 ## last first
@assert sum(points .!= [ga[n] for n in 1:length(grid)])==0 ## last first

@assert sum(points .!= [e[2] for e in enum(grid)][:])==0 ## last first


# [enum(ga)...]

##############################################################
##############################################################
##############################################################

