# import Base: merge

# function merge(a::SLArray, b::SLArray)
#     # TODO: type is incorrect (should correspond to SVector)
#     m = (merge(convert(NamedTuple,a), convert(NamedTuple,b)))
#     return SLVector(m)
# end
# import LabelledArrays: merge

# # type piracy
# function merge(a::SLArray, b::NamedTuple)
#     @assert issubset(keys(b), keys(a))
#     SLVector( (merge(NamedTuple(a), b)) )
# end

# function LVectorLike(m0::SLArray{Tuple{d}, T, 1, d, M}, m) where d where T where M
#     tt = eltype(m)
#     TT = SLArray{Tuple{d}, tt, 1, d, M}
#     return TT(m...)
# end