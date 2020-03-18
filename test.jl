push!(LOAD_PATH,".")
#include("ObjectiveFunctions.jl")
using .ObjectiveFunctions
#
# observed = [1,2,3,4]
# modelled = [1,1,3.5,4]
print(einfach(3))
# # print(nse(observed, modelled))
# # print(lognse(observed, modelled))

x = 5
print(3+x)
