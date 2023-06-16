using NoLib
using Plots

import NoLib: transition, arbitrage, recalibrate, initial_guess, projection, equilibrium

include("models/consumption_savings.jl")

# check we can solve the model with default calibration

@time sol_iti = NoLib.time_iteration(model; verbose=true, improve=true, T=5);


mem = NoLib.time_iteration_workspace(model)
@time sol = NoLib.time_iteration_4(model, mem; verbose=false, improve=false, T=15);
@time sol_iti = NoLib.time_iteration_4(model, mem; verbose=true, improve=true);


sol = sol_4

x0 = sol.solution
μ0 = NoLib.ergodic_distribution(model, x0)



svec = [e[1] for e in model.grid[1,:]]

pl1 = plot(svec, [e[1] for e in x0[1,:]])
plot!(svec, [e[1] for e in x0[2,:]])
plot!(svec, [e[1] for e in x0[3,:]])

pl2 = plot(svec, [e[1] for e in μ0[1,:]])
plot!(svec, [e[1] for e in μ0[2,:]])
plot!(svec, [e[1] for e in μ0[3,:]])

plot(pl1, pl2)

### find the equilibrium

y0 = model.calibration.y

@time NoLib.NoLib.ss_residual(model, y0; x0=x0);


@time NoLib.NoLib.ss_residual(model, y0; x0=x0, diff=true);

@time ys = NoLib.find_equilibrium(model)



### visualize equilibrium

# plot residuals
kvec = range(30, 80; length=20)
rvec = []

@time NoLib.ss_residual(model, SVector(41.0); diff=true, x0=sol.solution)

using ProgressLogging
@progress for k in kvec
    val = try
        NoLib.ss_residual(model, SVector(k), improve=true; x0=sol.solution, diff=true)
    catch 
        NaN
    end
    push!(rvec, val)
end


#### check
## for some reason there are kinks in that graph

using Plots
plot(kvec, [e[1][1] for e in rvec])
for i=[ e for e in 1:length(rvec) if (e%5==0)]
    x_ = kvec[i]
    y_, c_ = rvec[i]
    scatter!([x_], [y_], color="red")
    plot!(kvec, y_ .+ (kvec.-x_).*c_, color="red", alpha=0.5)
end
scatter!(ys, [0], color="black")
# plot!(kvec, rvec2)
# scatter!(kvec, rvec)
plot!(kvec, kvec*0)


struct IMinus{T}
    m::T
end

import Base: -, \, *
using LinearAlgebra: I, UniformScaling
using NoLib: LF, LinnMatt

-(i::UniformScaling{Bool}, rhs::Union{NoLib.LF, LinnMatt}) = IMinus(rhs)
*(i::IMinus, rhs) = rhs - i.m*rhs


# if invert computes the neumann series, it is a very, very bad name
\(i::IMinus{T}, rhs::GArray) where T <: LF = NoLib.invert(rhs,i.m)
\(i::IMinus{T}, rhs::GArray) where T <: LinnMatt = NoLib.invert_G_μ(rhs, i.m)

*(a::LinnMatt, rhs::SLArray) = a*SVector(rhs...)
*(a::LinnMatt, rhs::Vector) = a*SVector(rhs...)   ## that one we should not use (because it allocates)



# TODO: check the results are actually correct


### 
### steady-state jacobian

# U = NoLib.f_residuals(model, μ0, x0, y0; diff=true);

J = NoLib.f_residuals(model, μ0, x0, y0; diff=true);


T = J.F._x_1 \ J.F._x_2

# TODO: check the following is correct
(I-T) \ x0
(I-J.G._μ) \ μ0


# TODO: maybe do the next steps using the following

# JJ = (;
#     T=(;
#         _x = J.F._x_1 \ J.F._x_2,
#         _y = J.F._x_1 \ J.F._y
#     ),
#     G=J.G,
#     A=J.A
# )

# # or even the following to save on the (I-T, I-G) expressions
# JJJ = (;
#     T=(;
#         _x = I-J.F._x_1 \ J.F._x_2,
#         _y = J.F._x_1 \ J.F._y
#     ),
#     G=(;
#         _μ=I-J.G_μ,
#         _x=J.G_x,
#         _y=J.G_y,
#     ),
#     A=J.A
# )



function gauss_elimination(J, μ0, x0, y0)

    ## TEST Gauss elimination
    # NoLib.gauss_elimination_residuals(R, J)
    # R = [μ0, x0, y0];

    function build_X(y, J)
        
        T_x = J.F._x_1 \ J.F._x_2;

        # If y contains only 1 element
        if length(y) == 1
            J.F._y * y

            interm = T_x \ (J.F._y * y)
            val = J.A._y * y + J.A._μ * ((I - J.G._μ) \ (J.G._y * y)) + J.A._x * interm + J.A._μ * ( (I - J.G._μ) \ (J.G._x * interm) )
            return SMatrix{1,1}(val...)
            # If y has a higher dimension
        else
            X = Array{Any}(undef, length(y))
            for (i, e) in enumerate(y)
                interm = (I-T_x) \ (J.F._y * e);
                # val = J.A._y * e + J.A._μ * NoLib.invert_G_μ(J.G._y * e, J.G._μ) + J.A._x * interm + J.A._μ * NoLib.invert_G_μ(J.G._x * interm, J.G._μ)    
                val = J.A._y +  J.A._μ * ((I - J.G._μ) \ (J.G._y * y)) + J.A._x * interm + J.A._μ * ( (I - J.G._μ) \ (J.G._x * interm) )
                X[i] = val
            end
            # TODO check this is correct
            p = length(X)
            X = cat(X; dims=2)
            return SMatrix{p,p}(X)
        end
        # return X
    end

    rx = deepcopy(μ0)
    ry = deepcopy(x0);
    rz = deepcopy(y0);

    T_x = J.F._x_1 \ J.F._x_2;

    rx = (I-J.G._μ) \ rx;
    rz = rz - J.A._μ * rx;
    ry = (I-T_x) \ ry;
    rz = rz - (J.A._x * ry) + J.A._μ * ((I-J.G._μ) \ (J.G._x * ry));
    


    X = build_X(rz, J);
    # rz = inv(X) * rz; # if calculations are correct, we don't need to invert
    rz = X \ rz

    # rz = SVector{1}(rz);
    ry = ry + (I-T_x) \ (J.F._y * rz);
    rx = rx + (I-J.G._μ) \ (J.G._y * rz);
    rx = rx + (I-J.G._μ) \ (J.G._x * ry);

    return (rx, ry, rz)


end


(x,y,z) = gauss_elimination(J, μ0, x0, y0)


## check result is correct

function jacmult(J, μ0, x0, y0)

    # maybe we should keep T_x in the jacobian
    T_x = J.F._x_1 \ J.F._x_2;

    r_x = (I-J.G._μ)*μ0 +  J.G._x * x0 +  J.G._y * y0 
    r_y =                 (I-T_x) * x0 +  J.F._y * y0 
    r_z =   (J.A._μ)*μ0 +  J.A._x * x0 +  J.A._y * y0 

    return (r_x, r_y, r_z)

end


μ1, x1, y1 = jacmult(J, x, y, z)

# right now it looks like the following is not zero

maximum(abs, μ0 - μ1)
NoLib.norm(x0 - x1)
maximum(abs, y0 - y1)