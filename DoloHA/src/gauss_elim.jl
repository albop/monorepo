function gauss_elimination_residuals(R::Any, J::Any)
    rx = R[1];
    ry = R[2];
    rz = R[3];

    T_x = J.F._x_1 \ J.F._x_2;

    rx = invert_G_μ(rx, J.G._μ);
    rz = rz - J.A._μ * rx;
    ry = NoLib.invert(ry, T_x);
    # ry = T_x \ ry; ## SHOULD GIVE SAME RESULT AS ABOVE
    rz = rz - (J.A._x * ry) + J.A._μ * invert_G_μ(J.G._x * ry, J.G._μ);
    X = build_X(rz, J);
    rz = inv(X) * rz;
    rz = SVector{1}(rz); # Convert to SVector (TO DO, size)
    ry = ry + NoLib.invert(J.F._y * rz, T_x);
    rx = rx + invert_G_μ(J.G._y * rz, J.G._μ);
    rx = rx + invert_G_μ(J.G._x * ry, J.G._μ);

    return (; rx, ry, rz)
end

function invert_G_μ(dr, Gμ; K=1000, τ_η=1e-10)
    oldP = Gμ * dr
    for k=1:K
        newP = Gμ * oldP
        η = maximum(abs.(newP - oldP)) # Change to norm
        if η<τ_η
            break
        end
        oldP = newP
    end
    return oldP
end

# \(Gμ::LinnLatt, r) = invert_G_μ(r, Gμ)

function build_X(y, J)
    T_x = J.F._x_1 \ J.F._x_2;

    # If y contains only 1 element
    if length(y) == 1
        interm = NoLib.invert(J.F._y * y, T_x)
        val = J.A._y * y + J.A._μ * invert_G_μ(J.G._y * y, J.G._μ) + J.A._x * interm + J.A._μ * invert_G_μ(J.G._x * interm, J.G._μ)
        return cat(val; dims=2)
    # If y has a higher dimension
    else
        X = Array{Any}(undef, length(y))
        for (i, e) in enumerate(y)
            interm = NoLib.invert(J.F._y * e, T_x);
            val = J.A._y * e + J.A._μ * invert_G_μ(J.G._y * e, J.G._μ) + J.A._x * interm + J.A._μ * invert_G_μ(J.G._x * interm, J.G._μ)    
            X[i] = val
        end
        X = cat(X; dims=2)
        return X
    end
 end