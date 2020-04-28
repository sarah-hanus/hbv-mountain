function runmodelprecipitationzones(Area_Zones, Elevations_Each_Precipitation_Zone, Elevation_Zone_Catchment, Potential_Evaporation, Precipitation_All_Zones, Temperature_Elevation_Catchment, ID_Prec_Zones, Inputs_All_Zones, Storages_All_Zones, SlowStorage, bare_parameters, forest_parameters, grass_parameters, rip_parameters, Ks, Ratio_Riparian, Nr_Elevationbands_All_Zones, Elevation_Percentage)
        Total_Discharge = zeros(length(Precipitation_All_Zones[1][:,1]))
        count = zeros(length(Precipitation_All_Zones[1][:,1]), length(Elevation_Zone_Catchment))
        Snow_Extend_Catchment = zeros(length(Precipitation_All_Zones[1][:,1]), length(Elevation_Zone_Catchment))
        for i in 1: length(ID_Prec_Zones)
                Inputs_HRUs = Inputs_All_Zones[i]
                Storages_HRUs = Storages_All_Zones[i]

                Discharge, Snow_Extend, Waterbalance, Faststorage, GWstorage, Interceptionstorage, Snowstorage, Soilstorage, Waterbalance2, Snow_Elevations, Bare_Snow = runmodel(Area_Zones[i], Potential_Evaporation, Precipitation_All_Zones[i], Temperature_Elevation_Catchment,
                        Inputs_HRUs[1], Inputs_HRUs[2], Inputs_HRUs[3], Inputs_HRUs[4],
                        Storages_HRUs[1], Storages_HRUs[2], Storages_HRUs[3], Storages_HRUs[4], SlowStorage,
                        bare_parameters, forest_parameters, grass_parameters, rip_parameters, Ks, Ratio_Riparian, Nr_Elevationbands_All_Zones[i], Elevation_Percentage[i])
                Total_Discharge += Discharge
                @assert -0.01 <= Waterbalance2 <= 0.01
                j = 1
                for (h, elevation) in enumerate(Elevation_Zone_Catchment)
                        if j <= length(Elevations_Each_Precipitation_Zone[i]) && Elevations_Each_Precipitation_Zone[i][j] == elevation
                                Snow_Extend_Catchment[:,h] += Snow_Extend[:,j]
                                count[:,h]+= ones(length(Precipitation_All_Zones[1][:,1]))
                                j += 1
                        end
                end
        end
        #count = ones(length(Precipitation_All_Zones[1][:,1]), length(Elevation_Zone_Catchment)) * count
        print(size(Snow_Extend_Catchment), size(count))
        Snow_Extend_Catchment = Snow_Extend_Catchment ./ count


        return Total_Discharge, Snow_Extend_Catchment
end
