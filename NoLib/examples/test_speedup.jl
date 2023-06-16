include("models/rbc.jl")

isbits(model)

using KernelAbstractions

x0 = NoLib.initial_guess(model)
r0 = deepcopy(x0)
φ = NoLib.DFun(model, deepcopy(x0))
r1 = r0*0.0

cpu = CPU()

@time begin NoLib.F!(r1, model, x0, φ); NoLib.norm(r1) end
@time begin NoLib.F!(r1, model, x0, φ, cpu); NoLib.norm(r1) end


df = NoLib.dF_1(model, x0, φ);


@time begin NoLib.dF_1!(df, model, x0, φ); NoLib.norm(r1) end
@time begin NoLib.dF_1!(df, model, x0, φ, cpu); NoLib.norm(r1) end