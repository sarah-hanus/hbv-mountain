using CSV
using Plots
#Timeseries  = CSV.read("Pitztal/pr_model_timeseries.txt", header=["Year", "Month", "Day"])
Timeseries = readdlm("Defreggental/tas_model_timeseries.txt")
Precipitation  = CSV.read("Defreggental/pr_sim1.txt", header=false)
Temperature = CSV.read("Defreggental/tas_sim1.txt", header=false)

#take data at point 49 because this data is at around 2300 meter height, so average height of catchment

grid_point = 49

Precipitation_Sample = Precipitation[:,grid_point]/10
Temp_Sample = Temperature[:,grid_point]/10 #makes a vector
# 30 years: 10957 days
Days = 10957
Precipitation_Sample = Precipitation_Sample[1:Days]
Temp_Sample = Temp_Sample[1:Days]
Dates_Sample = Timeseries[1:Days]


Nr_Elevationbands, Prec_Elevation, Temp_Elevation = getelevationdata(100, 1096, 2233, 3485, 0.003, Temp_Sample, Precipitation_Sample)

#print("NR", Nr_Elevationbands)
# Potential_Evaporation = rand(3650, Nr_Elevationbands) * 5
# Potential_Evaporation_Mean = Potential_Evaporation[:,1]
Sunhours_Vienna = [8.83, 10.26, 11.95, 13.75, 15.28, 16.11, 15.75, 14.36, 12.63, 10.9, 9.28, 8.43]

Potential_Evaporation = Array{Float64}(undef, Days, Nr_Elevationbands)

for i in 1 : Nr_Elevationbands
  Potential_Evaporation[:,i] = getEpot_thornthwaite(Temp_Elevation[:,i], Dates_Sample, Sunhours_Vienna)
end

#plot([Potential_Evaporation[1:730,1], Potential_Evaporation[1:730,2], Potential_Evaporation[1:730,3],Potential_Evaporation[1:730,4],Potential_Evaporation[1:730,5], Potential_Evaporation[1:730,6], Potential_Evaporation[1:730,7], Potential_Evaporation[1:730,8], Potential_Evaporation[1:730,9], Potential_Evaporation[1:730,10]])

# get the mean potential evaporation by summing up all the elevations and dividing by elevation band
Potential_Evaporation_Mean = vec(sum( Potential_Evaporation, dims=2)) / Nr_Elevationbands
Area = 267.46 * 10^6 #m2
Areas = [0.43, 0.24, 0.31, 0.02]
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
bare_parameters = Parameters(1, 0.4, 0, 2, 0.8, 1, 0.5, 0.1, 50, 0)
forest_parameters = Parameters(1, 0.4, 0, 3, 0.8, 1, 0.5, 0.1, 100, 0)
grass_parameters = Parameters(1, 0.4, 0, 2, 0.8, 1, 0.5, 0.1, 50, 0)
rip_parameters = Parameters(1, 0.4, 0.1, 2, 0.8, 1, 0.5, 0.1, 50, 0)
Ks = 0.001
Ratio_Riparian = 0.1

@time begin
Discharge, Waterbalance, Faststorage, GWstorage, Interceptionstorage, Snowstorage, Soilstorage, Waterbalance2 = runmodel(Area, Potential_Evaporation, Potential_Evaporation_Mean, Prec_Elevation, Temp_Elevation,
        bare_input, forest_input, grass_input, rip_input,
        bare_storage, forest_storage, grass_storage, rip_storage, Slowstorage,
        bare_parameters, forest_parameters, grass_parameters, rip_parameters, Ks, Ratio_Riparian)
end
