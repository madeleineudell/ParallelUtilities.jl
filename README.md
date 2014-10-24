# ParallelUtilities

[![Build Status](https://travis-ci.org/madeleineudell/ParallelUtilities.jl.svg?branch=master)](https://travis-ci.org/madeleineudell/ParallelUtilities.jl)

This package facilitates the use of shared memory parallelism for iterative algorithms.
It defines two macros that make it easy to repeat a for loop multiple times, or 
to alternate between two for loops, without resending the data to the processors.
This functionality is most useful when combined with SharedArrays.

# Usage

For these examples, assume we have initialized a shared array
```
n = 10000
A = Base.shmem_fill(zero(Float64),n,n)
```

Example 1: repeating a `for` loop. The following code
adds `1` to every column of A `niters` times.
```
niters = 10

@time begin
    @sync begin
        @parallel_repeat niters for i=1:n
            A[:,i] += 1
        end
    end
end
```

Example 2: repeating a `for` loop. The following code
adds `i` to the `i`th row of A and 
`i` to the `i`th column of A `niters` times.
```
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

println(A[5,5]) # niters*(5+5)
println(A[5,10]) # niters*(5+10)
```