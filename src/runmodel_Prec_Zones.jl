function runmodelprecipitationzones(Area_Zones, Elevations_Each_Precipitation_Zone, Elevation_Zone_Catchment, Potential_Evaporation, Precipitation_All_Zones, Temperature_Elevation_Catchment, ID_Prec_Zones, Inputs_All_Zones, Storages_All_Zones, SlowStorage, parameters, Nr_Elevationbands_All_Zones, Elevation_Percentage, observed_snow_cover, start2000)
        Total_Discharge = zeros(length(Precipitation_All_Zones[1][:,1]))
        Total_GWStorage = zeros(length(Precipitation_All_Zones[1][:,1]))
        count = zeros(length(Precipitation_All_Zones[1][:,1]), length(Elevation_Zone_Catchment))
        #Snow_Extend_Catchment = zeros(length(Precipitation_All_Zones[1][:,1]), length(Elevation_Zone_Catchment))
        Snow_Extend_Catchment = Array{Float64,2}[]
        Snow_Overall_Objective_Function = 0
        for i in 1: length(ID_Prec_Zones)
                Inputs_HRUs = Inputs_All_Zones[i]
                Storages_HRUs = Storages_All_Zones[i]

                Discharge, Snow_Extend, Waterbalance, Faststorage, GWstorage, Interceptionstorage, Snowstorage, Soilstorage, Waterbalance2, Snow_Elevations, Bare_Snow = runmodel(Area_Zones[i], Potential_Evaporation, Precipitation_All_Zones[i], Temperature_Elevation_Catchment,
                        Inputs_HRUs[1], Inputs_HRUs[2], Inputs_HRUs[3], Inputs_HRUs[4],
                        Storages_HRUs[1], Storages_HRUs[2], Storages_HRUs[3], Storages_HRUs[4], SlowStorage,
                        parameters[1], parameters[2], parameters[3], parameters[4], parameters[5], Nr_Elevationbands_All_Zones[i], Elevation_Percentage[i])
                Total_Discharge += Discharge
                Total_GWStorage += GWstorage * Area_Zones[i]/sum(Area_Zones)
                @assert -0.01 <= Waterbalance2 <= 0.01
                j = 1
                push!(Snow_Extend_Catchment, Snow_Extend)
                elevations = size(Snow_Extend)[2]
                #print(elevations, " ", length(observed_snow_cover[i][:,1]), " ", size(Snow_Extend))
                snow_cover_modelled = Snow_Extend[start2000: start2000 + length(observed_snow_cover[i][:,1]) - 1, :]
                Mean_difference = 0
                for h in 1: elevations
                        Difference = snowcover(snow_cover_modelled[:,h], observed_snow_cover[i][:,h])
                        Mean_difference += Difference
                end
                Mean_difference = Mean_difference / elevations
                Snow_Overall_Objective_Function += Mean_difference
        end
        Snow_Overall_Objective_Function = Snow_Overall_Objective_Function / length(ID_Prec_Zones)
        return Total_Discharge, Snow_Overall_Objective_Function, Total_GWStorage
end
