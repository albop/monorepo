
using Optim


function Q(model, s, x, φv)

    p = model.calibration.p
    r = reward(model, s, x)
    contv = sum( w*φv(S)  for (w,S) in NoLib.τ(model, s, x))
    return r + p.β*contv

end

function X(model, s_::SVector)

    m,s = NoLib.split_states(model, s_)
    mm_ = NoLib.LVectorLike(model.calibration.m, m)
    ss_ = NoLib.LVectorLike(model.calibration.s, s)
    ss = catl(mm_, ss_)

    X(model, ss)

end

function X(model, s::Tuple)
    X(model, s[2])
end


function Bellman_update(model, x0, φv)

    nx = deepcopy(x0)
    nv = deepcopy(φv)

    for (n,(s,x)) in enumerate(zip(enum( model.grid ),x0))

        lb, ub = X(model, s)
        fun = u->-Q(model, s, SVector(u...), φv)
        res = Optim.optimize(
            u->-Q(model, s, SVector(u...), φv),
            lb,
            ub,
            Vector(x);
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


function vfi(model; verbose=true, improve=true, T=1000)

    nx = initial_guess(model)
    nv = GArray(model.grid, [1.0 for i=1:length(model.grid)])

    for k=1:T

        nx1,nv = Bellman_update(model, nx, nv)
        η_x = maximum((distance(a,b) for (a,b) in zip(nx1,nx)))
        verbose ? println(η_x) : nothing
        if η_x<1e-8
            return (nx, nv)
        end
        nx = nx1
        if k >5 & improve
            for n=1:50
                nv = Bellman_eval(model, nx, nv)
            end
        end
    end

    return nx, nv
end



# function catl(a::SLArray{Tuple{d1},Float64,1,d1,dims1}, b::SLArray{Tuple{d2},Float64,1,d2,dims2})
function catl(a::SLArray, b::SLArray)
    
    sa = LabelledArrays.symbols(a)
    sb = LabelledArrays.symbols(b)

    dims = tuple(sa..., sb...)
    vec = SVector(a..., b...)

    d = length(dims)
    
    SLArray{Tuple{d},Float64,1,d,dims}(vec...)

end

function reward(model, s_::SVector, x_::SVector)
    
    p = model.calibration.p
    
    m,s = NoLib.split_states(model, s_)
    mm_ = NoLib.LVectorLike(model.calibration.m, m)
    ss_ = NoLib.LVectorLike(model.calibration.s, s)
    ss = catl(mm_, ss_)
    xx = NoLib.LVectorLike(model.calibration.x, x_)

    return reward(model, ss, xx, p)

end

function reward(model, s, x::SVector)

    return reward(model, SVector(s[2]), x)

end
