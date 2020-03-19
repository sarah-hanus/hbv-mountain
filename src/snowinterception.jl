function interception(Potential_Evaporation, Precipitation, Temp, Interceptionstorage, Interception_Evaporation,
                            Interceptionstoragecapacity, Temp_Thresh)
    # Storagecapacity is Imax
    if Temp > Temp_Thresh
        #if the temperature is higher than freezing temp, precipitation falls as rain
        if Precipitation > 0
            #if it rains
            Interceptionstorage = Interceptionstorage + Precipitation
            # the amount stored in Interception Reservoir will increase by amount of precipitation
            Effective_Precipitation = max(0, Interceptionstorage - Interceptionstoragecapacity)
            # the excess precipitation will leave the reservoir directly
            Interceptionstorage = Interceptionstorage - Effective_Precipitation
            #change in storage
            Interception_Evaporation = 0
            # no water will evaporate on rainy days
        else
            # if it does not rain
            # Evaporation only when there is no rainfall
            Effective_Precipitation = 0
            # no excess water leaves storage
            Interception_Evaporation = min(Interceptionstorage, Potential_Evaporation)
            # the Interception Evporation will be either the amount stored or the potential evaporation
            Interceptionstorage = Interceptionstorage - Interception_Evaporation
            # the amount stored in the Interception Reservoir will decrease because of evaporation
        end
        # snow melt
    else
        # snow accumulates
        # evporation is 0 and no effective precipitation is released
        Interception_Evaporation = 0
        effective_Precipitation = 0
        Interceptionstorage = Interceptionstorage #amount stored does not change??!


    return Effective_Precipitation, Interception_Evaporation, Interceptionstorage
end


function snow(Area_Glacier, Precipitation, Temp, Snowstorage, Meltfactor, Mm, Temp_Thresh)

    if Temp > Temp_Thresh
        # if temperature higher than freezing temperature, melting takes place
        Melt = Meltfactor * Mm * ( (Temp - Temp_Thresh) / Mm + log(1 + exp(- (Temp - Temp_Thresh) / Mm) ) )
        # it can only melt as much as it is stored in snow storage
        Melt_Snow = min(Melt, Snowstorage)
        Melt_Glacier = Melt
        # the total melt is the combination of snow and glacier melt and the areal extent
        Melt_Total = Melt_Snow * (1 - Area_Glacier) + Melt_Glacier * Area_Glacier
        # the amount of snow stored decreases by amount melted
        Snowstorage = Snowstorage - Melt_Snow
    else
        # the amount of snow stored increases by Precipitation
        Snowstorage = Snowstorage + Precipitation
        # no snow melts
        Melt_Total = 0

    return Melt_Total, Snowstorage
end


function soilstorage(Effective_Precipitation, Interception_Evaporation, Potential_Evaporation, Soil_Evaporation, Soilstorage, beta, Ce, Percolationcapacity, Ratio_Pref, Soilstoragecapacity)
    if Effective_Precipitation > 0
        # rho represents the non linear process that only part of precipitation enters soil
        # different rho??
        Ratio_Soil = 1 - (1 - (Soilstorage/Soilstoragecapacity))^beta
        # # part of precipitation doesn't enters soil, but flows directly to fast reservoir
        # Overlandflow = Ratio_Soil * Effective_Precipitation * Ratio_pref
        # # or flows into the groundwater reservoir
        # Preferentialflow = Ratio_Soil * Effective_Precipitation * (1 - Ratio_pref)
        # # the rest of the water enters the soil reservoir
        # Soilstorage = Soilstorage + (1 - Ratio_Soil) * Effective_Precipitation #flow into unsaturated zone

        # part of the water enters the soil, it cannot exceed the soil storage capacity
        Q_Soil = min(1 - Ratio_Soil) * Effective_Precipitation, Soilstoragecapacity - Soilstorage)
        Soilstorage = Soilstorage + Q_Soil
        # the other part does not enter the soil but flows into the fast reservoir
        Overlandflow = (Effective_Precipitation - Q_Soil) * Ratio_Pref
        # or flows into the groundwater
        Preferentialflow = = (Effective_Precipitation - Q_Soil) * (1 - Ratio_Pref)

    else
        # if it does not rain no overland flow occurs
        Overlandflow = 0
        Preferentialflow = 0
    end
    # Transpiration in soil, only the part that not evaporated in interception reservoir can evaporate
    Potential_Soilevaporation = max(0, Potential_Evaporation - Interception_Evaporation)
    # transpiration can maximum be the amount stored in soil, or a percentage of potential evaporation
    # possibly WRONG because more can evaporate than it is present
    #plot it to see it!!!
    Soil_Evaporation = Potential_Soilevaporation * min(Soilstorage / (Soilstoragecapacity * Ce), 1)
    Soil_Evaporation = min(Soilstorage, Soil_Evaporation)
    Soilstorage = Soilstorage - Soil_Evaporation
    # Part of the water stored in soil will percolate into groundwater depending on the percolation capacity
    Percolationflow = (Soilstorage / Soilstoragecapacity) * Percolationcapacity
    Soilstorage = Soilstorage - Percolationflow #??

    return Overlandflow, Percolationflow, Preferentialflow, Soil_Evaporation, Soilstorage
end
