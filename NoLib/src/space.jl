import Base: dims

abstract type Space{d} end

struct CartesianSpace{d,dims}
    # names::NTuple{d, Symbol}
    min::NTuple{d, Float64}
    max::NTuple{d, Float64}
end



CartesianSpace(a::Tuple{Float64}, b::Tuple{Float64}) = CartesianSpace{length(a), Val{(:x,)}}(a,b)
CartesianSpace(a::Tuple{Float64, Float64}, b::Tuple{Float64, Float64}) = CartesianSpace{length(a), Val{(:x_1, :x_2)}}(a,b)

function CartesianSpace(;kwargs...)
    names = tuple(keys(kwargs)...)
    a = tuple((v[1] for v in values(kwargs))...)
    b = tuple((v[2] for v in values(kwargs))...)
    d = length(names)
    return CartesianSpace{d, names}(a,b)
end

getindex(cs::CartesianSpace{d}, ind::SVector{d, Float64}) where d = ind

import Base: rand, in

function Base.rand(cs::CartesianSpace) 
    loc = SVector(( (cs.min[i] + rand()*(cs.max[i]-cs.min[i])) for i=1:length(cs.min) )...)
    val = loc
    QP(loc,val)
    # (;loc, val)
end

Base.in(e::SVector, cs) = all( ( (e[i]<=cs.max[i])&(e[i]>=cs.min[i]) for i=1:length(cs.min) ) )

# TODO: why is this not working?
# dims(dom::CartesianSpace{d,dims}) where d where dims = dims

ddims(dom::CartesianSpace{d,t}) where d where t = t

dims(dom::CartesianSpace) = ddims(dom)
ndims(dom::CartesianSpace{d, dims}) where d where dims = d

variables(c::CartesianSpace) = dims(c)

struct GridSpace{N,d,dims}
    points::SVector{N,SVector{d,Float64}}
end
GridSpace(v::SVector{N, SVector{d, Float64}}) where d where N = GridSpace{length(v), d, Val{(:i_,)}}(SVector(v...))
GridSpace(v::Vector{SVector{d, Float64}}) where d = GridSpace{length(v), d, Val{(:i_,)}}(SVector(v...))
GridSpace(names, v::SVector{k, SVector{d, Float64}}) where k where d = GridSpace{length(v), d, names}(v)

getindex(gs::GridSpace, i::Int64) = gs.points[i]

function rand(g::GridSpace) 
    i =  rand(1:length(g.points))   # loc
    v = g.points[i]                 # val
    QP(i,v)
    # (;loc=i,val=v)
end

ndims(gd::GridSpace{N,d,dims}) where N where d where dims = d
ddims(gd::GridSpace{N,d,dims}) where N where d where dims<:Val{e} where e = e
ddims(gd::GridSpace{N,d,dims}) where N where d where dims = dims
dims(gd::GridSpace) = ddims(gd)


struct ProductSpace{A,B}
    spaces::Tuple{A,B}
end

ProductSpace(A,B) = ProductSpace((A,B))

function rand(p::ProductSpace)
    a = rand(p.spaces[1])
    b = rand(p.spaces[2])
    QP(
        (a.loc,b.loc),
        SVector(a.val...,b.val...)
    )
    # (;loc=(a.loc,b.loc),val=SVector(a.val...,b.val...))
end

getindex(ps::ProductSpace, ind) = SVector(getindex(ps.spaces[1], ind[1])..., getindex(ps.spaces[2], ind[2])...)

variables(p::ProductSpace) = dims(p)

cross(A::DA, B::DB) where DA<:GridSpace where DB<:CartesianSpace = ProductSpace{DA, DB}((A,B))
ndims(p::P) where P<:ProductSpace = ndims(p.spaces[1]) + ndims(p.spaces[2])
dims(p::P) where P<:ProductSpace = tuple(dims(p.spaces[1])..., dims(p.spaces[2])...)

