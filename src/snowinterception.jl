function interception(Precipitation, Potential_Evaporation, Interceptionstorage, Interception_Evaporation,
                            Interceptionstoragecapacity, Temp, Temp_Thresh)
    # Storagecapacity is Imax
    if Temp > Temp_Thresh
        #if the temperature is higher than freezing temp, precipitation falls as rain
        if Precipitation > 0
            #if it rains
            Interceptionstorage = Interceptionstorage + Precipitation
            # the amount stored in Interception Reservoir will increase by amount of precipitation
            effective_Precipitation = max(0, Interceptionstorage - Interceptionstoragecapacity)
            # the excess precipitation will leave the reservoir directly
            Interceptionstorage = Interceptionstorage - effective_Precipitation
            #change in storage
            Interception_Evaporation = 0
            # no water will evaporate on rainy days
        else
            # if it does not rain
            # Evaporation only when there is no rainfall
            effective_Precipitation = 0
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


    return Interceptionstorage, Interception_Evaporation, effective_Precipitation
end


function snow(Area_Glacier, Precipitation, Temp, Snowstorage, Meltfactor, Mm, Temp_Thresh)

    if Temp > Temp_Thresh
        # if temperature higher than freezing temperature, melting takes place
        Melt = Meltfactor * Mm * ((Temp - ThresholdTemp)/Mm + log(1 + exp(-(Temp - ThresholdTemp)/Mm)))
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
