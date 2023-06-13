import Base.*

struct Tk{T, k}
    T::T
    k::k
end

function *(tk::Tk, dx::Vector)
    @assert length(dx)==tk.k+1 "The objects' sizes are not compatible"
    # res = deepcopy(dx)
    res = Vector(undef, length(dx))
    res[length(dx)] = dx[length(dx)]
    for i in tk.k:-1:1
        res[i] = dx[i] + (tk.T * res[i+1])
    end
    return res
end

struct UVk{U, V, k}
    U::U
    V::V
    k::k
end

function *(uvk::UVk, dp::Vector)
    @assert length(dp)==uvk.k+1 "The objects' sizes are not compatible"
    # res = deepcopy(dy)
    res = Vector(undef, length(dp))
    for i in 1:uvk.k
        # res[i] = hk.U * dy[i] + hk.V * dy[i+1]
        res[i] = GArray(uvk.U.grid, [e * dp[i] for e in uvk.U] + [e * dp[i+1] for e in uvk.V])
    end
    res[length(dp)] = GArray(uvk.U.grid, [e * dp[length(dp)] for e in uvk.U])
    return res
end

struct Gk{G, k}
    G::G
    k::k
end

function *(gk::Gk, dμ::Vector)
    @assert length(dμ)==gk.k+1 "The objects' sizes are not compatible"
    # res = deepcopy(dx)
    res = Vector(undef, length(dμ))
    res[1] = dμ[1]
    for i in 2:gk.k+1
        res[i] = dμ[i] + (gk.G * res[i-1])
    end
    return res
end

struct Hk{H, k}
    H::H
    k::k
end

function *(hk::Hk, dx::Vector)
    @assert length(dx)==hk.k+1 "The objects' sizes are not compatible"
    # res = deepcopy(dy)
    res = Vector(undef, length(dx))
    # Need to change the size of the vector of zeros to match the dimension of y
    res[1] = hk.H * GArray(dx[1].grid, Vector([SVector{2, Float64}([0, 0]) for i in 1:length(dx[1])]))
    for i in 2:hk.k+1
        res[i] = hk.H * dx[i-1]
    end
    return res
end

struct ABk{A, B, k}
    A::A
    B::B
    k::k
end

function *(abk::ABk, dp::Vector)
    @assert length(dp)==abk.k+1 "The objects' sizes are not compatible"
    # res = deepcopy(dy)
    res = Vector(undef, length(dp))
    res[1] = abk.B * dP[1]
    for i in 2:abk.k+1
        res[i] = abk.A * dp[i-1] + abk.B * dp[i]
    end
    return res
end

struct Bk{B, k}
    B::B
    k::k
end

function *(bk::Bk, dp::Vector)
    @assert length(dp)==bk.k+1 "The objects' sizes are not compatible"
    # res = deepcopy(dy)
    res = Vector(undef, length(dp))
    for i in 1:bk.k+1
        res[i] = bk.B * dp[i]
    end
    return res
end

function J(F, G, A, P, dy)
    k = length(dy)-1

    dP = [P._y * y for y in dy]
    T = F._J1 \ F._J2
    U = F._J1 \ F._U
    V = F._J1 \ F._V 

    tk = Tk(T, k)
    uvk = UVk(U, V, k)
    term_x = tk * (uvk * dP)
    
    bk = Bk(G._B, k)
    hk = Hk(G._x, k)
    gk = Gk(G._μ, k)
    term_μ = gk * (bk * dP + hk * term_x)
    
    return [A._x * x for x in term_x] + [A._μ * μ for μ in term_μ] + [A._y * y for y in dy]
end

# function J_T(T, U, V, k::Int64)
#     dy1 = SVector{2, Float64}(1.0, 0.0) 
#     dy2 = SVector{2, Float64}(0.0, 1.0)

#     U1 = GArray(U.grid, [e * dy1 for e in U.data])
#     U2 = GArray(U.grid, [e * dy2 for e in U.data])
#     V1 = GArray(U.grid, [e * dy1 for e in V.data])
#     V2 = GArray(U.grid, [e * dy2 for e in V.data])
    
#     res1 = Vector(undef, k+1)
#     res1[k+1] = U1
#     res1[k] = V1 + T * U1
#     res2 = Vector(undef, k+1)
#     res2[k+1] = U2
#     res2[k] = V2 + T * U2

#     for i in k-1:-1:1
#         res1[i] = T * res1[i+1] 
#         res2[i] = T * res2[i+1] 
#     end
    
#     return res1, res2
# end

function J_forward(A, G, T, U, V, P, k::Int64)

    # Works for y on size 1 only
    dy = SVector{1, Float64}(1.0)
    dP = P._y * dy
    
    U1 = U*dP
    V1 = V*dP


    # Rk = Vector{typeof(U1)}(undef, k+1)
    Rk = fill(U1, k+1)
    Tk0 =  A._x * Rk[k+1]
    Tk = fill(Tk0, k+1)

    # Rk[k+1] = U1
    # Tk[k+1] = A._x * Rk[k+1]

    Rk[k] = V1 + T * U1
    Tk[k] = A._x * Rk[k]

    for i in k-1:-1:1
        Rk[i] = T * Rk[i+1] 
        Tk[i] = A._x * Rk[i+1] 
    end

    
    #### TODO: CHeck wether the following is correct (it is super slow)
    hk = Hk(G._x, k)    
    Sk = hk * Rk

    # looks simpler
    # Sk = [G._x*e for e in Rk]
    
    return Rk, Tk, Sk
    
end

function J_backward(A, G, P, Rk, k::Int64)
    # Works for y on size 1 only
    dy = SVector{1, Float64}(1.0) 
    dP = P._y * dy

    B1 = G._p * dP
    A1 = G._p * dP # Change G._B by G._A

    Wk = Vector(undef, k+1)
    Wk[1] = B1
    Wk[2] = G._μ * B1 + A1
    for i in 3:k+1
       Wk[i] = G._μ * Wk[i-1]
    end

    Xk = Vector(undef, k+1)
    for i in 2:(k+1)
        Xk[i] = G._x * Rk[i-1]
    end
    Xk[1] = GArray(Xk[2].grid, zeros(length(Xk[2].data)))

    return [A._μ * e for e in Wk], [A._μ * e for e in Xk]
end

# function J_GB(G, B, k::Int64)
#     dy1 = SVector{2, Float64}(1.0, 0.0) 
#     dy2 = SVector{2, Float64}(0.0, 1.0)

#     B1 = B * dy1
#     B2 = B * dy2

#     res1 = Vector(undef, k+1)
#     res2 = Vector(undef, k+1)
#     res1[1] = B1
#     res2[1] = B2
#     for i in 2:k+1
#        res1[i] = G * res1[i-1]
#        res2[i] = G * res2[i-1]
#     end

#     return res1, res2
# end

# function J_GH(G, H, res1, res2)
#     k = length(res1) - 1
#     gk = Gk(G, k)
#     hk = Hk(H, k)
#     res3 = gk * (hk * res1)
#     res4 = gk * (hk * res2)
#     return res3, res4
# end

# function J_GH(H, res1, res2)
#     k = length(res1) - 1
#     hk = Hk(H, k)
#     res3 = hk * res1
#     res4 = hk * res2
#     return res3, res4
# end


function jacobian_matrices(Tk, Wk, Xk, K)
    # Works for y of size 1 only
    TkT = zeros(1, K+1)
    WkT = zeros(1, K+1)
    XkT = zeros(1, K+1)
    for i in 1:(K+1)
        TkT[i] = Tk[K+1-(i-1)][1]
        WkT[i] = Wk[K+1-(i-1)][1]
        XkT[i] = Xk[K+1-(i-1)][1]
    end

    J_x = zeros(K+1, K+1)
    for i in 1:(K+1)
        J_x[i, i:(K+1)] = TkT[1:(K+1-(i-1))]
    end

    J_μ1 = zeros(K+1, K+1)
    for i in (K+1):-1:1
        J_μ1[i, 1:i] = WkT[1:i]
    end

    J_μ2 = zeros(K+1, K+1)
    for i in 2:(K+1)
        J_μ2[i, i:(K+1)] = XkT[i:(K+1)]
    end

    return J_x, J_μ1, J_μ2
end
