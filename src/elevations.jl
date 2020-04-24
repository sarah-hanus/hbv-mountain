function hillslopeHRU(hill::HRU_Input, storages::Storages, parameters::Parameters)
    # Are_Elevations gives the areal percentage of each elevation band. The sum has to be 1
    # Area_elevations, Precipitation, Temp_elevation, Snowstorage, Interceptionstorage has to be array of length Nr_Elevationbands
    @assert hill.Total_Interception_Evaporation == 0
    @assert hill.Total_Effective_Precipitation == 0
    @assert 1 - eps(Float64) <= sum(hill.Area_Elevations) <= 1 + eps(Float64)
    @assert hill.Area_HRU >= 0 and <= 1
    @assert hill.Nr_Elevationbands >= 1
    #@assert round(sum(hill.Potential_Evaporation)/length(hill.Potential_Evaporation), digits=14) == round(hill.Potential_Evaporation_Mean, digits=14)

    # define Arrays for Snow and Interception
    Snow = zeros(hill.Nr_Elevationbands)
    Interception = zeros(hill.Nr_Elevationbands)
    storages.Snow_Cover = 0
    for i in 1 : hill.Nr_Elevationbands
        # snow component
        Melt::Float64, Snow[i]::Float64 = snow(hill.Area_Glacier, hill.Precipitation[i], hill.Temp_Elevation[i], storages.Snow[i], parameters.Meltfactor, parameters.Mm, parameters.Temp_Thresh)
        #interception component
        Effective_Precipitation::Float64, Interception_Evaporation::Float64, Interception[i]::Float64 = interception(hill.Potential_Evaporation_Mean, hill.Precipitation[i], hill.Temp_Elevation[i], storages.Interception[i], parameters.Interceptionstoragecapacity, parameters.Temp_Thresh)
        # the melt, effective precipitation and evaporation can be summed up over all elevations according to the areal extent
        hill.Total_Effective_Precipitation::Float64 += (Effective_Precipitation + Melt) * hill.Area_Elevations[i]
        #global Total_Melt += (Melt * Area_Elevations[i])
        hill.Total_Interception_Evaporation::Float64 += (Interception_Evaporation * hill.Area_Elevations[i])
        # the storage components have to be saved for each  elevation seperately
        if storages.Snow[i] > 0
            storages.Snow_Cover += hill.Area_Elevations[i]
        end
    end

    # problem: interception storage of every elevation band must be divided by areal fraction of the elevation band

    #soil storage component
    Overlandflow::Float64, Preferentialflow::Float64, Soil_Evaporation::Float64, Soilstorage::Float64 = soilstorage(hill.Total_Effective_Precipitation, hill.Total_Interception_Evaporation, hill.Potential_Evaporation_Mean, storages.Soil, parameters.beta, parameters.Ce, parameters.Ratio_Pref, parameters.Soilstoragecapacity)
    GWflow::Float64 = Preferentialflow
    #fast storage
    Fast_Discharge::Float64, Faststorage::Float64 = faststorage(Overlandflow, storages.Fast, parameters.Kf)

    #calculate total outflow
    Flows = Fast_Discharge + GWflow + hill.Total_Interception_Evaporation + Soil_Evaporation

    # change discharges and evaporation fluxed according to areal fraction
    Fast_Discharge = Fast_Discharge * hill.Area_HRU
    GWflow = GWflow * hill.Area_HRU
    Total_Interception_Evaporation = hill.Total_Interception_Evaporation * hill.Area_HRU
    Soil_Evaporation = Soil_Evaporation * hill.Area_HRU
    # returning all fluxes (evporative, discharge)
    hill_out = Outflows(Fast_Discharge, GWflow, Soil_Evaporation, Total_Interception_Evaporation)
    #returning all storages
    hill_storages = Storages(Faststorage, Interception, Snow, storages.Snow_Cover, Soilstorage)
    # total interception should be zero again for next run
    hill.Total_Interception_Evaporation = 0
    hill.Total_Effective_Precipitation = 0


    #assertions for the outflows
    @assert hill_out.Fast_Discharge >= 0
    @assert hill_out.GWflow >= 0
    @assert hill_out.Soil_Evaporation >= 0
    @assert hill_out.Interception_Evaporation >= 0
    @assert hill_out.Soil_Evaporation + hill_out.Interception_Evaporation <= hill.Potential_Evaporation_Mean

    #assertions for the storages
    @assert hill_storages.Fast >= 0
    @assert hill_storages.Interception >= zeros(hill.Nr_Elevationbands)
    @assert hill_storages.Snow >= zeros(hill.Nr_Elevationbands)
    @assert hill_storages.Soil >= 0
    @assert ones(hill.Nr_Elevationbands) * parameters.Interceptionstoragecapacity - hill_storages.Interception >= -10^(-10) * ones(hill.Nr_Elevationbands)
    @assert parameters.Soilstoragecapacity - hill_storages.Soil >= -10^(-10)

    #assertion water balance
    Precipitation = 0
    Interception_Storage_New = 0
    Snow_Storage_New = 0
    Interception_Storage_Old = 0
    Snow_Storage_Old = 0
    for i in 1: hill.Nr_Elevationbands
        Precipitation += hill.Precipitation[i] * hill.Area_Elevations[i]
        Interception_Storage_New += hill_storages.Interception[i] * hill.Area_Elevations[i]
        Snow_Storage_New += hill_storages.Snow[i] * hill.Area_Elevations[i]
        Interception_Storage_Old += storages.Interception[i] * hill.Area_Elevations[i]
        Snow_Storage_Old += storages.Snow[i] * hill.Area_Elevations[i]
    end
    #print("Prec", Precipitation)
    # print("Flows", Flows, "\n")
    # print("Fast", (hill_storages.Fast - storages.Fast), "\n")
    # print("soil", (hill_storages.Soil -storages.Soil), "\n")
    # print("snow", (Snow_Storage_New -Snow_Storage_Old), "\n")
    # print("inter", (Interception_Storage_New - Interception_Storage_Old), "\n")
    Flows_Area = Fast_Discharge + GWflow + Total_Interception_Evaporation + Soil_Evaporation
    All_Storages = (hill_storages.Fast - storages.Fast) + (hill_storages.Soil - storages.Soil) + (Snow_Storage_New -Snow_Storage_Old) + (Interception_Storage_New - Interception_Storage_Old)
    #FlowsandStorages = Flows + (hill_storages.Fast - storages.Fast) + (hill_storages.Soil -storages.Soil) + (Snow_Storage_New -Snow_Storage_Old) + (Interception_Storage_New - Interception_Storage_Old)
    #All_Storages = (hill_storages.Fast - storages.Fast) + (hill_storages.Soil - storages.Soil) + (Snow_Storage_New -Snow_Storage_Old) + (Interception_Storage_New - Interception_Storage_Old)
    #print("flows", FlowsandStorages,"\n")
    #FlowsandStorage = (Flows_Area + All_Storages * hill.Area_HRU)
    @assert -0.00000001 <= Precipitation - (Flows + All_Storages) <= 0.00000001
    @assert -0.00000001 <= Precipitation * hill.Area_HRU - (Flows_Area + All_Storages * hill.Area_HRU) <= 0.00000001
    #print(Precipitation * hill.Area_HRU - (Flows_Area + All_Storages * hill.Area_HRU),"TEST\n")
    return hill_out::Outflows, hill_storages::Storages, Precipitation, All_Storages
    #return GWflow, Fast_Discharge, Soil_Evaporation, Total_Interception_Evaporation, Interceptionstorage, Snowstorage, Soilstorage, Faststorage

end

function riparianHRU(rip::HRU_Input, storages::Storages, parameters::Parameters)
    # Are_Elevations gives the areal percentage of each elevation band. The sum has to be 1
    # Area_elevations, Precipitation, Temp_elevation, Snowstorage, Interceptionstorage has to be array of length Nr_Elevationbands
    # riparian HRU has no preferential and percolation flow
    Snow = zeros(rip.Nr_Elevationbands)
    Interception = zeros(rip.Nr_Elevationbands)
    storages.Snow_Cover = 0
    for i in 1 : rip.Nr_Elevationbands
        # snow component
        Melt::Float64, Snow[i]::Float64 = snow(rip.Area_Glacier, rip.Precipitation[i], rip.Temp_Elevation[i], storages.Snow[i], parameters.Meltfactor, parameters.Mm, parameters.Temp_Thresh)
        #interception component
        Effective_Precipitation::Float64, Interception_Evaporation::Float64, Interception[i]::Float64 = interception(rip.Potential_Evaporation_Mean, rip.Precipitation[i], rip.Temp_Elevation[i], storages.Interception[i], parameters.Interceptionstoragecapacity, parameters.Temp_Thresh)
        # the melt, effective precipitation and evaporation can be summed up over all elevations according to the areal extent
        rip.Total_Effective_Precipitation::Float64 += (Effective_Precipitation + Melt) * rip.Area_Elevations[i]
        #global Total_Melt += (Melt * Area_Elevations[i])
        rip.Total_Interception_Evaporation::Float64 += Interception_Evaporation * rip.Area_Elevations[i]
        # the storage components have to be saved for each  elevation seperately
        #get snow cover extent
        if storages.Snow[i] > 0
            storages.Snow_Cover += rip.Area_Elevations[i]
        end
    end

    #soil storage component
    Overlandflow::Float64, Soil_Evaporation::Float64, Soilstorage::Float64 = ripariansoilstorage(rip.Total_Effective_Precipitation, rip.Total_Interception_Evaporation, rip.Potential_Evaporation_Mean, rip.Riparian_Discharge / rip.Area_HRU, storages.Soil, parameters.beta, parameters.Ce, parameters.Drainagecapacity, parameters.Soilstoragecapacity)
    #GWflow = Percolationflow + Preferentialflow
    #fast storage
    Fast_Discharge::Float64, Faststorage::Float64 = faststorage(Overlandflow, storages.Fast, parameters.Kf)
    GWflow = 0

    #calculate total outflow
    Flows = Fast_Discharge + GWflow + rip.Total_Interception_Evaporation + Soil_Evaporation
    # change discharges according to areal fraction
    Fast_Discharge = Fast_Discharge * rip.Area_HRU

    Total_Interception_Evaporation = rip.Total_Interception_Evaporation * rip.Area_HRU
    Soil_Evaporation = Soil_Evaporation * rip.Area_HRU
    # retunrn water flows, evaporation, and states of the storage components
    rip_out = Outflows(Fast_Discharge, GWflow, Soil_Evaporation, Total_Interception_Evaporation)
    rip_storages = Storages(Faststorage, Interception, Snow, storages.Snow_Cover, Soilstorage)

    rip.Total_Interception_Evaporation = 0
    rip.Total_Effective_Precipitation = 0

    #assertions for the outflows
    @assert rip_out.Fast_Discharge >= 0
    @assert rip_out.GWflow >= 0
    @assert rip_out.Soil_Evaporation >= 0
    @assert rip_out.Interception_Evaporation >= 0
    @assert rip_out.Soil_Evaporation + rip_out.Interception_Evaporation <= rip.Potential_Evaporation_Mean

    #assertions for the storages
    @assert rip_storages.Fast >= 0
    @assert rip_storages.Interception >= zeros(rip.Nr_Elevationbands)
    @assert rip_storages.Snow >= zeros(rip.Nr_Elevationbands)
    @assert rip_storages.Soil >= 0
    #@assert rip_storages.Interception <= ones(rip.Nr_Elevationbands) * parameters.Interceptionstoragecapacity
    @assert ones(rip.Nr_Elevationbands) * parameters.Interceptionstoragecapacity - rip_storages.Interception >= -10^(-10) * ones(rip.Nr_Elevationbands)
    #@assert rip_storages.Soil <= parameters.Soilstoragecapacity
    @assert parameters.Soilstoragecapacity - rip_storages.Soil >= -10^(-10)

    Precipitation = 0
    Interception_Storage_New = 0
    Snow_Storage_New = 0
    Interception_Storage_Old = 0
    Snow_Storage_Old = 0
    for i in 1: rip.Nr_Elevationbands
        Precipitation += rip.Precipitation[i] * rip.Area_Elevations[i]
        Interception_Storage_New += rip_storages.Interception[i] * rip.Area_Elevations[i]
        Snow_Storage_New += rip_storages.Snow[i] * rip.Area_Elevations[i]
        Interception_Storage_Old += storages.Interception[i] * rip.Area_Elevations[i]
        Snow_Storage_Old += storages.Snow[i] * rip.Area_Elevations[i]
    end
    #print("Precrip", round(Precipitation + rip.Riparian_Discharge, digits=14))
    Flows_Area = Fast_Discharge + GWflow + Total_Interception_Evaporation + Soil_Evaporation
    All_Storages = (rip_storages.Fast - storages.Fast) + (rip_storages.Soil -storages.Soil) + (Snow_Storage_New -Snow_Storage_Old) + (Interception_Storage_New - Interception_Storage_Old)
    #print("flows", round(FlowsandStorages, digits = 14), FlowsandStorages, "\n")
    #@assert -0.00000000001 <= Precipitation + rip.Riparian_Discharge - FlowsandStorages <= 0.00000000001
    @assert -0.00000001 <= Precipitation + rip.Riparian_Discharge / rip.Area_HRU - (Flows + All_Storages) <= 0.00000001
    @assert -0.00000001 <= (Precipitation * rip.Area_HRU + rip.Riparian_Discharge) - (Flows_Area + All_Storages * rip.Area_HRU) <= 0.00000001
    #print((Precipitation * rip.Area_HRU + rip.Riparian_Discharge) - (Flows_Area + All_Storages * rip.Area_HRU),"TEST\n")

    return rip_out, rip_storages, Precipitation, All_Storages
    #return Fast_Discharge, Soil_Evaporation, Total_Interception_Evaporation, Interceptionstorage, Snowstorage, Soilstorage, Faststorage

end
