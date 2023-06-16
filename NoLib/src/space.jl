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
    return CartesianSpace{d, Val{names}}(a,b)
end

import Base: rand, in

Base.rand(cs::CartesianSpace) = SVector( ( (cs.min[i] + rand()*(cs.max[i]-cs.min[i])) for i=1:length(cs.min))...)
Base.in(e::SVector, cs) = all( ( (e[i]<=cs.max[i])&(e[i]>=cs.min[i]) for i=1:length(cs.min) ) )

# TODO: why is this not working?
# dims(dom::CartesianSpace{d,dims}) where d where dims = dims
ddims(dom::CartesianSpace{d,dims}) where d where dims<:Val{t} where t = t

dims(dom::CartesianSpace) = ddims(dom)
ndims(dom::CartesianSpace{d, dims}) where d where dims = d

variables(c::CartesianSpace) = dims(c)

struct GridSpace{N,d,dims}
    points::SVector{N,SVector{d,Float64}}
end
GridSpace(v::SVector{N, SVector{d, Float64}}) where d where N = GridSpace{length(v), d, Val{(:i_,)}}(SVector(v...))
GridSpace(v::Vector{SVector{d, Float64}}) where d where N = GridSpace{length(v), d, Val{(:i_,)}}(SVector(v...))
GridSpace(names, v::SVector{k, SVector{d, Float64}}) where k where d = GridSpace{length(v), d, names}(SVector(v...))

ndims(gd::GridSpace{N,d,dims}) where N where d where dims = d
ddims(gd::GridSpace{N,d,dims}) where N where d where dims<:Val{e} where e = e
ddims(gd::GridSpace{N,d,dims}) where N where d where dims = dims
dims(gd::GridSpace) = ddims(gd)


struct ProductSpace{A,B}
    spaces::Tuple{A,B}
end

ProductSpace(A,B) = ProductSpace((A,B))

rand(p::ProductSpace) = SVector( rand(p.spaces[1])..., rand(p.spaces[2])...)

variables(p::ProductSpace) = dims(p)

cross(A::DA, B::DB) where DA<:GridSpace where DB<:CartesianSpace = ProductSpace{DA, DB}((A,B))
ndims(p::P) where P<:ProductSpace = ndims(p.spaces[1]) + ndims(p.spaces[2])
dims(p::P) where P<:ProductSpace = tuple(dims(p.spaces[1])..., dims(p.spaces[2])...)

