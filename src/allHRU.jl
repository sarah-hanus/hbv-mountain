function allHRU(bare_input::HRU_Input, forest_input::HRU_Input, grass_input::HRU_Input, rip_input::HRU_Input,
                bare_storage::Storages, forest_storage::Storages, grass_storage::Storages, rip_storage::Storages,
                bare_parameters::Parameters, forest_parameters::Parameters, grass_parameters::Parameters, rip_parameters::Parameters,
                Slowstorage::Float64, Ks::Float64, Ratio_Riparian::Float64)
    #this function runs thy model for different HRUs
    #bare rock HRU
    bare_outflow::Outflows, bare_storage::Storages, Bare_precipitation::Float64, Bare_Storages::Float64 = hillslopeHRU(bare_input, bare_storage, bare_parameters)
    # forest HRU
    forest_outflow::Outflows, forest_storage::Storages, Forest_precipitation::Float64, Forest_Storages::Float64= hillslopeHRU(forest_input, forest_storage, forest_parameters)
    # Grassland HRU
    grass_outflow::Outflows, grass_storage::Storages, Grass_precipitation::Float64, Grass_Storages::Float64= hillslopeHRU(grass_input, grass_storage, grass_parameters)
    # riparian HRU
    rip_outflow::Outflows, rip_storage::Storages, Rip_precipitation::Float64, Rip_Storages::Float64= riparianHRU(rip_input, rip_storage, rip_parameters)
    # total flow into groundwater is the weighted sum of the HRUs according to areal extent (this was already done in hillslopeHRU)
    Total_GWflow = bare_outflow.GWflow + forest_outflow.GWflow  + grass_outflow.GWflow
    # Groundwater storage
    Riparian_Discharge::Float64, Slow_Discharge::Float64, Slowstorage_New::Float64 = slowstorage(Total_GWflow, Slowstorage, rip_input.Area_HRU, Ks, Ratio_Riparian)
    #return all storage values, all evaporation values, Fast_Discharge and Slow_Discharge
    # calculate total discharge of the timestep using weighted sum of each HRU
    Total_Discharge::Float64 = bare_outflow.Fast_Discharge  + forest_outflow.Fast_Discharge + grass_outflow.Fast_Discharge  + rip_outflow.Fast_Discharge  + Slow_Discharge
    Total_Soil_Evaporation::Float64 = bare_outflow.Soil_Evaporation + forest_outflow.Soil_Evaporation + grass_outflow.Soil_Evaporation  + rip_outflow.Soil_Evaporation
    Total_Interception_Evaporation::Float64 = bare_outflow.Interception_Evaporation  + forest_outflow.Interception_Evaporation + grass_outflow.Interception_Evaporation + rip_outflow.Interception_Evaporation
    @assert Riparian_Discharge >= 0
    @assert Total_Discharge >= 0
    @assert Total_Interception_Evaporation >= 0
    @assert Total_Soil_Evaporation >= 0
    @assert Slowstorage_New >= 0
    # riparian input has to be corrected for areal extent of riparian HRU
    Total_Flows = Total_Discharge + Total_Soil_Evaporation + Total_Interception_Evaporation + Riparian_Discharge
    #print("barestorage",Bare_Storages)
    Total_Storages = Bare_Storages * bare_input.Area_HRU + Forest_Storages * forest_input.Area_HRU + Grass_Storages * grass_input.Area_HRU + Rip_Storages * rip_input.Area_HRU + Slowstorage_New - Slowstorage
#    print("Dischareg", Total_Discharge, "slow", Slow_Discharge_Area)
    # print("Flows", Total_Flows)
    # print("storage", Total_Storages)
    # print("Flows_store", round(Total_Flows + Total_Storages, digits=15))
    # print("prec", round(Bare_precipitation + rip_input.Riparian_Discharge, digits = 15), "\n")
    @assert -0.00000001 <= Bare_precipitation + rip_input.Riparian_Discharge - (Total_Flows + Total_Storages) <= 0.00000001
    Waterbalance = Bare_precipitation + rip_input.Riparian_Discharge - (Total_Flows + Total_Storages)
    return Riparian_Discharge::Float64, Total_Discharge::Float64, Total_Interception_Evaporation::Float64, Total_Soil_Evaporation::Float64, bare_storage::Storages, forest_storage::Storages, grass_storage::Storages, rip_storage::Storages, Slowstorage_New::Float64, Waterbalance::Float64, Bare_precipitation::Float64
end


function runmodel(Area, Evaporation_Mean::Array{Float64,1}, Precipitation::Array{Float64}, Temp::Array{Float64},
                bare_input::HRU_Input, forest_input::HRU_Input, grass_input::HRU_Input, rip_input::HRU_Input,
                bare_storage::Storages, forest_storage::Storages, grass_storage::Storages, rip_storage::Storages, Slowstorage::Float64,
                bare_parameters::Parameters, forest_parameters::Parameters, grass_parameters::Parameters, rip_parameters::Parameters, Ks::Float64, Ratio_Riparian::Float64)
    # the function takes as input the parameters of each HRU, the inital storage values of each HRU, the inital value of the slow storage
    # KS, ratio riparian, all inputs

    # define the maximum time
    tmax::Int128 = length(Precipitation[:,1])

    # make arrays for each Model Component
    Int_Evaporation::Array{Float64,1} = zeros(tmax) #interception evaporation
    Soil_Evaporation::Array{Float64,1} = zeros(tmax) #soil evaporation
    Discharge::Array{Float64,1} = zeros(tmax)

    # store the initial storage values, Does not take into account GW storage!!
    # Assumption_ GW storage is 0 at start
    #TO DO: average values over area
    Initial_Storage_bare::Float64 = bare_storage.Fast + sum(bare_storage.Interception) + sum(bare_storage.Snow) + bare_storage.Soil
    Initial_Storage_forest::Float64 = forest_storage.Fast + sum(forest_storage.Interception) + sum(forest_storage.Snow) + forest_storage.Soil
    Initial_Storage_grass::Float64 = grass_storage.Fast + sum(grass_storage.Interception) + sum(grass_storage.Snow) + grass_storage.Soil
    Initial_Storage_rip::Float64 = rip_storage.Fast + sum(rip_storage.Interception) + sum(rip_storage.Snow) + rip_storage.Soil
    Initial_Storage::Float64 = Initial_Storage_bare + Initial_Storage_forest + Initial_Storage_grass + Initial_Storage_rip

    #OPTIONAL: store all storage states
    Interceptionstorage::Array{Float64,2} = zeros(tmax, 4) #storage interception
    Snowstorage::Array{Float64,2} = zeros(tmax, 4)
    Soilstorage::Array{Float64,2} = zeros(tmax, 4) #stroage unsaturated zone
    Faststorage::Array{Float64,2} = zeros(tmax, 4) #storage fast
    GWstorage::Array{Float64,1} = zeros(tmax) #storage GW
    WBtotal::Array{Float64,1} = zeros(tmax)
    Snow_Extend::Array{Float64,1} = zeros(tmax)
    Precipitation_Total::Array{Float64,1} = zeros(tmax)

    for t in 1:tmax
        #print("t", t,"\n")
        # at each timestep new temp, precipitation and Epot values have to be delivered
        # areas don't change
        # riparian discharge from former timestep has to be used
        # gives the current precipitation, evaporation and temperature
        #Evaporation_Current = Evaporation[t, :]
        Evaporation_Mean_Current = Evaporation_Mean[t]
        Precipitation_Current = Precipitation[t, :]
        Temperature_Current = Temp[t, :]

        bare_input::HRU_Input = input_timestep(bare_input, Evaporation_Mean_Current, Precipitation_Current, Temperature_Current)
        forest_input::HRU_Input = input_timestep(forest_input, Evaporation_Mean_Current, Precipitation_Current, Temperature_Current)
        grass_input::HRU_Input = input_timestep(grass_input, Evaporation_Mean_Current, Precipitation_Current, Temperature_Current)
        rip_input::HRU_Input = input_timestep(rip_input, Evaporation_Mean_Current, Precipitation_Current, Temperature_Current)

        # bare_input.Potential_Evaporation::Array{Float64,1} = Evaporation[t, :]
        # bare_input.Potential_Evaporation_Mean::Float64 =
        # bare_input.Temp_Elevation::Array{Float64,2} = Temp[t, :]
        # bare_input.Precipitation::Array{Float64,2} = Precipitation[t, :]
        # # Evaporaiton, Temperature and Precipitation data of timestep t for forest HRU
        # forest_input.Potential_Evaporation = Evaporation[t, :]
        # forest_input.Potential_Evaporation_Mean = Evaporation_Mean[t]
        # forest_input.Precipitation = Precipitation[t, :]
        # forest_input.Temp_Elevation = Temp[t, :]
        # # Evaporaiton, Temperature and Precipitation data of timestep t for grass HRU
        # grass_input.Potential_Evaporation = Evaporation[t, :]
        # grass_input.Potential_Evaporation_Mean = Evaporation_Mean[t]
        # grass_input.Precipitation = Precipitation[t, :]
        # grass_input.Temp_Elevation = Temp[t, :]
        # # Evaporaiton, Temperature and Precipitation data of timestep t for riparian HRU
        # rip_input.Potential_Evaporation = Evaporation[t, :]
        # rip_input.Potential_Evaporation_Mean = Evaporation_Mean[t]
        # rip_input.Precipitation = Precipitation[t, :]
        # rip_input.Temp_Elevation = Temp[t, :]


        # parameters stay the same in each timestep
        # values of storages of timestep before have to be given
        #print("t", t, "\n")
        #print("Bare_Soil", bare_storage.Soil, "forest soil", forest_storage.Soil, "grasssoil", grass_storage.Soil, "ripsoil", rip_storage.Soil)
        Riparian_Discharge::Float64, Total_Discharge::Float64, Total_Interception_Evaporation::Float64, Total_Soil_Evaporation::Float64, bare_storage::Storages, forest_storage::Storages, grass_storage::Storages, rip_storage::Storages, Slowstorage::Float64, WB::Float64, Total_Prec::Float64 = allHRU(bare_input, forest_input, grass_input, rip_input,
                                                                                                            bare_storage, forest_storage, grass_storage, rip_storage,
                                                                                                            bare_parameters, forest_parameters, grass_parameters, rip_parameters,
                                                                                                            Slowstorage, Ks, Ratio_Riparian)
        # give new riparian discharge as input for next timestep
        # the
        rip_input.Riparian_Discharge = Riparian_Discharge
        # storage output of one timestep is the storage input of the next timestep, output is stored in the same struct, so it overwrites old storage values
        #do I need the storage values of each timestep???!!
        # mm convert it to meter and than * area / seconds in one day
        Discharge[t]::Float64 = Total_Discharge/1000 * Area / (3600 * 24)
        Int_Evaporation[t]::Float64 = Total_Interception_Evaporation
        Soil_Evaporation[t]::Float64 = Total_Soil_Evaporation
        #OPTIONAL: store all storage states at each timestep
        #get the total value stored as mean value of elevations and areal extent of HRU
        Bare_Interceptionstorage::Float64, Bare_Snowstorage::Float64 = Storage_Total(bare_storage, bare_input)
        Forest_Interceptionstorage::Float64, Forest_Snowstorage::Float64 = Storage_Total(forest_storage, forest_input)
        Grass_Interceptionstorage::Float64, Grass_Snowstorage::Float64 = Storage_Total(grass_storage, grass_input)
        Rip_Interceptionstorage::Float64, Rip_Snowstorage::Float64 = Storage_Total(rip_storage, rip_input)

        Snow_Extend[t]::Float64 = bare_storage.Snow_Cover * bare_input.Area_HRU + forest_storage.Snow_Cover * forest_input.Area_HRU + grass_storage.Snow_Cover * grass_input.Area_HRU + rip_storage.Snow_Cover * rip_input.Area_HRU



        #Interceptionstorage[t, :] = [sum(bare_storage.Interception), sum(forest_storage.Interception), sum(grass_storage.Interception), sum(rip_storage.Interception)]
        #Snowstorage[t, :] = [sum(bare_storage.Snow), sum(forest_storage.Snow), sum(grass_storage.Snow), sum(rip_storage.Snow)]
        Interceptionstorage[t, :]::Array{Float64,1} = [Bare_Interceptionstorage, Forest_Interceptionstorage, Grass_Interceptionstorage, Rip_Interceptionstorage]
        Snowstorage[t,:]::Array{Float64,1} = [Bare_Snowstorage, Forest_Snowstorage, Grass_Snowstorage, Rip_Snowstorage]
        #Soilstorage[t, :]::Array{Float64,1} = [bare_storage.Soil * bare_input.Area_HRU, forest_storage.Soil * forest_input.Area_HRU, grass_storage.Soil * grass_input.Area_HRU, rip_storage.Soil * rip_input.Area_HRU]
        #Faststorage[t, :]::Array{Float64,1} = [bare_storage.Fast * bare_input.Area_HRU, forest_storage.Fast * forest_input.Area_HRU, grass_storage.Fast * grass_input.Area_HRU, rip_storage.Fast * rip_input.Area_HRU]
        Soilstorage[t, :]::Array{Float64,1} = [bare_storage.Soil, forest_storage.Soil, grass_storage.Soil, rip_storage.Soil]
        Faststorage[t, :]::Array{Float64,1} = [bare_storage.Fast, forest_storage.Fast, grass_storage.Fast, rip_storage.Fast]
        GWstorage[t]::Float64 = Slowstorage
        WBtotal[t]::Float64 = WB
        Precipitation_Total[t]::Float64 = Total_Prec

    end

    # Check Water Balance


    # End_Storage_Interception =
    # End_Storage_Snow = sum(Snowstorage[end,:], dims=1)
    # End_Storage_Soil = sum(Soilstorage[end,:], dims=1)
    # End_Storage_Fast = sum(Faststorage[end,:], dims=1)
    End_Storage_GW::Float64 = GWstorage[end]
    End_Storage_bare::Float64 = (bare_storage.Fast + Interceptionstorage[end, 1] + Snowstorage[end, 1] + bare_storage.Soil) * bare_input.Area_HRU
    End_Storage_forest::Float64 = (forest_storage.Fast + Interceptionstorage[end, 2] + Snowstorage[end, 2] + forest_storage.Soil) * forest_input.Area_HRU
    End_Storage_grass::Float64 = (grass_storage.Fast + Interceptionstorage[end, 3] + Snowstorage[end, 3] + grass_storage.Soil) * grass_input.Area_HRU
    End_Storage_rip::Float64 = (rip_storage.Fast + Interceptionstorage[end, 4] + Snowstorage[end, 4] + rip_storage.Soil) * rip_input.Area_HRU
    End_Storage::Float64 = End_Storage_bare + End_Storage_forest + End_Storage_grass + End_Storage_rip + End_Storage_GW
      #print("Si",Interceptionstorage[1:3],"Ss",Soilstorage[1:3],"Sf",Faststorage[1:3],"Su",Slowstorage[1:3])
      #print("sin",Sin,"send", Send)
    # inital storage in mm , end storage also in mm
    Total_Storage::Float64 = End_Storage - Initial_Storage
      #print("Sin", Sin,"Ei", sum(Eidt),"Ea", sum(Eadt),"Qtot", sum(Qtotdt))
      #precipitation in mm/day, so sum precipitation in mm, Discharge in mm/d, Int_Evaporation in mm/d, Soil_Evaporation in mm/d
    Waterbalance::Float64 = sum(Precipitation)/ bare_input.Nr_Elevationbands - sum(Int_Evaporation) - sum(Soil_Evaporation) - sum(Discharge) / Area * (3600 * 24 * 1000) - rip_input.Riparian_Discharge - Total_Storage
    #Waterbalance::Float64 = sum(Precipitation_Total) - sum(Int_Evaporation) - sum(Soil_Evaporation) - sum(Discharge) / Area * (3600 * 24 * 1000) - rip_input.Riparian_Discharge - Total_Storage
    print(sum(Precipitation)/ bare_input.Nr_Elevationbands)
    Waterbalance2 = sum(WBtotal)::Float64
    #offset the discharge
    # Weigths=Weigfun(Tlag)
    # Modelled_Discharge = conv(Total_Discharge, Weigths)
    # Modelled_Discharge = Modelled_Discharge[1:tmax]
    # NashSutcliffe = NSE(Observed_Discharge, Modelled_Discharge)

    return Discharge::Array{Float64,1}, Snow_Extend::Array{Float64,1}, Waterbalance::Float64, Faststorage::Array{Float64,2}, GWstorage::Array{Float64,1}, Interceptionstorage::Array{Float64,2}, Snowstorage::Array{Float64,2}, Soilstorage::Array{Float64,2}, Waterbalance2::Float64
end

function Storage_Total(Storage::Storages, Input::HRU_Input)
    #print([bare_storage.Interception[1] * bare_input.Area_Elevations[1], forest_storage.Interception[1] * forest_input.Area_Elevations[1] , grass_storage.Interception[1] * grass_input.Area_Elevations[1], rip_storage.Interception[1] * rip_input.Area_Elevations[1]])
    # this function gives the total storage stored in reservoirs that are elevation distributed
    Total_Interception_Storage = 0
    Total_Snow_Storage = 0
    for i in 1 : Input.Nr_Elevationbands
        Interception_Storage = Storage.Interception[i] * Input.Area_Elevations[i]
        Snow_Storage = Storage.Snow[i] * Input.Area_Elevations[i]
        Former_Total_Interception_Storage = Total_Interception_Storage
        Former_Total_Snow_Storage = Total_Snow_Storage

        Total_Interception_Storage += Interception_Storage
        Total_Snow_Storage += Snow_Storage

        @assert Total_Interception_Storage >= Interception_Storage
        @assert Total_Snow_Storage >= Snow_Storage
        @assert Total_Interception_Storage >= Former_Total_Interception_Storage
        @assert Total_Snow_Storage >= Former_Total_Snow_Storage
    end
    return Total_Interception_Storage::Float64, Total_Snow_Storage::Float64
end

function input_timestep(Input::HRU_Input, Evaporation_Mean::Float64, Precipitation::Array{Float64,1}, Temperature::Array{Float64,1})
    #Input.Potential_Evaporation::Array{Float64,1} = Evaporation
    Input.Potential_Evaporation_Mean::Float64 = Evaporation_Mean
    # get the precipitation data of the necessary elevations
    Precipitation_HRU = Float64[]
    Temperature_HRU = Float64[]
    for i in Input.Elevation_Count
        push!(Precipitation_HRU, Precipitation[i])
        push!(Temperature_HRU, Temperature[i])
    end
    Input.Precipitation::Array{Float64,1} = Precipitation_HRU
    Input.Temp_Elevation::Array{Float64,1} = Temperature_HRU
    return Input::HRU_Input
end
