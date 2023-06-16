using Test


include("models/neoclassical.jl")



φ = GVector(model.grid, [Iterators.repeated(SVector(model.calibration.x), length(model.grid))...])
i0 = 3
s0_ = [NoLib.enum(model.grid)...][i0]
s0 = [NoLib.enum(model.grid)...][i0]
m0 = s0[2:end]

s0 = [enum(model.grid)...][1]
x0 = φ[1]


import Adapt
Adapt.@adapt_structure NoLib.GArray

using KernelAbstractions
import KernelAbstractions.Extras.LoopInfo: @unroll


@kernel function F_gpu(@Const(model), r, @Const(φ))

    c = @index(Global, Cartesian)
    i,j = c.I

    n = @index(Global)

    s_ = model.grid[i,j]
    s = ((i,j), s_)
    x = φ[i,j]
    
    rr = x*0
    for (w,S) in NoLib.τ(model, s, x)
        rr += w*NoLib.arbitrage(model,s,x,S,φ(S))
    end
    r[i,j] = rr

        
end

ev = F_gpu(CUDADevice(), 128)
ev2 = F_gpu(CPU(), 4)


function timing(K, φ0)
    r = deepcopy(φ0)
    local event
    for k=1:K
        ev2( model, r, φ0, ndrange=(2,500))
        # NoLib.F_gpu(r, model, φ0, φ0)
        r.data .*= 0.0000001
        φ0.data .+= r.data
    end
    return r
end

res_cpu = timing(10000, φ)
@time timing(10000, φ);

@inbounds @fastmath function FF!(res, model, xx, φ0,)


    Q = model.grid.g1
    p = model.calibration.p
    P = model.transition
    k = size(P,1)
    (a,b,N) = model.grid.g2.ranges[1]

    T = typeof(model.calibration.x)

    for n=1:N
        for i=1:k
        s_ = a + (b-a)*(n-1)/(N-1)
        s = SVector(s_)
            r = zero(T)
            m = Q[i]
            x = xx[i,n]
            for j=1:k
                w = P[i,j]
                M = Q[j]
                S = @inline NoLib.transition(model, m, s, x, M, p)
                X = x
                res.data[n] = w*(@inline NoLib.arbitrage(model, m, s, x, M, S, X, p))
            end
        end
    end

end

r = deepcopy(φ)
FF!(r, model, φ, φ)

function timing_hand(model, K, φ0)
    
    P = model.transition
    k = size(P,1)
    r = deepcopy(φ0)
    D = reshape(r.data, N, k)

    for k=1:K
        FF!(r, model, φ0, φ0)
        r.data .*= 0.0000001
        φ0.data .+= r.data
    end
    return r
end

@time timing_hand(model, 10000, φ);
