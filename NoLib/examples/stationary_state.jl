using Plots;

function residual_(y::SVector)
    model = let 
        β = 0.96
        γ = 4.0
        σ = 0.1
        ρ = 0.0
        # r = 1.025
        # y = 1.0 # available income
        
        K = y[1]
        α = 0.36
        A = 1
        δ = 0.025
        r = 1+α*(1/K)^(1-α) - δ
        w = (1-α)*K^α
    
        y = w
    
        c = 0.9*y
    
        λ = 0
    
        e = 0
        cbar = c
    
    
        m = SLVector(;w,r,e)
        s = SLVector(;y)
        x = SLVector(;c, λ)
        y = SLVector(;K)
        z = SLVector(;z=0.0)
    
        p = SLVector(;β, γ, σ, ρ, cbar, α, δ)
    
        mc = rouwenhorst(3,ρ,σ)
        
        P = mc.p
        ## decide whether this should be matrix or smatrix
        Q = [SVector(w,r,e) for e in mc.state_values] 
    
        N = 20
    
        grid = SSGrid(Q) × CGrid(((0.01,4.0,N),))
        
        name = Val(:ayiagari)
    
        DModel(
            (;m, s, x, y, z, p),
            grid,
            P
        )
    
    end

    sol = NoLib.time_iteration(model; verbose=false, improve=false)
    x0 = sol.solution   # GVector
    μ0 = NoLib.ergodic_distribution(model, sol.solution)   # GDist
    
    return equilibrium(model, x0, μ0, y)
end
