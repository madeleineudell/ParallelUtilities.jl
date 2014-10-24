using ParallelUtilities

n = 1000
verbose=false
if verbose println("building $n x $n test matrix ...") end
@time A = Base.shmem_fill(zero(Float64),n,n)
if verbose println("done") end

# assertion fails for non-shared matrices, eg if A = zeros(n,n)

niters = 10

println("testing parallel repeat")
@time begin
    @sync begin
        @parallel_repeat 10 for i=1:n
            A[:,i] += 1
        end
    end
end

@assert(A[5,5] == 10)
@assert(A[5,10] == 10)

println("testing parallel alternate")
@time begin
    @sync begin
        @parallel_alternate(10, 
            for i=1:n
                A[i,:] += i
            end,
            for i=1:n
                A[:,i] += i
            end
            )
    end
end

println(A[5,5]) # niters*(5+5)
println(A[5,10]) # niters*(5+10)
@assert(A[5,5] == 110)
@assert(A[5,10] == 160)