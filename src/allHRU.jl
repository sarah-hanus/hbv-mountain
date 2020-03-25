function allHRU(bare_input::HRU_Input, forest_inpt::HRU_Input, grass_input::HRU_Input, rip_input::HRU_Input,
                bare_storage::Storages, forest_storage::Storages, grass_storage::Storages, rip_storage::Storages,
                bare_parameters::Parameters, forest_parameters::Parameters, grass_parameters::Parameters, rip_parameters::Parameters,
                Slowstorage, Ks, Ratio_Riparian)
    #bare rock HRU
    bare_outflow::Outflows, bare_storage::Storages = hillslopeHRU(bare_input, bare_storage, bare_parameters)
    # forest HRU
    forest_outflow::Outflows, forest_storage::Storages = hillslopeHRU(forest_input, forest_storage, forest_parameters)
    # Grassland HRU
    grass_outflow::Outflows, grass_storage::Storages = hillslopeHRU(grass_input, grass_storage, grass_parameters)
    # riparian HRU
    rip_outflow::Outflows, rip_storage::Storages = riparianHRU(rip_input, rip_storage, rip_parameters)
    # total flow into groundwater is the weighted sum of the HRUs
    Total_GWflow = bare_outflow.GWflow + forest_outflow.GWflow + grass_outflow.GWflow
    # Groundwater storage
    Riparian_Discharge, Slow_Discharge, Slowstorage = slowstorage(Total_GWflow, Slowstorage, Ks, Ratio_Riparian)
    #return all storage values, all evaporation values, Fast_Discharge and Slow_Discharge
    # calculate total discharge of the timestep using weighted sum of each HRU
    Total_Discharge = bare_outflow.Fast_Discharge + forest_outflow.Fast_Discharge + grass_outflow.Fast_Discharge + rip_outflow.Fast_Discharge + Slow_Discharge
    Total_Soil_Evaporation = bare_outflow.Soil_Evaporation + forest_outflow.Soil_Evaporation + grass_outflow.Soil_Evaporation + rip_outflow.Soil_Evaporation
    Total_Interception_Evaporation = bare_outflow.Interception_Evaporation + forest_outflow.Interception_Evaporation + grass_outflow.Interception_Evaporation + rip_outflow.Interception_Evaporation

    return Riparian_Discharge, Total_Discharge, Total_Interception_Evaporation, Total_Soil_Evaporation, bare_storage, forest_storage, grass_storage, rip_storage, Slowstorage
end


function runmodel(Evaporation, Evaporation_Mean, Precipitation, Temp, bare_input, forest_input, grass_input, rip_input, bare_storage, forest_storage, grass_storage, rip_storage, Slowstorage, bare_parameters, forest_parameters, grass_parameters, rip_parameters, Ks, Ratio_Riparian)
    # the function takes as input the parameters of each HRU, the inital storage values of each HRU, the inital value of the slow storage
    # KS, ratio riparian, all inputs

    # define the maximum time
    tmax = length(Precipitation[:,1])

    # make arrays for each Model Component
    Int_Evaporation = zeros(tmax) #interception evaporation
    Soil_Evaporation = zeros(tmax) #soil evaporation
    Discharge = zeros(tmax)

    # store the initial storage values
    Initial_Storage_bare = bare_storage.Fast + sum(bare_storage.Interception) + sum(bare_storage.Snow) + bare_storage.Soil
    Initial_Storage_forest = forest_storage.Fast + sum(forest_storage.Interception) + sum(forest_storage.Snow) + forest_storage.Soil
    Initial_Storage_grass = grass_storage.Fast + sum(grass_storage.Interception) + sum(grass_storage.Snow) + grass_storage.Soil
    Initial_Storage_rip = rip_storage.Fast + sum(rip_storage.Interception) + sum(rip_storage.Snow) + rip_storage.Soil
    Initial_Storage = Initial_Storage_bare + Initial_Storage_forest + Initial_Storage_grass + Initial_Storage_rip

    #OPTIONAL: store all storage states
    Interceptionstorage = zeros(tmax, 4) #storage interception
    Snowstorage = zeros(tmax, 4)
    Soilstorage = zeros(tmax, 4) #stroage unsaturated zone
    Faststorage = zeros(tmax, 4) #storage fast
    GWstorage = zeros(tmax) #storage GW

    for t in 1:tmax
        # at each timestep new temp, precipitation and Epot values have to be delivered
        # areas don't change
        # riparian discharge from former timestep has to be used
        bare_input.Potential_Evaporation = Evaporation[t, :]
        bare_input.Potential_Evaporation_Mean = Evaporation_Mean[t]
        bare_input.Temp_Elevation = Temp[t, :]
        bare_input.Precipitation = Precipitation[t, :]

        forest_input.Potential_Evaporation = Evaporation[t, :]
        forest_input.Potential_Evaporation_Mean = Evaporation_Mean[t]
        forest_input.Precipitation = Precipitation[t, :]
        forest_input.Temp_Elevation = Temp[t, :]

        grass_input.Potential_Evaporation = Evaporation[t, :]
        grass_input.Potential_Evaporation_Mean = Evaporation_Mean[t]
        grass_input.Precipitation = Precipitation[t, :]
        grass_input.Temp_Elevation = Temp[t, :]

        rip_input.Potential_Evaporation = Evaporation[t, :]
        rip_input.Potential_Evaporation_Mean = Evaporation_Mean[t]
        rip_input.Precipitation = Precipitation[t, :]
        rip_input.Temp_Elevation = Temp[t, :]


        # parameters stay the same in each timestep
        # values of storages of timestep before have to be given
        Riparian_Discharge, Total_Discharge, Total_Interception_Evaporation, Total_Soil_Evaporation, bare_storage, forest_storage, grass_storage, rip_storage, Slowstorage = allHRU(bare_input, forest_input, grass_input, rip_input,
                                                                                                            bare_storage, forest_storage, grass_storage, rip_storage,
                                                                                                            bare_parameters, forest_parameters, grass_parameters, rip_parameters,
                                                                                                            Slowstorage, Ks, Ratio_Riparian)
        # give new riparian discharge as input for next timestep
        rip_input.Riparian_Discharge = Riparian_Discharge
        # storage output of one timestep is the storage input of the next timestep, output is stored in the same struct, so it overwrites old storage values
        #do I need the storage values of each timestep???!!
        Discharge[t] = Total_Discharge
        Int_Evaporation[t] = Total_Interception_Evaporation
        Soil_Evaporation[t] = Total_Soil_Evaporation
        #OPTIONAL: store all storage states at each timestep
        Interceptionstorage[t, :] = [sum(bare_storage.Interception), sum(forest_storage.Interception), sum(grass_storage.Interception), sum(rip_storage.Interception)]
        Snowstorage[t, :] = [sum(bare_storage.Snow), sum(forest_storage.Snow), sum(grass_storage.Snow), sum(rip_storage.Snow)]
        Soilstorage[t, :] = [bare_storage.Soil, forest_storage.Soil, grass_storage.Soil, rip_storage.Soil]
        Faststorage[t, :] = [bare_storage.Fast, forest_storage.Fast, grass_storage.Fast, rip_storage.Fast]
        GWstorage[t] = Slowstorage
    end

    # Check Water Balance
    End_Storage_bare = bare_storage.Fast + sum(bare_storage.Interception) + sum(bare_storage.Snow) + bare_storage.Soil
    End_Storage_forest = forest_storage.Fast + sum(forest_storage.Interception) + sum(forest_storage.Snow) + forest_storage.Soil
    End_Storage_grass = grass_storage.Fast + sum(grass_storage.Interception) + sum(grass_storage.Snow) + grass_storage.Soil
    End_Storage_rip = rip_storage.Fast + sum(rip_storage.Interception) + sum(rip_storage.Snow) + rip_storage.Soil
    End_Storage = End_Storage_bare + End_Storage_forest + End_Storage_grass + End_Storage_rip
      #print("Si",Interceptionstorage[1:3],"Ss",Soilstorage[1:3],"Sf",Faststorage[1:3],"Su",Slowstorage[1:3])
      #print("sin",Sin,"send", Send)
    Total_Storage = End_Storage - Initial_Storage
      #print("Sin", Sin,"Ei", sum(Eidt),"Ea", sum(Eadt),"Qtot", sum(Qtotdt))
    Waterbalance = sum(Precipitation) - sum(Int_Evaporation) - sum(Soil_Evaporation) - sum(Discharge) - Total_Storage
    #offset the discharge
    # Weigths=Weigfun(Tlag)
    # Modelled_Discharge = conv(Total_Discharge, Weigths)
    # Modelled_Discharge = Modelled_Discharge[1:tmax]
    # NashSutcliffe = NSE(Observed_Discharge, Modelled_Discharge)

    return Discharge, Waterbalance, Faststorage, GWstorage, Interceptionstorage, Snowstorage, Soilstorage
end
