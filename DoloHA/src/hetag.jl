using FiniteDiff
using SparseArrays

struct LinearOperator{From,To}
    from::From
    to::To
    fun
end

import Base: *
*(L::LinearOperator, x) = L.fun(x)

function convert(::Type{Matrix}, L::LinearOperator)
    convert(Matrix,
        convert(LinearMap, L)
    )
end

function convert(::Type{LinearMap}, L::LinearOperator)
    p = length(ravel(L.to))
    q = length(ravel(L.from))
    LinearMap( u-> ravel( L* unravel(L.from, u)), p, q)

end


function τ(model, ss::Tuple, a::SVector, p0, p1)


    p = model.calibration.p
    P = model.transition
    Q = model.grid.g1.points

    ss = cover(p0, ss)

    (i,_),(s_) = ss # get current state values

    # TODO: replace following block by one nonallocating function
    k = length(model.calibration.m)
    l = length(model.calibration.s)
    m = SVector((s_[i] for i=1:k)...)
    s = SVector((s_[i] for i=k+1:(k+l))...)

    it = (
        (
            P[i,j],
            (
                (j,),
                let
                    q = cover(p1,Q[j])
                    SVector(
                        q...,
                        transition(model, m, s, a, q, p)...
                    )
                end
            )
        )
        for j in 1:size(P, 2)
    )

    it

end

# function τ_test(model, ss::Tuple, a::SVector, p0; linear_index=false)

#     p = model.calibration.p
#     P = model.transition
#     Q = model.grid.g1.points


#     i = ss[1][1]


#     n_m = length(model.calibration.m)

#     ss = cover(p0, ss)

#     (i,_),(s_) = ss # get current state values

#     # TODO: replace following block by one nonallocating function
#     k  = length(model.calibration.m)
#     l = length(model.calibration.s)
#     m = SVector((s_[i] for i=1:k)...)
#     s = SVector((s_[i] for i=k+1:(k+l))...)

#     for j in 1:size(P, 2)

#         S = transition(model, m, s, a, Q[j], p)

#         for (w, i_S) in trembling__hand(model.grid.g2, S)

#             res = (
#                 P[i,j]*w,

#                 (
#                     (linear_index ? to__linear_index(model.grid, (j,i_S)) : (j,i_S)),

#                     SVector(Q[j]..., model.grid.g2[i_S]...)
#                 )
#             )
#             if linear_index
#                 res
#                 # res::Tuple{Float64, Tuple{Int64, Tuple{SVector{1},SVector{1}}}}
#             else
#                 res
#                 # res::Tuple{Float64, Tuple{Tuple{Int64, Int64}, Tuple{SVector{1},SVector{1}}}}
#             end

#         end
#     end
# end


 @resumable function τ_fit(model, ss::Tuple, a::SVector, p0, p1; linear_index=false)

    p = model.calibration.p
    P = model.transition
    Q = model.grid.g1.points

    n_m = length(model.calibration.m)

    (i,_),(s_) = ss # get current state values

    # TODO: replace following block by one nonallocating function
    k  = length(model.calibration.m)
    l = length(model.calibration.s)

    s_ = cover(p0, s_)

    m = SVector((s_[__i] for __i=1:k)...)
    s = SVector((s_[__i] for __i=k+1:(k+l))...)

    for j in 1:size(P, 2)
        
        M = cover(p1, Q[j])
        S = transition(model, m, s, a, M , p)

        for (w, i_S) in trembling__hand(model.grid.g2, S)

            res = (
                P[i,j]*w,

                (
                    (linear_index ? to__linear_index(model.grid, (j,i_S)) : (j,i_S)),

                    SVector(M..., model.grid.g2[i_S]...)
                )
            )
            if linear_index
                res
                # res::Tuple{Float64, Tuple{Int64, Tuple{SVector{1},SVector{1}}}}
            else
                res
                # res::Tuple{Float64, Tuple{Tuple{Int64, Int64}, Tuple{SVector{1},SVector{1}}}}
            end
            @yield res

        end
    end
end


function transition_matrix(model, x, p0)

    N = length(x)
    P = zeros(N,N)

    p1 = p0 # irrelevant here

    for (ss,a) in zip(enum(model.grid),x)
        ind_i = ss[1]
        i = to__linear_index(model.grid, ind_i)
        for (w, (ind_j, _)) in τ_fit(model, ss, a, p0, p1)
            j = to__linear_index(model.grid, ind_j)
            P[i,j] = w
        end
    end

    P

end

function transition_matrix_diff(model, x, p0)

    n_x = length(model.calibration.x)
    N = length(x)
    P = zeros(SVector{n_x, Float64},N,N)

    p1 = p0 # irrelevant here

    for (ss,a) in zip(enum(model.grid),x)
        ind_i = ss[1]
        i = to__linear_index(model.grid, ind_i)
        indices = tuple( (to__linear_index(model.grid, ind_j) for (w, (ind_j, _)) in τ_fit(model, ss, a, p0, p1) )...)
        values = ForwardDiff.jacobian(
            u->SVector( (w for (w,e) in  NoLib.τ_fit(model, ss, u, p0, p1))... ),
            a
        )
        for (k,j) in enumerate(indices)
            P[i,j] = values[k,:]
        end
    end

    P

end

# TODO: this is a linear operation GArray->GArray, stored as a matrix.
struct LinnMatt{G}
    grid::G
    μ 
    P::AbstractMatrix{Float64}
end

convert(::Type{Matrix}, a::LinnMatt) = a.P

*(L::LinnMatt, v::GVector) = unravel(L.μ, L.P*ravel(v))
*(L::LinnMatt, v::SVector) = unravel(L.μ, L.P*v)
*(L::LinnMatt, v:: SLArray{Tuple{d}, Float64, 1, d, N})  where N where d = L*SVector(v...)


*(L::GVector, v::SVector) = GVector(L.grid, [e*v for e in L.data])
*(L::GVector, v::SMatrix) = GVector(L.grid, [e*v for e in L.data])

struct GG_x{T}
    P_x::T
    μ::GDist
end

function *(L::GG_x, x::GVector)
    P = [L.P_x[i,j]'*x[j] for i=1:size(L.P_x,1), j=1:size(L.P_x,2)]
    return GVector(
        L.μ.grid,
        P*L.μ.data
    )
end

function G(model, μ::GDist{T}, x, p0; diff=false) where T

    μ1 = GArray(μ.grid, zeros(Float64, length(μ)))
    for ss in enum(model.grid)
        ss = cover(p0,ss)
        a = x[ss[1]...]
        mass = μ[ss[1]...]
        for (w, (ind, _)) in τ_fit(model, ss, a, p0, p0)
            μ1[ind...] += w*mass
        end
    end

    if !diff
        return μ1
    else

        t_μ = typeof(μ)
        # satisfying but apparently slower than P*μ

        # G_μ = LinearOperator{t_μ,t_μ}(
        #     dμ->G(model, dμ, x, p0; diff=false)
        # )
        P = transition_matrix(model, x, p0)
        G_μ = LinnMatt(model.grid, μ, SparseMatrixCSC(P'))

        # G_μ = LinearOperator{typeof(x),t_μ}(
        #     u->unravel(μ, P*ravel(u))
        # )
        
        mat_p = FiniteDiff.finite_difference_jacobian(
            u->ravel(G(model, μ, x, u; diff=false)),
            p0
        )
        n_p = length(p0)
        G_p = LinnMatt(model.grid, μ, mat_p)
        # G_p = GVector(
        #     model.grid, #should be distribution grid
        #     reinterpret( SMatrix{1, n_p, Float64, n_p} ,(copy(mat_p'))[:])
        # )

        P_x = transition_matrix_diff(model, x, p0)
        G_x = GG_x(copy(P_x'), μ)

        
        # the returned functions are inefficient by dimensionally consistent
        return (;_0=μ1, _μ=G_μ, _x=G_x, _p=G_p)
    end

end


cover(p, s::Tuple{IND, Tuple{T_m, T_s}})  where IND where T_m <: SVector{U,T} where T_s where U where T = (s[1], (cover(p, s[2][1]), s[2][2]))
cover(p, s::Tuple{IND, Tuple{TT}})  where IND where TT <: SVector{U,T} where U where T = (s[1], (cover(p, s[2])))
cover(p, s::Tuple{IND, TT})  where IND where TT <: SVector{U,T} where U where T = (s[1], (cover(p, s[2])))
# cover(p, s::Tuple{IND, TT})  where IND where TT where d = (s[1], (cover(p, s[2])))


F(model, s, x::SVector, φ::DFun, p0, p1) =
    sum(
        w*arbitrage(model,cover(p0,s),x,cover(p1,S),φ(S)) 
         for (w,S) in τ(model, s, x, p0, p1)
    )


function F(model, controls::GArray, φ::DFun, p0, p1; diff=false)

    r = GArray(
        model.grid,
        [
            F(model,s,x,φ,p0,p1)
            for (s,x) in zip(enum(model.grid), controls)
        ],
    )

    if !diff
        return r
    end
    
    r_1 = dF_1(model, controls, φ, p0, p1)
    r_2 = dF_2(model, controls, φ, p0, p1)

    N = length(model.grid)
    n_x = length(eltype(controls))
    n_p = length(p0)
    
    # ordering of the jacobian is: (n_x*N)*n_p
    r_p0 = FiniteDiff.finite_difference_jacobian(
        u->ravel(F(model, controls, φ, u, p1; diff=false)),
        p0
    )
    r_p1 = FiniteDiff.finite_difference_jacobian(
        u->ravel(F(model, controls, φ, p0, u; diff=false)),
        p1
    )

    rm_p0 = reshape( view(r_p0, :), (n_x, N, n_p) )
    rm_p1 = reshape( view(r_p1, :), (n_x, N, n_p) )

    rr_p0 = permutedims(rm_p0, (1,3,2))
    rr_p1 = permutedims(rm_p1, (1,3,2))

    elt = SMatrix{n_x, n_p, Float64, n_x*n_p}
    r_3 = GArray(model.grid, reinterpret(elt, rr_p0[:]))
    r_4 = GArray(model.grid, reinterpret(elt, rr_p1[:]))

    return (; _0=r, _J1=r_1, _J2=r_2, _U=r_3, _V=r_4)

end

dF_1(model, controls::GArray, φ::DFun, p0, p1) =
    GArray(    # this shouldn't be needed
        model.grid,
        [
            ForwardDiff.jacobian(u->F(model, s, u, φ, p0, p1), x)
            for (s,x) in zip(enum(model.grid), controls) 
        ]
    )

dF_2(model, s, x::SVector, φ::DFun, dφ::DFun, p0, p1) = 
    sum(
            w*ForwardDiff.jacobian(u->arbitrage(model,cover(p0,s),x,S,u), φ(S))* dφ(S)
            for (w, S) in τ(model, s, x, p0, p1)
    )


dF_2(model, controls::GArray, φ::DFun, dφ::DFun, p0, p1) =
    GArray(
        model.grid,
        [(dF_2(model,s,x,φ,dφ,p0,p1)) for (s,x) in zip(enum(model.grid), controls) ],
    )

using LinearMaps

# dF_2(model, x::GArray, φ::GArray, p0, p1) = let
#     n = length(φ)*length(eltype(φ))
#     fun = u->(ravel(dF_2(model, x, φ, unravel(x, u), p0, p1)))
#     xxx = ravel(x)
#     # return xxx
#     e = fun(xxx)
#     LinearMap(
#         fun,
#         n,
#         n
#     )
# end

function dF_2(model, x::GArray, φ::DFun, p0, p1 )
    # TODO: one should preallocate here
    res = []
    for (s,x) in zip(enum(model.grid), x)
        l = []
        for (w, S) in τ(model, cover(p0, s), x)
            el = w*ForwardDiff.jacobian(u->arbitrage(model,cover(p0,s),x,cover(p1,S),u), φ(S))
            push!(l, (el, S))
        end
        push!(res, l)
    end
    N = length(res)
    J = length(res[1])
    tt = res[1][1]
    M_ij = Array{typeof(tt[1])}(undef,N,J)
    S_ij = Array{typeof(tt[2])}(undef,N,J)
    for n=1:N
        for j=1:J
            M_ij[n,j] = res[n][j][1]
            S_ij[n,j] = res[n][j][2]
        end
    end
    return LF(model.grid, M_ij, S_ij, φ)
end


function projection(model, y::SVector, z::SVector; diff=false)

    y_ = NoLib.LVectorLike(model.calibration.y, y)
    z_ = NoLib.LVectorLike(model.calibration.z, z)
    
    pp = SVector(projection(model, y_, z_)...)

    if diff==false
        return pp
    else

        P_y = ForwardDiff.jacobian(u->projection(model, u, z; diff=false), y)
        P_z = ForwardDiff.jacobian(u->projection(model, y, u; diff=false), z)

        return (;_0=pp, _y=P_y, _z=P_z)
    end

end


function projection(model, y::SLArray, z::SLArray)
    p = model.calibration.p
    projection(model, y, z, p)
end

function equilibrium(model, s::SLArray, x::SLArray, y::SLArray)
    p = model.calibration.p
    equilibrium(model, s, x, y, p)
end


function equilibrium(model, s::SVector, x::SVector, y::SVector)
    s_ = NoLib.LVectorLike(merge(model.calibration.m, model.calibration.s),s)
    x_ = NoLib.LVectorLike(model.calibration.x,x)
    y_ = NoLib.LVectorLike(model.calibration.y,y)
    equilibrium(model, s_, x_, y_)
end

struct ALinOp{G, T}
    v::GVector{G, T}
end
*(a::ALinOp, v::GVector) = sum(a.v*v)
# *(a::ALinOp, v::SVector) = sum(e*v for e in a.v.data)

convert(::Type{Matrix}, a::ALinOp) = cat(a.v.data...; dims=2)

function equilibrium(model, μ::NoLib.GVector, x, y; diff=false)
    res = sum(  μ[i]*equilibrium(model, model.grid[i], x[i], y) for i=1:length(model.grid))
    if !diff
        return res
    else
        r_μ = ALinOp(
            GVector(
                model.grid,
                [equilibrium(model,model.grid[i], x[i], y) for i=1:length(model.grid)]
            )
        )
        # res_μ = LinearOperator{typeof(μ), SVector{1,Float64}}(
        #     dμ ->  sum(  dμ[i]*equilibrium(model,model.grid[i], x[i], y) for i=1:length(model.grid))
        # )

        r_x = ALinOp(
            GVector(
                model.grid,
                [μ[i]*ForwardDiff.jacobian(u->equilibrium(model,model.grid[i], u, y), x[i]) for i=1:length(model.grid)]
            )
        )
        # res_x = LinearOperator{typeof(x), SVector{length(y),Float64}}(
        #     dx -> sum(  μ[i]*ForwardDiff.jacobian(u->equilibrium(model,model.grid[i], u, y), x[i])*dx[i] for i=1:length(model.grid))
        # )
        r_y = sum(
            μ[i]*ForwardDiff.jacobian(u->equilibrium(model,model.grid[i], x[i], u), y) for i=1:length(model.grid)
        )
        # res_y = LinearOperator{SVector{1,Float64},SVector{1,Float64}}(
        #     dy -> sum(  μ[i]*ForwardDiff.jacobian(u->equilibrium(model,model.grid[i], x[i], u), y)*dy for i=1:length(model.grid))
        # )
        # return res, (r_μ,res_μ), (r_x,res_x), (r_y,res_y)
        return (;_0=res, _μ=r_μ, _x=r_x, _y=r_y)
    end

end

