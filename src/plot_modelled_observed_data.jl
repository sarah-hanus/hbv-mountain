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
        Faststorage_All = zeros(length(Precipitation_All_Zones[1][:,1]), 4)
        for i in 1: length(ID_Prec_Zones)
                # take the storages and input of the specific precipitation zone
                Inputs_HRUs = Inputs_All_Zones[i]
                Storages_HRUs = Storages_All_Zones[i]
                # run the model for the specific precipitation zone
                Discharge, Snow_Extend, GWstorage, Snowstorage, Snow_Elevations, Soilstorage, Faststorage = runmodel_alloutput(Area_Zones[i], Potential_Evaporation, Precipitation_All_Zones[i], Temperature_Elevation_Catchment,
                        Inputs_HRUs[1], Inputs_HRUs[2], Inputs_HRUs[3], Inputs_HRUs[4],
                        Storages_HRUs[1], Storages_HRUs[2], Storages_HRUs[3], Storages_HRUs[4], SlowStorage,
                        parameters[1], parameters[2], parameters[3], parameters[4], slow_parameters, Nr_Elevationbands_All_Zones[i], Elevation_Percentage[i])
                # sum up the discharge of all precipitation zones
                Total_Discharge += Discharge
                Total_GWstorage += GWstorage * Area_Zones_Percent[i]
                Total_Snowstorage += Snowstorage * Area_Zones_Percent[i]
                #push!(Total_Snow_Elevations, Snow_Elevations)
                #snow extend is given as 0 or 1 for each elevation zone at each timestep)
                elevations = size(observed_snow_cover[i],2)
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
                        if counter <= elevations && Elevations_Each_Precipitation_Zone[i][counter] == current_elevation
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
                        Faststorage_All[:,h] .+= Faststorage[:,h] .* Inputs_HRUs[h].Area_HRU .* Area_Zones_Percent[i]
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
        Faststorage_All = Faststorage_All ./ percentage_soil
        return Total_Discharge::Array{Float64,1}, Snow_Overall_Objective_Function::Float64, Total_GWstorage::Array{Float64,1}, Total_Snowstorage::Array{Float64,1}, Snow_Elevations_All, Soilstorage_All, Snow_Extend_All, Snow_Extend_All_Observed, Faststorage_All
end

function run_bestparameters_gailtal(path_to_best_parameter, nmax, startyear, endyear)

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
        index_spinup = findfirst(x -> Dates.year(x) == firstyear + 3, Timeseries)
        # evaluations chouls alsways contain whole year
        index_lastdate = findlast(x -> Dates.year(x) == lastyear, Timeseries)
        Timeseries_Obj = Timeseries[index_spinup: index_lastdate]
        Observed_Discharge_Obj = Observed_Discharge[index_spinup: index_lastdate]
        Total_Precipitation_Obj = Total_Precipitation[index_spinup: index_lastdate]
        #calculating the observed FDC; AC; Runoff
        observed_FDC = flowdurationcurve(Observed_Discharge_Obj)[1]
        observed_AC_1day = autocorrelation(Observed_Discharge_Obj, 1)
        observed_AC_90day = autocorrelationcurve(Observed_Discharge_Obj, 90)[1]
        observed_monthly_runoff = monthlyrunoff(Area_Catchment, Total_Precipitation_Obj, Observed_Discharge_Obj, Timeseries_Obj)[1]

        # ---------------- START MONTE CARLO SAMPLING ------------------------
        All_Discharges = zeros(length(Observed_Discharge_Obj))
        All_GWstorage = zeros(length(Observed_Discharge_Obj))
        All_Snowstorage = zeros(length(Observed_Discharge_Obj))
        All_Snow_Elevations = Array{Float64,2}[]
        All_Soilstorage = Array{Float64,2}[]
        All_Faststorage = Array{Float64,2}[]
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
                Discharge, Snow_Extend, GWstorage, Snowstorage, Snow_Elevations, Soilstorage, Snow_Extend_Modeled, Snow_Extend_Observed, Faststorage = runmodelprecipitationzones(Potential_Evaporation, Precipitation_All_Zones, Temperature_Elevation_Catchment, Current_Inputs_All_Zones, Current_Storages_All_Zones, Current_GWStorage, parameters, slow_parameters, Area_Zones, Area_Zones_Percent, Elevation_Percentage, Elevation_Zone_Catchment, ID_Prec_Zones, Nr_Elevationbands_All_Zones, observed_snow_cover, start2000, Elevations_Each_Precipitation_Zone)

                All_Discharges = hcat(All_Discharges, Discharge[index_spinup: index_lastdate])
                All_GWstorage = hcat(All_GWstorage, GWstorage[index_spinup: index_lastdate])
                All_Snowstorage = hcat(All_Snowstorage, Snowstorage[index_spinup: index_lastdate])
                push!(All_Snow_Elevations, Snow_Elevations[index_spinup: index_lastdate, :])
                push!(All_Soilstorage, Soilstorage[index_spinup: index_lastdate,:])
                push!(All_Faststorage, Faststorage[index_spinup: index_lastdate,:])
                push!(All_Snow_Extend_Modeled, Snow_Extend_Modeled)
                push!(All_Snow_Extend_Observed, Snow_Extend_Observed)

        end

        return All_Discharges[:, 2:end], All_GWstorage[:, 2:end], All_Snowstorage[:, 2:end], All_Snow_Elevations, All_Soilstorage, All_Snow_Extend_Modeled, All_Snow_Extend_Observed, Observed_Discharge_Obj, Timeseries_Obj, All_Faststorage
end

function run_bestparameters_palten(path_to_best_parameter, nmax, startyear, endyear)

        local_path = "/home/sarah/"
        # ------------ CATCHMENT SPECIFIC INPUTS----------------
        ID_Prec_Zones = [106120, 111815, 9900]
        # size of the area of precipitation zones
        Area_Zones = [198175943.0, 56544073.0, 115284451.3]
        Area_Catchment = sum(Area_Zones)
        Area_Zones_Percent = Area_Zones / Area_Catchment

        Mean_Elevation_Catchment = 1300 # in reality 1314
        Elevations_Catchment = Elevations(200.0, 600.0, 2600.0, 648.0, 648.0)
        Sunhours_Vienna = [8.83, 10.26, 11.95, 13.75, 15.28, 16.11, 15.75, 14.36, 12.63, 10.9, 9.28, 8.43]
        # where to skip to in data file of precipitation measurements
        Skipto = [22, 22]
        # get the areal percentage of all elevation zones in the HRUs in the precipitation zones
        Areas_HRUs =  CSV.read(local_path*"HBVModel/Palten/HBV_Area_Elevation_round.csv", skipto=2, decimal='.', delim = ',')
        # get the percentage of each HRU of the precipitation zone
        Percentage_HRU = CSV.read(local_path*"HBVModel/Palten/HRU_Prec_Zones.csv", header=[1], decimal='.', delim = ',')
        Elevation_Catchment = convert(Vector, Areas_HRUs[2:end,1])
        # timeperiod for which model should be run (look if timeseries of data has same length)
        Timeseries = collect(Date(startyear, 1, 1):Day(1):Date(endyear,12,31))

        # ----------- PRECIPITATION 106120 --------------

        Precipitation = CSV.read(local_path*"HBVModel/Palten/N-Tagessummen-"*string(ID_Prec_Zones[1])*".csv", header= false, skipto=Skipto[1], missingstring = "L\xfccke", decimal=',', delim = ';')
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
        Precipitation_106120 = convert(Matrix, df)
        #print(Precipitation_Array[1:10,2],"\n")

        #------------ TEMPERATURE AND POT. EVAPORATION CALCULATIONS ---------------------
        #Temperature is the same in whole catchment
        Temperature = CSV.read(local_path*"HBVModel/Palten/prenner_tag_9900.dat", header = true, skipto = 3, delim = ' ', ignorerepeated = true)

        # get data for 20 years: from 1987 to end of 2006
        # from 1986 to 2005 13669: 20973
        #hydrological year 13577:20881
        Temperature = dropmissing(Temperature)
        Temperature_Array = Temperature.t / 10
        Precipitation_9900 = Temperature.nied / 10
        Timeseries_Temp = Date.(Temperature.datum, Dates.DateFormat("yyyymmdd"))
        startindex = findfirst(isequal(Date(startyear, 1, 1)), Timeseries_Temp)
        endindex = findfirst(isequal(Date(endyear, 12, 31)), Timeseries_Temp)
        Temperature_Daily = Temperature_Array[startindex[1]:endindex[1]]
        #Timeseries_Temp = Timeseries[startindex[1]:endindex[1]]
        Dates_Temperature_Daily = Timeseries_Temp[startindex[1]:endindex[1]]
        Dates_missing_Temp = Dates_Temperature_Daily[findall(x-> x == 999.9, Temperature_Daily)]

        # --- also more dates missing 16.3.03 - 30.3.03
        Dates_missing =  collect(Date(2003,3,17):Day(1):Date(2003,3,30))

        Dates_Temperature_Daily_all = Array{Date,1}(undef, 0)
        Temperature_Daily_all = Array{Float64,1}(undef, 0)
        # index where Dates are missing
        index = findall(x -> x == Date(2003,3,17) - Day(1), Dates_Temperature_Daily)[1]
        append!(Dates_Temperature_Daily_all, Dates_Temperature_Daily[1:index])
        append!(Dates_Temperature_Daily_all, Dates_missing)
        append!(Dates_Temperature_Daily_all, Dates_Temperature_Daily[index+1:end])



        @assert Dates_Temperature_Daily_all == Timeseries
        # ----------- add Temperature for missing temperature -------------------
        # station 13120 is 100 m higher than station 9900, so 0.6 °C colder
        Temperature_13120 = CSV.read(local_path*"HBVModel/Palten/prenner_tag_13120.dat", header = true, skipto = 3, delim = ' ', ignorerepeated = true)
        Temperature_13120 = dropmissing(Temperature_13120)
        Temperature_Array_13120 = Temperature_13120.t / 10
        Timeseries_13120 = Date.(Temperature_13120.datum, Dates.DateFormat("yyyymmdd"))
        index = Int[]
        for i in 1:length(Dates_missing_Temp)
                append!(index, findall(x -> x == Dates_missing_Temp[i], Timeseries_13120))
        end
        Temperature_13120_missing_data = Temperature_Array_13120[index] + ones(length(index))*0.6
        Temperature_Daily[findall(x-> x == 999.9, Temperature_Daily)] .= Temperature_13120_missing_data

        Temperature_Daily_all = Array{Float64,1}(undef, 0)
        # index where Dates are missing
        index = findall(x -> x == Date(2003,3,17) - Day(1), Dates_Temperature_Daily)[1]
        index_missing_dataset = Int[]
        for i in 1:length(Dates_missing)
                append!(index_missing_dataset, findall(x -> x == Dates_missing[i], Timeseries_13120))
        end
        #Temperature_13120_missing_data = Temperature_Array_13120[index] + ones(length(Temperature_13120_missing_data))*0.6
        append!(Temperature_Daily_all, Temperature_Daily[1:index])
        append!(Temperature_Daily_all, Temperature_Array_13120[index_missing_dataset] + ones(length(index_missing_dataset))*0.6)
        append!(Temperature_Daily_all, Temperature_Daily[index+1:end])

        Temperature_Daily = Temperature_Daily_all
        # ---------- Precipitation Data for Zone 9900 -------------------

        Precipitation_9900 = Precipitation_9900[startindex[1]:endindex[1]]
        # data is -1 for no precipitation at all
        Precipitation_9900[findall(x -> x == -0.1, Precipitation_9900)] .= 0.0
        # for the days where there is no precipitation data use the precipitation of the next station (106120)
        #Precipitation_9900[findall(x-> x == 999.9, Precipitation_9900)] .= Precipitation_106120[findall(x-> x == 999.9, Precipitation_9900),2]

        Precipitation_9900_all = Array{Float64,1}(undef, 0)

        append!(Precipitation_9900_all, Precipitation_9900[1:index])
        append!(Precipitation_9900_all, Precipitation_106120[index+1:index+length(Dates_missing),2])
        append!(Precipitation_9900_all, Precipitation_9900[index+1:end])

        Precipitation_9900_all[findall(x-> x == 999.9, Precipitation_9900_all)] .= Precipitation_106120[findall(x-> x == 999.9, Precipitation_9900_all),2]

        Precipitation_9900 = Precipitation_9900_all
        #Dates_Temperature_Daily, Temperature_Daily = daily_mean(Timeseries, Temperature_Array)

        # Temperature = CSV.read(local_path*"HBVModel/Gailtal/LTkont113597.csv", header=false, skipto = 20, missingstring = "L\xfccke", decimal='.', delim = ';')
        # Temperature_Array = convert(Matrix, Temperature)
        # startindex = findfirst(isequal("01.01."*string(startyear)*" 07:00:00"), Temperature_Array)
        # endindex = findfirst(isequal("31.12."*string(endyear)*" 23:00:00"), Temperature_Array)
        # Temperature_Array = Temperature_Array[startindex[1]:endindex[1],:]
        # Temperature_Array[:,1] = Date.(Temperature_Array[:,1], Dates.DateFormat("d.m.y H:M:S"))
        # Dates_Temperature_Daily, Temperature_Daily = daily_mean(Temperature_Array)
        # get the temperature data at each elevation
        Elevation_Zone_Catchment, Temperature_Elevation_Catchment, Total_Elevationbands_Catchment = gettemperatureatelevation(Elevations_Catchment, Temperature_Daily)
        # get the temperature data at the mean elevation to calculate the mean potential evaporation
        Temperature_Mean_Elevation = Temperature_Elevation_Catchment[:,findfirst(x-> x==Mean_Elevation_Catchment, Elevation_Zone_Catchment)]
        Potential_Evaporation = getEpot_Daily_thornthwaite(Temperature_Mean_Elevation, Timeseries, Sunhours_Vienna)

        # ------------ LOAD OBSERVED DISCHARGE DATA ----------------
        Discharge = CSV.read(local_path*"HBVModel/Palten/Q-Tagesmittel-210815.csv", header= false, skipto=21, decimal=',', delim = ';', types=[String, Float64])
        Discharge = convert(Matrix, Discharge)
        startindex = findfirst(isequal("01.01."*string(startyear)*" 00:00:00"), Discharge)
        endindex = findfirst(isequal("31.12."*string(endyear)*" 00:00:00"), Discharge)
        Observed_Discharge = Array{Float64,1}[]
        push!(Observed_Discharge, Discharge[startindex[1]:endindex[1],2])
        Observed_Discharge = Observed_Discharge[1]

        # ------------ LOAD TIMESERIES DATA AS DATES ------------------
        #Timeseries = Date.(Discharge[startindex[1]:endindex[1],1], Dates.DateFormat("d.m.y H:M:S"))
        firstyear = Dates.year(Timeseries[1])
        lastyear = Dates.year(Timeseries[end])

        # ------------- LOAD OBSERVED SNOW COVER DATA PER PRECIPITATION ZONE ------------
        # find day wehere 2000 starts for snow cover calculations
        start2000 = findfirst(x -> x == Date(2000, 01, 01), Timeseries)
        length_2000_end = length(Timeseries) - start2000 + 1
        observed_snow_cover = Array{Float64,2}[]
        for ID in ID_Prec_Zones
                current_observed_snow = readdlm(local_path*"HBVModel/Palten/snow_cover_fixed_Zone"*string(ID)*".csv",',', Float64)
                current_observed_snow = current_observed_snow[1:length_2000_end,3: end]
                push!(observed_snow_cover, current_observed_snow)
        end

        # ------------- LOAD PRECIPITATION DATA OF EACH PRECIPITATION ZONE ----------------------
        # get elevations at which precipitation was measured in each precipitation zone
        # changed to 1400 in 2003
        Elevations_106120= Elevations(200., 600., 2600., 1265.,648.)
        Elevations_111815 = Elevations(200, 600, 2400, 890., 648.)
        Elevations_9900 = Elevations(200, 600, 2400, 648., 648.)
        Elevations_All_Zones = [Elevations_106120, Elevations_111815, Elevations_9900]

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
                if ID_Prec_Zones[i] == 106120 || ID_Prec_Zones[i] == 111815
                        #print(ID_Prec_Zones[i])
                        Precipitation = CSV.read(local_path*"HBVModel/Palten/N-Tagessummen-"*string(ID_Prec_Zones[i])*".csv", header= false, skipto=Skipto[i], missingstring = "L\xfccke", decimal=',', delim = ';')
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
                else
                        Precipitation_Array = Precipitation_9900
                        # for all non data values use values of other precipitation zone
                        Elevation_HRUs, Precipitation, Nr_Elevationbands = getprecipitationatelevation(Elevations_All_Zones[i], Precipitation_Gradient, Precipitation_Array)
                        push!(Precipitation_All_Zones, Precipitation)
                        push!(Nr_Elevationbands_All_Zones, Nr_Elevationbands)
                        push!(Elevations_Each_Precipitation_Zone, Elevation_HRUs)
                end



                index_HRU = (findall(x -> x==ID_Prec_Zones[i], Areas_HRUs[1,2:end]))
                # for each precipitation zone get the relevant areal extentd
                Current_Areas_HRUs = convert(Matrix, Areas_HRUs[2: end, index_HRU])
                # the elevations of each HRU have to be known in order to get the right temperature data for each elevation
                Area_Bare_Elevations, Bare_Elevation_Count = getelevationsperHRU(Current_Areas_HRUs[:,1], Elevation_Catchment, Elevation_HRUs)
                Area_Forest_Elevations, Forest_Elevation_Count = getelevationsperHRU(Current_Areas_HRUs[:,2], Elevation_Catchment, Elevation_HRUs)
                Area_Grass_Elevations, Grass_Elevation_Count = getelevationsperHRU(Current_Areas_HRUs[:,3], Elevation_Catchment, Elevation_HRUs)

                Area_Rip_Elevations, Rip_Elevation_Count = getelevationsperHRU(Current_Areas_HRUs[:,4], Elevation_Catchment, Elevation_HRUs)
                #print(Bare_Elevation_Count, Forest_Elevation_Count, Grass_Elevation_Count, Rip_Elevation_Count)
                @assert 0.999 <= sum(Area_Bare_Elevations) <= 1.0001
                @assert 0.999 <= sum(Area_Forest_Elevations) <= 1.0001
                @assert 0.999 <= sum(Area_Grass_Elevations) <= 1.0001
                @assert 0.999 <= sum(Area_Rip_Elevations) <= 1.0001

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
        Total_Precipitation = Precipitation_All_Zones[1][:,1]*Area_Zones_Percent[1] + Precipitation_All_Zones[2][:,1]*Area_Zones_Percent[2] + Precipitation_All_Zones[3][:,1]*Area_Zones_Percent[3]

        #check_waterbalance = hcat(Total_Precipitation, Observed_Discharge, Potential_Evaporation)

        # don't consider spin up time for calculation of Goodness of Fit
        # end of spin up time is 3 years after the start of the calibration and start in the month October
        index_spinup = findfirst(x -> Dates.year(x) == firstyear + 3, Timeseries)
        # evaluations chouls alsways contain whole year
        index_lastdate = findlast(x -> Dates.year(x) == lastyear, Timeseries)
        Timeseries_Obj = Timeseries[index_spinup: index_lastdate]
        Observed_Discharge_Obj = Observed_Discharge[index_spinup: index_lastdate]
        Total_Precipitation_Obj = Total_Precipitation[index_spinup: index_lastdate]
        #calculating the observed FDC; AC; Runoff
        observed_FDC = flowdurationcurve(log.(Observed_Discharge_Obj))[1]
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
        All_Faststorage = Array{Float64,2}[]
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
                Discharge, Snow_Extend, GWstorage, Snowstorage, Snow_Elevations, Soilstorage, Snow_Extend_Modeled, Snow_Extend_Observed, Faststorage = runmodelprecipitationzones(Potential_Evaporation, Precipitation_All_Zones, Temperature_Elevation_Catchment, Current_Inputs_All_Zones, Current_Storages_All_Zones, Current_GWStorage, parameters, slow_parameters, Area_Zones, Area_Zones_Percent, Elevation_Percentage, Elevation_Zone_Catchment, ID_Prec_Zones, Nr_Elevationbands_All_Zones, observed_snow_cover, start2000, Elevations_Each_Precipitation_Zone)

                All_Discharges = hcat(All_Discharges, Discharge[index_spinup: index_lastdate])
                All_GWstorage = hcat(All_GWstorage, GWstorage[index_spinup: index_lastdate])
                All_Snowstorage = hcat(All_Snowstorage, Snowstorage[index_spinup: index_lastdate])
                push!(All_Snow_Elevations, Snow_Elevations)
                push!(All_Soilstorage, Soilstorage)
                push!(All_Faststorage, Faststorage)
                push!(All_Snow_Extend_Modeled, Snow_Extend_Modeled)
                push!(All_Snow_Extend_Observed, Snow_Extend_Observed)

        end

        return All_Discharges[:, 2:end], All_GWstorage[:, 2:end], All_Snowstorage[:, 2:end], All_Snow_Elevations, All_Soilstorage, All_Snow_Extend_Modeled, All_Snow_Extend_Observed, Observed_Discharge_Obj, Timeseries_Obj, All_Faststorage
end

function run_bestparameters_feistritz(path_to_best_parameter, nmax, startyear, endyear)
        local_path = "/home/sarah/"
        # ------------ CATCHMENT SPECIFIC INPUTS----------------
        ID_Prec_Zones = [109967]
        # size of the area of precipitation zones
        Area_Zones = [115496400.]
        Area_Catchment = sum(Area_Zones)
        Area_Zones_Percent = Area_Zones / Area_Catchment

        Mean_Elevation_Catchment = 900 # in reality 917
        # two last entries of array are height of temp measurement
        Elevations_Catchment = Elevations(200.0, 400.0, 1600.0, 488., 488.)
        Sunhours_Vienna = [8.83, 10.26, 11.95, 13.75, 15.28, 16.11, 15.75, 14.36, 12.63, 10.9, 9.28, 8.43]
        # where to skip to in data file of precipitation measurements
        Skipto = [24]
        # get the areal percentage of all elevation zones in the HRUs in the precipitation zones
        Areas_HRUs =  CSV.read(local_path*"HBVModel/Feistritz/HBV_Area_Elevation.csv", skipto=2, decimal='.', delim = ',')
        # get the percentage of each HRU of the precipitation zone
        Percentage_HRU = CSV.read(local_path*"HBVModel/Feistritz/HRU_Prec_Zones.csv", header=[1], decimal='.', delim = ',')
        Elevation_Catchment = convert(Vector, Areas_HRUs[2:end,1])
        # timeperiod for which model should be run (look if timeseries of data has same length)
        Timeseries = collect(Date(startyear, 1, 1):Day(1):Date(endyear,12,31))

        #------------ TEMPERATURE AND POT. EVAPORATION CALCULATIONS ---------------------
        #Temperature is the same in whole catchment
        Temperature = CSV.read(local_path*"HBVModel/Feistritz/prenner_tag_10510.dat", header = true, skipto = 3, delim = ' ', ignorerepeated = true)

        # get data for 20 years: from 1987 to end of 2006
        # from 1986 to 2005 13669: 20973
        #hydrological year 13577:20881
        Temperature = dropmissing(Temperature)
        Temperature_Array = Temperature.t / 10
        #Precipitation_9900 = Temperature.nied / 10
        Timeseries_Temp = Date.(Temperature.datum, Dates.DateFormat("yyyymmdd"))
        startindex = findfirst(isequal(Date(startyear, 1, 1)), Timeseries_Temp)
        endindex = findfirst(isequal(Date(endyear, 12, 31)), Timeseries_Temp)
        Temperature_Daily = Temperature_Array[startindex[1]:endindex[1]]
        Timeseries_Temp = Timeseries_Temp[startindex[1]:endindex[1]]

        @assert Timeseries_Temp == Timeseries
        #println("works", "\n")
        Elevation_Zone_Catchment, Temperature_Elevation_Catchment, Total_Elevationbands_Catchment = gettemperatureatelevation(Elevations_Catchment, Temperature_Daily)
        # get the temperature data at the mean elevation to calculate the mean potential evaporation
        Temperature_Mean_Elevation = Temperature_Elevation_Catchment[:,findfirst(x-> x==Mean_Elevation_Catchment, Elevation_Zone_Catchment)]
        Potential_Evaporation = getEpot_Daily_thornthwaite(Temperature_Mean_Elevation, Timeseries, Sunhours_Vienna)

        # ------------ LOAD OBSERVED DISCHARGE DATA ----------------
        Discharge = CSV.read(local_path*"HBVModel/Feistritz/Q-Tagesmittel-214353.csv", header= false, skipto=388, decimal=',', delim = ';', types=[String, Float64])
        Discharge = convert(Matrix, Discharge)
        startindex = findfirst(isequal("01.01."*string(startyear)*" 00:00:00"), Discharge)
        endindex = findfirst(isequal("31.12."*string(endyear)*" 00:00:00"), Discharge)
        Observed_Discharge = Array{Float64,1}[]
        push!(Observed_Discharge, Discharge[startindex[1]:endindex[1],2])
        Observed_Discharge = Observed_Discharge[1]
        # ------------ LOAD TIMESERIES DATA AS DATES ------------------
        #Timeseries = Date.(Discharge[startindex[1]:endindex[1],1], Dates.DateFormat("d.m.y H:M:S"))
        firstyear = Dates.year(Timeseries[1])
        lastyear = Dates.year(Timeseries[end])

        # ------------- LOAD OBSERVED SNOW COVER DATA PER PRECIPITATION ZONE ------------
        # find day wehere 2000 starts for snow cover calculations
        start2000 = findfirst(x -> x == Date(2000, 01, 01), Timeseries)
        length_2000_end = length(Timeseries) - start2000 + 1
        observed_snow_cover = Array{Float64,2}[]
        for ID in ID_Prec_Zones
                current_observed_snow = readdlm(local_path*"HBVModel/Feistritz/snow_cover_fixed_Zone"*string(ID)*".csv",',', Float64)
                current_observed_snow = current_observed_snow[1:length_2000_end,3: end]
                push!(observed_snow_cover, current_observed_snow)
        end

        # ------------- LOAD PRECIPITATION DATA OF EACH PRECIPITATION ZONE ----------------------
        # get elevations at which precipitation was measured in each precipitation zone
        Elevations_109967= Elevations(200., 400., 1600., 563.,488.)
        # Elevations_111815 = Elevations(200, 600, 2400, 890., 648.)
        # Elevations_9900 = Elevations(200, 600, 2400, 648., 648.)
        Elevations_All_Zones = [Elevations_109967]

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
                Precipitation = CSV.read(local_path*"HBVModel/Feistritz/N-Tagessummen-"*string(ID_Prec_Zones[i])*".csv", header= false, skipto=Skipto[i], missingstring = "L\xfccke", decimal=',', delim = ';')
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
                println((Area_Bare_Elevations), " ", Bare_Elevation_Count,"\n")
                println((Area_Forest_Elevations), " ", Forest_Elevation_Count,"\n")
                Area_Bare_Elevations = [0.0]
                Bare_Elevation_Count = [1]
                @assert 0.999 <= sum(Area_Bare_Elevations) <= 1.0001 || sum(Area_Bare_Elevations) == 0

                @assert 0.999 <= sum(Area_Forest_Elevations) <= 1.0001
                @assert 0.999 <= sum(Area_Grass_Elevations) <= 1.0001
                @assert 0.999 <= sum(Area_Rip_Elevations) <= 1.0001

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
        #Total_Precipitation = Precipitation_All_Zones[1][:,1]*Area_Zones_Percent[1] + Precipitation_All_Zones[2][:,1]*Area_Zones_Percent[2] + Precipitation_All_Zones[3][:,1]*Area_Zones_Percent[3]
        Total_Precipitation = Precipitation_All_Zones[1][:,1]
        #check_waterbalance = hcat(Total_Precipitation, Observed_Discharge, Potential_Evaporation)

        # don't consider spin up time for calculation of Goodness of Fit
        # end of spin up time is 3 years after the start of the calibration and start in the month October
        index_spinup = findfirst(x -> Dates.year(x) == firstyear + 3, Timeseries)
        # evaluations chouls alsways contain whole year
        index_lastdate = findlast(x -> Dates.year(x) == lastyear, Timeseries)
        Timeseries_Obj = Timeseries[index_spinup: index_lastdate]
        Observed_Discharge_Obj = Observed_Discharge[index_spinup: index_lastdate]
        Total_Precipitation_Obj = Total_Precipitation[index_spinup: index_lastdate]
        #calculating the observed FDC; AC; Runoff
        observed_FDC = flowdurationcurve(log.(Observed_Discharge_Obj))[1]
        observed_AC_1day = autocorrelation(Observed_Discharge_Obj, 1)
        observed_AC_90day = autocorrelationcurve(Observed_Discharge_Obj, 90)[1]
        observed_monthly_runoff = monthlyrunoff(Area_Catchment, Total_Precipitation_Obj, Observed_Discharge_Obj, Timeseries_Obj)[1]

        # ---------------- START MONTE CARLO SAMPLING ------------------------
        All_Discharges = zeros(length(Observed_Discharge_Obj))
        All_GWstorage = zeros(length(Observed_Discharge_Obj))
        All_Snowstorage = zeros(length(Observed_Discharge_Obj))
        All_Snow_Elevations = Array{Float64,2}[]
        All_Soilstorage = Array{Float64,2}[]
        All_Faststorage = Array{Float64,2}[]
        All_Snow_Extend_Modeled = Array{Float64,2}[]
        All_Snow_Extend_Observed = Array{Float64,2}[]

        #All_Parameter_Sets = Array{Any, 1}[]
        GWStorage = 70.0
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
                Discharge, Snow_Extend, GWstorage, Snowstorage, Snow_Elevations, Soilstorage, Snow_Extend_Modeled, Snow_Extend_Observed, Faststorage = runmodelprecipitationzones(Potential_Evaporation, Precipitation_All_Zones, Temperature_Elevation_Catchment, Current_Inputs_All_Zones, Current_Storages_All_Zones, Current_GWStorage, parameters, slow_parameters, Area_Zones, Area_Zones_Percent, Elevation_Percentage, Elevation_Zone_Catchment, ID_Prec_Zones, Nr_Elevationbands_All_Zones, observed_snow_cover, start2000, Elevations_Each_Precipitation_Zone)

                All_Discharges = hcat(All_Discharges, Discharge[index_spinup: index_lastdate])
                All_GWstorage = hcat(All_GWstorage, GWstorage[index_spinup: index_lastdate])
                All_Snowstorage = hcat(All_Snowstorage, Snowstorage[index_spinup: index_lastdate])
                push!(All_Snow_Elevations, Snow_Elevations)
                push!(All_Soilstorage, Soilstorage)
                push!(All_Faststorage, Faststorage)
                push!(All_Snow_Extend_Modeled, Snow_Extend_Modeled)
                push!(All_Snow_Extend_Observed, Snow_Extend_Observed)

        end

        return All_Discharges[:, 2:end], All_GWstorage[:, 2:end], All_Snowstorage[:, 2:end], All_Snow_Elevations, All_Soilstorage, All_Snow_Extend_Modeled, All_Snow_Extend_Observed, Observed_Discharge_Obj, Timeseries_Obj, All_Faststorage
end
# ---------- RUN MODEL TO GET DISCHARGE, GW, SNOW AND SOIL DATA
#Catchment_Name = "Gailtal"
#All_Discharges, All_GWstorage, ALl_Snowstorage, All_Snow_Elevations, All_Soilstorage, All_Snow_Cover_Modeled, All_Snow_Cover_Observed, Observed_Discharge, Timeseries, All_Faststorage = run_bestparameters_gailtal("/home/sarah/Master/Thesis/Calibrations/Gailtal/Calibration8-10.5/Gailtal_Parameterfit_best100.csv", 100, 1983, 2009)
#Catchment_Name = "Paltental"
#All_Discharges, All_GWstorage, ALl_Snowstorage, All_Snow_Elevations, All_Soilstorage, All_Snow_Cover_Modeled, All_Snow_Cover_Observed, Observed_Discharge, Timeseries, All_Faststorage = run_bestparameters_palten("/home/sarah/Master/Thesis/Calibrations/Paltental/Paltental_Parameterfit_All_best_100.csv", 100, 1983, 2009)
Catchment_Name = "Feistritz"
#All_Discharges, All_GWstorage, ALl_Snowstorage, All_Snow_Elevations, All_Soilstorage, All_Snow_Cover_Modeled, All_Snow_Cover_Observed, Observed_Discharge, Timeseries, All_Faststorage = run_bestparameters_feistritz("/home/sarah/Master/Thesis/Calibrations/Feistritz/Feistritz_best_4.2MioRuns/Feistritz_Parameterfit_All_best_100.csv", 100, 1983, 2013)


function plot_hydrographs(All_Discharges, Timeseries, Catchment_Name, Nr_Years)
        for i in 1:Nr_Years
                current_year = 1985+i
                indexfirstday = findall(x -> x == Dates.firstdayofyear(Date(current_year,1,1)), Timeseries)[1]
                indexlasttday = findall(x -> x == Dates.lastdayofyear(Date(current_year,1,1)), Timeseries)[1]
                plot()
                for h in 1:100
                        plot!(Timeseries[indexfirstday:indexlasttday], All_Discharges[indexfirstday:indexlasttday, h], color = ["black"], legend=false, size=(1800,1000))
                end
                plot!(Timeseries[indexfirstday:indexlasttday], Observed_Discharge[indexfirstday:indexlasttday], label="Observed",size=(1800,1000), color = ["red"], linewidth = 3)
                ylabel!("Discharge [m³/s]")
                xlabel!("Time in Year")
                savefig("/home/sarah/Master/Thesis/Results/Calibration/"*Catchment_Name*"/Discharge/Discharge_All_"*string(current_year)*".png")
        end
end

function plot_gwstorage(GW_Storage, Timeseries, Catchment_Name, Nr_Years)
        for i in 1:Nr_Years
                current_year = 1985+i
                indexfirstday = findall(x -> x == Dates.firstdayofyear(Date(current_year,1,1)), Timeseries)[1]
                indexlasttday = findall(x -> x == Dates.lastdayofyear(Date(current_year,1,1)), Timeseries)[1]
                plot()
                for h in 1:100
                        plot!(Timeseries[indexfirstday:indexlasttday], GW_Storage[indexfirstday:indexlasttday, h], color = ["black"], legend=false, size=(1800,1000))
                end
                #plot!(Timeseries[indexfirstday:indexlasttday], Observed_Discharge[indexfirstday:indexlasttday], label="Observed",size=(1800,1000), color = ["red"])
                ylabel!("Slow Storage [mm]")
                xlabel!("Time in Year")
                savefig("/home/sarah/Master/Thesis/Results/Calibration/"*Catchment_Name*"/GWStorage/GW_Storage_"*string(current_year)*".png")
        end

        current_year = 1986
        indexfirstday = findall(x -> x == Dates.firstdayofyear(Date(current_year,1,1)), Timeseries)[1]
        indexlasttday = findall(x -> x == Dates.lastdayofyear(Date(2009,1,1)), Timeseries)[1]
        plot()
        for h in 1:100
                plot!(Timeseries[indexfirstday:indexlasttday], GW_Storage[indexfirstday:indexlasttday, h], color = ["black"], legend=false, size=(1800,1000))
        end
        ylabel!("Slow Storage [mm]")
        xlabel!("Time in Year")
        savefig("/home/sarah/Master/Thesis/Results/Calibration/"*Catchment_Name*"/GWStorage/GW_Storage_all_years"*string(current_year)*".png")
        plot()
        for h in 1:100
                mean_GW = Float64[]
                mean_Date = Date[]
                for i in 1:Nr_Years
                        current_year = 1985+i
                        indexfirstday = findall(x -> x == Dates.firstdayofyear(Date(current_year,1,1)), Timeseries)[1]
                        indexlasttday = findall(x -> x == Dates.lastdayofyear(Date(current_year,1,1)), Timeseries)[1]
                        append!(mean_Date, [Timeseries[indexfirstday+182]])
                        append!(mean_GW, mean(GW_Storage[indexfirstday:indexlasttday, h]))
                end
                plot!(mean_Date, mean_GW, color = ["red"], legend=false, size=(1800,1000))

        end
        hline!([200, 400], color=("black"))
        ylabel!("Slow Storage [mm]")
        xlabel!("Time in Year")
        savefig("/home/sarah/Master/Thesis/Results/Calibration/"*Catchment_Name*"/GWStorage/GW_Storage_mean_all_years.png")
        #plot!(Timeseries[indexfirstday:indexlasttday], Observed_Discharge[indexfirstday:indexlasttday], label="Observed",size=(1800,1000), color = ["red"])
end

function plot_snowstorage(Snowstorage, Timeseries, Catchment_Name, Nr_Years)
        for i in 1:Nr_Years
                current_year = 1985+i
                indexfirstday = findall(x -> x == Dates.firstdayofyear(Date(current_year,1,1)), Timeseries)[1]
                indexlasttday = findall(x -> x == Dates.lastdayofyear(Date(current_year,1,1)), Timeseries)[1]
                plot()
                for h in 1:100
                        plot!(Timeseries[indexfirstday:indexlasttday], Snowstorage[indexfirstday:indexlasttday, h], color = ["black"], legend=false, size=(1800,1000))
                end
                #plot!(Timeseries[indexfirstday:indexlasttday], Observed_Discharge[indexfirstday:indexlasttday], label="Observed",size=(1800,1000), color = ["red"])
                ylabel!("Snow Storage [mm]")
                xlabel!("Time in Year")
                savefig("/home/sarah/Master/Thesis/Results/Calibration/"*Catchment_Name*"/Snow_Storage/Snow_Storage_"*string(current_year)*".png")
        end


        current_year = 1986
        indexfirstday = findall(x -> x == Dates.firstdayofyear(Date(current_year,1,1)), Timeseries)[1]
        indexlasttday = findall(x -> x == Dates.lastdayofyear(Date(2009,1,1)), Timeseries)[1]
        plot()
        for h in 1:100
                plot!(Timeseries[indexfirstday:indexlasttday], Snowstorage[indexfirstday:indexlasttday, h], color = ["black"], legend=false, size=(1800,1000))
        end
        #plot!(Timeseries[indexfirstday:indexlasttday], Observed_Discharge[indexfirstday:indexlasttday], label="Observed",size=(1800,1000), color = ["red"])
        ylabel!("Snow Storage [mm]")
        xlabel!("Time in Year")
        savefig("/home/sarah/Master/Thesis/Results/Calibration/"*Catchment_Name*"/Snow_Storage/Snow_Storage_all_years"*string(current_year)*".png")
end

function plot_snowcover(All_Snow_Cover_Modeled, All_Snow_Cover_Observed, min_elevation, max_elevation, Catchment_Name)
        Farben = palette(:tab20)
        Farben = ["blue", "red", "green", "blue", "red", "green", "blue", "red", "green", "blue", "red", "green"]
        current_elevation = collect(min_elevation:200:max_elevation)
        # labels_HRU = ["bare", "forest", "grass", "rip"]
        for i in 1:1
                #plot()
                current_year = 2005+i
                indexfirstday = findall(x -> x == Dates.firstdayofyear(Date(current_year,1,1)), Timeseries)[1]
                indexlasttday = findall(x -> x == Dates.lastdayofyear(Date(2010,12,31)), Timeseries)[1]
                startday_snow = 1
                endday_snow = length(Timeseries[indexfirstday:indexlasttday])
                # h is best parameter sets
                for h in 1:1
                plot()
                        for elevation in 4:6
                                index = findall(x-> x >= -1, All_Snow_Cover_Observed[h][1:endday_snow, elevation])
                                print(size(index))
                                #print(typeof(All_Snow_Cover_Observed[h][startday_snow:endday_snow, elevation]))
                                plot!(Timeseries[indexfirstday:indexlasttday], All_Snow_Cover_Modeled[h][startday_snow:endday_snow, elevation], color = Farben[elevation],label=string(current_elevation[elevation]), size=(2200,700))
                                scatter!(Timeseries[indexfirstday:indexlasttday], All_Snow_Cover_Observed[h][startday_snow:endday_snow, elevation], color = Farben[elevation], label=string(current_elevation[elevation]), size=(2200,700), ylims=(-0.1,1.1))
                        end
                end
                xlabel!("Timeseries")
                ylabel!("Snow Cover")
                title!("Best parameter set: Paltental")
                savefig("/home/sarah/Master/Thesis/Results/Calibration/"*Catchment_Name*"/Snow_Cover/Snow_Cover_high_elevations_to2010.png")

        end
end

function plot_soilstorage(Soilstorage, Timeseries, Catchment_Name)
        current_year = 1986
        indexfirstday = findall(x -> x == Dates.firstdayofyear(Date(current_year,1,1)), Timeseries)[1]
        indexlasttday = findall(x -> x == Dates.lastdayofyear(Date(2009,12,31)), Timeseries)[1]
        # the different parameter sets
        Farben = ["blue", "orange", "green", "red"]
        HRU = ["bare", "forest", "grass", "riparian"]
        for h in 1:20
                plot()
                for hru in 1:4
                        plot!(Timeseries[indexfirstday:indexlasttday], Soilstorage[h][indexfirstday:indexlasttday, hru], color=Farben[hru], size=(2200, 700), label=HRU[hru])
                end
                xlabel!("Timeseries")
                ylabel!("Soil Storage [mm]")
                title!("Best parameter set: Paltental")
                savefig("/home/sarah/Master/Thesis/Results/Calibration/"*Catchment_Name*"/Soil_Storage/Soilstorage_best_"*string(h)*".png")
        end
end

function plot_faststorage(Faststorage, Timeseries, Catchment_Name)
        current_year = 1986
        indexfirstday = findall(x -> x == Dates.firstdayofyear(Date(current_year,1,1)), Timeseries)[1]
        indexlasttday = findall(x -> x == Dates.lastdayofyear(Date(2009,12,31)), Timeseries)[1]
        # the different parameter sets
        Farben = ["blue", "orange", "green", "red"]
        HRU = ["bare", "forest", "grass", "riparian"]
        for h in 1:20
                plot()
                for hru in 1:4
                        plot!(Timeseries[indexfirstday:indexlasttday], Faststorage[h][indexfirstday:indexlasttday, hru], color=Farben[hru], size=(2200, 700), label=HRU[hru])
                end
                xlabel!("Timeseries")
                ylabel!("Fast Storage [mm]")
                title!("Best parameter set: Paltental")
                savefig("/home/sarah/Master/Thesis/Results/Calibration/"*Catchment_Name*"/Fast_Storage/Faststorage_best_"*string(h)*".png")
        end
end

#Timeseries = collect(Date(1986,1,1):Day(1):Date(2009,12, 31))
# change function
#plot_snowcover(All_Snow_Cover_Modeled, All_Snow_Cover_Observed, 500, 1500, Catchment_Name)
plot_hydrographs(All_Discharges, Timeseries, Catchment_Name, 28)
#plot_gwstorage(All_GWstorage, Timeseries, Catchment_Name, 28)
#plot_snowstorage(ALl_Snowstorage, Timeseries, Catchment_Name, 28)
#plot_soilstorage(All_Soilstorage, Timeseries, Catchment_Name)
#plot_faststorage(All_Faststorage, Timeseries, Catchment_Name)
