
using Optim


function Q(dmodel::DYModel, s, x, φv)

    β = discount_factor(dmodel)
    r = reward(dmodel, s, x)
    contv = sum( w*φv(S)  for (w,S) in NoLib.τ(dmodel, s, x))
    return r + β*contv

end

function X(model, s_::SVector)

    m,s = NoLib.split_states(model, s_)
    mm_ = NoLib.LVectorLike(model.calibration.m, m)
    ss_ = NoLib.LVectorLike(model.calibration.s, s)
    ss = catl(mm_, ss_)

    bounds(model, ss)

end

function X(model, s::Tuple)
    X(model, s[2])
end


function Bellman_update(model, x0, φv)

    nx = deepcopy(x0)
    nv = deepcopy(φv.values)

    for (n,(s,x)) in enumerate(zip(enum( model.grid ),x0))

        # lb, ub = X(model, s)
        # φ = NoLib.DFun(dmodel, nx)
        
        lb, ub = bounds(model, s)
        # fun = u->-Q(model, s, SVector(u...), φv)
        x_ = max.(min.(x, ub), lb)

        res = Optim.optimize(
            u->-Q(model, s, SVector(u...), φv),
            lb,
            ub,
            Vector(x_);
        )

        nx[n] = res.minimizer
        nv[n] = -res.minimum
    end

    return nx, nv

end

function Bellman_eval(model, x0, φv)
    data = [Q(model, s, x, φv)  for (s,x) in zip(enum( model.grid ),x0)]
    GVector(model.grid,data)
end


function vfi(model; verbose=true, improve=true, trace=false, T=1000)

    nx = initial_guess(model)

    nv = GArray(model.grid, [1.0 for i=1:length(model.grid)])
    φv = NoLib.DFun(model.grid, nv)

    ti_trace = trace ? IterationTrace(typeof((;x=nx,v=φv))[]) : nothing


    for k=1:T

        # fit!(φv, nv)
        φv = NoLib.DFun(model.grid, nv)

        trace && push!( ti_trace.data, deepcopy((;x=nx,v=φv)) )


        nx1,nv = Bellman_update(model, nx, φv)

        η_x = maximum((distance(a,b) for (a,b) in zip(nx1,nx)))
        verbose ? println(η_x) : nothing
        if η_x<1e-8
            return (nx, nv, ti_trace)
        end
        nx = nx1
        if (k > 5) & improve
            for n=1:50
                φv = NoLib.DFun(model.grid, nv)
                fit!(φv, nv)
                nv = Bellman_eval(model, nx, φv)
            end
        end
    end

    return nx, nv, ti_trace
end



# # function catl(a::SLArray{Tuple{d1},Float64,1,d1,dims1}, b::SLArray{Tuple{d2},Float64,1,d2,dims2})
# function catl(a::SLArray, b::SLArray)
    
#     sa = LabelledArrays.symbols(a)
#     sb = LabelledArrays.symbols(b)

#     dims = tuple(sa..., sb...)
#     vec = SVector(a..., b...)

#     d = length(dims)
    
#     SLArray{Tuple{d},Float64,1,d,dims}(vec...)

# end
