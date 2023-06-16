using StaticArrays

function f(x)

    m = zero(MVector{30, Float64})
    m[1] = x
    for i=2:30
        m[i] = m[i-1]*x
    end
    return sum(m)
end

@allocated f(0.1)

using StaticArrays
import NoLib

data = rand(10)
@time prefilter!(data)

data = rand(10)
sdata = MVector(data...)

@time NoLib.splines.prefilter!(sdata)

data_3d = rand(10,10,10)
@time NoLib.splines.prefilter!(data_3d)



# @code_warntype prefilter!(sdata)


# T = eltype(data)
# M = length(data) - 2

# bands = zero(MMatrix{M+2, 3, Float64, M+2*3})
# bb = zero(MVector{M+2, T})

# @time NoLib.splines.fill_bands!(M, bands, bb, data)