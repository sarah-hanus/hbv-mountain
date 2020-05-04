# load list of structs
include("structs.jl")
# load components of models represented by buckets
include("processes_buckets.jl")
# load functions that combine all components of one HRU
include("elevations.jl")
# load functions for combining all HRUs and for running the model
include("allHRU.jl")
# load function for running model which just returns the necessary output for calibration
include("run_model.jl")
# load functions for preprocessing temperature and precipitation data
include("Preprocessing.jl")
# load functions for calculating the potential evaporation
include("Potential_Evaporation.jl")
# load objective functionsM
include("ObjectiveFunctions.jl")
# load parameterselection
include("parameterselection.jl")
# load running model in several precipitation zones
include("runmodel_Prec_Zones.jl")
