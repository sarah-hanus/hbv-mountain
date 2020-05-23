using CSV
using DelimitedFiles
using Statistics
using DataFrames
using Plots

function runmodelprecipitationzones(Potential_Evaporation::Array{Float64,1}, Precipitation_All_Zones::Array{Array{Float64,2},1}, Temperature_Elevation_Catchment::Array{Float64,2}, Inputs_All_Zones::Array{Array{HRU_Input,1},1}, Storages_All_Zones::Array{Array{Storages,1},1}, SlowStorage::Float64, parameters::Array{Parameters,1}, slow_parameters::Slow_Paramters, Area_Zones::Array{Float64,1}, Area_Zones_Percent::Array{Float64,1}, Elevation_Percentage::Array{Array{Float64,1},1}, Elevation_Zone_Catchment::Array{Float64,1}, ID_Prec_Zones::Array{Int64,1}, Nr_Elevationbands_All_Zones::Array{Int64,1}, observed_snow_cover::Array{Array{Float64,2},1}, year_snow_observations::Int64, Elevations_Each_Precipitation_Zone)
        Total_Discharge = zeros(length(Precipitation_All_Zones[1][:,1]))
        Total_Snowstorage = zeros(length(Precipitation_All_Zones[1][:,1]))
        Total_GWstorage = zeros(length(Precipitation_All_Zones[1][:,1]))
        #Total_Snow_Elevations = Array{Float64,2}[]
        count = zeros(length(Precipitation_All_Zones[1][:,1]), length(Elevation_Zone_Catchment))
        Snow_Overall_Objective_Function = 0
        Snow_Elevations_All = zeros(length(Precipitation_All_Zones[1][:,1]), length(Elevation_Zone_Catchment))
        Snow_Extend_All = zeros(length(observed_snow_cover[1][:,1]), length(Elevation_Zone_Catchment))
        Snow_Extend_All_Observed = zeros(length(observed_snow_cover[1][:,1]), length(Elevation_Zone_Catchment))
        percentage = zeros(length(Precipitation_All_Zones[1][:,1]), length(Elevation_Zone_Catchment))
        percentage_Snow_Extend = zeros(length(observed_snow_cover[1][:,1]), length(Elevation_Zone_Catchment))
        percentage_soil = zeros(length(Precipitation_All_Zones[1][:,1]), 4)
        Soilstorage_All = zeros(length(Precipitation_All_Zones[1][:,1]), 4)
        for i in 1: length(ID_Prec_Zones)
                # take the storages and input of the specific precipitation zone
                Inputs_HRUs = Inputs_All_Zones[i]
                Storages_HRUs = Storages_All_Zones[i]
                # run the model for the specific precipitation zone
                Discharge, Snow_Extend, GWstorage, Snowstorage, Snow_Elevations, Soilstorage = runmodel_alloutput(Area_Zones[i], Potential_Evaporation, Precipitation_All_Zones[i], Temperature_Elevation_Catchment,
                        Inputs_HRUs[1], Inputs_HRUs[2], Inputs_HRUs[3], Inputs_HRUs[4],
                        Storages_HRUs[1], Storages_HRUs[2], Storages_HRUs[3], Storages_HRUs[4], SlowStorage,
                        parameters[1], parameters[2], parameters[3], parameters[4], slow_parameters, Nr_Elevationbands_All_Zones[i], Elevation_Percentage[i])
                # sum up the discharge of all precipitation zones
                Total_Discharge += Discharge
                Total_GWstorage += GWstorage * Area_Zones_Percent[i]
                Total_Snowstorage += Snowstorage * Area_Zones_Percent[i]
                #push!(Total_Snow_Elevations, Snow_Elevations)
                #snow extend is given as 0 or 1 for each elevation zone at each timestep)
                elevations = size(Snow_Extend)[2]
                # only use the modeled snow cover data that is in line with the observed snow cover data
                snow_cover_modelled = Snow_Extend[year_snow_observations: year_snow_observations + length(observed_snow_cover[i][:,1]) - 1, :]
                Mean_difference = 0
                All_Snow_Elevations = Array{Float64,1}[]
                #calculate the mean difference for all elevation zones
                for h in 1: elevations
                        Difference = snowcover(snow_cover_modelled[:,h], observed_snow_cover[i][:,h])
                        # take the area weighted average mean difference in snow cover
                        Mean_difference += Difference * Elevation_Percentage[i][h]
                        # Snow_Elevations_new = Snow_Elevations[:,h] * Elevation_Percentage[i][h] * Area_Zones_Percent[i]
                        # append!(All_Snow_Elevations, Snow_Elevations_new)
                end
                counter = 1
                for (h, current_elevation) in enumerate(Elevation_Zone_Catchment)
                        if counter <= length(Elevations_Each_Precipitation_Zone[i]) && Elevations_Each_Precipitation_Zone[i][counter] == current_elevation
                                Snow_Elevations_All[:,h] .+= Snow_Elevations[:,counter] .* Elevation_Percentage[i][counter] .* Area_Zones_Percent[i]
                                Snow_Extend_All[:,h] .+= snow_cover_modelled[:,counter] .* Elevation_Percentage[i][counter] .* Area_Zones_Percent[i]
                                Snow_Extend_All_Observed[:,h] .+= observed_snow_cover[i][:,counter] .* Elevation_Percentage[i][counter] .* Area_Zones_Percent[i]
                                percentage[:,h] .+= Elevation_Percentage[i][counter] .* Area_Zones_Percent[i] .* ones(length(Precipitation_All_Zones[1][:,1]))
                                percentage_Snow_Extend[:,h] .+= Elevation_Percentage[i][counter] .* Area_Zones_Percent[i] .* ones(length(observed_snow_cover[1][:,1]))
                                #plot(Snow_Elevations[:,counter], title=string(current_elevation))
                                #savefig("Gailtal/Calibration_8.05/Plots/Snowstorage_"*string(current_elevation)*string(ID_Prec_Zones[i])*".png")
                                counter += 1
                        end
                end
                # Soilstorage
                for h in 1:4
                        Soilstorage_All[:,h] .+= Soilstorage[:,h] .* Inputs_HRUs[h].Area_HRU .* Area_Zones_Percent[i]
                        percentage_soil[:,h] .+= Inputs_HRUs[h].Area_HRU .* Area_Zones_Percent[i] .* ones(length(Precipitation_All_Zones[1][:,1]))
                end

                #take the area weighted mean difference in snow cover
                Snow_Overall_Objective_Function += Mean_difference * Area_Zones_Percent[i]
        end
        # calculate the mean difference over all precipitation zones
        Snow_Elevations_All = Snow_Elevations_All ./ percentage
        Snow_Extend_All = Snow_Extend_All ./percentage_Snow_Extend
        Snow_Extend_All_Observed = Snow_Extend_All_Observed ./percentage_Snow_Extend
        Soilstorage_All = Soilstorage_All ./ percentage_soil
        return Total_Discharge::Array{Float64,1}, Snow_Overall_Objective_Function::Float64, Total_GWstorage::Array{Float64,1}, Total_Snowstorage::Array{Float64,1}, Snow_Elevations_All, Soilstorage_All, Snow_Extend_All, Snow_Extend_All_Observed
end

function run_bestparameters(path_to_best_parameter, nmax)

        local_path = "/home/sarah/"
        # ------------ CATCHMENT SPECIFIC INPUTS----------------
        ID_Prec_Zones = [113589, 113597, 113670, 114538]
        # size of the area of precipitation zones
        Area_Zones = [98227533.0, 184294158.0, 83478138.0, 220613195.0]
        Area_Catchment = sum(Area_Zones)
        Area_Zones_Percent = Area_Zones / Area_Catchment

        Mean_Elevation_Catchment = 1500 # in reality 1476
        Elevations_Catchment = Elevations(200.0, 400.0, 2800.0,1140.0, 1140.0)
        Sunhours_Vienna = [8.83, 10.26, 11.95, 13.75, 15.28, 16.11, 15.75, 14.36, 12.63, 10.9, 9.28, 8.43]
        # where to skip to in data file of precipitation measurements
        Skipto = [24, 22, 22, 22]
        # get the areal percentage of all elevation zones in the HRUs in the precipitation zones
        Areas_HRUs =  CSV.read(local_path*"HBVModel/Gailtal/HBV_Area_Elevation.csv", skipto=2, decimal=',', delim = ';')
        # get the percentage of each HRU of the precipitation zone
        Percentage_HRU = CSV.read(local_path*"HBVModel/Gailtal/HRUPercentage.csv", header=[1], decimal=',', delim = ';')
        Elevation_Catchment = convert(Vector, Areas_HRUs[2:end,1])
        startyear = 1983
        endyear = 2005


        #------------ TEMPERATURE AND POT. EVAPORATION CALCULATIONS ---------------------
        #Temperature is the same in whole catchment
        Temperature = CSV.read(local_path*"HBVModel/Gailtal/LTkont113597.csv", header=false, skipto = 20, missingstring = "L\xfccke", decimal='.', delim = ';')
        Temperature_Array = convert(Matrix, Temperature)
        startindex = findfirst(isequal("01.01."*string(startyear)*" 07:00:00"), Temperature_Array)
        endindex = findfirst(isequal("31.12."*string(endyear)*" 23:00:00"), Temperature_Array)
        Temperature_Array = Temperature_Array[startindex[1]:endindex[1],:]
        Temperature_Array[:,1] = Date.(Temperature_Array[:,1], Dates.DateFormat("d.m.y H:M:S"))
        Dates_Temperature_Daily, Temperature_Daily = daily_mean(Temperature_Array)
        # get the temperature data at each elevation
        Elevation_Zone_Catchment, Temperature_Elevation_Catchment, Total_Elevationbands_Catchment = gettemperatureatelevation(Elevations_Catchment, Temperature_Daily)
        # get the temperature data at the mean elevation to calculate the mean potential evaporation

        Temperature_Mean_Elevation = Temperature_Elevation_Catchment[:,findfirst(x-> x==1500, Elevation_Zone_Catchment)]
        Potential_Evaporation = getEpot_Daily_thornthwaite(Temperature_Mean_Elevation, Dates_Temperature_Daily, Sunhours_Vienna)

        # ------------ LOAD OBSERVED DISCHARGE DATA ----------------
        Discharge = CSV.read(local_path*"HBVModel/Gailtal/Q-Tagesmittel-212670.csv", header= false, skipto=23, decimal=',', delim = ';', types=[String, Float64])
        Discharge = convert(Matrix, Discharge)
        startindex = findfirst(isequal("01.01."*string(startyear)*" 00:00:00"), Discharge)
        endindex = findfirst(isequal("31.12."*string(endyear)*" 00:00:00"), Discharge)
        Observed_Discharge = Array{Float64,1}[]
        push!(Observed_Discharge, Discharge[startindex[1]:endindex[1],2])
        Observed_Discharge = Observed_Discharge[1]

        # ------------ LOAD TIMESERIES DATA AS DATES ------------------
        Timeseries = Date.(Discharge[startindex[1]:endindex[1],1], Dates.DateFormat("d.m.y H:M:S"))
        firstyear = Dates.year(Timeseries[1])
        lastyear = Dates.year(Timeseries[end])

        # ------------- LOAD OBSERVED SNOW COVER DATA PER PRECIPITATION ZONE ------------
        # find day wehere 2000 starts for snow cover calculations
        start2000 = findfirst(x -> x == Date(2000, 01, 01), Timeseries)
        length_2000_end = length(Observed_Discharge) - start2000 + 1
        observed_snow_cover = Array{Float64,2}[]
        for ID in ID_Prec_Zones
                current_observed_snow = readdlm(local_path*"HBVModel/Gailtal/snow_cover_fixed_"*string(ID)*".csv",',', Float64)
                current_observed_snow = current_observed_snow[1:length_2000_end,3: end]
                push!(observed_snow_cover, current_observed_snow)
        end

        # ------------- LOAD PRECIPITATION DATA OF EACH PRECIPITATION ZONE ----------------------
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
        Nr_Elevationbands_All_Zones = Int64[]
        Elevations_Each_Precipitation_Zone = Array{Float64, 1}[]

        for i in 1: length(ID_Prec_Zones)
                #print(ID_Prec_Zones)
                Precipitation = CSV.read(local_path*"HBVModel/Gailtal/N-Tagessummen-"*string(ID_Prec_Zones[i])*".csv", header= false, skipto=Skipto[i], missingstring = "L\xfccke", decimal=',', delim = ';')
                Precipitation_Array = convert(Matrix, Precipitation)
                startindex = findfirst(isequal("01.01."*string(startyear)*" 07:00:00   "), Precipitation_Array)
                endindex = findfirst(isequal("31.12."*string(endyear)*" 07:00:00   "), Precipitation_Array)
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
                # calculate percentage of elevations
                Perc_Elevation = zeros(Total_Elevationbands_Catchment)
                for j in 1 : Total_Elevationbands_Catchment
                        for h in 1:4
                                Perc_Elevation[j] += Current_Areas_HRUs[j,h] * Current_Percentage_HRU[h]
                        end
                end
                Perc_Elevation = Perc_Elevation[(findall(x -> x!= 0, Perc_Elevation))]
                @assert 0.99 <= sum(Perc_Elevation) <= 1.01
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
        # ---------------- CALCULATE OBSERVED OBJECTIVE FUNCTIONS -------------------------------------
        # calculate the sum of precipitation of all precipitation zones to calculate objective functions
        Total_Precipitation = Precipitation_All_Zones[1][:,1]*Area_Zones_Percent[1] + Precipitation_All_Zones[2][:,1]*Area_Zones_Percent[2] + Precipitation_All_Zones[3][:,1]*Area_Zones_Percent[3] + Precipitation_All_Zones[4][:,1]*Area_Zones_Percent[4]
        # don't consider spin up time for calculation of Goodness of Fit
        # end of spin up time is 3 years after the start of the calibration and start in the month October
        index_spinup = findfirst(x -> Dates.year(x) == firstyear + 2 && Dates.month(x) == 10, Timeseries)
        # evaluations chouls alsways contain whole year
        index_lastdate = findfirst(x -> Dates.year(x) == lastyear && Dates.month(x) == 10, Timeseries) - 1
        Timeseries_Obj = Timeseries[index_spinup: index_lastdate]
        Observed_Discharge_Obj = Observed_Discharge[index_spinup: index_lastdate]
        Total_Precipitation_Obj = Total_Precipitation[index_spinup: index_lastdate]
        #calculating the observed FDC; AC; Runoff
        observed_FDC = flowdurationcurve(Observed_Discharge_Obj)[1]
        observed_AC_1day = autocorrelation(Observed_Discharge_Obj, 1)
        observed_AC_90day = autocorrelationcurve(Observed_Discharge_Obj, 90)[1]
        observed_monthly_runoff = monthlyrunoff(Area_Catchment, Total_Precipitation_Obj, Observed_Discharge_Obj, Timeseries_Obj)[1]

        # ---------------- START MONTE CARLO SAMPLING ------------------------
        #All_Goodness_new = []
        All_Discharges = zeros(length(Observed_Discharge_Obj))
        All_GWstorage = zeros(length(Observed_Discharge_Obj))
        All_Snowstorage = zeros(length(Observed_Discharge_Obj))
        All_Snow_Elevations = Array{Float64,2}[]
        All_Soilstorage = Array{Float64,2}[]
        All_Snow_Extend_Modeled = Array{Float64,2}[]
        All_Snow_Extend_Observed = Array{Float64,2}[]

        #All_Parameter_Sets = Array{Any, 1}[]
        GWStorage = 40.0
        #print("worker ", ID, " preparation finished", "\n")
        count = 1
        number_Files = 0

        best_calibrations = readdlm(path_to_best_parameter, ',')
        parameters_best_calibrations = best_calibrations[1:nmax,10:29]

        #All_discharge = Array{Any, 1}[]
        for n in 1 : 1:size(parameters_best_calibrations)[1]
                #print(typeof(all_inputs))
                Current_Inputs_All_Zones = deepcopy(Inputs_All_Zones)
                Current_Storages_All_Zones = deepcopy(Storages_All_Zones)
                Current_GWStorage = deepcopy(GWStorage)
                beta_Bare, beta_Forest, beta_Grass, beta_Rip, Ce, Interceptioncapacity_Forest, Interceptioncapacity_Grass, Interceptioncapacity_Rip, Kf_Rip, Kf, Ks, Meltfactor, Mm, Ratio_Pref, Ratio_Riparian, Soilstoaragecapacity_Bare, Soilstoaragecapacity_Forest, Soilstoaragecapacity_Grass, Soilstoaragecapacity_Rip, Temp_Thresh = parameters_best_calibrations[n, :]
                bare_parameters = Parameters(beta_Bare, Ce, 0, 0.0, Kf, Meltfactor, Mm, Ratio_Pref, Soilstoaragecapacity_Bare, Temp_Thresh)
                forest_parameters = Parameters(beta_Forest, Ce, 0, Interceptioncapacity_Forest, Kf, Meltfactor, Mm, Ratio_Pref, Soilstoaragecapacity_Forest, Temp_Thresh)
                grass_parameters = Parameters(beta_Grass, Ce, 0, Interceptioncapacity_Grass, Kf, Meltfactor, Mm, Ratio_Pref, Soilstoaragecapacity_Grass, Temp_Thresh)
                rip_parameters = Parameters(beta_Rip, Ce, 0.0, Interceptioncapacity_Rip, Kf, Meltfactor, Mm, Ratio_Pref, Soilstoaragecapacity_Rip, Temp_Thresh)
                slow_parameters = Slow_Paramters(Ks, Ratio_Riparian)

                parameters = [bare_parameters, forest_parameters, grass_parameters, rip_parameters]
                parameters_array = parameters_best_calibrations[n, :]
                # parameter ranges
                #parameters, parameters_array = parameter_selection()
                Discharge, Snow_Extend, GWstorage, Snowstorage, Snow_Elevations, Soilstorage, Snow_Extend_Modeled, Snow_Extend_Observed = runmodelprecipitationzones(Potential_Evaporation, Precipitation_All_Zones, Temperature_Elevation_Catchment, Current_Inputs_All_Zones, Current_Storages_All_Zones, Current_GWStorage, parameters, slow_parameters, Area_Zones, Area_Zones_Percent, Elevation_Percentage, Elevation_Zone_Catchment, ID_Prec_Zones, Nr_Elevationbands_All_Zones, observed_snow_cover, start2000, Elevations_Each_Precipitation_Zone)

                All_Discharges = hcat(All_Discharges, Discharge[index_spinup: index_lastdate])
                All_GWstorage = hcat(All_GWstorage, GWstorage[index_spinup: index_lastdate])
                All_Snowstorage = hcat(All_Snowstorage, Snowstorage[index_spinup: index_lastdate])
                push!(All_Snow_Elevations, Snow_Elevations)
                push!(All_Soilstorage, Soilstorage)
                push!(All_Snow_Extend_Modeled, Snow_Extend_Modeled)
                push!(All_Snow_Extend_Observed, Snow_Extend_Observed)

                #calculate snow for each precipitation zone
                # don't calculate the goodness of fit for the spinup time!
                # Goodness_Fit, ObjFunctions = objectivefunctions(Discharge[index_spinup:index_lastdate], Snow_Extend, Observed_Discharge_Obj, observed_FDC, observed_AC_1day, observed_AC_90day, observed_monthly_runoff, Area_Catchment, Total_Precipitation_Obj, Timeseries_Obj)
                # #if goodness higher than -9999 save it
                # if Goodness_Fit != -9999
                #         Goodness = [Goodness_Fit, ObjFunctions, parameters_array]
                #         Goodness = collect(Iterators.flatten(Goodness))
                #         All_Goodness = hcat(All_Goodness, Goodness)
                #         #append!(All_Goodness_new, Goodness_new)
                #         #push!(All_Goodness, Goodness)
                #         if size(All_Goodness)[2]-1 == 100
                #                 All_Goodness = transpose(All_Goodness[:, 2:end])
                #                 if count != 100
                #                         open(local_path*"HBVModel/Gailtal_Parameterfit_"*string(ID)*"_"*string(number_Files)*".csv", "a") do io
                #                                 writedlm(io, All_Goodness,",")
                #                         end
                #                         count+= 1
                #                 else
                #                         open(local_path*"HBVModel/Gailtal_Parameterfit_"*string(ID)*"_"*string(number_Files)*".csv", "a") do io
                #                                 writedlm(io, All_Goodness,",")
                #                         end
                #                         count = 1
                #                         number_Files += 1
                #                 end
                #
                #                 #print("worker ", ID, " wrote 100 tested parameter sets to file.", "\n")
                #                 All_Goodness = zeros(29)
                #         end
                # end
                # if mod(n, 1000) == 0
                #         print("number of runs", n, "\n")
                # end
        end
        #All_Discharges = transpose(All_Discharges[:, 2:end])
        # open(local_path*"HBVModel/Gailtal_Parameterfit_"*string(ID)*".csv", "a") do io
        #         writedlm(io, All_Goodness,",")
        #end
        return All_Discharges[:, 2:end], All_GWstorage[:, 2:end], All_Snowstorage[:, 2:end], All_Snow_Elevations, All_Soilstorage, All_Snow_Extend_Modeled, All_Snow_Extend_Observed, Observed_Discharge_Obj, Timeseries_Obj
end

#All_Discharges, All_GWstorage, ALl_Snowstorage, All_Snow_Elevations, All_Soilstorage, All_Snow_Cover_Modeled, All_Snow_Cover_Observed, Observed_Discharge, Timeseries = run_bestparameters("Gailtal/Calibration_8.05/Gailtal_Parameterfit_best100.csv", 100)

# writedlm("Gailtal/Calibration_8.05/Discharges_best100.csv", All_Discharges)
# for i in 1:1
#         current_year = 1985+i
#         indexfirstday = findall(x -> x == Dates.firstdayofyear(Date(current_year,1,1)), Timeseries)[1]
#         indexlasttday = findall(x -> x == Dates.lastdayofyear(Date(2004,1,1)), Timeseries)[1]
#         plot!(Timeseries[indexfirstday:indexlasttday], Observed_Discharge[indexfirstday:indexlasttday], label="Observed",size=(1800,1000), color = ["red"])
#         plot(Timeseries[indexfirstday:indexlasttday], Observed_Discharge[indexfirstday:indexlasttday], label="Observed",size=(1800,1000), color = ["red"])
#         for h in 1:100
#                 plot!(Timeseries[indexfirstday:indexlasttday], All_Discharges[indexfirstday:indexlasttday, h], color = ["black"], legend=false, size=(1800,1000))
#         end
#
#         savefig("Gailtal/Calibration_8.05/Plots/Discharge_All"*string(current_year)*".png")
#         #plot GW storage
#         # plot()
#         # for h in 1:100
#         #         plot!(Timeseries[indexfirstday:indexlasttday], All_GWstorage[indexfirstday:indexlasttday, h], color = ["black"], legend=false, size=(1800,1000))
#         # end
#         # xlabel!("Timeseries")
#         # ylabel!("Slow Storage [mm]")
#         # title!("100 best parameters sets: Gailtal")
#         # savefig("Gailtal/Calibration_8.05/Plots/GWstorage_"*string(current_year)*".png")
#         # #plot Snow storage
#         # plot()
#         # for h in 1:100
#         #         plot!(Timeseries[indexfirstday:indexlasttday], ALl_Snowstorage[indexfirstday:indexlasttday, h], color = ["black"], legend=false, size=(1800,1000),)
#         # end
#         # xlabel!("Timeseries")
#         # ylabel!("Snow Storage [mm]")
#         # title!("100 best parameters sets: Gailtal")
#         # savefig("Gailtal/Calibration_8.05/Plots/Snowstorage_"*string(current_year)*".png")
#
# end
#Farben = palette(:tab20)
Farben = ["blue", "red", "green", "blue", "red", "green", "blue", "red", "green", "blue", "red", "green"]
current_elevation = collect(500:200:2700)
# labels_HRU = ["bare", "forest", "grass", "rip"]
for i in 1:1
        #plot()
        current_year = 1999+i
        indexfirstday = findall(x -> x == Dates.firstdayofyear(Date(current_year,1,1)), Timeseries)[1]
        indexlasttday = findall(x -> x == Dates.lastdayofyear(Date(current_year,1,1)), Timeseries)[1]
        endday_snow = 0
        startday_snow = 1
        endday_snow = 365*5
        for h in 1:1
        plot()
                for elevation in 10:12
                        index = findall(x-> x >= -1, All_Snow_Cover_Observed[h][startday_snow:endday_snow, elevation])
                        print(size(index))
                        #print(typeof(All_Snow_Cover_Observed[h][startday_snow:endday_snow, elevation]))
                        plot!(All_Snow_Cover_Modeled[h][startday_snow:endday_snow, elevation], color = Farben[elevation],label=string(current_elevation[elevation]), size=(2200,700))
                        scatter!(All_Snow_Cover_Observed[h][startday_snow:endday_snow, elevation], color = Farben[elevation], label=string(current_elevation[elevation]), size=(2200,700), ylims=(-0.1,1.1))
                end
        end
        xlabel!("Timeseries")
        ylabel!("Snow Cover")
        title!("Best parameter set: Gailtal")
        savefig("Gailtal/Calibration_8.05/Plots/Snow_Cover_high_elevations_all.png")

end
