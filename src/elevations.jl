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

function bareHRU(Area_Glacier, Precipitation, Temp_Elevation, Snowstorage, Meltfactor, Mm, Temp_Thresh, Potential_Evaporation, Interceptionstorage, Interceptionstoragecapacity, Soilstorage, beta, Ce, Percolationcapacity, Ratio_Pref, Soilstoragecapacity, Faststorage, Kf)
    for i in 1 : Nr_Elevationbands
        # snow component
        Melt, Snowstorage[i] = snow(Area_Glacier, Precipitation, Temp_Elevation, Snowstorage[i], Meltfactor, Mm, Temp_Thresh)
        #interception component
        Effective_Precipitation, Interception_Evaporation, Interceptionstorage[i] = interception(Potential_Evaporation, Precipitation, Temp_Elevation, Interceptionstorage[i], Interceptionstoragecapacity, Temp_Thresh)
        # the melt, effective precipitation and evaporation can be summed up over all elevations according to the areal extent
        global Total_Effective_Precipitation += (Effective_Precipitation * Area[i])
        global Total_Melt += (Melt * Area[i])
        global Total_Interception_Evaporation += (Interception_Evaporation * Area[i])
        # the storage components have to be saved for each  elevation seperately
    end

    #soil storage component
    Overlandflow, Percolationflow, Preferentialflow, Soil_Evaporation, Soilstorage = soilstorage(Total_Effective_Precipitation, Total_Interception_Evaporation, Potential_Evaporation, Soilstorage, beta, Ce, Percolationcapacity, Ratio_Pref, Soilstoragecapacity)
    GWflow = Percolationflow + Preferentialflow
    #fast storage
    Fast_Discharge, Faststorage = faststorage(Overlandflow, Faststorage, Kf)
    # retungs water flows, evaporation, and states of the storage components
    return GWflow, Fast_Discharge, Soil_Evaporation, Total_Interception_Evaporation, Interceptionstorage, Snowstorage, Soilstorage, Faststorage
