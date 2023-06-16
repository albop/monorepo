using NoLib

model = include("models/rbc.jl")


@time mem = NoLib.time_iteration_workspace(model);
@time begin NoLib.time_iteration(model, mem; verbose=false, interp_mode=:cubic) end;

@time mem = NoLib.time_iteration_workspace(model);
@time begin NoLib.time_iteration(model, mem; verbose=false, interp_mode=:cubic) end;

@time mem = NoLib.time_iteration_workspace(model);
@time begin NoLib.time_iteration(model, mem; improve=true, verbose=false, interp_mode=:cubic) end;


@time mem = NoLib.newton_workspace(model);
@time NoLib.newton(model, mem; verbose=false, interp_mode=:cubic);

x0 = mem.x0
φ= mem.φ

@code_warntype NoLib.dF_2!(Tp, model, x0, φ)


@time NoLib.dF_2!(Tp, model, x0, φ)

@time NoLib.dF_2(model, x0, φ)

@code_warntype NoLib.dF_2!(Tp, model, mem.x0, mem.φ)


J= NoLib.dF_1(model, x0, φ)
T= NoLib.dF_2(model, x0, φ)


function (f(T,J))
    T.M_ij .= J.data .\ T.M_ij ;
end
@time T.M_ij .= J.data .\ T.M_ij ;
@time f(T,J);



function mult!(res, T,r)
    NoLib.mul!(res,T,r)
end

@time mult!(out, Tp, r0);
# out =  mult(Tp,r0);


NoLib.neumann!(out, Tp, r0; K=1000)

@time out = NoLib.neumann(Tp, r0; K=10000)

NoLib.norm( out-Tp*out - r0 )

mem = (;du=deepcopy(r0), dv=deepcopy(r0))

using BenchmarkTools
@benchmark NoLib.neumann!(out, Tp, r0, mem; K=1000)
@benchmark NoLib.neumann(Tp, r0; K=1000)


    
@time mem = NoLib.time_iteration_workspace(model);
@time begin NoLib.time_iteration(model, mem; verbose=false, interp_mode=:cubic, engine=:cpu) end;
    

    
@time mem = NoLib.time_iteration_workspace(model);
@time begin NoLib.time_iteration(model, mem; verbose=false, interp_mode=:linear) end;
        
@time mem = NoLib.time_iteration_workspace(model);
@time begin NoLib.time_iteration(model, mem; verbose=false, interp_mode=:linear, engine=:cpu) end;


@code_warntype NoLib.time_iteration(model, mem; verbose=false, interp_mode=:linear, engine=:cpu);

        


@time mem = NoLib.time_iteration_workspace(model);
@profview begin NoLib.time_iteration(model, mem; verbose=false, interp_mode=:cubic, engine=:cpu) end;
    
    
    
@time mem = NoLib.time_iteration_workspace(model);
@time NoLib.time_iteration(model, mem; verbose=true, improve=true) ;


@time begin NoLib.time_iteration(model; verbose=true, improve=true) end


@time begin NoLib.time_iteration(model; verbose=false) end
@time begin NoLib.time_iteration(model; verbose=true, interp_mode=:cubic) end
@time begin NoLib.time_iteration(model; verbose=true, interp_mode=:linear) end



@time begin NoLib.time_iteration(model; verbose=false, interp_mode=:linear) end;
@time begin NoLib.time_iteration(model; verbose=false, interp_mode=:cubic) end;


@time begin NoLib.time_iteration(model; improve=true, verbose=false, interp_mode=:linear) end

@time begin NoLib.time_iteration(model; improve=true, verbose=false, interp_mode=:cubic) end


@time mem = NoLib.time_iteration_workspace(model);
@time begin NoLib.time_iteration(model, mem; verbose=false, T=5) end;
@time begin NoLib.time_iteration(model, mem; verbose=false, improve=true) end;


@time mem = NoLib.time_iteration_workspace(model);
@time sol = begin NoLib.time_iteration(model, mem; verbose=false, T=10, interp_mode=:cubic) end;


@time mem = NoLib.time_iteration_workspace(model);

@time begin NoLib.time_iteration_4(model, mem; verbose=false) end





mem = NoLib.time_iteration_workspace(model, interp_mode=:cubic);
@time sol = begin NoLib.time_iteration(model, mem; verbose=false) end;

mem = NoLib.time_iteration_workspace(model, interp_mode=:linear);
@time sol = begin NoLib.time_iteration(model, mem; verbose=false) end;
    

# @time sol = begin NoLib.time_iteration(model, mem; improve=true, verbose=false) end;

@time mem = NoLib.time_iteration_workspace(model, interp_mode=:cubic);
@time sol = NoLib.time_iteration(model, mem);
    
@time mem = NoLib.time_iteration_workspace(model, interp_mode=:cubic);
@time sol = NoLib.time_iteration(model, mem; improve=true);

@time mem = NoLib.time_iteration_workspace(model, interp_mode=:linear);
@time sol = NoLib.time_iteration(model, mem);
    

@time mem = NoLib.time_iteration_workspace(model, interp_mode=:linear);
@time sol = NoLib.time_iteration(model, mem; improve=true);



x0 = sol.solution
φ = NoLib.DFun(model, x0; interp_mode=:cubic)

typeof(φ)
typeof(φ.itp)

f(φ, x0) = begin NoLib.fit!(φ, x0); nothing end

@time f(φ, x0)

r0 = deepcopy(x0)

@time NoLib.F!(r0, model, x0, φ)

J0 = NoLib.dF_1(model, x0, φ)

@time NoLib.dF_1!(J0, model, x0, φ);

