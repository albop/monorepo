
struct IterationLog
    header::Array{String, 1}
    keywords::Array{Symbol, 1}
    types::Vector
    entries::Array{Any, 1}
    fmt::String
end

# function IterationLog()
#     header = [ "It", "ϵₙ", "ηₙ=|xₙ-xₙ₋₁|", "λₙ=ηₙ/ηₙ₋₁", "Time", "Newton steps"]
#     keywords = [:it, :err, :gain, :time, :nit]
#     IterationLog(header, keywords, [])
# end

function IterationLog(;kw...)
    keywords = Symbol[]
    header = String[]
    elts = []
    types= []
    for (k,(v,t)) in kw
        push!(types, t)
        push!(keywords, k)
        push!(header, v)
        if t<:Int
            push!(elts, "{:>8}")
        elseif t<:Real
            push!(elts, "{:>12.4e}")
        else
            error("Don't know how to format type $t")
        end
    end
    fmt = join(elts, " | ")
    IterationLog(header, keywords, types, [], fmt)
end

function append!(log::IterationLog; verbose=true, entry...)
    d = Dict(entry)
    push!(log.entries, d)
    verbose && show_entry(log, d)
end

function initialize(log::IterationLog; verbose=true, message=nothing)
    verbose && show_start(log; message=message)
end

function finalize(log::IterationLog; verbose=true)
    verbose && show_end(log)
end

function show(log::IterationLog)
    show_start(log)
    for entry in log.entries
        show_entry(log,entry)
    end
    show_end(log)
end

function show_start(log::IterationLog; message=nothing)
    # println(repeat("-", 66))
    # @printf "%-6s%-16s%-16s%-16s%-16s%-5s\n" "It" "ϵₙ" "ηₙ=|xₙ-xₙ₋₁|" "λₙ=ηₙ/ηₙ₋₁" "Time" "Newton steps"
    # println(repeat("-", 66))

    l = []
    for t in log.types
        if t<:Int
            push!(l, "{:>8}")
        elseif t<:Real
            push!(l, "{:>12}")
        end
    end

    a = join(l, " | ")
    s = format(a, log.header...)

    if message !== nothing
        println(repeat("-", length(s)))
        println(message)
    end
    println(repeat("-", length(s)))

    println(s)
    println(repeat("-", length(s)))
end


function show_entry(log::IterationLog, entry)

    vals = [entry[k] for k in log.keywords]
    printfmt(log.fmt, vals...)
    print("\n")

end

function show_end(log::IterationLog)
    println(repeat("-", 66))
end

###


struct IterationTrace
    data::Array{Any,1}
end

length(t::IterationTrace) = length(t.data)


mutable struct TimeIterationResult
    dr
    iterations::Int
    tol_η::Float64
    η::Float64
    log::IterationLog
    trace::Union{Nothing,IterationTrace}
end

converged(r::TimeIterationResult) = (r.η<r.tol_η)
function Base.show(io::IO, r::TimeIterationResult)
    @printf io "Results of Time Iteration Algorithm\n"
    # @printf io " * Complementarities: %s\n" string(r.complementarities)
    @printf io " * Decision Rule type: %s\n" string(typeof(r.dr))
    @printf io " * Number of iterations: %s\n" string(r.iterations)
    @printf io " * Convergence: %s\n" converged(r) ? "true" : RED_FG("false")
    @printf io "   * |x - x'| < %.1e: %s\n" r.tol_η converged(r)
end
