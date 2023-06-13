
using NoLib
const NL=NoLib

using StaticArrays
using LabelledArrays
using NoLib: SGrid, CGrid, PGrid, GArray, GVector, enum, SSGrid, GridSpace, CartesianSpace
import NoLib: ×, ⟂
using NoLib: DModel
import NoLib: transition, arbitrage, recalibrate, initial_guess, projection, equilibrium

using NoLib: GridSpace, CartesianSpace
using QuantEcon: rouwenhorst

model = let 

    β = 0.96
    γ = 4.0
    σ = 0.1
    ρ = 0.8
    # r = 1.025
    # y = 1.0 # available income
    
    K = 40.0
    α = 0.36
    A = 1
    δ = 0.025

    r = α*(1/K)^(1-α) - δ
    w = (1-α)*K^α

    y = w

    c = 0.9*y

    λ = 0

    e = 0
    cbar = c

    N = 500


    m = SLVector(;w,r,e)
    s = SLVector(;y)
    x = SLVector(;c, λ)
    y = SLVector(;K)
    z = SLVector(;z=0.0)

    p = SLVector(;β, γ, σ, ρ, cbar, α, δ, N)

    n_m = 3
    mc = rouwenhorst(3,ρ,σ)
    

    P = convert(SMatrix{n_m, n_m}, mc.p)
    ## decide whether this should be matrix or smatrix
    Q = SVector( (SVector(w,r,e) for e in mc.state_values)... )

    gm = GridSpace(
        [Q[i] for i=1:size(Q,1)] 
    )
    gb =  CartesianSpace(;
        k=[0.01, 100]
    )


    domain = GridSpace(
        [Q[i] for i=1:size(Q,1)] 
    )×CartesianSpace(;
        k=[0.01, 100]
    )

    grid = SSGrid(Q) × CGrid(((0.01,100.0,N),))
    
    name = Val(:ayiagari)

    DModel(
        (;m, s, x, y, z, p),
        domain,
        grid,
        P
    )

end

# small workaround to limit endless printing
show(io::IO, tt::Type{typeof(model)}) = print(io, "DModel{#$(hash(tt))}")

@assert isbits(model)



function recalibrate(mod::typeof(model); K=mod.calibration.y.K, N=mod.calibration.p.N)

    # this lacks generality but should be future proof

    (;m, s, x, y, z, p) = mod.calibration
    
    (;ρ, σ, α, δ) = p

    r = α*(1/K)^(1-α) - δ
    w = (1-α)*K^α

    m = merge(m, (;w=w, r=r))
    y = merge(y, (;K=K))
    p = merge(p, (;N=N))


    N_ = convert(Int,N)
    
    ## decide whether this should be matrix or smatrix
    n_m = 3
    mc = rouwenhorst(3,ρ,σ)
    
    P = convert(SMatrix{n_m, n_m}, mc.p)
    ## decide whether this should be matrix or smatrix
    Q = SVector( (SVector(w,r,e) for e in mc.state_values)... )

    grid = SSGrid(Q) × CGrid(((0.01,100.0,N_),))
    

    domain = GridSpace(
        [Q[i] for i=1:size(Q,1)] 
    )×CartesianSpace(;
        k=[0.01, 100]
    )

    nmodel = DModel(
        (;m, s, x, y, z, p),
        domain,
        grid,
        P
    )

    # important to check we are not changing the type
    @assert (typeof(nmodel) == typeof(model))

    return nmodel

end


function transition(mod::typeof(model), m::SLArray, s::SLArray, x::SLArray, M::SLArray, p)
    y = exp(M.e)*M.w + (s.y-x.c)*(1+M.r)
    return SLVector( (;y) )
end


function arbitrage(mod::typeof(model), m::SLArray, s::SLArray, x::SLArray, M::SLArray, S::SLArray, X::SLArray, p)
    eq = 1 - p.β*( X.c/x.c )^(-p.γ)*(1+M.r) - x.λ
    # @warn "The euler equation is satisfied only if c<w. If c=w, it can be strictly positive."
    eq2 = x.λ ⟂ s.y-x.c
    return SLVector( (;eq, eq2) )
end


function equilibrium(model, s::SLArray, x::SLArray, y::SLArray, p)
    res = s.y - x.c - y.K*p.δ
    SLVector((;res))
end

function projection(model, y::SLArray, z::SLArray, p)

    r = p.α*exp(z.z)*(1/y.K)^(1-p.α) - p.δ
    w = (1-p.α)*exp(z.z)*y.K^(p.α)

    return SLVector((;w, r)) # XXX: warning, this is order-sensitive
    
end


function initial_guess(model, m::SLArray, s::SLArray, p)
    c = s.y*0.8
    λ = 0.01
    return SLVector(;c, λ)
end