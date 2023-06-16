
using NoLib

using StaticArrays
using LabelledArrays
using NoLib: SGrid, CGrid, PGrid, GArray, GVector, enum, SSGrid, GridSpace, CartesianSpace
import NoLib: transition, arbitrage, reward, X
import NoLib: ×, DModel



## Define Model

model = let 

    α = 0.3
    β = 0.96
    γ = 2.0
    δ = 0.1

    k = ((1/β - (1-δ))/α)^(1/(α-1))
    i = δ*k
    z = 0.0

    p = (;α, β, γ, δ)
    
    m = SLVector( (; z))
    s = SLVector( (; k))
    x = SLVector( (; i))

    P = @SMatrix [0.9 0.1; 0.1 0.9]
    # Q = @SMatrix [-0.05; 0.05]
    Q = @SMatrix [-0.1; 0.1]

    domain = GridSpace(
        [Q[i,:] for i=1:size(Q,1)] 
    ) × CartesianSpace(
        k=[0.1, 5.0]
    )

    exo = SSGrid( [Q[i,:] for i=1:size(Q,1)] )
    endo = CGrid( ((0.1, 5.0, 500),) )
    grid = exo × endo

    DModel(
        (;m, s, x, p,),
        domain,
        grid,
        P
    )

end

function transition(model::typeof(model), m::SLArray, s::SLArray, x::SLArray, M::SLArray, p)
    K = s.k*(1-p.δ) + x.i
    return SLVector( (;K) )
end

function arbitrage(model::typeof(model), m::SLArray, s::SLArray, x::SLArray, M::SLArray, S::SLArray, X::SLArray, p)
    c = exp(m.z)*s.k^p.α - x.i
    C = exp(M.z)*S.k^p.α - X.i
    r = p.β*(C/c)^(-p.γ)*(1-p.δ + p.α*exp(M.z)*S.k^(p.α-1)) - 1
    return SLVector( (;r) )
end

function X(model, s)

    p = model.calibration.p

    y = exp(s.z)*s.k^p.α 
    ([0], [y*0.95])

end

function reward(model::typeof(model), s::SLArray, x::SLArray, p)
    c = exp(s.z)*s.k^p.α - x.i
    return c^(1-p.γ) / (1-p.γ)
end