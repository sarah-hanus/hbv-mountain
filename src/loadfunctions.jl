using DocStringExtensions
using Dates
using DelimitedFiles
using CSV
# load list of structs
include("structs.jl")
# load components of models represented by buckets
include("processes_buckets.jl")
# load functions that combine all components of one HRU
include("elevations.jl")
# load functions for combining all HRUs and for running the model
include("allHRU.jl")
# load functions for preprocessing temperature and precipitation data
include("Preprocessing.jl")
# load functions for calculating the potential evaporation
include("Potential_Evaporation.jl")
# load objective functions
include("ObjectiveFunctions.jl")
