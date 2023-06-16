using NoLib

using StaticArrays
using LabelledArrays

import NoLib: Model
using NoLib: SGrid, CGrid, PGrid, GArray, GVector, enum, SSGrid, GridSpace, CartesianSpace
import NoLib: transition, arbitrage
import NoLib: ×, DModel

import Dolo
## Define Model

model = let
	
	β = 0.9
	σ = 5
	η = 1
	δ = 0.025
	α = 0.33
	ρ = 0.8
	zbar = 0.0
	σ_z = 0.016
	n = 0.33
	z = zbar
	rk = 1/β - 1+δ
	k = n/(rk/α)^(1/(1-α))
	w = (1-α)*exp(z)*(k/n)^α
	y = exp(z)*k^α*n^(1-α)
	i = δ*k
	c = y - i
	χ =  w/c^σ/n^η
	
	p = (; β, σ, η, χ, δ, α, ρ, zbar, σ_z)
	
	m = SLVector( (; z))
    s = SLVector( (; k))
    x = SLVector( (; n, i))
	
	P = @SMatrix [0.4 0.6; 0.6 0.4]
	Q = @SMatrix [-0.01; 0.01]

	Dolo.MarkovChain(P,Q)

    domain = GridSpace(
        [Q[i,:] for i=1:size(Q,1)] 
    ) × CartesianSpace(
        k=[k*0.5, k*1.5]
    )

	# N = 200
    # exo = SSGrid( [Q[i,:] for i=1:size(Q,1)] )
    # endo = CGrid( ((k*0.5, k*1.5, N),) )
    # grid = exo × endo



    Model(
        (;m, s, x, p,),
        domain,
        P
    )

	
end

function intermediate(model::typeof(model), m::SLArray, s::SLArray, x::SLArray, p)
	y = exp(m.z)*(s.k^p.α)*(x.n^(1-p.α))
	w = (1-p.α)*y/x.n
	rk = p.α*y/s.k
	c = y - x.i
	return SLVector( (; y, c, rk, w))
end

function transition(model::typeof(model), m::SLArray, s::SLArray, x::SLArray, M::SLArray, p)
    K = s.k*(1-p.δ) + x.i
    return SLVector( (;K) )
end
	
function arbitrage(model::typeof(model), m::SLArray, s::SLArray, x::SLArray, M::SLArray, S::SLArray, X::SLArray, p)
	y = intermediate(model, m, s, x, p)
	Y = intermediate(model, M, S, X, p)
	res_1 = p.χ*(x.n^p.η)*(y.c^p.σ) - y.w
	res_2 = (p.β*(y.c/Y.c)^p.σ)*(1 - p.δ + Y.rk) - 1
    return SLVector( (;res_1, res_2) )
end

model