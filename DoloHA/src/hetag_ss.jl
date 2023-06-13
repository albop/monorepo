using  LinearAlgebra: I

##### 

function ss_residual(model, y_::Union{SVector, SLArray}; diff=false, return_all=false, improve=true, x0=nothing)

    y = SVector(y_...)
    z = SVector(model.calibration.z...)
    # p = projection(model, y, z; diff=false)


    # TODO: replace these two lines (time_iteration should take an optional p0 argument)
    mod = recalibrate(model; K=y[1])

    if improve
        sol = time_iteration(mod; verbose=false, improve=true, T=20, x0=x0)
    else
        sol = time_iteration(mod; verbose=true, improve=false, x0=x0)
    end
    # if !converged(sol)
    #     return NaN
    # end
    
    x = sol.solution

    # p = projection(model, y, z)
    μ = NoLib.ergodic_distribution(mod, x)   # GDist

    z = SVector(mod.calibration.z...)

    a = SVector( equilibrium(mod, μ, x, y; diff=false) ...)

    if return_all
        return (x,μ,a)
    end

    if diff==true
        
        J = f_residuals(mod, μ, x, y; diff=true)
        # return J
        @assert length(y) == 1

        da = ss_residual_J(J, SVector(1.0))[3]

        return a,SMatrix{1,1}(da[1])
    end
    return a

end



function ss_residual_J(J, dy)

    T = J.F._x_1 \ J.F._x_2
    T.M_ij[:] = T.M_ij *(-1.0)

    _x = ( J.F._x_1 \ (J.F._y * dy))* (-1.0)

    dx = _x
    tt = _x
    for i=1:500
        tt = T*tt
        dx = dx + tt
    end

    _μ = (J.G._x*dx) + J.G._y*dy
                
    G_μ = J.G._μ

    dμ = _μ
    mm = _μ
    for i=1:500
        mm = G_μ*mm
        dμ += mm # this is incorrect
    end

    da = (J.A._μ*dμ) + (J.A._x*dx) + (J.A._y*dy)
    
    return dx, dμ, da

end


function find_equilibrium(model; x0=nothing, y0=model.calibration.y, τ_ε=1e-8, verbose=true)


    for it=1:10

        res = ss_residual(model, y0; x0=x0, diff=true)
        println(res)
        a, da = res
        ε = maximum(abs, a)

        verbose ? println("$it : $ε") : nothing

        if ε<τ_ε
            return y0
        end
        
        y0 = y0 - da\a

    end

    throw("We did not find a solution.")

end

####


function f_residuals(model, μ, x, y; diff=false)
    
    z = SVector(model.calibration.z...)

    if diff==false

        p = projection(model, y, z; diff=false)
        r = NoLib.F(model, x, x, p, p; diff=false);
        μ1 = NoLib.G(model, μ, x, p; diff=false)
        a = equilibrium(model, μ, x, y; diff=false)

        return (
            r,
            μ1 - μ,
            a
        )

    else

        p, P_y, P_z = projection(model, SVector(y), SVector(z); diff=true)

        r, J_1, J_2, U_p, V_p = NoLib.F(model, x, x, p, p; diff=true);
        
        # U_y = NoLib.GArray(U_p.grid, [e*P_y for e in U_p.data])
        # V_y = NoLib.GArray(V_p.grid, [e*P_y for e in V_p.data])

        U_y = U_p*P_y
        V_y = V_p*P_y

        U_ = U_y + V_y

        # U = NoLib.LinnMatt(model.grid, x, cat(U_.data...; dims=1))
        U = U_
    
        μ1, G_μ, G_x, G_p = NoLib.G(model, μ, x, p; diff=true)
    
        G_y = NoLib.LinnMatt(G_p.grid, G_p.μ, G_p.P*P_y)
    
        a, A_μ, A_x,  A_y = equilibrium(model, μ, x, SVector(y); diff=true)
        
        return (;
            G=(;_μ=G_μ, _x=G_x, _y=G_y),
            F=(;_x_1=J_1, _x_2=J_2, _y=U),
            A=(;_μ=A_μ, _x=A_x, _y=A_y)
        )
        # (J_1, J_2, U),(G_μ, G_x, G_y),(A_μ, A_x,  A_y))
        
    end

end

ravel(v::SVector{d, Float64}) where d= v[:]

ravel(μ, x, y) = [NoLib.ravel(μ); NoLib.ravel(x); ravel(y)]

function f_residuals(model, v; diff=false, return_res=false)

    N = length(model.grid)
    n_y = length(model.calibration.y)
    n_x = length(model.calibration.x)

    v_μ = v[1:N]
    v_x = v[N+1:end-n_y]
    v_y = v[end-n_y+1: end]

    μ = NoLib.GDist(model.grid, v_μ)
    x = NoLib.GVector(model.grid, reinterpret(SVector{n_x,Float64}, v_x))
    y = SVector(v_y...)

    if diff == false

        r, dμ, a = f_residuals(model, μ, x, y; diff=false)

        return [
            NoLib.ravel(r);
            NoLib.ravel(dμ);
            (a)
        ]

    else

        res = f_residuals(model, μ, x, y; diff=true)

        if return_res
            return res    
        end

        ((J_1, J_2, U),(G_μ, G_x, G_y),(A_μ, A_x,  A_y)) = res

        J_1, J_2, U, G_μ, G_x, G_y, A_μ, A_x, A_y = [convert(Matrix,e) for e in (J_1, J_2, U, G_μ, G_x, G_y, A_μ, A_x, A_y) ]

        return [
            [ (I-G_μ)                              ;;   -G_x     ;;  -G_y];
            [ zeros(size(J_1,1), size(G_μ,2))    ;; (J_1+J_2)  ;;  U];
            [ A_μ                                ;;   A_x      ;;  A_y]
        ]

    end

end
