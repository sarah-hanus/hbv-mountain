function runmodelprecipitationzones(Area_Zones, Elevations_Each_Precipitation_Zone, Elevation_Zone_Catchment, Potential_Evaporation, Precipitation_All_Zones, Temperature_Elevation_Catchment, ID_Prec_Zones, Inputs_All_Zones, Storages_All_Zones, SlowStorage, bare_parameters, forest_parameters, grass_parameters, rip_parameters, slow_parameters, Nr_Elevationbands_All_Zones, Elevation_Percentage, observed_snow_cover, start2000)
        Total_Discharge = zeros(length(Precipitation_All_Zones[1][:,1]))
        Total_GWStorage = zeros(length(Precipitation_All_Zones[1][:,1]))
        count = zeros(length(Precipitation_All_Zones[1][:,1]), length(Elevation_Zone_Catchment))
        #Snow_Extend_Catchment = zeros(length(Precipitation_All_Zones[1][:,1]), length(Elevation_Zone_Catchment))
        Snow_Extend_Catchment = Array{Float64,2}[]
        for i in 1: length(ID_Prec_Zones)
                Inputs_HRUs = Inputs_All_Zones[i]
                Storages_HRUs = Storages_All_Zones[i]

                Discharge, Snow_Extend, Waterbalance, Faststorage, GWstorage, Interceptionstorage, Snowstorage, Soilstorage, Waterbalance2, Snow_Elevations, Bare_Snow = runmodel(Area_Zones[i], Potential_Evaporation, Precipitation_All_Zones[i], Temperature_Elevation_Catchment,
                        Inputs_HRUs[1], Inputs_HRUs[2], Inputs_HRUs[3], Inputs_HRUs[4],
                        Storages_HRUs[1], Storages_HRUs[2], Storages_HRUs[3], Storages_HRUs[4], SlowStorage,
                        bare_parameters, forest_parameters, grass_parameters, rip_parameters, slow_parameters, Nr_Elevationbands_All_Zones[i], Elevation_Percentage[i])
                Total_Discharge += Discharge
                Total_GWStorage += GWstorage * Area_Zones[i]/sum(Area_Zones)
                @assert -0.01 <= Waterbalance2 <= 0.01
                j = 1
                push!(Snow_Extend_Catchment, Snow_Extend)
                # for (h, elevation) in enumerate(Elevation_Zone_Catchment)
                #         if j <= length(Elevations_Each_Precipitation_Zone[i]) && Elevations_Each_Precipitation_Zone[i][j] == elevation
                #                 Snow_Extend_Catchment[:,h] += Snow_Extend[:,j]
                #                 count[:,h]+= ones(length(Precipitation_All_Zones[1][:,1]))
                #                 j += 1
                #         end
                # end
                elevations = size(Snow_Extend)[2]
                print(elevations)
                snow_cover_modelled = Snow_Extend[start2000: length(observed_snow_cover[i][:,1]), :]
                print(size(snow_cover_modelled))
                for i in 1: elevations
                        Dufference = snowcover(snow_cover_modelled[:,i], observed_snow_cover[i][:,i])
                end
        end
        #count = ones(length(Precipitation_All_Zones[1][:,1]), length(Elevation_Zone_Catchment)) * count
        #print(size(Snow_Extend_Catchment), size(count))
        #Modelled_Snow_Extend_Catchment = Snow_Extend_Catchment ./ count
        #calculate objective function for snow extend
        #snowcover(Modelled_Snow_Extend_Catchment)


        return Total_Discharge, Snow_Extend_Catchment, Total_GWStorage
end
