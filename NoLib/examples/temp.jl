function cpu_fun_(__ctx__, model, r, φ; )

    let 
        model = (KernelAbstractions.constify)(model)
        φ = (KernelAbstractions.constify)(φ)
        Expr(:aliasscope)
        begin

            var"##N#313" = length((KernelAbstractions.__workitems_iterspace)(__ctx__))
            begin
                #= /home/pablo/.julia/packages/KernelAbstractions/DqITC/src/macros.jl:264 =#
                for var"##I#312" = (KernelAbstractions.__workitems_iterspace)(__ctx__)
                    #= /home/pablo/.julia/packages/KernelAbstractions/DqITC/src/macros.jl:265 =#
                    (KernelAbstractions.__validindex)(__ctx__, var"##I#312") || continue
                    #= /home/pablo/.julia/packages/KernelAbstractions/DqITC/src/macros.jl:266 =#
                    c = KernelAbstractions.__index_Global_Cartesian(__ctx__, var"##I#312")
                    n = KernelAbstractions.__index_Global_Linear(__ctx__, var"##I#312")
                    if n==1
                        @show __ctx__
                    end
                    #= /home/pablo/.julia/packages/KernelAbstractions/DqITC/src/macros.jl:267 =#
                    begin
                        (j, i) = c.I
                        s_ = model.grid[i, j]
                        s = ((i, j), s_)
                        x = φ[i, j]
                        rr = x * 0
                        for (w, S) = NoLib.τ(model, s, x)
                            rr += w * NoLib.arbitrage(model, s, x, S, φ(S))
                        end
                        r[i, j] = rr
                    end
                end
            end
        end
        Expr(:popaliasscope)
        return nothing
    end
end

fun_(dev) = fun_(dev, (KernelAbstractions.NDIteration.DynamicSize)(), (KernelAbstractions.NDIteration.DynamicSize)())
fun_(dev, size) = fun_(dev, (KernelAbstractions.NDIteration.StaticSize)(size), (KernelAbstractions.NDIteration.DynamicSize)())
fun_(dev, size, range) = 
fun_(dev, (KernelAbstractions.NDIteration.StaticSize)(size), (KernelAbstractions.NDIteration.StaticSize)(range))

function fun_(dev::Dev, sz::S, range::NDRange) where {Dev, S <: KernelAbstractions.NDIteration._Size, NDRange <: KernelAbstractions.NDIteration._Size}

    if (KernelAbstractions.isgpu)(dev)
        #= /home/pablo/.julia/packages/KernelAbstractions/DqITC/src/macros.jl:58 =#
        return (KernelAbstractions.construct)(dev, sz, range, gpu_fun_)
    else
        println("Building it for the CPU")
        @show dev
        @show sz
        @show range
        return (KernelAbstractions.construct)(dev, sz, range, cpu_fun_)
    end

end
   