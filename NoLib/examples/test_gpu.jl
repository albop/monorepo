using Test
# using CUDA
using Adapt
# using CUDAKernels # Required to access CUDADevice
using KernelAbstractions


include("models/neoclassical.jl")





Adapt.@adapt_structure NoLib.GArray

@kernel function fun_(@Const(model), r, @Const(φ))

    c = @index(Global, Cartesian)
    i,j = c.I

    s_ = model.grid[i,j]
    s = ((i,j), s_)
    x = φ[i,j]
    
    rr = zero(typeof(x))
    # for (w,S) in NoLib.τ(model, s, x)
    #     rr += w*(@inline NoLib.arbitrage(model,s,x,S,φ(S)))
    # end

    # rr = sum(
    #     w*NoLib.arbitrage(model,s,x,S,φ(S)) 
    #     for (w,S) in NoLib.τ(model, s, x)
    # )      
    # r[n] = rr

    r[i,j] = rr

end

fun_gpu = fun_(CUDADevice())
φ0 = GVector(model.grid, [Iterators.repeated(SVector(model.calibration.x), length(model.grid))...])
r0 = deepcopy(φ0)
r_gpu = Adapt.adapt(CuArray,r0)
φ_gpu = Adapt.adapt(CuArray,φ0)
fun_gpu(model, r_gpu, φ_gpu; ndrange=(2,500))

using FLoops

function fun_hand(model, r, φ; M=M)

    N = length(r)

    @floop for c in CartesianIndices((2,500))

        i = c[1]
        j = c[2]

        s_ = model.grid[i,j]
        s = ((i,j), s_)
        x = φ[i,j]
    
        rr = x*0
        for (w,S) in NoLib.τ(model, s, x)
            rr += w*NoLib.arbitrage(model,s,x,S,φ(S))
        end

        r[i,j] = rr
    end

end


fun_gpu = fun_(CUDADevice())
fun_cpu = fun_(CPU())


function timing(model; K=1000, method=:cpu, M=nothing)

    φ0 = GVector(model.grid, [Iterators.repeated(SVector(model.calibration.x), length(model.grid))...])
    r0 = deepcopy(φ0)
    r = deepcopy(φ0)
    local event
    if method==:gpu
        r_gpu = Adapt.adapt(CuArray, φ0)
        φ_gpu = Adapt.adapt(CuArray, φ0)
    end
    for k=1:K
        if method==:cpu
            event = fun_cpu(model, r, φ0,  ndrange=(2,500))
            # r0.data .+= r.data*0.0001
        elseif method==:hand
            event = fun_hand(model, r, φ0; M=M)
                # r0.data .+= r.data*0.0001
        elseif method==:normal
            NoLib.F!(r, model, φ0, φ0)
            # r0.data .+= r.data*0.0001
        elseif method==:gpu
            event = fun_gpu(model, r_gpu, φ_gpu,  ndrange=(2,500))
            # wait(event)

        end
        # r *= 0.0000001
        # φ0 += r
    end
    if method in (:cpu, :gpu)
        wait(event)
    end
    if method == :gpu
        r = Adapt.adapt(Array, r_gpu)
    end
    return r

end

M = zeros(2,500)
res_normal = timing(model; K=1, method=:normal)

res_hand = timing(model; K=1, method=:hand, M=M)

res_cpu = timing(model; K=1)
res_gpu = timing(model; K=1, method=:gpu)


@time res_normal = timing(model; K=10000, method=:normal);

@time res_hand = timing(model; K=10000, method=:hand);

@time res_cpu = timing(model; K=10000);
@time res_gpu = timing(model; K=10000, method=:gpu);


err = maximum(u->maximum(abs.(u)), res_cpu - res_normal)
err = maximum(u->maximum(abs.(u)), res_gpu - res_normal)

err = maximum(u->maximum(abs.(u)), res_cpu - res_gpu)




########
########

φ0 = GVector(model.grid, [Iterators.repeated(SVector(model.calibration.x), length(model.grid))...])

φ_ = KernelAbstractions.constify(φ0)

####


# include("temp.jl")
# eval(code)

# fun_cpu = fun_(CPU(), 8)

# @time res_cpu = timing(model; K=1);
