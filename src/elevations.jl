# function to get the elevation data of each elevation
function getelevationdata(Thickness_Band, Lowest_Elevation, Mean_Elevation, Highest_Elevation)
    Nr_Elevationbands = Int(ceil((Highest_Elevation - Lowest_Elevation) / 250))
    Temp_Elevation = zeros(Nr_Elevationbands)
    Precipitation = zeros(Nr_Elevationbands)
    for i in 1 : Nr_Elevationbands
        Elevation = (Lowest_Elevation + Thickness_Band/2) + Thickness_Band * (i - 1)
        Temp_Elevation = Temperature - 0.0065 * (Elevation - Mean_Elevation)
        Precipitation = Precipitation_Mean + Prec_Gradient * (Elevation - Mean_Elevation)
    end
    return Precipitation, Temp_Elevation
end

Total_Effective_Precipitation = 0
Total_Interception_Evaporation = 0
#Total_Melt = 0

function hillslopeHRU(hill::HRU_Input)
    # Are_Elevations gives the areal percentage of each elevation band. The sum has to be 1
    # Area_elevations, Precipitation, Temp_elevation, Snowstorage, Interceptionstorage has to be array of length Nr_Elevationbands
    for i in 1 : hill.Nr_Elevationbands
        # snow component
        Melt, Snowstorage[i] = snow(hill.Area_Glacier, hill.Precipitation[i], hill.Temp_Elevation[i], hill.Snowstorage[i], hill.Meltfactor, hill.Mm, hill.Temp_Thresh)
        #interception component
        Effective_Precipitation, Interception_Evaporation, Interceptionstorage[i] = interception(hill.Potential_Evaporation[i], hill.Precipitation[i], hill.Temp_Elevation[i], hill.Interceptionstorage[i], hill.Interceptionstoragecapacity, hill.Temp_Thresh)
        # the melt, effective precipitation and evaporation can be summed up over all elevations according to the areal extent
        global Total_Effective_Precipitation += (Effective_Precipitation + Melt) * hill.Area_Elevations[i]
        #global Total_Melt += (Melt * Area_Elevations[i])
        global Total_Interception_Evaporation += (Interception_Evaporation * hill.Area_Elevations[i])
        # the storage components have to be saved for each  elevation seperately
    end

    #soil storage component
    Overlandflow, Percolationflow, Preferentialflow, Soil_Evaporation, Soilstorage = soilstorage(Total_Effective_Precipitation, Total_Interception_Evaporation, hill.Potential_Evaporation_Mean, hill.Soilstorage, hill.beta, hill.Ce, hill.Percolationcapacity, hill.Ratio_Pref, hill.Soilstoragecapacity)
    GWflow = Percolationflow + Preferentialflow
    #fast storage
    Fast_Discharge, Faststorage = faststorage(Overlandflow, hill.Faststorage, hill.Kf)

    # change discharges according to areal fraction
    Fast_Discharge = Fast_Discharge * Area_HRU
    GWflow = GWflow * Area_HRU
    # retungs water flows, evaporation, and states of the storage components
    hill_out = HRU_Output(Fast_Discharge, GWflow, Soil_Evaporation, Total_Interception_Evaporation, Faststorage, Interceptionstorage, Snowstorage, Soilstorage)

    return hill_out
    #return GWflow, Fast_Discharge, Soil_Evaporation, Total_Interception_Evaporation, Interceptionstorage, Snowstorage, Soilstorage, Faststorage

end

function riparianHRU(rip::HRU_Input)
    # Are_Elevations gives the areal percentage of each elevation band. The sum has to be 1
    # Area_elevations, Precipitation, Temp_elevation, Snowstorage, Interceptionstorage has to be array of length Nr_Elevationbands
    # riparian HRU has no preferential and percolation flow
    for i in 1 : rip.Nr_Elevationbands
        # snow component
        Melt, Snowstorage[i] = snow(rip.Area_Glacier, rip.Precipitation[i], rip.Temp_Elevation[i], rip.Snowstorage[i], rip.Meltfactor, rip.Mm, rip.Temp_Thresh)
        #interception component
        Effective_Precipitation, Interception_Evaporation, Interceptionstorage[i] = interception(rip.Potential_Evaporation[i], rip.Precipitation[i], rip.Temp_Elevation[i], rip.Interceptionstorage[i], rip.Interceptionstoragecapacity, rip.Temp_Thresh)
        # the melt, effective precipitation and evaporation can be summed up over all elevations according to the areal extent
        global Total_Effective_Precipitation += (Effective_Precipitation + Melt) * rip.Area_Elevations[i]
        #global Total_Melt += (Melt * Area_Elevations[i])
        global Total_Interception_Evaporation += (Interception_Evaporation * rip.Area_Elevations[i])
        # the storage components have to be saved for each  elevation seperately
    end

    #soil storage component
    Overlandflow, Soil_Evaporation, Soilstorage = ripariansoilstorage(Total_Effective_Precipitation, Total_Interception_Evaporation, rip.Potential_Evaporation_Mean, rip.Riparian_Discharge, rip.Soilstorage, rip.beta, rip.Ce, rip.Drainagecapacity, rip.Soilstoragecapacity)
    #GWflow = Percolationflow + Preferentialflow
    #fast storage
    Fast_Discharge, Faststorage = faststorage(Overlandflow, rip.Faststorage, rip.Kf)
    # change discharges according to areal fraction
    Fast_Discharge = Fast_Discharge * Area_HRU
    GWflow = 0
    # retungs water flows, evaporation, and states of the storage components
    rip_out = HRU_Output(Fast_Discharge, GWflow, Soil_Evaporation, Total_Interception_Evaporation, Faststorage, Interceptionstorage, Snowstorage, Soilstorage)
    return rip_out
    #return Fast_Discharge, Soil_Evaporation, Total_Interception_Evaporation, Interceptionstorage, Snowstorage, Soilstorage, Faststorage

end
