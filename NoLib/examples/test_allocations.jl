include("models/consumption_savings_ayiagari.jl")


φ = GVector(model.grid, [Iterators.repeated(SVector(model.calibration.x), length(model.grid))...])
r = deepcopy(φ)



function check_indexing(model, φ)
    r = sum( model.grid[i][2] for i=1:length(model.grid) )
    if r<0.0
        return 1.0
    else
        return 
    end
end

@time check_indexing(model, φ);
@allocated check_indexing(model, φ)

function check_cover()
    a = SVector(1.0, 2.0, 3.0, 4.0)
    m = SVector(0.0, 0.0)
    c = NoLib.cover(m,a)
    sum(c)
end

@time check_cover()
@allocated check_cover()

function compute_transition(model, φ)
    i = 1
    s = ((1,1),(model.grid[1]))
    r = sum(s for (w,(i,s)) in NoLib.τ(model, s, φ))
    e = sum(r)
    if e<-1.0
        return true
    else
        return
    end
end

# check whether model equations allocate

function eqs_(model)
    s0 = ((1,1),(model.grid[1]))
    x0 = SVector(model.calibration.x...)
    NoLib.arbitrage(model, s0, x0, s0, x0)
end

@time eqs_(model);

function compute_res_(model, φ)
    s0 = ((1,1),(model.grid[1]))
    x0 = SVector(model.calibration.x...)
    NoLib.F(model, s0, x0, φ)
end

@time compute_res_( model, φ);

function compute_res!(r, model, φ)
    NoLib.F!(r, model, φ, φ)
end

function compute_res_2!(r, model, φ)
    x = model.calibration.x

    for (i,s) in NoLib.enum(model.grid)
        x = φ[i...]
        r[i...] = NoLib.F(model, (i,s), x, φ)
    end
end


@time compute_transition(model, φ);


@time compute_res!(r, model, φ)

@time compute_res_2!(r, model, φ)

@assert (@allocated compute_res!(r, model, φ)) == 0
@assert (@allocated compute_res_2!(r, model, φ)) == 0
