using Dates
using DelimitedFiles
using CSV
using Plots
using Statistics
using DocStringExtensions
using DataFrames
using Random

# ID_S of measurement station for precipitation zones
ID_Prec_Zones = [113589, 113597, 113670, 114538]
# size of the area of precipitation zones
Area_Zones = [98227533, 184294158, 83478138, 220613195]
Area_Catchment = sum(Area_Zones)
Area_Zones_Percent = Area_Zones / Area_Catchment

Mean_Elevation_Catchment = 1500 # in reality 1476
Elevations_Catchment = Elevations(200, 400, 2800,1140, 1140)
Sunhours_Vienna = [8.83, 10.26, 11.95, 13.75, 15.28, 16.11, 15.75, 14.36, 12.63, 10.9, 9.28, 8.43]
# where to skip to in data file
Skipto = [24, 22, 22, 22]



#Temperature is the same in whole catchment
#first do temperature calculations
Temperature = CSV.read("Gailtal/LTkont113597.csv", header=false, skipto = 20, missingstring = "L\xfccke", decimal='.', delim = ';')
Temperature_Array = convert(Matrix, Temperature)
startindex = findfirst(isequal("01.01.1994 07:00:00"), Temperature_Array)
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


#real discharge

Discharge = CSV.read("Gailtal/Q-Tagesmittel-212670.csv", header= false, skipto=23, decimal=',', delim = ';', types=[String, Float64])
Discharge = convert(Matrix, Discharge)
startindex = findfirst(isequal("01.01.1994 00:00:00"), Discharge)
endindex = findfirst(isequal("31.12.2009 00:00:00"), Discharge)
Timeseries = Date.(Discharge[startindex[1]:endindex[1],1], Dates.DateFormat("d.m.y H:M:S"))
start2000 = findfirst(x -> x == Date(2000, 01, 01), Timeseries)

Observed_Discharge = Array{Float64,1}[]
push!(Observed_Discharge, Discharge[startindex[1]:endindex[1],2])
Observed_Discharge = Observed_Discharge[1]
length_2000_end = length(Observed_Discharge) - start2000
observed_snow_cover = Array{Float64,2}[]
for ID in ID_Prec_Zones
        current_observed_snow = readdlm("Gailtal/snow_cover_fixed_"*string(114538)*".csv",',', Float64)
        print(size(current_observed_snow))
        push!(observed_snow_cover, current_observed_snow[2:length_2000_end,:])
end


# for Monte Carlo Simulation Parameters have to change

# get a randomized variable for all parameters
function random_parameter(Min_Parameter, Max_Parameter)
        Rnum= rand(Float64)
        Parameter = Rnum .* (Max_Parameter - Min_Parameter) + Min_Parameter
        return Parameter
end

# get elevations at which precipitation was measured in each precipitation zone
# changed to 1400 in 2003
Elevations_113589 = Elevations(200., 1000., 2600., 1430.,1140)
Elevations_113597 = Elevations(200, 800, 2800, 1140, 1140)
Elevations_113670 = Elevations(200, 400, 2400, 635, 1140)
Elevations_114538 = Elevations(200, 600, 2400, 705, 1140)
Elevations_All_Zones = [Elevations_113589, Elevations_113597, Elevations_113670, Elevations_114538]

#get the total discharge
Total_Discharge = zeros(length(Temperature_Daily))
Inputs_All_Zones = Array{HRU_Input, 1}[]
Storages_All_Zones = Array{Storages, 1}[]
Precipitation_All_Zones = Array{Float64, 2}[]
Precipitation_Gradient = 0.0
Elevation_Percentage = Array{Float64, 1}[]
nmax = 3
Nr_Elevationbands_All_Zones = Int64[]
Elevations_Each_Precipitation_Zone = Array{Float64, 1}[]

for i in 1: length(ID_Prec_Zones)
        #print(ID_Prec_Zones)
        Precipitation = CSV.read("Gailtal/N-Tagessummen-"*string(ID_Prec_Zones[i])*".csv", header= false, skipto=Skipto[i], missingstring = "L\xfccke", decimal=',', delim = ';')
        Precipitation_Array = convert(Matrix, Precipitation)
        startindex = findfirst(isequal("01.01.1994 07:00:00   "), Precipitation_Array)
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
        push!(Precipitation_All_Zones, Precipitation)
        push!(Nr_Elevationbands_All_Zones, Nr_Elevationbands)
        push!(Elevations_Each_Precipitation_Zone, Elevation_HRUs)

        index_HRU = (findall(x -> x==ID_Prec_Zones[i], Areas_HRUs[1,2:end]))
        #print(Areas_HRUs[1,:])

        # for each precipitation zone get the relevant areal extentd
        Current_Areas_HRUs = convert(Matrix, Areas_HRUs[2: end, index_HRU])
        # the elevations of each HRU have to be known in order to get the right temperature data for each elevation
        Area_Bare_Elevations, Bare_Elevation_Count = getelevationsperHRU(Current_Areas_HRUs[:,1], Elevation_Catchment, Elevation_HRUs)
        Area_Forest_Elevations, Forest_Elevation_Count = getelevationsperHRU(Current_Areas_HRUs[:,2], Elevation_Catchment, Elevation_HRUs)
        Area_Grass_Elevations, Grass_Elevation_Count = getelevationsperHRU(Current_Areas_HRUs[:,3], Elevation_Catchment, Elevation_HRUs)
        Area_Rip_Elevations, Rip_Elevation_Count = getelevationsperHRU(Current_Areas_HRUs[:,4], Elevation_Catchment, Elevation_HRUs)
        #print(Bare_Elevation_Count, Forest_Elevation_Count, Grass_Elevation_Count, Rip_Elevation_Count)
        @assert 1 - eps(Float64) <= sum(Area_Bare_Elevations) <= 1 + eps(Float64)
        @assert 1 - eps(Float64) <= sum(Area_Forest_Elevations) <= 1 + eps(Float64)
        @assert 1 - eps(Float64) <= sum(Area_Grass_Elevations) <= 1 + eps(Float64)
        @assert 1 - eps(Float64) <= sum(Area_Rip_Elevations) <= 1 + eps(Float64)

        Area = Area_Zones[i]
        Current_Percentage_HRU = Percentage_HRU[:,1 + i]/Area
        #print(sum(Current_Percentage_HRU))
        # calculate percenatge of elevations
        Perc_Elevation = zeros(Total_Elevationbands_Catchment)
        for j in 1 : Total_Elevationbands_Catchment
                for h in 1:4
                        Perc_Elevation[j] += Current_Areas_HRUs[j,h] * Current_Percentage_HRU[h]
                end
        end
        Perc_Elevation = Perc_Elevation[(findall(x -> x!= 0, Perc_Elevation))]
        push!(Elevation_Percentage, Perc_Elevation)
        # calculate the inputs once for every precipitation zone because they will stay the same during the Monte Carlo Sampling
        bare_input = HRU_Input(Area_Bare_Elevations, Current_Percentage_HRU[1], 0.0, Bare_Elevation_Count, length(Bare_Elevation_Count), 0, [0], 0, [0], 0, 0)
        forest_input = HRU_Input(Area_Forest_Elevations, Current_Percentage_HRU[2], 0, Forest_Elevation_Count, length(Forest_Elevation_Count), 0, [0], 0, [0],  0, 0)
        grass_input = HRU_Input(Area_Grass_Elevations, Current_Percentage_HRU[3], 0, Grass_Elevation_Count,length(Grass_Elevation_Count), 0, [0], 0, [0],  0, 0)
        rip_input = HRU_Input(Area_Rip_Elevations, Current_Percentage_HRU[4], 0, Rip_Elevation_Count, length(Rip_Elevation_Count), 0, [0], 0, [0],  0, 0)

        all_inputs = [bare_input, forest_input, grass_input, rip_input]
        #print(typeof(all_inputs))
        push!(Inputs_All_Zones, all_inputs)

        bare_storage = Storages(0, zeros(length(Bare_Elevation_Count)), zeros(length(Bare_Elevation_Count)), zeros(length(Bare_Elevation_Count)), 0)
        forest_storage = Storages(0, zeros(length(Forest_Elevation_Count)), zeros(length(Forest_Elevation_Count)), zeros(length(Bare_Elevation_Count)), 0)
        grass_storage = Storages(0, zeros(length(Grass_Elevation_Count)), zeros(length(Grass_Elevation_Count)), zeros(length(Bare_Elevation_Count)), 0)
        rip_storage = Storages(0, zeros(length(Rip_Elevation_Count)), zeros(length(Rip_Elevation_Count)), zeros(length(Bare_Elevation_Count)), 0)

        all_storages = [bare_storage, forest_storage, grass_storage, rip_storage]
        push!(Storages_All_Zones, all_storages)
end
Total_Precipitation = Precipitation_All_Zones[1][:,1]*Area_Zones_Percent[1] + Precipitation_All_Zones[2][:,1]*Area_Zones_Percent[2] + Precipitation_All_Zones[3][:,1]*Area_Zones_Percent[3] + Precipitation_All_Zones[4][:,1]*Area_Zones_Percent[4]
#calculating the observed FDC; AC; Runoff
observed_FDC = flowdurationcurve(Observed_Discharge)[1]
observed_AC_1day = autocorrelation(Observed_Discharge, 1)
observed_AC_90day = autocorrelationcurve(Observed_Discharge, 90)[1]
observed_average_runoff = averagemonthlyrunoff(Area_Catchment, Total_Precipitation, Observed_Discharge, Timeseries)


All_Goodness = Float64[]
All_Discharges = Array{Float64,1}[]
All_Parameter_Sets = Array{Any, 1}[]
@time begin
for n in 1 : nmax
        Total_Discharge = zeros(length(Temperature_Daily))
        beta_Bare = round(random_parameter(0.1, 3), digits = 3)
        beta_Forest = round(random_parameter(0.1, 3), digits = 3)
        beta_Grass = round(random_parameter(0.1, 3), digits = 3)
        beta_Rip = round(random_parameter(0.1, 3), digits = 3)
        Ce = round(random_parameter(0.4, 0.8), digits = 3)
        Drainagecapacity = 0.0
        Interceptioncapacity_Bare = 0.0
        Interceptioncapacity_Forest = round(random_parameter(1, 3), digits=2)
        Interceptioncapacity_Grass = round(random_parameter(0, 2), digits=2)
        Interceptioncapacity_Rip = round(random_parameter(0, 2), digits=2)
        Kf = round(random_parameter(0.5, 3), digits=2)
        Kf_Rip = round(random_parameter(0.5, 5), digits=2)
        Meltfactor = round(random_parameter(1.75, 6), digits=2)
        Mm = round(random_parameter(0.001, 1.5), digits=4)
        Precipitation_Gradient = 0.0
        #Precipitation_Gradient = round(random_parameter(0, 0.0045), digits= 5)
        Ratio_Pref = round(random_parameter(0, 1), digits=3)
        Soilstoaragecapacity_Bare = round(random_parameter(5, 100), digits=1)
        Soilstoaragecapacity_Forest = round(random_parameter(70, 500), digits=1)
        Soilstoaragecapacity_Grass = round(random_parameter(50, 250), digits=1)
        Soilstoaragecapacity_Rip = round(random_parameter(50, 250), digits=1)
        Temp_Thresh = round(random_parameter(-2, 2), digits=3)
        Ks = round(random_parameter(0.001, 0.1), digits=4)
        Ratio_Riparian = round(random_parameter(0.05, 0.5), digits=2)
        GWStorage = 0.0

        bare_parameters = Parameters(beta_Bare, Ce, 0, Interceptioncapacity_Bare, Kf, Meltfactor, Mm, Ratio_Pref, Soilstoaragecapacity_Bare, Temp_Thresh)
        forest_parameters = Parameters(beta_Forest, Ce, 0, Interceptioncapacity_Forest, Kf, Meltfactor, Mm, Ratio_Pref, Soilstoaragecapacity_Forest, Temp_Thresh)
        grass_parameters = Parameters(beta_Grass, Ce, 0, Interceptioncapacity_Grass, Kf, Meltfactor, Mm, Ratio_Pref, Soilstoaragecapacity_Grass, Temp_Thresh)
        rip_parameters = Parameters(beta_Rip, Ce, Drainagecapacity, Interceptioncapacity_Rip, Kf, Meltfactor, Mm, Ratio_Pref, Soilstoaragecapacity_Rip, Temp_Thresh)
        slow_parameters = Slow_Paramters(Ks, Ratio_Riparian)
        Discharge, Snow_Extend, Total_GWStorage = runmodelprecipitationzones(Area_Zones, Elevations_Each_Precipitation_Zone, Elevation_Zone_Catchment, Potential_Evaporation, Precipitation_All_Zones, Temperature_Elevation_Catchment, ID_Prec_Zones, Inputs_All_Zones, Storages_All_Zones, GWStorage, bare_parameters, forest_parameters, grass_parameters, rip_parameters, slow_parameters, Nr_Elevationbands_All_Zones, Elevation_Percentage, observed_snow_cover, start2000)
        #writedlm( "Snowextend.csv",  Snow_Extend, ',')
        #Plots.display(plot(Total_GWStorage, title = "Run" * string(n)))
        #calculate goodness of parameter set
        # timeseries as Dates
        #calculate snow for each precipitation zone
        print(size(Snow_Extend[1]), typeof(Snow_Extend[1]), "\n")
        print(size(Snow_Extend[2]), typeof(Snow_Extend[2]), "\n")
        print(size(Snow_Extend[3]), typeof(Snow_Extend[3]), "\n")
        print(size(Snow_Extend[4]), typeof(Snow_Extend[4]), "\n")
        # Goodness_Fit = objectivefunctions(Total_Discharge, Snow_Cover, Observed_Discharge, observed_FDC, observed_AC_1day, observed_AC_90day, observed_average_runoff, Area_Catchment, Total_Precipitation, Timerseries)
        # if Goodness_Fit != -9999
        #         push!(All_Goodness, Goodness_Fit)
        #         push!(All_Discharges, Total_Discharge)
        #         All_Parameters = [bare_parameters, forest_parameters, grass_parameters, rip_parameters, slow_parameters]
        #         push!(All_Parameter_Sets, All_Parameters)
        # end
end
end
