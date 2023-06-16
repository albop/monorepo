define void @julia_cpu_fun__4132({ [1 x [2 x i64]], [1 x [2 x [1 x i64]]], { [1 x [2 x [1 x i64]]] } }* nocapture nonnull readonly align 8 dereferenceable(48) %0, { { [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [4 x double] }, { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x [4 x double]] }* nocapture nonnull readonly align 8 dereferenceable(128) %1, { { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, {}* }* nocapture nonnull readonly align 8 dereferenceable(48) %2, { { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, {}* }* nocapture nonnull readonly align 8 dereferenceable(48) %3) #0 {
L7.outer:
  %4 = alloca {}*, align 8
  %gcframe455 = alloca [6 x {}*], align 16
  %gcframe455.sub = getelementptr inbounds [6 x {}*], [6 x {}*]* %gcframe455, i64 0, i64 0
  %5 = bitcast [6 x {}*]* %gcframe455 to i8*
  call void @llvm.memset.p0i8.i32(i8* noundef nonnull align 16 dereferenceable(48) %5, i8 0, i32 48, i1 false)
  %6 = getelementptr inbounds [6 x {}*], [6 x {}*]* %gcframe455, i64 0, i64 3
  %7 = getelementptr inbounds [6 x {}*], [6 x {}*]* %gcframe455, i64 0, i64 2
  %8 = alloca [1 x [1 x double]], align 8
  %9 = alloca { { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x {}*] }, align 8
  %10 = alloca [1 x [1 x [1 x double]]], align 8
  %11 = alloca [1 x [1 x [1 x double]]], align 8
  %12 = alloca [1 x [1 x [1 x double]]], align 8
  %13 = alloca [1 x [1 x [1 x double]]], align 8
  %14 = alloca [1 x [1 x [1 x double]]], align 8
  %15 = alloca [1 x [1 x [1 x double]]], align 8
  %thread_ptr = call i8* asm "movq %fs:0, $0", "=r"() #6
  %ppgcstack_i8 = getelementptr i8, i8* %thread_ptr, i64 -8
  %ppgcstack = bitcast i8* %ppgcstack_i8 to {}****
  %pgcstack = load {}***, {}**** %ppgcstack, align 8
;  @ /home/pablo/Econforge/NoLib/examples/temp.jl:5 within `cpu_fun_`
; ┌ @ /home/pablo/.julia/packages/KernelAbstractions/DqITC/src/KernelAbstractions.jl:332 within `constify`
; │┌ @ /home/pablo/.julia/packages/Adapt/LAQOx/src/Adapt.jl:40 within `adapt`
; ││┌ @ /home/pablo/.julia/packages/Adapt/LAQOx/src/macro.jl:11 within `adapt_structure`
; │││┌ @ Base.jl:38 within `getproperty`
      %16 = bitcast [6 x {}*]* %gcframe455 to i64*
      store i64 16, i64* %16, align 16
      %17 = getelementptr inbounds [6 x {}*], [6 x {}*]* %gcframe455, i64 0, i64 1
      %18 = bitcast {}** %17 to {}***
      %19 = load {}**, {}*** %pgcstack, align 8
      store {}** %19, {}*** %18, align 8
      %20 = bitcast {}*** %pgcstack to {}***
      store {}** %gcframe455.sub, {}*** %20, align 8
      %21 = getelementptr inbounds { { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, {}* }, { { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, {}* }* %3, i64 0, i32 1
      %22 = load atomic {}*, {}** %21 unordered, align 8
; │││└
; │││┌ @ /home/pablo/Econforge/NoLib/src/garray.jl:4 within `GArray` @ /home/pablo/Econforge/NoLib/src/garray.jl:4
      %23 = bitcast { { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, {}* }* %3 to <4 x double>*
      %24 = load <4 x double>, <4 x double>* %23, align 8
      %.unpack150.unpack.unpack.elt164 = getelementptr inbounds { { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, {}* }, { { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, {}* }* %3, i64 0, i32 0, i32 1, i64 0, i64 0, i32 2
      %.unpack150.unpack.unpack.unpack165 = load i64, i64* %.unpack150.unpack.unpack.elt164, align 8
; └└└└
;  @ /home/pablo/Econforge/NoLib/examples/temp.jl:6 within `cpu_fun_`
; ┌ @ boot.jl:263 within `Expr`
   store {}* inttoptr (i64 140505460990392 to {}*), {}** %4, align 8
   %25 = call nonnull {}* @jl_f__expr({}* null, {}** nonnull %4, i32 1)
   %26 = getelementptr inbounds { [1 x [2 x i64]], [1 x [2 x [1 x i64]]], { [1 x [2 x [1 x i64]]] } }, { [1 x [2 x i64]], [1 x [2 x [1 x i64]]], { [1 x [2 x [1 x i64]]] } }* %0, i64 0, i32 0, i64 0, i64 0
   %27 = load i64, i64* %26, align 8
   %28 = shl i64 %27, 3
   %29 = getelementptr inbounds { [1 x [2 x i64]], [1 x [2 x [1 x i64]]], { [1 x [2 x [1 x i64]]] } }, { [1 x [2 x i64]], [1 x [2 x [1 x i64]]], { [1 x [2 x [1 x i64]]] } }* %0, i64 0, i32 0, i64 0, i64 1
   %30 = load i64, i64* %29, align 8
   %31 = getelementptr inbounds { [1 x [2 x i64]], [1 x [2 x [1 x i64]]], { [1 x [2 x [1 x i64]]] } }, { [1 x [2 x i64]], [1 x [2 x [1 x i64]]], { [1 x [2 x [1 x i64]]] } }* %0, i64 0, i32 1, i64 0, i64 0, i64 0
   %32 = load i64, i64* %31, align 8
   %33 = getelementptr inbounds { [1 x [2 x i64]], [1 x [2 x [1 x i64]]], { [1 x [2 x [1 x i64]]] } }, { [1 x [2 x i64]], [1 x [2 x [1 x i64]]], { [1 x [2 x [1 x i64]]] } }* %0, i64 0, i32 1, i64 0, i64 1, i64 0
   %34 = load i64, i64* %33, align 8
   %35 = icmp sgt i64 %32, 0
   %36 = select i1 %35, i64 %32, i64 0
   %37 = getelementptr inbounds { { [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [4 x double] }, { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x [4 x double]] }, { { [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [4 x double] }, { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x [4 x double]] }* %1, i64 0, i32 1, i32 1, i64 0, i64 0, i32 0
   %38 = getelementptr inbounds { { [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [4 x double] }, { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x [4 x double]] }, { { [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [4 x double] }, { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x [4 x double]] }* %1, i64 0, i32 1, i32 1, i64 0, i64 0, i32 1
   %39 = getelementptr inbounds { { [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [4 x double] }, { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x [4 x double]] }, { { [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [4 x double] }, { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x [4 x double]] }* %1, i64 0, i32 1, i32 1, i64 0, i64 0, i32 2
   %40 = bitcast {}* %22 to { i8*, i64, i16, i16, i32 }*
   %41 = getelementptr inbounds { i8*, i64, i16, i16, i32 }, { i8*, i64, i16, i16, i32 }* %40, i64 0, i32 1
   %42 = bitcast {}* %22 to [1 x [1 x double]]**
   %43 = getelementptr inbounds { { [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [4 x double] }, { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x [4 x double]] }, { { [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [4 x double] }, { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x [4 x double]] }* %1, i64 0, i32 1, i32 0, i64 0
   %44 = getelementptr inbounds { { [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [4 x double] }, { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x [4 x double]] }, { { [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [4 x double] }, { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x [4 x double]] }* %1, i64 0, i32 0, i32 3, i64 3
   %.not169 = icmp eq [1 x [2 x [1 x [1 x double]]]]* %43, null
   %.sroa.0128.0..sroa_idx = getelementptr inbounds { { [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [4 x double] }, { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x [4 x double]] }, { { [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [4 x double] }, { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x [4 x double]] }* %1, i64 0, i32 1, i32 0, i64 0, i64 0, i64 0, i64 0, i64 0
   %.sroa.0133.0..sroa_idx = getelementptr inbounds [1 x [1 x double]], [1 x [1 x double]]* %8, i64 0, i64 0, i64 0
   %.fca.0.1.0.0.2.gep = getelementptr inbounds { { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x {}*] }, { { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x {}*] }* %9, i64 0, i32 0, i32 1, i64 0, i64 0, i32 2
   %.fca.1.0.gep = getelementptr inbounds { { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x {}*] }, { { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x {}*] }* %9, i64 0, i32 1, i64 0
   %45 = getelementptr inbounds { { [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [4 x double] }, { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x [4 x double]] }, { { [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [4 x double] }, { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x [4 x double]] }* %1, i64 0, i32 0, i32 3
   %.sroa.0124.0..sroa_idx = getelementptr inbounds [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]]* %10, i64 0, i64 0, i64 0, i64 0
   %.sroa.0122.0..sroa_idx = getelementptr inbounds [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]]* %11, i64 0, i64 0, i64 0, i64 0
   %.sroa.0120.0..sroa_idx = getelementptr inbounds [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]]* %12, i64 0, i64 0, i64 0, i64 0
   %.sroa.0118.0..sroa_idx = getelementptr inbounds [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]]* %13, i64 0, i64 0, i64 0, i64 0
   %.sroa.0116.0..sroa_idx = getelementptr inbounds [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]]* %14, i64 0, i64 0, i64 0, i64 0
   %.sroa.0114.0..sroa_idx = getelementptr inbounds [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]]* %15, i64 0, i64 0, i64 0, i64 0
   %46 = getelementptr inbounds { { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, {}* }, { { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, {}* }* %2, i64 0, i32 1
   %47 = icmp sgt i64 %30, 0
   %48 = icmp sle i64 %30, %34
   %49 = and i1 %47, %48
   %50 = add i64 %30, -1
   %51 = mul i64 %36, %50
   %52 = icmp ult i64 %50, 2
   %53 = load i64, i64* %39, align 8
   %54 = add i64 %53, -1
   %55 = sitofp i64 %54 to double
   %56 = load double, double* %38, align 8
   %57 = load double, double* %37, align 8
   %58 = fsub double %56, %57
   %59 = getelementptr inbounds { { [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [4 x double] }, { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x [4 x double]] }, { { [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [4 x double] }, { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x [4 x double]] }* %1, i64 0, i32 1, i32 0, i64 0, i64 0, i64 %50, i64 0, i64 0
   %60 = add i64 %30, -2
   %61 = getelementptr inbounds { { [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [4 x double] }, { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x [4 x double]] }, { { [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [4 x double] }, { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x [4 x double]] }* %1, i64 0, i32 2, i64 0, i64 %50
   %62 = load double, double* %44, align 8
   %63 = fsub double 1.000000e+00, %62
   %.not168 = icmp eq double* %61, null
   %64 = load atomic {}*, {}** %46 unordered, align 8
   %65 = bitcast {}* %64 to { i8*, i64, i16, i16, i32 }*
   %66 = getelementptr inbounds { i8*, i64, i16, i16, i32 }, { i8*, i64, i16, i16, i32 }* %65, i64 0, i32 1
   %67 = bitcast {}* %64 to [1 x [1 x double]]**
; └
;  @ /home/pablo/Econforge/NoLib/examples/temp.jl:14 within `cpu_fun_`
  br label %L7

L7:                                               ; preds = %L320, %L7.outer
  %.sroa.0128.0 = phi double [ %.sroa.0128.2, %L320 ], [ undef, %L7.outer ]
  %value_phi = phi i64 [ %78, %L320 ], [ 1, %L7.outer ]
; ┌ @ /home/pablo/.julia/packages/KernelAbstractions/DqITC/src/cpu.jl:196 within `__validindex`
; │┌ @ /home/pablo/.julia/packages/KernelAbstractions/DqITC/src/nditeration.jl:74 within `expand`
; ││┌ @ ntuple.jl:49 within `ntuple`
; │││┌ @ /home/pablo/.julia/packages/KernelAbstractions/DqITC/src/nditeration.jl:78 within `#1`
; ││││┌ @ int.jl:88 within `*`
       %68 = add nsw i64 %value_phi, -8
; ││││└
; ││││┌ @ int.jl:87 within `+`
       %69 = add i64 %68, %28
; │└└└└
; │ @ /home/pablo/.julia/packages/KernelAbstractions/DqITC/src/cpu.jl:197 within `__validindex`
; │┌ @ multidimensional.jl:469 within `in`
; ││┌ @ tuple.jl:247 within `map`
; │││┌ @ range.jl:1409 within `in`
; ││││┌ @ int.jl:481 within `<=`
       %70 = icmp sgt i64 %69, 0
       %71 = icmp sle i64 %69, %32
; ││││└
; ││││┌ @ bool.jl:38 within `&`
       %72 = and i1 %70, %71
; ││└└└
; ││┌ @ tuple.jl:515 within `all`
; │││┌ @ bool.jl:38 within `&`
      %73 = and i1 %72, %49
; └└└└
  br i1 %73, label %L42, label %L320

L42:                                              ; preds = %L7
;  @ /home/pablo/Econforge/NoLib/examples/temp.jl:17 within `cpu_fun_`
; ┌ @ /home/pablo/.julia/packages/KernelAbstractions/DqITC/src/cpu.jl:178 within `__index_Global_Linear`
; │┌ @ abstractarray.jl:1241 within `getindex`
; ││┌ @ abstractarray.jl:1274 within `_getindex`
; │││┌ @ abstractarray.jl:1280 within `_to_linear_index`
; ││││┌ @ abstractarray.jl:2634 within `_sub2ind` @ abstractarray.jl:2650
; │││││┌ @ abstractarray.jl:2666 within `_sub2ind_recurse` @ abstractarray.jl:2666
; ││││││┌ @ int.jl:87 within `+`
         %74 = add i64 %69, %51
; └└└└└└└
;  @ /home/pablo/Econforge/NoLib/examples/temp.jl:18 within `cpu_fun_`
; ┌ @ promotion.jl:477 within `==`
   %.not = icmp eq i64 %74, 1
; └
  br i1 %.not, label %L131, label %L133

L131:                                             ; preds = %L42
  %75 = getelementptr inbounds [6 x {}*], [6 x {}*]* %gcframe455, i64 0, i64 5
  store {}* %64, {}** %75, align 8
;  @ /home/pablo/Econforge/NoLib/examples/temp.jl:19 within `cpu_fun_`
; ┌ @ strings/io.jl:282 within `repr`
; │┌ @ strings/io.jl:282 within `#repr#455`
; ││┌ @ strings/io.jl:107 within `sprint##kw`
     %76 = call nonnull {}* @"j_#sprint#452_4134"(i64 signext 0, {}* readonly inttoptr (i64 140505217222992 to {}*), { [1 x [2 x i64]], [1 x [2 x [1 x i64]]], { [1 x [2 x [1 x i64]]] } }* nocapture nonnull readonly %0) #0
     %77 = getelementptr inbounds [6 x {}*], [6 x {}*]* %gcframe455, i64 0, i64 4
     store {}* %76, {}** %77, align 16
; └└└
  call void @j_println_4135({}* inttoptr (i64 140503379559248 to {}*), {}* nonnull %76) #0
  br label %L133

L133:                                             ; preds = %L131, %L42
;  @ /home/pablo/Econforge/NoLib/examples/temp.jl:24 within `cpu_fun_`
; ┌ @ /home/pablo/Econforge/NoLib/src/grids.jl:59 within `getindex` @ /home/pablo/Econforge/NoLib/src/grids.jl:44 @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/SArray.jl:62 @ tuple.jl:29
   br i1 %52, label %pass, label %fail

L320:                                             ; preds = %idxend26, %L7
   %.sroa.0128.2 = phi double [ %.sroa.0128.0, %L7 ], [ %.sroa.0102.0.copyload105, %idxend26 ]
; └
;  @ /home/pablo/Econforge/NoLib/examples/temp.jl:33 within `cpu_fun_`
; ┌ @ multidimensional.jl:404 within `iterate`
; │┌ @ multidimensional.jl:428 within `__inc`
; ││┌ @ int.jl:87 within `+`
     %78 = add nuw nsw i64 %value_phi, 1
; ││└
; ││ @ multidimensional.jl:429 within `__inc`
    %exitcond = icmp eq i64 %78, 9
    br i1 %exitcond, label %L369, label %L7

L369:                                             ; preds = %L320
; └└
;  @ /home/pablo/Econforge/NoLib/examples/temp.jl:36 within `cpu_fun_`
; ┌ @ boot.jl:263 within `Expr`
   store {}* inttoptr (i64 140505460990344 to {}*), {}** %4, align 8
   %79 = call nonnull {}* @jl_f__expr({}* null, {}** nonnull %4, i32 1)
   %80 = load {}*, {}** %17, align 8
   %81 = bitcast {}*** %pgcstack to {}**
   store {}* %80, {}** %81, align 8
; └
;  @ /home/pablo/Econforge/NoLib/examples/temp.jl:37 within `cpu_fun_`
  ret void

fail:                                             ; preds = %L133
;  @ /home/pablo/Econforge/NoLib/examples/temp.jl:24 within `cpu_fun_`
; ┌ @ Base.jl:38 within `getproperty`
   %82 = getelementptr inbounds { { [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [4 x double] }, { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x [4 x double]] }, { { [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [4 x double] }, { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x [4 x double]] }* %1, i64 0, i32 1
; └
; ┌ @ /home/pablo/Econforge/NoLib/src/grids.jl:59 within `getindex` @ /home/pablo/Econforge/NoLib/src/grids.jl:44 @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/SArray.jl:62 @ tuple.jl:29
   %83 = bitcast { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }* %82 to i8*
   call void @ijl_bounds_error_unboxed_int(i8* %83, {}* nonnull inttoptr (i64 140505438097728 to {}*), i64 %30)
   unreachable

pass:                                             ; preds = %L133
; │ @ /home/pablo/Econforge/NoLib/src/grids.jl:59 within `getindex` @ /home/pablo/Econforge/NoLib/src/grids.jl:123
; │┌ @ int.jl:97 within `/`
; ││┌ @ float.jl:269 within `float`
; │││┌ @ float.jl:243 within `AbstractFloat`
; ││││┌ @ float.jl:146 within `Float64`
       %84 = sitofp i64 %69 to double
; ││└└└
; ││ @ int.jl:97 within `/` @ float.jl:386
    %85 = fdiv double %84, %55
; │└
; │┌ @ float.jl:385 within `*`
    %86 = fmul double %85, %58
; │└
; │┌ @ float.jl:383 within `+`
    %87 = fadd double %57, %86
; └└
;  @ /home/pablo/Econforge/NoLib/examples/temp.jl:26 within `cpu_fun_`
; ┌ @ /home/pablo/Econforge/NoLib/src/garray.jl:20 within `getindex`
; │┌ @ int.jl:88 within `*`
    %88 = shl nuw i64 %69, 1
; │└
; │┌ @ int.jl:87 within `+`
    %89 = add i64 %60, %88
; │└
; │ @ /home/pablo/Econforge/NoLib/src/garray.jl:20 within `getindex` @ experimental.jl:32
   %90 = add i64 %89, -1
   %91 = load i64, i64* %41, align 8
   %92 = icmp ult i64 %90, %91
   br i1 %92, label %pass11, label %oob

oob:                                              ; preds = %pass
   %93 = alloca i64, align 8
   store i64 %89, i64* %93, align 8
   call void @ijl_bounds_error_ints({}* %22, i64* nonnull %93, i64 1)
   unreachable

pass11:                                           ; preds = %pass
   %94 = load [1 x [1 x double]]*, [1 x [1 x double]]** %42, align 8
   %95 = getelementptr inbounds [1 x [1 x double]], [1 x [1 x double]]* %94, i64 %90, i64 0, i64 0
   %.unpack.unpack = load double, double* %95, align 8
; └
;  @ /home/pablo/Econforge/NoLib/examples/temp.jl:27 within `cpu_fun_`
; ┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/linalg.jl:22 within `*`
; │┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/mapreduce.jl:31 within `map`
; ││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/mapreduce.jl:40 within `_map`
; │││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/mapreduce.jl:75 within `macro expansion`
; ││││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/linalg.jl:22 within `#266`
; │││││┌ @ promotion.jl:389 within `*` @ float.jl:385
        %96 = fmul double %.unpack.unpack, 0.000000e+00
; └└└└└└
;  @ /home/pablo/Econforge/NoLib/examples/temp.jl:28 within `cpu_fun_`
; ┌ @ generator.jl:47 within `iterate`
; │┌ @ none within `#23`
; ││┌ @ /home/pablo/Econforge/NoLib/src/model.jl:37 within `transition` @ /home/pablo/Econforge/NoLib/examples/neoclassical_model.jl:48
; │││┌ @ float.jl:385 within `*`
      %97 = fmul double %87, %63
; │││└
; │││┌ @ float.jl:383 within `+`
      %98 = fadd double %.unpack.unpack, %97
      br i1 %.not168, label %pass47, label %guard_pass53

oob25:                                            ; preds = %guard_pass85
; └└└└
;  @ /home/pablo/Econforge/NoLib/examples/temp.jl:31 within `cpu_fun_`
; ┌ @ /home/pablo/Econforge/NoLib/src/garray.jl:28 within `setindex!` @ array.jl:966
   %99 = alloca i64, align 8
   store i64 %89, i64* %99, align 8
   call void @ijl_bounds_error_ints({}* %64, i64* nonnull %99, i64 1)
   unreachable

idxend26:                                         ; preds = %guard_pass85
; └
;  @ /home/pablo/Econforge/NoLib/examples/temp.jl:29 within `cpu_fun_`
; ┌ @ /home/pablo/Econforge/NoLib/src/model.jl:54 within `arbitrage` @ /home/pablo/Econforge/NoLib/src/model.jl:48
   %.fca.0.0.0.extract.1 = extractvalue [1 x [1 x [1 x double]]] %118, 0, 0, 0
; └
; ┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/linalg.jl:21 within `*`
; │┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/mapreduce.jl:31 within `map`
; ││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/mapreduce.jl:40 within `_map`
; │││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/mapreduce.jl:75 within `macro expansion`
; ││││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/linalg.jl:21 within `#264`
; │││││┌ @ float.jl:385 within `*`
        %100 = fmul double %116, %.fca.0.0.0.extract.1
; └└└└└└
; ┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/linalg.jl:12 within `+`
; │┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/mapreduce.jl:37 within `map`
; ││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/mapreduce.jl:40 within `_map`
; │││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/mapreduce.jl:75 within `macro expansion`
; ││││┌ @ float.jl:383 within `+`
       %101 = fadd double %111, %100
; └└└└└
;  @ /home/pablo/Econforge/NoLib/examples/temp.jl:31 within `cpu_fun_`
; ┌ @ /home/pablo/Econforge/NoLib/src/garray.jl:28 within `setindex!` @ array.jl:966
   %102 = load [1 x [1 x double]]*, [1 x [1 x double]]** %67, align 8
   %103 = getelementptr inbounds [1 x [1 x double]], [1 x [1 x double]]* %102, i64 %90, i64 0, i64 0
   store double %101, double* %103, align 8
   br label %L320

pass47:                                           ; preds = %guard_pass53, %pass11
   %104 = phi double [ undef, %pass11 ], [ %114, %guard_pass53 ]
   %.sroa.0128.0.copyload = load double, double* %.sroa.0128.0..sroa_idx, align 8
   %.sroa.0128.3 = select i1 %.not169, double %.sroa.0128.0, double %.sroa.0128.0.copyload
; └
;  @ /home/pablo/Econforge/NoLib/examples/temp.jl:28 within `cpu_fun_`
  store double %98, double* %.sroa.0133.0..sroa_idx, align 8
;  @ /home/pablo/Econforge/NoLib/examples/temp.jl:29 within `cpu_fun_`
; ┌ @ /home/pablo/Econforge/NoLib/src/garray.jl:66 within `GArray`
   %105 = bitcast { { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x {}*] }* %9 to <4 x double>*
   store <4 x double> %24, <4 x double>* %105, align 8
   store i64 %.unpack150.unpack.unpack.unpack165, i64* %.fca.0.1.0.0.2.gep, align 8
   store {}* %22, {}** %7, align 16
   store {}* %22, {}** %.fca.1.0.gep, align 8
   %106 = getelementptr inbounds [6 x {}*], [6 x {}*]* %gcframe455, i64 0, i64 5
   store {}* %64, {}** %106, align 8
   %107 = call [1 x [1 x double]] @j_GArray_4136({ { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x {}*] }* nocapture readonly %9, i64 signext 1, [1 x [1 x double]]* nocapture readonly %8) #0
   %.fca.0.0.extract = extractvalue [1 x [1 x double]] %107, 0, 0
; └
; ┌ @ /home/pablo/Econforge/NoLib/src/model.jl:54 within `arbitrage` @ /home/pablo/Econforge/NoLib/src/model.jl:42
; │┌ @ /home/pablo/Econforge/NoLib/src/model.jl:27 within `LVectorLike`
; ││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/convert.jl:160 within `StaticArray`
     %108 = load double, double* %59, align 8
; │││┌ @ /home/pablo/.julia/packages/LabelledArrays/QY8rm/src/slarray.jl:23 within `SLArray`
      store double %108, double* %.sroa.0124.0..sroa_idx, align 8
; │└└└
; │ @ /home/pablo/Econforge/NoLib/src/model.jl:54 within `arbitrage` @ /home/pablo/Econforge/NoLib/src/model.jl:43
; │┌ @ /home/pablo/Econforge/NoLib/src/model.jl:27 within `LVectorLike`
; ││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/convert.jl:160 within `StaticArray`
; │││┌ @ /home/pablo/.julia/packages/LabelledArrays/QY8rm/src/slarray.jl:23 within `SLArray`
      store double %87, double* %.sroa.0122.0..sroa_idx, align 8
; │└└└
; │ @ /home/pablo/Econforge/NoLib/src/model.jl:54 within `arbitrage` @ /home/pablo/Econforge/NoLib/src/model.jl:44
; │┌ @ /home/pablo/Econforge/NoLib/src/model.jl:27 within `LVectorLike`
; ││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/convert.jl:160 within `StaticArray`
; │││┌ @ /home/pablo/.julia/packages/LabelledArrays/QY8rm/src/slarray.jl:23 within `SLArray`
      store double %.unpack.unpack, double* %.sroa.0120.0..sroa_idx, align 8
; │└└└
; │ @ /home/pablo/Econforge/NoLib/src/model.jl:54 within `arbitrage` @ /home/pablo/Econforge/NoLib/src/model.jl:45
; │┌ @ /home/pablo/Econforge/NoLib/src/model.jl:27 within `LVectorLike`
; ││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/convert.jl:160 within `StaticArray`
; │││┌ @ /home/pablo/.julia/packages/LabelledArrays/QY8rm/src/slarray.jl:23 within `SLArray`
      store double %.sroa.0128.3, double* %.sroa.0118.0..sroa_idx, align 8
; │└└└
; │ @ /home/pablo/Econforge/NoLib/src/model.jl:54 within `arbitrage` @ /home/pablo/Econforge/NoLib/src/model.jl:46
; │┌ @ /home/pablo/Econforge/NoLib/src/model.jl:27 within `LVectorLike`
; ││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/convert.jl:160 within `StaticArray`
; │││┌ @ /home/pablo/.julia/packages/LabelledArrays/QY8rm/src/slarray.jl:23 within `SLArray`
      store double %98, double* %.sroa.0116.0..sroa_idx, align 8
; │└└└
; │ @ /home/pablo/Econforge/NoLib/src/model.jl:54 within `arbitrage` @ /home/pablo/Econforge/NoLib/src/model.jl:47
; │┌ @ /home/pablo/Econforge/NoLib/src/model.jl:27 within `LVectorLike`
; ││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/convert.jl:160 within `StaticArray`
; │││┌ @ /home/pablo/.julia/packages/LabelledArrays/QY8rm/src/slarray.jl:23 within `SLArray`
      store double %.fca.0.0.extract, double* %.sroa.0114.0..sroa_idx, align 8
; │└└└
; │ @ /home/pablo/Econforge/NoLib/src/model.jl:54 within `arbitrage` @ /home/pablo/Econforge/NoLib/src/model.jl:48
   %109 = call [1 x [1 x [1 x double]]] @j_arbitrage_4137({ { [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [4 x double] }, { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x [4 x double]] }* nocapture nonnull readonly %1, [1 x [1 x [1 x double]]]* nocapture readonly %10, [1 x [1 x [1 x double]]]* nocapture readonly %11, [1 x [1 x [1 x double]]]* nocapture readonly %12, [1 x [1 x [1 x double]]]* nocapture readonly %13, [1 x [1 x [1 x double]]]* nocapture readonly %14, [1 x [1 x [1 x double]]]* nocapture readonly %15, [4 x double]* nocapture readonly %45) #0
   %.fca.0.0.0.extract = extractvalue [1 x [1 x [1 x double]]] %109, 0, 0, 0
; └
; ┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/linalg.jl:21 within `*`
; │┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/mapreduce.jl:31 within `map`
; ││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/mapreduce.jl:40 within `_map`
; │││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/mapreduce.jl:75 within `macro expansion`
; ││││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/linalg.jl:21 within `#264`
; │││││┌ @ float.jl:385 within `*`
        %110 = fmul double %104, %.fca.0.0.0.extract
; └└└└└└
; ┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/linalg.jl:12 within `+`
; │┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/mapreduce.jl:37 within `map`
; ││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/mapreduce.jl:40 within `_map`
; │││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/mapreduce.jl:75 within `macro expansion`
; ││││┌ @ float.jl:383 within `+`
       %111 = fadd double %96, %110
; └└└└└
;  @ /home/pablo/Econforge/NoLib/examples/temp.jl:30 within `cpu_fun_`
; ┌ @ generator.jl:47 within `iterate`
; │┌ @ none within `#23`
; ││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/indexing.jl:13 within `getindex`
; │││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/indexing.jl:16 within `_getindex_scalar`
; ││││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/indexing.jl:36 within `macro expansion`
; │││││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/SArray.jl:62 within `getindex` @ tuple.jl:29
        %112 = add nsw i64 %30, 1
        %113 = getelementptr inbounds { { [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [4 x double] }, { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x [4 x double]] }, { { [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [4 x double] }, { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x [4 x double]] }* %1, i64 0, i32 2, i64 0, i64 %112
; │└└└└└
; │ @ generator.jl:44 within `iterate` @ range.jl:883
   %.not173 = icmp eq double* %113, null
   br i1 %.not173, label %guard_pass85, label %guard_pass73

guard_pass53:                                     ; preds = %pass11
   %114 = load double, double* %61, align 8
   br label %pass47

guard_pass73:                                     ; preds = %pass47
   %115 = load double, double* %113, align 8
   br label %guard_pass85

guard_pass85:                                     ; preds = %guard_pass73, %pass47
   %116 = phi double [ undef, %pass47 ], [ %115, %guard_pass73 ]
; │ @ generator.jl:45 within `iterate`
   %.sroa.0102.0..sroa_idx104 = getelementptr inbounds { { [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [4 x double] }, { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x [4 x double]] }, { { [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [4 x double] }, { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x [4 x double]] }* %1, i64 0, i32 1, i32 0, i64 0, i64 0, i64 1, i64 0, i64 0
   %.sroa.0102.0.copyload105 = load double, double* %.sroa.0102.0..sroa_idx104, align 8
; └
;  @ /home/pablo/Econforge/NoLib/examples/temp.jl:28 within `cpu_fun_`
  store double %98, double* %.sroa.0133.0..sroa_idx, align 8
;  @ /home/pablo/Econforge/NoLib/examples/temp.jl:29 within `cpu_fun_`
; ┌ @ /home/pablo/Econforge/NoLib/src/garray.jl:66 within `GArray`
   store <4 x double> %24, <4 x double>* %105, align 8
   store i64 %.unpack150.unpack.unpack.unpack165, i64* %.fca.0.1.0.0.2.gep, align 8
   store {}* %22, {}** %6, align 8
   store {}* %22, {}** %.fca.1.0.gep, align 8
   %117 = call [1 x [1 x double]] @j_GArray_4136({ { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x {}*] }* nocapture readonly %9, i64 signext 2, [1 x [1 x double]]* nocapture readonly %8) #0
   %.fca.0.0.extract.1 = extractvalue [1 x [1 x double]] %117, 0, 0
; └
; ┌ @ /home/pablo/Econforge/NoLib/src/model.jl:54 within `arbitrage` @ /home/pablo/Econforge/NoLib/src/model.jl:42
; │┌ @ /home/pablo/Econforge/NoLib/src/model.jl:27 within `LVectorLike`
; ││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/convert.jl:160 within `StaticArray`
; │││┌ @ /home/pablo/.julia/packages/LabelledArrays/QY8rm/src/slarray.jl:23 within `SLArray`
      store double %108, double* %.sroa.0124.0..sroa_idx, align 8
; │└└└
; │ @ /home/pablo/Econforge/NoLib/src/model.jl:54 within `arbitrage` @ /home/pablo/Econforge/NoLib/src/model.jl:43
; │┌ @ /home/pablo/Econforge/NoLib/src/model.jl:27 within `LVectorLike`
; ││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/convert.jl:160 within `StaticArray`
; │││┌ @ /home/pablo/.julia/packages/LabelledArrays/QY8rm/src/slarray.jl:23 within `SLArray`
      store double %87, double* %.sroa.0122.0..sroa_idx, align 8
; │└└└
; │ @ /home/pablo/Econforge/NoLib/src/model.jl:54 within `arbitrage` @ /home/pablo/Econforge/NoLib/src/model.jl:44
; │┌ @ /home/pablo/Econforge/NoLib/src/model.jl:27 within `LVectorLike`
; ││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/convert.jl:160 within `StaticArray`
; │││┌ @ /home/pablo/.julia/packages/LabelledArrays/QY8rm/src/slarray.jl:23 within `SLArray`
      store double %.unpack.unpack, double* %.sroa.0120.0..sroa_idx, align 8
; │└└└
; │ @ /home/pablo/Econforge/NoLib/src/model.jl:54 within `arbitrage` @ /home/pablo/Econforge/NoLib/src/model.jl:45
; │┌ @ /home/pablo/Econforge/NoLib/src/model.jl:27 within `LVectorLike`
; ││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/convert.jl:160 within `StaticArray`
; │││┌ @ /home/pablo/.julia/packages/LabelledArrays/QY8rm/src/slarray.jl:23 within `SLArray`
      store double %.sroa.0102.0.copyload105, double* %.sroa.0118.0..sroa_idx, align 8
; │└└└
; │ @ /home/pablo/Econforge/NoLib/src/model.jl:54 within `arbitrage` @ /home/pablo/Econforge/NoLib/src/model.jl:46
; │┌ @ /home/pablo/Econforge/NoLib/src/model.jl:27 within `LVectorLike`
; ││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/convert.jl:160 within `StaticArray`
; │││┌ @ /home/pablo/.julia/packages/LabelledArrays/QY8rm/src/slarray.jl:23 within `SLArray`
      store double %98, double* %.sroa.0116.0..sroa_idx, align 8
; │└└└
; │ @ /home/pablo/Econforge/NoLib/src/model.jl:54 within `arbitrage` @ /home/pablo/Econforge/NoLib/src/model.jl:47
; │┌ @ /home/pablo/Econforge/NoLib/src/model.jl:27 within `LVectorLike`
; ││┌ @ /home/pablo/.julia/packages/StaticArrays/PUoe1/src/convert.jl:160 within `StaticArray`
; │││┌ @ /home/pablo/.julia/packages/LabelledArrays/QY8rm/src/slarray.jl:23 within `SLArray`
      store double %.fca.0.0.extract.1, double* %.sroa.0114.0..sroa_idx, align 8
; │└└└
; │ @ /home/pablo/Econforge/NoLib/src/model.jl:54 within `arbitrage` @ /home/pablo/Econforge/NoLib/src/model.jl:48
   %118 = call [1 x [1 x [1 x double]]] @j_arbitrage_4137({ { [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [1 x [1 x [1 x double]]], [4 x double] }, { [1 x [1 x [2 x [1 x [1 x double]]]]], [1 x [1 x { double, double, i64 }]] }, [1 x [4 x double]] }* nocapture nonnull readonly %1, [1 x [1 x [1 x double]]]* nocapture readonly %10, [1 x [1 x [1 x double]]]* nocapture readonly %11, [1 x [1 x [1 x double]]]* nocapture readonly %12, [1 x [1 x [1 x double]]]* nocapture readonly %13, [1 x [1 x [1 x double]]]* nocapture readonly %14, [1 x [1 x [1 x double]]]* nocapture readonly %15, [4 x double]* nocapture readonly %45) #0
; └
;  @ /home/pablo/Econforge/NoLib/examples/temp.jl:31 within `cpu_fun_`
; ┌ @ /home/pablo/Econforge/NoLib/src/garray.jl:28 within `setindex!` @ array.jl:966
   %119 = load i64, i64* %66, align 8
   %120 = icmp ult i64 %90, %119
   br i1 %120, label %idxend26, label %oob25
; └
}