# function to get the elevation data of each elevation
function getelevationdata(Thickness_Band, Lowest_Elevation, Mean_Elevation, Highest_Elevation, Prec_Gradient, Temperature, Precipitation_Mean)
    Nr_Elevationbands = Int(ceil((Highest_Elevation - Lowest_Elevation) / 250))
    # make an array with number of rows equal to number of days, and columns equal to number of elevations
    Temp_Elevation = zeros(length(Temperature), Nr_Elevationbands)
    Precipitation = zeros(length(Temperature),Nr_Elevationbands)

    for i in 1 : Nr_Elevationbands
        Elevation = (Lowest_Elevation + Thickness_Band/2) + Thickness_Band * (i - 1)
        for j in 1: length(Temperature)
            global Temp_Elevation[j,i] = Temperature[j] - 0.0065 * (Elevation - Mean_Elevation)
            global Precipitation[j,i] = max((Precipitation_Mean[j] + Prec_Gradient * (Elevation - Mean_Elevation)),0)
        end
    end
    return Nr_Elevationbands, Precipitation, Temp_Elevation
end

function hillslopeHRU(hill::HRU_Input, storages::Storages, parameters::Parameters)
    # Are_Elevations gives the areal percentage of each elevation band. The sum has to be 1
    # Area_elevations, Precipitation, Temp_elevation, Snowstorage, Interceptionstorage has to be array of length Nr_Elevationbands

    for i in 1 : hill.Nr_Elevationbands
        # snow component
        Melt, storages.Snow[i] = snow(hill.Area_Glacier, hill.Precipitation[i], hill.Temp_Elevation[i], storages.Snow[i], parameters.Meltfactor, parameters.Mm, parameters.Temp_Thresh)
        #interception component
        Effective_Precipitation, Interception_Evaporation, storages.Interception[i] = interception(hill.Potential_Evaporation[i], hill.Precipitation[i], hill.Temp_Elevation[i], storages.Interception[i], parameters.Interceptionstoragecapacity, parameters.Temp_Thresh)
        # the melt, effective precipitation and evaporation can be summed up over all elevations according to the areal extent
        global hill.Total_Effective_Precipitation += (Effective_Precipitation + Melt) * hill.Area_Elevations[i]
        #global Total_Melt += (Melt * Area_Elevations[i])
        global hill.Total_Interception_Evaporation += (Interception_Evaporation * hill.Area_Elevations[i])
        # the storage components have to be saved for each  elevation seperately
    end

    #soil storage component
    Overlandflow, Percolationflow, Preferentialflow, Soil_Evaporation, Soilstorage = soilstorage(hill.Total_Effective_Precipitation, hill.Total_Interception_Evaporation, hill.Potential_Evaporation_Mean, storages.Soil, parameters.beta, parameters.Ce, parameters.Percolationcapacity, parameters.Ratio_Pref, parameters.Soilstoragecapacity)
    GWflow = Percolationflow + Preferentialflow
    #fast storage
    Fast_Discharge, Faststorage = faststorage(Overlandflow, storages.Fast, parameters.Kf)

    # change discharges and evaporation fluxed according to areal fraction
    Fast_Discharge = Fast_Discharge * hill.Area_HRU
    GWflow = GWflow * hill.Area_HRU
    Total_Interception_Evaporation = hill.Total_Interception_Evaporation * hill.Area_HRU
    Soil_Evaporation = Soil_Evaporation * hill.Area_HRU
    # returning all fluxes (evporative, discharge)
    hill_out = Outflows(Fast_Discharge, GWflow, Soil_Evaporation, Total_Interception_Evaporation)
    #returning all storages
    hill_storages = Storages(Faststorage, storages.Interception, storages.Snow, Soilstorage)

    return hill_out, hill_storages
    #return GWflow, Fast_Discharge, Soil_Evaporation, Total_Interception_Evaporation, Interceptionstorage, Snowstorage, Soilstorage, Faststorage

end

function riparianHRU(rip::HRU_Input, storages::Storages, parameters::Parameters)
    # Are_Elevations gives the areal percentage of each elevation band. The sum has to be 1
    # Area_elevations, Precipitation, Temp_elevation, Snowstorage, Interceptionstorage has to be array of length Nr_Elevationbands
    # riparian HRU has no preferential and percolation flow
    for i in 1 : rip.Nr_Elevationbands
        # snow component
        Melt, storages.Snow[i] = snow(rip.Area_Glacier, rip.Precipitation[i], rip.Temp_Elevation[i], storages.Snow[i], parameters.Meltfactor, parameters.Mm, parameters.Temp_Thresh)
        #interception component
        Effective_Precipitation, Interception_Evaporation, storages.Interception[i] = interception(rip.Potential_Evaporation[i], rip.Precipitation[i], rip.Temp_Elevation[i], storages.Interception[i], parameters.Interceptionstoragecapacity, parameters.Temp_Thresh)
        # the melt, effective precipitation and evaporation can be summed up over all elevations according to the areal extent
        global rip.Total_Effective_Precipitation += (Effective_Precipitation + Melt) * rip.Area_Elevations[i]
        #global Total_Melt += (Melt * Area_Elevations[i])
        global rip.Total_Interception_Evaporation += (Interception_Evaporation * rip.Area_Elevations[i])
        # the storage components have to be saved for each  elevation seperately
    end

    #soil storage component
    Overlandflow, Soil_Evaporation, Soilstorage = ripariansoilstorage(rip.Total_Effective_Precipitation, rip.Total_Interception_Evaporation, rip.Potential_Evaporation_Mean, rip.Riparian_Discharge, storages.Soil, parameters.beta, parameters.Ce, parameters.Drainagecapacity, parameters.Soilstoragecapacity)
    #GWflow = Percolationflow + Preferentialflow
    #fast storage
    Fast_Discharge, Faststorage = faststorage(Overlandflow, storages.Fast, parameters.Kf)
    # change discharges according to areal fraction
    Fast_Discharge = Fast_Discharge * rip.Area_HRU
    GWflow = 0
    Total_Interception_Evaporation = rip.Total_Interception_Evaporation * rip.Area_HRU
    Soil_Evaporation = Soil_Evaporation * rip.Area_HRU
    # retungs water flows, evaporation, and states of the storage components
    rip_out = Outflows(Fast_Discharge, GWflow, Soil_Evaporation, Total_Interception_Evaporation)
    rip_storages = Storages(Faststorage, storages.Interception, storages.Snow, Soilstorage)
    return rip_out, rip_storages
    #return Fast_Discharge, Soil_Evaporation, Total_Interception_Evaporation, Interceptionstorage, Snowstorage, Soilstorage, Faststorage

end
