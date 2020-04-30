using Distributed

@everywhere function compute_pi(N::Float64)
    """
    Compute pi with a Monte Carlo simulation of N darts thrown in [-1,1]^2
    Returns estimate of pi
    """
    n_landed_in_circle = 0  # counts number of points that have radial coordinate < 1, i.e. in circle
    for i = 1:N
        x = rand() * 2 - 1  # uniformly distributed number on x-axis
        y = rand() * 2 - 1  # uniformly distributed number on y-axis

        r2 = x*x + y*y  # radius squared, in radial coordinates
        if r2 < 1.0
            n_landed_in_circle += 1
        end
    end

    return n_landed_in_circle / N * 4.0
end
input = ones(6) * 10000000000
@time begin
#name = Future[]
# for i in 1
#      push!(name, remotecall(compute_pi, i, 6000000))
# end
#
# for i in 1
#     print(fetch(name[i]), "\n")
# end

pmap(x->compute_pi(x), input)

end



# x = 0
# addprocs(3)
# x1 = @spawnat 1 compute_pi(100000000)
# x1 = fetch(x1)
# x2 = @spawnat 2 compute_pi(100000000)
# x2 = fetch(x2)
# x3 = @spawnat 3 compute_pi(10000000)
# x3 = fetch(x3)
# x4 = @spawnat 4 compute_pi(10000000)
# x4 = fetch(x3)

# function parallel_pi_computation(N::Int)
#     """
#     Compute pi in parallel, over ncores cores, with a Monte Carlo simulation throwing N total darts
#     """
#
#     # compute sum of pi's estimated among all cores in parallel
#     sum_of_pis = pmap(compute_pi, 1:100000)
#
#     return sum_of_pis
# end
#
#
# y = compute_pi(10000)
# y = parallel_pi_computation(10000)
