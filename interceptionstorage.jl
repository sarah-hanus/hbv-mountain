function interceptionstorage(Precipitation, Potential_Evaporation, Interceptionstorage, Interception_Evaporation,
                            Interceptionstoragecapacity)
    # Storagecapacity is Imax
    if Precipitation > 0
        #if it rains
        Interceptionstorage = Interceptionstorage + Precipitation
        # the amount stored in Interception Reservoir will increase by amount of precipitation
        effective_Precipitation = max(0, Interceptionstorage - Interceptionstoragecapacity)
        # the excess precipitation will leave the reservoir directly
        Interceptionstorage = Interceptionstorage - effective_Precipitation #change in storage
        # the Interception Evporation will be either the amount stored or the potential evaporation
        Interception_Evaporation = min(Interceptionstorage, Potential_Evaporation)
        # the amount stored in the Interception Reservoir will decrease because of evaporation
        Interceptionstorage = Interceptionstorage - Interception_Evaporation
    else
        # if it does not rain
        # Evaporation only when there is no rainfall
        # no excess water leaves storage
        effective_Precipitation = 0
        # the Interception Evporation will be either the amount stored or the potential evaporation
        Interception_Evaporation = min(Interceptionstorage, Potential_Evaporation)
        # the amount stored in the Interception Reservoir will decrease because of evaporation
        Interceptionstorage = Interceptionstorage - Interception_Evaporation
    end

    return Interceptionstorage, Interception_Evaporation, effective_Precipitation
end
