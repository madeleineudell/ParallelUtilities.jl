export @parallel_repeat, @parallel_alternate

function pfor_ntimes(niters::Int, f, N::Int)
    for iter in 1:niters
        for c in Base.splitrange(N, nworkers())
            @spawn f(first(c), last(c))
        end
    end
    nothing
end 

function pfor_ntimes(niters::Int, f1, N1::Int, f2, N2::Int)
    for iter in 1:niters
        for c in Base.splitrange(N1, nworkers())
            @spawn f1(first(c), last(c))
        end
        for c in Base.splitrange(N2, nworkers())
            @spawn f2(first(c), last(c))
        end
    end
    nothing
end 

macro parallel_repeat(niters, args...)
    na = length(args)
    if na==1
        loop = args[1]
    else
        throw(ArgumentError("wrong number of arguments to @parallel_repeat"))
    end
    if !isa(loop,Expr) || !is(loop.head,:for)
        error("malformed @parallel_repeat loop")
    end
    var = loop.args[1].args[1]
    r = loop.args[1].args[2]
    body = loop.args[2]
    quote
        pfor_ntimes($(Base.localize_vars(niters)), 
                    $(Base.make_pfor_body(var, body, r)), length($(esc(r))))
    end
end

macro parallel_alternate(niters, loop1::Expr, loop2::Expr)
    loops = [loop1, loop2]
    if !all([isa(loop,Expr) for loop in loops]) || !all([is(loop.head,:for) for loop in loops])
        error("malformed @parallel_alternate loop")
    end
    var1 = loop1.args[1].args[1]
    r1 = loop1.args[1].args[2]
    body1 = loop1.args[2]
    var2 = loop2.args[1].args[1]
    r2 = loop2.args[1].args[2]
    body2 = loop2.args[2]
    quote
        pfor_ntimes($(Base.localize_vars(niters)),
                    $(Base.make_pfor_body(var1, body1, r1)), length($(esc(r1))),
                    $(Base.make_pfor_body(var2, body2, r2)), length($(esc(r2))))
    end
end