F(model, s, x::SVector, φ::DFun) = 
    sum(
         w*arbitrage(model,s,x,S,φ(S)) 
         for (w,S) in τ(model, s, x)
    )



F(model, s, x::SVector, φ::Union{GArray, DFun}) = 
    sum(
         w*arbitrage(model,s,x,S,φ(S)) 
         for (w,S) in τ(model, s, x)
    )


F(model, controls::GArray, φ::Union{GArray, DFun}) =
    GArray(
        model.grid,
        [
            F(model,s,x,φ)
            for (s,x) in zip(enum(model.grid), controls)
        ],
    )

# using LoopVectorization
function F!(out, model, controls::GArray, φ::Union{GArray, DFun})
    for n in 1:length(model.grid)
        i, j = NoLib.from_linear(model.grid, n)

        s_ = model.grid[n]
        s = ((i,j), s_)
        x = controls[n]
        out[n] = F(model,s,x,φ)
    end
end

# function F!(out, model, controls::GArray, φ::GArray)
#     @floop for (n, (s,x)) in enumerate(zip(enum(model.grid), controls))
#         out[n] = F(model,s,x,φ)
#     end
# end   #### no alloc

## no alloc
dF_1(model, s, x, φ) = ForwardDiff.jacobian(u->F(model, s, u, φ), x)

dF_1(model, controls::GArray, φ::Union{GArray, DFun}) =
    GArray(    # this shouldn't be needed
        model.grid,
        [
            dF_1(model, s, x, φ)
            for (s,x) in zip(enum(model.grid), controls) 
        ]
    )

function dF_1!(out, model, controls::GArray, φ::Union{GArray, DFun})
    for (n, (s,x)) in enumerate(zip(enum(model.grid), controls))
        out[n] = ForwardDiff.jacobian(u->F(model, s, u, φ), x)
    end
end    #### no alloc
    




dF_2(model, s, x::SVector, φ::GArray, dφ::GArray) = 
    sum(
            w*ForwardDiff.jacobian(u->arbitrage(model,s,x,S,u), φ(S))* dφ(S)
            for (w, S) in τ(model, s, x)
    )   ### no alloc


dF_2(model, controls::GArray, φ::GArray, dφ::GArray) =
    GArray(
        model.grid,
        [(dF_2(model,s,x,φ,dφ)) for (s,x) in zip(enum(model.grid), controls) ],
    )

function dF_2!(out::GArray, model, controls::GArray, φ::GArray, dφ::GArray)
    for (n, (s,x)) in enumerate(zip(enum(model.grid), controls))
        out[n] = dF_2(model, s, x, φ, dφ)
    end
end   

include("dev_L2.jl")

using LinearMaps


function time_iteration_workspace(model; interp_mode=:linear)

    x0 = (NoLib.initial_guess(model))
    x1 = deepcopy(x0)
    x2 = deepcopy(x0)
    r0 = deepcopy(x0)
    dx = deepcopy(x0)
    N = length(dx)
    n = length(dx.data[1])
    J = GArray(
        model.grid,
        zeros(SMatrix{n,n,Float64,n*n}, N)
    )
    φ = DFun(model, x0; interp_mode=interp_mode)
    return (;x0, x1, x2, r0, dx, J, φ)
end

function newton_workspace(model; interp_mode=:linear)

    
    res = time_iteration_workspace(model; interp_mode=interp_mode)
    T =  NoLib.dF_2(model, res.x0, res.φ)
    res = merge(res, (;T=T,memn=(;du=deepcopy(res.x0), dv=deepcopy(res.x0))))
    return res
end


function time_iteration(model, workspace=time_iteration_workspace(model);
    T=500, K=10, tol_ε=1e-8, tol_η=1e-6, verbose=false, improve=false, interp_mode=:cubic, engine=:none
    )

    # mem = typeof(workspace) <: Nothing ? time_iteration_workspace(model) : workspace
    mbsteps = 5
    lam = 0.5

    (;x0, x1, x2, dx, r0, J, φ) = workspace

    for t=1:T
        
        NoLib.fit!(φ, x0)

        if engine==:cpu
            F!(r0, model, x0, φ, CPU())
        else
            F!(r0, model, x0, φ)
        end
        # r0 = F(model, x0, φ)

        ε = norm(r0)

        if ε<tol_ε
            return (;message="Solution found", solution=x0, n_iterations=t, dr=φ)
        end

        # solve u->F(u,x0) 
        # result in x1
        # J and r0 are modified

        x1.data .= x0.data

        for k=1:10

            if engine==:cpu
                F!(r0, model, x1,  φ, CPU())
            else
                F!(r0, model, x1,  φ)
            end

            ε_n = norm(r0)
            if ε_n<tol_ε
                break
            end

            if engine==:cpu
                dF_1!(J, model, x1,  φ, CPU())
            else
                dF_1!(J, model, x1,  φ)
            end

            dx.data .= J.data .\ r0.data

            for k=0:mbsteps
                x2.data .= x1.data .- dx.data .* lam^k
                if engine==:cpu
                    F!(r0, model, x2,  φ, CPU())
                else
                    F!(r0, model, x2,  φ)
                end
                ε_b = norm(r0)
                if ε_b<ε_n
                    break
                end
            end

            x1.data .= x2.data

        end

        η = distance(x0, x1)
        verbose ? println("$t: $ε : $η: ") : nothing

        if !(improve)

            x0.data .= x1.data
            
        else
            # x = T(x)
            # x1 = T(x0)
            # x - x1 = -T'(x) (x - x0)
            # x = x1 - T' (x - x0)
            # x = (I-T')\(x1 - T' x0)

            J_1 = NoLib.dF_1(model, x1, φ)
            J_2 =  NoLib.dF_2(model, x1, φ)
            J_2.M_ij[:] *= -1.0
            Tp = J_1 \ J_2
            r = x1 - Tp * x0

            x0 = neumann(Tp, r; K=1000)
            x1.data .= x0.data

        end


    end

    return (;solution=x0, message="No Convergence") # The only allocation when workspace is preallocated

end


function newton(model, workspace=newton_workspace(model);
    K=10, tol_ε=1e-8, tol_η=1e-6, verbose=false, improve=false, interp_mode=:cubic
    )

    # mem = typeof(workspace) <: Nothing ? time_iteration_workspace(model) : workspace

    (;x0, x1, x2, dx, r0, J, φ, T, memn) = workspace


    for t=1:K
        
        NoLib.fit!(φ, x0)

        F!(r0, model, x0, φ)

        ε = norm(r0)
        verbose ? println("$t: $ε") : nothing

        if ε<tol_ε
            return (;message="Solution found", solution=x0, n_iterations=t, dr=φ)
        end

        x1.data .= x0.data


        dF_1!(J, model, x0, φ)
        dF_2!(T, model, x0, φ)

        
        T.M_ij .*= -1.0
        T.M_ij .= J.data .\ T.M_ij 
        
        r0.data .= J.data .\ r0.data
        
        neumann!(dx, T, r0, memn; K=1000)

        x0.data .= x1.data .- dx.data
        x1.data .= x0.data


        # end


    end

    return (;solution=x0, message="No Convergence") # The only allocation when workspace is preallocated

end



function time_iteration_1(model;
    T=500,
    K=10,
    tol_ε=1e-8,
    tol_η=1e-6,
    verbose=false,
)

    N = length(model.grid)
    x0 = GArray(model.grid, [SVector(model.calibration.x) for n=1:N])
    x1 = deepcopy(x0)

    local x0
    local x1
    local t


    for t=1:T

        r0 = F(model, x0, x0)

        ε = norm(r0)

        if ε<tol_ε
            return (;message="Solution found", solution=x0, n_iterations=t)
        end
        # println("Iteration $t: $ε")
        if verbose
            println("ϵ=$(ε)")
        end

        x1.data .= x0.data
        
        for k=1:K

            r1 = F(model, x1, x0)
            J = dF_1(model, x1, x0)
            # dF!(J, model, x1, x0)

            dx = GArray(model.grid, J.data .\ r1.data)

            η = norm(dx)
            
            x1.data .-= dx.data

            verbose ? println(" - $k: $η") : nothing

            if η<tol_η
                break
            end

        end

        x0 = x1

    end

    return (;solution=x0, message="No Convergence", n_iterations=t)

end

using NLsolve

function time_iteration_2(model;
    T=500,
    K=10,
    tol_ε=1e-8,
    tol_η=1e-6,
    verbose=false
)

    N = length(model.grid)
    x0 = GArray(model.grid, [SVector(model.calibration.x) for n=1:N])
    x1 = deepcopy(x0)

    local x0
    local x1
    local t


    for t=1:T

        function fun(u::AbstractVector{Float64})
            x = unravel(x0, u)
            r = F(model, x, x0)
            return ravel(r)
        end

        function dfun(u::AbstractVector{Float64})
            x = unravel(x0, u)
            dr = dF_1(model, x, x0)
            J = convert(Matrix,dr)
            return J
        end

        u0 = ravel(x0)
        sol = nlsolve(fun, dfun, u0)
        u1 = sol.zero

        η = maximum(u->abs(u[1]-u[2]), zip(u0,u1))
        
        verbose ? println("Iteration $t: $η") : nothing
        
        x0 = unravel(x0, u1)

        if η<tol_η
            return (;solution=x0, message="Convergence", n_iterations=t)
        end

    end

    return (;message="No Convergence", n_iterations=T)

end

using LinearAlgebra

function time_iteration_3(model;
    T=500,
    K=10,
    tol_ε=1e-8,
    tol_η=1e-8,
    verbose=false,
    improve=true,
    x0=nothing,
    interp_mode=:linear
)

    N = length(model.grid)
    if x0===nothing
        x0 = initial_guess(model)
    else
        x0 = deepcopy(x0)
    end
    # x0 = GArray(model.grid, [SVector(model.calibration.x) for n=1:N])

    x1 = deepcopy(x0)

    # local x0
    local x1
    local t


    for t=1:T

        φ = DFun(model, x0; interp_mode=interp_mode)

        r0 = F(model, x0, φ)
        ε = norm(r0)

        if ε<tol_ε
            return (;message="Solution found", solution=x0, n_iterations=t)
        end

        # φ = x0
        x1.data .= x0.data
        
        for k=1:K

            r1 = F(model, x1, φ)
            J = dF_1(model, x1, φ)
            # dF!(J, model, x1, x0)

            dx = GArray(model.grid, J.data .\ r1.data)

            η = norm(dx)
            
            x1.data .-= dx.data

            verbose ? println(" - $k: $η") : nothing

            if η<tol_η
                break
            end

        end

        # ε = norm(F(model, x1, φ))
        η = distance(x1,x0)

        if !(improve)
            x0.data[:] = x1.data[:]
        else
            # x = T(x)
            # xnn = T(xn)
            # x - xnn = -T'(x) (x - xn)
            # x = xnn - T' (x - xn)
            # x = (I-T')\(xnn - T' xn)

            # # this version assumes same number of shocks

            J_1 = NoLib.dF_1(model, x1, φ)
            J_2 =  NoLib.dF_2(model, x1, x0)
            J_2.M_ij[:] *= -1.0
            Tp = J_1 \ J_2
            r = x1 - Tp * x0
            x0 = invert(r, Tp; K=500)

        end
        
        ε = maximum(abs, ravel(F(model, x0, x0)))

        verbose ? println("Iteration $t : $η : $ε") : nothing

        if η<tol_η
            return (;solution=x0, dr=φ, message="Convergence", n_iterations=t)
        end

    end

    return (;solution=x0, message="No Convergence", n_iterations=T)

end



# function time_iteration(model;
#     T=500,
#     K=10,
#     tol_ε=1e-8,
#     tol_η=1e-6,
#     verbose=false
# )


#     N = length(model.grid)

#     x0 = GArray(model.grid, [SVector(model.x) for n=1:N])
#     x1 = deepcopy(x0)
#     dx = deepcopy(x0)

#     r0 = x0*0
    
#     J = dF0(model, x0, x0)[2]

#     local x0
#     local x1

#     for t=1:T
#         # r0 = F(model, x0, x0)
#         F!(r0, model, x0, x0)
#         ε = norm(r0)
#         if ε<tol_ε
#             break
#         end
#         if verbose
#             println("ϵ=$(ε)")
#         end
#         x1.data .= x0.data
#         for k=1:K
#             # r = F(model, x1, x0)
#             F!(r0, model, x1, x0)
#             # J = dF(model, x1, x0)
#             dF!(J, model, x1, x0)
#             # dx = J\r0
#             for n=1:length(r0)
#                 dx.data[n] = J.data[n]\r0.data[n]
#             end
#             e = norm(dx)
#             # println("e=$(e)")
#             x1.data .-= dx.data
#             if e<tol_η
#                 break
#             end
#         end
#         x0 = x1

#     end
#     return x0
# end



# # Alternative implementations

# function F0(model, s, x::SVector, xfut::GArray)
#     tot = SVector((x*0)...)
#     for (w, S) in τ(model, s, x)
#         ind = (S[1], S[3])
#         X = xfut(ind...)
#         tot += w*arbitrage(model,s,x,S,X)
#     end
#     return tot
# end


# F(model, controls::GArray, φ::GArray) =
#     GArray(
#         model.grid,
#         [F(model,s,x,φ) for (s,x) in zip(iti(model.grid), controls) ],
#     )

# function F!(out, model, controls, φ) 
#     # for (n,(s,x)) in enumerate(zip(iti(model.grid), controls))
#     n=0
#     for s in iti(model.grid)
#         n += 1
#         x = controls.data[n]
#         out.data[n] = F(model,s,x,φ)
#     end
#     # end
# end

# dF(model, controls::GArray, φ::GArray) =
#     GArray(    # this shouldn't be needed
#         model.grid,
#         [
#             ForwardDiff.jacobian(u->F(model, s, u, φ), x)
#             for (s,x) in zip(iti(model.grid), controls) 
#         ]
#     )

# function dF!(out, model, controls, φ) 
#     # for (n,(s,x)) in enumerate(zip(iti(model.grid), controls))
#     n=0
#     for s in iti(model.grid)
#         n += 1
#         x = controls.data[n]
#         out.data[n] = ForwardDiff.jacobian(u->F(model, s, u, φ), x)
#     end
#     # end
# end

# # function dF2!(out, model, controls, φ) 
# #     # for (n,(s,x)) in enumerate(zip(iti(model.grid), controls))
# #     n=0
# #     for s in iti(model.grid)
# #         n += 1
# #         x = controls.data[n]
# #         out.data[n] = ForwardDiff.jacobian(u->F(model, s, x, φ), φ)
# #     end
# #     # end
# # end


# FdF(model, controls::GArray, φ::GArray) =
#     GArray(
#         model.grid,
#         [
#             (F(model,s,x,φ), ForwardDiff.jacobian(u->F(model, s, u, φ), x))
#             for (s,x) in zip(iti(model.grid), controls) 
#         ]
#     )


# function F0(model, controls::GArray, xfut::GArray)

#     N = length(controls)
#     res = GArray(
#         model.grid,
#         zeros(typeof(controls[1]), N)
#     )
#     for (i,(s,x)) in enumerate(zip(iti(model.grid), controls))
#         res[i] = F(model,s,x,xfut)
#     end
#     return res
# end



# function dF0(model, controls::GArray, xfut::GArray)

#     N = length(controls)
#     res = deepcopy(controls)
#     dres = GArray(
#         model.grid,
#         zeros(typeof(res[1]*res[1]'), N)
#     )
#     for (i,(s,x)) in enumerate(zip(iti(model.grid), controls))
#         res[i] = F(model,s,x,xfut)
#         dres[i] = ForwardDiff.jacobian(u->F(model, s, u, xfut), x)
#     end
#     return res, dres
# end





