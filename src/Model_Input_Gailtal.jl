using Dates
using DelimitedFiles
using CSV
using Plots
using Statistics
using DocStringExtensions
using DataFrames

# ID_S of measurement station for precipitation zones
ID_Prec_Zones = [113589, 113597, 113670, 114538]
# size of the area of precipitation zones
Area_Zones = [98227533, 184294158, 83478138, 220613195]

Mean_Elevation_Catchment = 1500 # in reality 1476
Elevations_Catchment = Elevations(200, 400, 2800,1140, 1140)
Sunhours_Vienna = [8.83, 10.26, 11.95, 13.75, 15.28, 16.11, 15.75, 14.36, 12.63, 10.9, 9.28, 8.43]
# where to skip to in data file
Skipto = [24, 22, 22, 22]



#Temperature is the same in whole catchment
#first do temperature calculations
Temperature = CSV.read("Gailtal/LTkont113597.csv", header=false, skipto = 20, missingstring = "L\xfccke", decimal='.', delim = ';')
Temperature_Array = convert(Matrix, Temperature)
startindex = findfirst(isequal("01.01.1980 07:00:00"), Temperature_Array)
Temperature_Array = Temperature_Array[startindex[1]:end - 1,:]
Temperature_Array[:,1] = Date.(Temperature_Array[:,1], Dates.DateFormat("d.m.y H:M:S"))
Dates_Temperature_Daily, Temperature_Daily = daily_mean(Temperature_Array)
Elevation_Zone_Catchment, Temperature_Elevation_Catchment, Total_Elevationbands_Catchment = gettemperatureatelevation(Elevations_Catchment, Temperature_Daily)
# get the temperature data at the mean elevation to calculate the mean potential evaporation
Temperature_Mean_Elevation = Temperature_Elevation_Catchment[:,findfirst(x-> x==1500, Elevation_Zone_Catchment)]
Potential_Evaporation = getEpot_thornthwaite(Temperature_Mean_Elevation, Dates_Temperature_Daily, Sunhours_Vienna)

# get the areal percentage of all elevation zones in the HRUs in the precipitation zones
Areas_HRUs =  CSV.read("Gailtal/HBV_Area_Elevation.csv", skipto=2, decimal=',', delim = ';')
# get the percentage of each HRU of the precipitation zone
Percentage_HRU = CSV.read("Gailtal/HRUPercentage.csv", header=[1], decimal=',', delim = ';')
Elevation_Catchment = convert(Vector, Areas_HRUs[2:end,1])

#PARAMETERS
Precipitation_Gradient = 0.0035 # which units?
Slowstorage = 0.0
Meltfactor = 2.8
Mm = 1
bare_parameters = Parameters(1, 0.4, 0, 2, 0.8, Meltfactor, Mm, 0.1, 50, 0)
forest_parameters = Parameters(1, 0.4, 0, 3, 0.8, Meltfactor, Mm, 0.1, 100, 0)
grass_parameters = Parameters(1, 0.4, 0, 2, 0.8, Meltfactor, Mm, 0.1, 50, 0)
rip_parameters = Parameters(1, 0.4, 0.1, 2, 0.8, Meltfactor, Mm, 0.1, 50, 0)
Ks = 0.001
Ratio_Riparian = 0.1


# get elevations at which precipitation was measured in each precipitation zone
# changed to 1400 in 2003
Elevations_113589 = Elevations(200., 1000., 2800., 1430.,1140)
Elevations_113597 = Elevations(200, 800, 2800, 1140, 1140)
Elevations_113670 = Elevations(200, 400, 2400, 635, 1140)
Elevations_114538 = Elevations(200, 600, 2600, 705, 1140)
Elevations_All_Zones = [Elevations_113589, Elevations_113597, Elevations_113670, Elevations_114538]

#get the total discharge
Total_Discharge = zeros(length(Temperature_Daily))

for i in 1: length(ID_Prec_Zones)
        Precipitation = CSV.read("Gailtal/N-Tagessummen-"*string(ID_Prec_Zones[i])*".csv", header= false, skipto=Skipto[i], missingstring = "L\xfccke", decimal=',', delim = ';')
        Precipitation_Array = convert(Matrix, Precipitation)
        startindex = findfirst(isequal("01.01.1980 07:00:00   "), Precipitation_Array)
        endindex = findfirst(isequal("31.12.2013 07:00:00   "), Precipitation_Array)
        Precipitation_Array = Precipitation_Array[startindex[1]:endindex[1],:]
        Precipitation_Array[:,1] = Date.(Precipitation_Array[:,1], Dates.DateFormat("d.m.y H:M:S   "))
        # find duplicates and remove them
        df = DataFrame(Precipitation_Array)
        df = unique!(df)
        # drop missing values
        df = dropmissing(df)
        Precipitation_Array = convert(Matrix, df)

        Elevation_HRUs, Precipitation, Nr_Elevationbands = getprecipitationatelevation(Elevations_All_Zones[i], Precipitation_Gradient, Precipitation_Array[:,2])

        index_HRU = (findall(x -> x==ID_Prec_Zones[i], Areas_HRUs[1,2:end]))
        #print(Areas_HRUs[1,:])

        # for each precipitation zone get the relevant areal extentd
        Current_Areas_HRUs = convert(Matrix, Areas_HRUs[2: end, index_HRU])

        Area_Bare_Elevations, Bare_Elevation_Count = getelevationsperHRU(Current_Areas_HRUs[:,1], Elevation_Catchment, Elevation_HRUs)
        Area_Forest_Elevations, Forest_Elevation_Count = getelevationsperHRU(Current_Areas_HRUs[:,2], Elevation_Catchment, Elevation_HRUs)
        Area_Grass_Elevations, Grass_Elevation_Count = getelevationsperHRU(Current_Areas_HRUs[:,3], Elevation_Catchment, Elevation_HRUs)
        Area_Rip_Elevations, Rip_Elevation_Count = getelevationsperHRU(Current_Areas_HRUs[:,4], Elevation_Catchment, Elevation_HRUs)
        @assert 1 - eps(Float64) <= sum(Area_Bare_Elevations) <= 1 + eps(Float64)
        @assert 1 - eps(Float64) <= sum(Area_Forest_Elevations) <= 1 + eps(Float64)
        @assert 1 - eps(Float64) <= sum(Area_Grass_Elevations) <= 1 + eps(Float64)
        @assert 1 - eps(Float64) <= sum(Area_Rip_Elevations) <= 1 + eps(Float64)

        Area = Area_Zones[i]
        Current_Percentage_HRU = Percentage_HRU[:,1 + i]/Area

        bare_input = HRU_Input(Area_Bare_Elevations, Current_Percentage_HRU[1], 0.0, Bare_Elevation_Count, length(Bare_Elevation_Count), 0, [0], 0, [0], 0, 0)
        forest_input = HRU_Input(Area_Forest_Elevations, Current_Percentage_HRU[2], 0, Forest_Elevation_Count, length(Forest_Elevation_Count), 0, [0], 0, [0],  0, 0)
        grass_input = HRU_Input(Area_Grass_Elevations, Current_Percentage_HRU[3], 0, Grass_Elevation_Count,length(Grass_Elevation_Count), 0, [0], 0, [0],  0, 0)
        rip_input = HRU_Input(Area_Rip_Elevations, Current_Percentage_HRU[4], 0, Rip_Elevation_Count, length(Rip_Elevation_Count), 0, [0], 0, [0],  0, 0)

        bare_storage = Storages(0, zeros(length(Bare_Elevation_Count)), zeros(length(Bare_Elevation_Count)), 0, 0)
        forest_storage = Storages(0, zeros(length(Forest_Elevation_Count)), zeros(length(Forest_Elevation_Count)),0, 0)
        grass_storage = Storages(0, zeros(length(Grass_Elevation_Count)), zeros(length(Grass_Elevation_Count)),0, 0)
        rip_storage = Storages(0, zeros(length(Rip_Elevation_Count)), zeros(length(Rip_Elevation_Count)),0, 0)
        @time begin
        Discharge, Snow_Extend, Waterbalance, Faststorage, GWstorage, Interceptionstorage, Snowstorage, Soilstorage, Waterbalance2, Snow_Elevations, Bare_Snow = runmodel(Area, Potential_Evaporation, Precipitation, Temperature_Elevation_Catchment,
                bare_input, forest_input, grass_input, rip_input,
                bare_storage, forest_storage, grass_storage, rip_storage, Slowstorage,
                bare_parameters, forest_parameters, grass_parameters, rip_parameters, Ks, Ratio_Riparian, Total_Elevationbands_Catchment)
        end

        global Total_Discharge += Discharge


end




# #units
# #STorages [bare, forest, grass, rip]
# #Discharge in m3/s
# # GW Storage in mm (to get the amount of the total area has to be * Area_HRU)
# # Faststorage in mm (to get the amount of the total area has to be * Area_HRU)
# # Soilstorage in mm (to get the amount of the total area has to be * Area_HRU)
# plot(Snowstorage[end-365:end,1], label=["Bare"])
# xlabel!("Days of Year")
# ylabel!("Snow Cover [mm]")
# title!("Snow Cover after 30 years")
# savefig("Snow_Cover_Defreggen_Bare.png")
#
# plot(Bare_Snow[end-730:end,:], label=[2050 2150 2250 2350 2450 2550 2650 2750 2850 2950 3050 3150])
# xlabel!("Days")
# ylabel!("Snow Cover [mm]")
# title!("Snow Cover at Different Elevations")
# #savefig("Snow_Cover_Elevations.png")
#
# Discharge_Defreggen_Measured = CSV.read("Defreggental/Q-Tagesmittel-212100.csv", header= false, skipto=26, decimal=',', delim = ';', types=[String, Float64])
# Discharge_Defreggen_Measured = convert(Matrix, Discharge_Defreggen_Measured)
# startindex = findfirst(isequal("01.01.1979 00:00:00"), Discharge_Defreggen_Measured)
# endindex = findfirst(isequal("31.12.1979 00:00:00"), Discharge_Defreggen_Measured)
# #Plot Measure Discharge against modeled discharge
# plot(Discharge_Defreggen_Measured[startindex[1]:endindex[1],2])
# plot!(Discharge[end-365: end])
