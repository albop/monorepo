
using LinearAlgebra: mul!

K = 1000
z = deepcopy(U*0)
res = [z for k=1:K]

function construct_col!(res, T, U, V; K=1000, tol_η=1e-8)
    
    res[1] = U
    res[2] = T*U + V
    for k=3:K
        η = NoLib.norm(res[k-1])
        if η<tol_η
            break
        end
        # res[k] = T*res[k-1]
        NoLib.mul!(res[k], T, res[k-1])
    end
    return res

    # # no storage
    # el = T*U+V
    # le = deepcopy(el)
    # for k=3:K
    #     mul!(le,T,le)
    #     el,le=le,el
    # end
    # return (el.data)
end

println("Constructing Jacobian")
construct_col!(res, T,U,V; K=1000);
@time  construct_col!(res, T,U,V;K=1000);

using Profile
Profile.clear_malloc_data() 


P = 10
println("Many Times $(100)")
function many_times(;P=2)
    for p=1:P
        construct_col!(res, T,U,V);
    end
end



@time many_times(P=10)


# residual(model, model.y)

# resid(u::Float64) = residual(model, SLVector(K=u))

# Kvec = range(15, 20;length=20)
# Rvec = [resid(e) for e in Kvec]

# using Plots
# plot(Kvec, Rvec)


###

# J_1, J_2 = NoLib.time_iteration(model; verbose=false, improve=false, x0=sol.solution)
