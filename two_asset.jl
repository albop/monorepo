using NoLib
const NL=NoLib

using StaticArrays
using LabelledArrays
using NoLib: SGrid, CGrid, PGrid, GArray, YModel
import NoLib: ×, ⟂
import NoLib: transition, arbitrage, recalibrate, initial_guess, projection, equilibrium
using NoLib: GridSpace, CartesianSpace, MarkovChain
using NoLib: rouwenhorst

model = let 

    ### Parameters
    β  = 0.9762739006553215  # Discount factor
    θ  = 2.0733058732704945  # Disutility of labour (such that N=1)
    χ1 = 6.416419681929865

    γ  = 2.0    # Inverse of eis
    ν  = 1.0    # Inverse of Frisch elasticity

    r  = 0.0125
    ω  = 0.005
    K  = 10.0   # Capital
    δ  = 0.02
    εI = 4.0
    κp = 0.1
    κw = 0.1
    μw = 1.1
    
    G  = 0.2   # Government spending 
    Bh = 1.04  # Exogenous liquid assets
    Bg = 2.8   # Government debt 
    total_wealth = 14
    χ0 = 0.25
    χ2 = 2.0
    ϕπ = 1.5
    ϕy = 0.0

    λ  = 0
    μa = 0
    μb = 0

    # Analytical expressions
    y  = 1.0
    N  = 1.0
    I  = δ * K                              # Investment
    mc = 1.0 - r * (total_wealth - Bg - K)  # Marginal cost
    α  = (r + δ) * K / mc
    μp = 1 / mc
    Z  = K^(-α)
    w  = (1.0 - α) * mc
    τ  = (r * Bg + G) / w
    div = y - w - I
    share_price = div / r
    ra = r
    rb = r - ω
    
    πp = 0.0     # Inflation
    πw = 0.0     # Wage growth
    Tob= 1.0     # Tobin's Q

    # Initialisation values
    e = 0.0
    port_costs = 0.012706305587823754
    c  = y - G - I - port_costs - ω * Bh
    b  = Bh
    a  = total_wealth - b  

    # Grid parameters
    nE = 3
    ρE = 0.966
    σE = 0.92 
    a_min  = 0.0
    a_max  = 400.0
    nA     = 70
    b_min  = 0.0
    b_max  = 50.0
    nB     = 50

    ### Variables
    m = (;w,ra,rb,e) # Prices
    s = (;a,b)  # States
    x = (;c,λ,μa,μb,port_costs)  # Controls
    y = (;Bh,Bg,G,K,total_wealth)  # Exogenous
    z = (;z=0)
    p = (;β,γ,ν,θ,ρE,σE,χ0,χ1,χ2,a_min,b_min)

    calibration = merge(m,s,x,y,z,p)

    ### Grids
    e_grid = rouwenhorst(nE,ρE,σE)

    P = convert(SMatrix{nE, nE}, e_grid.P)
    Q = SVector( (SVector(w,ra,rb,e) for e in e_grid.V)... )

    states = GridSpace(
        (:w,:ra,:rb,:e),
        Q
    )×CartesianSpace(;
        a=[0.01, 10],
        b=[0.01, 10],
    )

    exogenous = MarkovChain((:w,:ra,:rb,:e), P, Q)

    controls = CartesianSpace(
        c=[0,Inf],
        λ=[0,Inf],
        μa=[0,Inf],
        μb=[0,Inf],
        port_costs=[0,Inf]
    )

    grid = SGrid(Q) × CGrid(((a_min,a_max,nA),(b_min,b_max,nB)))
    
    name = :two_asset

    YModel(
        name,
        states,
        controls,
        exogenous,
        calibration
    )

end


function transition(mod::typeof(model), s::NamedTuple, x::NamedTuple, M::NamedTuple)
    y = exp(M.e)*M.w + (s.y-x.c)*(1+M.r)
    return (;y)
end

function Psi1(s::NamedTuple, x::NamedTuple, S::NamedTuple, X::NamedTuple, p)
    return sign(X.A - (1.0+s.ra)*x.a) * p.χ1 * abs( (X.A - (1.0+s.ra)*x.a)/((1.0+s.ra)*x.a - p.χ0) )^(p.χ2-1.0)
end

function Psi2(s::NamedTuple, x::NamedTuple, S::NamedTuple, X::NamedTuple, p)
    return -(1.0+s.ra)*(Psi1(s,x,S,X,p) + p.χ1*(p.χ2-1.0) / p.χ2*(abs(X.a-(1.0+s.ra)*x.a)/((1.0+s.ra)*x.a+p.χ0))^p.χ2)
end

function arbitrage(mod::typeof(model), s::NamedTuple, x::NamedTuple, S::NamedTuple, X::NamedTuple)
    
    p = mod.calibration

    eq  = 1 - p.β*( ((X.c^(-p.γ))*(1+S.rb)) / ((x.c^(-p.γ)) - x.μb) )
    eq2 = 1 - p.β*( ((X.c^(-p.γ))*(1+S.ra-Psi2(s,x,S,X,p)))/((x.c^(-p.γ))*(1.0+Psi1(s,x,S,X,p))+x.μa) )
    eq3 = x.μb ⟂ x.b-p.b_min
    eq4 = x.μa ⟂ x.a-p.a_min
    return (;eq, eq2, eq3, eq4)

end

# @time sol_iti = NoLib.time_iteration(model; verbose=true, improve=true, T=5);


# function equilibrium(model, s::NamedTuple, x::NamedTuple, y::NamedTuple, p)
#     res1 = s.y - x.c - g - i - x.port_cost - psip
#     res2 = x.a + x.b - p - y.Bg
#     res3 = x.n - y.N
#     SLVector((;res1, res2, res3))
# end

# function projection(model, y::NamedTuple, z::NamedTuple, p)
#     r = p.α*exp(z.z)*(1/y.K)^(1-p.α) - p.δ
#     w = (1-p.α)*exp(z.z)*y.K^(p.α)
#     return SLVector((;w, r)) # XXX: warning, this is order-sensitive
    
# end

# function initial_guess(model, m::NamedTuple, s::NamedTuple, p)
#     c = s.y*0.9
#     a = 
#     b = 
#     return SLVector(;c)
# end

# function reward(model::typeof(model), s::NamedTuple, x::NamedTuple, p)
#     c = x.c
#     n = x.n
#     return (c^(1.0-p.γ) / (1.0-p.γ)) - p.θ*(n^(1.0+p.ν) / (1.0+p.ν))
# end


