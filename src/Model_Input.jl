using CSV
using Plots
Dates  = CSV.read("Pitztal/pr_model_timeseries.txt", header=["Year", "Month", "Day"])
Precipitation  = CSV.read("Pitztal/pr_sim1.txt", header=false)
Temperature = CSV.read("Pitztal/tas_sim1.txt", header=false)
Dates_Sample = Dates[in([1950:]).(Dates.Year), :]
Precipitation_Sample = Precipitation[:,25]
Temp_Sample = Temperature[:,25]/10 #makes a vector
Days = 36500
Precipitation_Sample = Precipitation_Sample[1:Days]/10
Temp_Sample = Temp_Sample[1:Days]


Nr_Elevationbands, Prec_Elevation, Temp_Elevation = getelevationdata(250, 1093, 2238, 3527, 0.003, Temp_Sample, Precipitation_Sample)

#print("NR", Nr_Elevationbands)
# Potential_Evaporation = rand(3650, Nr_Elevationbands) * 5
# Potential_Evaporation_Mean = Potential_Evaporation[:,1]

Potential_Evaporation = ones(Days, Nr_Elevationbands) * 5
Potential_Evaporation_Mean = ones(Days) * 5

Areas = [0.51, 0.22, 0.26, 0.01]
Area_elevation = ones(Nr_Elevationbands)/ Nr_Elevationbands
bare_input = HRU_Input(Area_elevation, Areas[1], 0.0, Nr_Elevationbands, [0], 0, [0], 0, [0], 0, 0)
forest_input = HRU_Input(Area_elevation, Areas[2], 0, Nr_Elevationbands,[0], 0, [0], 0, [0],  0, 0)
grass_input = HRU_Input(Area_elevation, Areas[3], 0, Nr_Elevationbands, [0], 0, [0], 0, [0],  0, 0)
rip_input = HRU_Input(Area_elevation, Areas[4], 0, Nr_Elevationbands, [0], 0, [0], 0, [0],  0, 0)

bare_storage = Storages(0, zeros(Nr_Elevationbands), zeros(Nr_Elevationbands), 0)
forest_storage = Storages(0, zeros(Nr_Elevationbands), zeros(Nr_Elevationbands), 0)
grass_storage = Storages(0, zeros(Nr_Elevationbands), zeros(Nr_Elevationbands), 0)
rip_storage = Storages(0, zeros(Nr_Elevationbands), zeros(Nr_Elevationbands), 0)
Slowstorage = 0.0
bare_parameters = Parameters(1, 0.4, 0, 2, 0.8, 1, 0.5, 0.1, 0.1, 50, 0)
forest_parameters = Parameters(1, 0.4, 0, 3, 0.8, 1, 0.5, 0.1, 0.1, 100, 0)
grass_parameters = Parameters(1, 0.4, 0, 2, 0.8, 1, 0.5, 0.1, 0.1, 50, 0)
rip_parameters = Parameters(1, 0.4, 0.1, 2, 0.8, 1, 0.5, 0.1, 0.1, 50, 0)
Ks = 0.001
Ratio_Riparian = 0.1

@time begin
Discharge, Waterbalance, Faststorage, GWstorage, Interceptionstorage, Snowstorage, Soilstorage = runmodel(Potential_Evaporation, Potential_Evaporation_Mean, Prec_Elevation, Temp_Elevation,
        bare_input, forest_input, grass_input, rip_input,
        bare_storage, forest_storage, grass_storage, rip_storage, Slowstorage,
        bare_parameters, forest_parameters, grass_parameters, rip_parameters, Ks, Ratio_Riparian)
end
