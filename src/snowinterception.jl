function interception(Potential_Evaporation, Precipitation, Temp, Interceptionstorage, Interception_Evaporation,
                            Interceptionstoragecapacity, Temp_Thresh)
    @assert Potential_Evaporation >= 0
    @assert Precipitation >= 0
    @assert Interceptionstorage >= 0
    @assert Interception_Evaporation >= 0 #or maybe it should be 0??
    @assert Interceptionstoragecapacity >= 0
    @assert Temp_Thresh >= -5 and <= 5 # it should be within the parameter range

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
    end
    return Effective_Precipitation, Interception_Evaporation, Interceptionstorage
end


function snow(Area_Glacier, Precipitation, Temp, Snowstorage, Meltfactor, Mm, Temp_Thresh)

    @assert Area_Glacier >= 0
    @assert Precipitation >= 0
    @assert Snowstorage >= 0
    @assert Meltfactor >= 0 #within the parameter range
    @assert Mm >= 0 #within the parameter range
    @assert Temp_Thresh >= -5 and <= 5 # it should be within the parameter range

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
    end

    return Melt_Total, Snowstorage
end


function soilstorage(Effective_Precipitation, Interception_Evaporation, Potential_Evaporation, Soil_Evaporation, Soilstorage, beta, Ce, Percolationcapacity, Ratio_Pref, Soilstoragecapacity)
    @assert Effective_Precipitation >= 0
    @assert Interception_Evaporation >= 0
    @assert Potential_Evaporation >= 0
    @assert Soil_Evaporation >= 0 #or should it be zero?
    @assert Soilstorage >= 0
    @assert Soilstoragecapacity > 0 #within the parameter range
    @assert beta > 0 #within the parameter range
    @assert Ce > 0 #within the parameter range
    @assert Percolationcapacity >= 0
    @assert Ratio_Pref >= 0


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
        Q_Soil = min((1 - Ratio_Soil) * Effective_Precipitation, Soilstoragecapacity - Soilstorage)
        Soilstorage = Soilstorage + Q_Soil
        # the other part does not enter the soil but flows into the fast reservoir
        Overlandflow = (Effective_Precipitation - Q_Soil) * Ratio_Pref
        # or flows into the groundwater
        Preferentialflow = (Effective_Precipitation - Q_Soil) * (1 - Ratio_Pref)

    else
        # if it does not rain no overland flow occurs
        Overlandflow = 0
        Preferentialflow = 0
    end
    # Transpiration in soil, only the part that not evaporated in interception reservoir can evaporate
    Potential_Soilevaporation = Potential_Evaporation - Interception_Evaporation
    # transpiration can maximum be the amount stored in soil, or a percentage of potential evaporation
    Soil_Evaporation = Potential_Soilevaporation * min(Soilstorage / (Soilstoragecapacity * Ce), 1)
    Soil_Evaporation = min(Soilstorage, Soil_Evaporation)
    Soilstorage = Soilstorage - Soil_Evaporation
    # Part of the water stored in soil will percolate into groundwater depending on the percolation capacity
    Percolationflow = (Soilstorage / Soilstoragecapacity) * Percolationcapacity
    Soilstorage = Soilstorage - Percolationflow

    return Overlandflow, Percolationflow, Preferentialflow, Soil_Evaporation, Soilstorage
end

function ripariansoilstorage(Effective_Precipitation, Interception_Evaporation, Potential_Evaporation, Riparian_Discharge, Soil_Evaporation, Soilstorage, beta, Ce, Drainagecapacity, Soilstoragecapacity)
    @assert Effective_Precipitation >= 0
    @assert Interception_Evaporation >= 0
    @assert Potential_Evaporation >= 0
    @assert Riparian_Discharge >= 0
    @assert Soil_Evaporation >= 0 #or should it be zero?
    @assert Soilstorage >= 0
    @assert Soilstoragecapacity > 0 #within the parameter range
    @assert beta > 0 #within the parameter range
    @assert Ce > 0 #within the parameter range
    @assert Drainagecapacity >= 0
    if Effective_Precipitation > 0
        # non linear process: only part of precipitation enters soil
        Ratio_Soil = 1 - (1 - (Soilstorage/Soilstoragecapacity))^beta
        # # part of precipitation doesn't enters soil, but flows directly to fast reservoir
        # Overlandflow = Ratio_Soil * Effective_Precipitation * Ratio_pref
        # # or flows into the groundwater reservoir
        # Preferentialflow = Ratio_Soil * Effective_Precipitation * (1 - Ratio_pref)
        # # the rest of the water enters the soil reservoir
        # Soilstorage = Soilstorage + (1 - Ratio_Soil) * Effective_Precipitation #flow into unsaturated zone

        # part of the water (Precipitation + melt + water from GW) enters the soil, it cannot exceed the soil storage capacity
        Q_Soil = min((1 - Ratio_Soil) * (Effective_Precipitation + Riparian_Discharge), Soilstoragecapacity - Soilstorage)
        Soilstorage = Soilstorage + Q_Soil
        # the other part does not enter the soil but flows into the fast reservoir
        Overlandflow = (Effective_Precipitation + Riparian_Discharge - Q_Soil)
    else
        # if it does not rain no overland flow occurs
        Overlandflow = 0
    end
    # Transpiration in soil, only the part that not evaporated in interception reservoir can evaporate
    Potential_Soilevaporation = Potential_Evaporation - Interception_Evaporation
    # transpiration can maximum be the amount stored in soil, or a percentage of potential evaporation
    Soil_Evaporation = Potential_Soilevaporation * min(Soilstorage / (Soilstoragecapacity * Ce), 1)
    Soil_Evaporation = min(Soilstorage, Soil_Evaporation)
    Soilstorage = Soilstorage - Soil_Evaporation
    # Part of the water stored in soil will drain to a maximum capacity, which is routed into the fast response reservoir
    Fastdrainage = (Soilstorage / Soilstoragecapacity) * Drainagecapacity
    Soilstorage = Soilstorage - Fastdrainage
    Overlandflow = Overlandflow + Fastdrainage

    return Overlandflow, Soil_Evaporation, Soilstorage
end


function faststorage(Overlandflow, Faststorage, Kf)
    @assert Overlandflow >= 0
    @assert Faststorage >= 0
    @assert Kf >=0 and <= 1
    # the fast storage increases with the overland flow
    Faststorage = Faststorage + Overlandflow
    # a part of the fast storage gets redirected into discharge depending on the reservoir constant (linear response)
    Fast_Discharge = Kf * Faststorage
    Faststorage = Faststorage - Fast_Discharge

    return Fast_Discharge, Faststorage
end

function slowstorage(Percolationflow, Preferentialflow, Slowstorage, Ks, Ratio_Riparian)
    @assert Percolationflow >= 0
    @assert Preferentialflow >= 0
    @assert Slowstorage >= 0
    @assert Ks >=0 and <= 1
    @assert Ratio_Riparian >=0 and <= 1

    Slowstorage = Slowstorage + Percolationflow + Preferentialflow
    Slow_Discharge = Ks * Slowstorage * (1 - Ratio_Riparian)
    Riparian_Discharge = Ratio_Riparian * Slow_Discharge
    Slowstorage = Slowstorage - Slow_Discharge

    return Riparian_Discharge, Slow_Discharge, Slowstorage
end

export interception
export snow
export ripariansoilstorage
export soilstorage
export faststorage
export slowstorage
