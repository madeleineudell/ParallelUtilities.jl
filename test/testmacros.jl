using ParallelUtilities

n = 1000
verbose=false
if verbose println("building $n x $n test matrix ...") end
@time A = Base.shmem_fill(zero(Float64),n,n)
if verbose println("done") end

# assertion fails for non-shared matrices, eg if A = zeros(n,n)

niters = 100

println("testing parallel repeat")
@time begin
    @sync begin
        @parallel_repeat niters for i=1:n
            A[:,i] += 1
        end
    end
end

@assert(A[5,5] == niters)
@assert(A[5,10] == niters)

println("testing parallel alternate")
@time begin
    @sync begin
        @parallel_alternate(niters, 
            for i=1:n
                A[i,:] += i
            end,
            for i=1:n
                A[:,i] += i
            end
            )
    end
end

@assert(A[5,5] == 10*niters + niters)
@assert(A[5,10] == 15*niters + niters)