using CSV
using Plots
#Timeseries  = CSV.read("Pitztal/pr_model_timeseries.txt", header=["Year", "Month", "Day"])
Timeseries = readdlm("Defreggental/tas_model_timeseries.txt")
Precipitation  = CSV.read("Defreggental/pr_sim1.txt", header=false)
Temperature = CSV.read("Defreggental/tas_sim1.txt", header=false)

Areas_HRUs =  CSV.read("Defreggental/allHRU.csv", header=true, decimal=',', delim = ';')

Areas_HRUs = convert(Matrix, Areas_HRUs)

#take data at point 49 because this data is at around 2300 meter height, so average height of catchment
#grid point at outlet  68
# grid point at 2700 m 23
grid_point = 23

# Temperature and Precipiation Data at Measured Elevation
Precipitation_Sample = Precipitation[:,grid_point]/10
Temp_Sample = Temperature[:,grid_point]/10 #makes a vector


# 30 years: 10957 days
# 50 years 18262 days
Days = 10957
Precipitation_Sample = Precipitation_Sample[1:Days]
Temp_Sample = Temp_Sample[1:Days]
Dates_Sample = Timeseries[1:Days]

# get potential Evaporation at elevation of temperature measurement
Sunhours_Vienna = [8.83, 10.26, 11.95, 13.75, 15.28, 16.11, 15.75, 14.36, 12.63, 10.9, 9.28, 8.43]
Potential_Evaporation = getEpot_thornthwaite(Temp_Sample, Dates_Sample, Sunhours_Vienna)

# get Precipitation, Temperature and Elevationband data for whole catchment
Elevation, Prec_Elevation, Temp_Elevation = getelevationdata(100, 1000, 2600, 3500, 0.003, Temp_Sample, Precipitation_Sample)
#get elevation and count of elevations which are contained in a HRU
Bare_Elevation_Count = getelevationbands(100, 2000, 3200, Elevation)
Forest_Elevation_Count = getelevationbands(100, 1100, 2300, Elevation)
Grass_Elevation_Count = getelevationbands(100, 1100, 2700, Elevation)
Rip_Elevation_Count = getelevationbands(100, 1100, 2700, Elevation)

Area_Bare_Elevations = Areas_HRUs[1:12, 2]
Area_Forest_Elevations = Areas_HRUs[1:12, 4]
Area_Grass_Elevations = Areas_HRUs[1:16, 6]
Area_Rip_Elevations = Areas_HRUs[1:16, 8]

#Nr_Elevationbands_rip, Prec_Elevation_rip, Temp_Elevation_rip = getelevationdata(100, 1096, 2233, 1400, 0.003, Temp_Sample, Precipitation_Sample)

# Potential_Evaporation = Array{Float64}(undef, Days, Nr_Elevationbands)
# for i in 1 : Nr_Elevationbands
#   Potential_Evaporation[:,i] = getEpot_thornthwaite(Temp_Elevation[:,i], Dates_Sample, Sunhours_Vienna)
# end


# get the mean potential evaporation by summing up all the elevations and dividing by elevation band
#Potential_Evaporation_Mean = vec(sum( Potential_Evaporation, dims=2)) / Nr_Elevationbands
Area = 267.46 * 10^6 #m2
Areas = [0.43, 0.24, 0.31, 0.02]
#Area_elevation = ones(Nr_Elevationbands)/ Nr_Elevationbands
#Area_Bare_Elevations = [0.2, 0.2, 0.2, 0.1, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05]
print(sum(Area_Bare_Elevations))
bare_input = HRU_Input(Area_Bare_Elevations, Areas[1], 0.0, Bare_Elevation_Count, length(Bare_Elevation_Count), 0, [0], 0, [0], 0, 0)
forest_input = HRU_Input(Area_Forest_Elevations, Areas[2], 0, Forest_Elevation_Count, length(Forest_Elevation_Count), 0, [0], 0, [0],  0, 0)
grass_input = HRU_Input(Area_Grass_Elevations, Areas[3], 0, Grass_Elevation_Count,length(Grass_Elevation_Count), 0, [0], 0, [0],  0, 0)
rip_input = HRU_Input(Area_Rip_Elevations, Areas[4], 0, Rip_Elevation_Count, length(Rip_Elevation_Count), 0, [0], 0, [0],  0, 0)

bare_storage = Storages(0, zeros(length(Bare_Elevation_Count)), zeros(length(Bare_Elevation_Count)), 0)
forest_storage = Storages(0, zeros(length(Forest_Elevation_Count)), zeros(length(Forest_Elevation_Count)), 0)
grass_storage = Storages(0, zeros(length(Grass_Elevation_Count)), zeros(length(Grass_Elevation_Count)), 0)
rip_storage = Storages(0, zeros(length(Rip_Elevation_Count)), zeros(length(Rip_Elevation_Count)), 0)
Slowstorage = 0.0
bare_parameters = Parameters(1, 0.4, 0, 2, 0.8, 1, 0.5, 0.1, 50, 0)
forest_parameters = Parameters(1, 0.4, 0, 3, 0.8, 1, 0.5, 0.1, 100, 0)
grass_parameters = Parameters(1, 0.4, 0, 2, 0.8, 1, 0.5, 0.1, 50, 0)
rip_parameters = Parameters(1, 0.4, 0.1, 2, 0.8, 1, 0.5, 0.1, 50, 0)
Ks = 0.001
Ratio_Riparian = 0.1

@time begin
Discharge, Waterbalance, Faststorage, GWstorage, Interceptionstorage, Snowstorage, Soilstorage, Waterbalance2 = runmodel(Area, Potential_Evaporation, Prec_Elevation, Temp_Elevation,
        bare_input, forest_input, grass_input, rip_input,
        bare_storage, forest_storage, grass_storage, rip_storage, Slowstorage,
        bare_parameters, forest_parameters, grass_parameters, rip_parameters, Ks, Ratio_Riparian)
end

#units
#Discharge in m3/s
# GW Storage in mm (to get the amount of the total area has to be * Area_HRU)
# Faststorage in mm (to get the amount of the total area has to be * Area_HRU)
# Soilstorage in mm (to get the amount of the total area has to be * Area_HRU)
plot(Snowstorage[end-365:end,1], label=["Bare"])
xlabel!("Days of Year")
ylabel!("Snow Cover [mm]")
title!("Snow Cover after 30 years")
savefig("Snow_Cover_Defreggen_Bare.png")
