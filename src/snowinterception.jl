function interception(Potential_Evaporation::Float64, Precipitation::Float64, Temp::Float64, Interceptionstorage::Float64, Interceptionstoragecapacity::Float64, Temp_Thresh::Float64)
    @assert Potential_Evaporation >= 0
    @assert Precipitation >= 0
    @assert Interceptionstorage >= 0
    @assert Interceptionstorage <= Interceptionstoragecapacity
    @assert Interceptionstoragecapacity >= 0
    @assert Temp_Thresh >= -5 and <= 5 # it should be within the parameter range

    # Storagecapacity is Imax
    if Temp > Temp_Thresh
        #if the temperature is higher than freezing temp, precipitation falls as rain
        if Precipitation > 0
            #if it rains
            # the amount stored in Interception Reservoir will increase by amount of precipitation
            Interceptionstorage = Interceptionstorage + Precipitation
            # the excess precipitation will leave the reservoir directly
            Effective_Precipitation = max(0.0, Interceptionstorage - Interceptionstoragecapacity)
            #change in storage
            Interceptionstorage = Interceptionstorage - Effective_Precipitation
            # after excess water has left interceptiion storage evaporation occurs
            Interception_Evaporation = min(Interceptionstorage, Potential_Evaporation * 0.5)
            #change in storage
            Interceptionstorage = Interceptionstorage - Interception_Evaporation
        else
            # if it does not rain
            # no excess water leaves storage
            Effective_Precipitation = 0.0
            # the Interception Evporation will be either the amount stored or 50% the potential evaporation
            Interception_Evaporation = min(Interceptionstorage, Potential_Evaporation * 0.5)
            # the amount stored in the Interception Reservoir will decrease because of evaporation
            Interceptionstorage = Interceptionstorage - Interception_Evaporation

        end
        # snow melt
    else
        # snow accumulates
        # evporation is 0 and no effective precipitation is released
        Interception_Evaporation = 0.0
        Effective_Precipitation = 0.0
        Interceptionstorage = Interceptionstorage #amount stored does not change??!
    end
    #print(Interception_Evaporation, "potential", Potential_Evaporation, "\n")
    @assert Interception_Evaporation <= Potential_Evaporation * 0.5
    @assert Effective_Precipitation >= 0
    @assert Interception_Evaporation >= 0
    @assert Interceptionstorage >= 0
    @assert Interceptionstorage <= Interceptionstoragecapacity
    return Effective_Precipitation::Float64, Interception_Evaporation::Float64, Interceptionstorage::Float64
end


function snow(Area_Glacier::Float64, Precipitation::Float64, Temp::Float64, Snowstorage::Float64, Meltfactor::Float64, Mm::Float64, Temp_Thresh::Float64)

    @assert Area_Glacier >= 0 and <= 1
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
        Melt_Total = 0.0
    end

    @assert Melt_Total >= 0
    @assert Snowstorage >= 0

    return Melt_Total::Float64, Snowstorage::Float64
end


function soilstorage(Effective_Precipitation::Float64, Interception_Evaporation::Float64, Potential_Evaporation::Float64, Soilstorage::Float64, beta::Float64, Ce::Float64, Percolationcapacity::Float64, Ratio_Pref::Float64, Soilstoragecapacity::Float64)
    @assert Effective_Precipitation >= 0
    @assert Interception_Evaporation >= 0
    @assert Potential_Evaporation >= 0
    #print(Interception_Evaporation, "pot", Potential_Evaporation,"\n")
    #asserz rounded value because there can be a difference because of rounding
    @assert round(Interception_Evaporation, digits=15) <= round(Potential_Evaporation, digits=15)
    #@assert Soil_Evaporation >= 0 #or should it be zero?
    @assert Soilstorage >= 0
    @assert Soilstorage <= Soilstoragecapacity
    @assert Soilstoragecapacity > 0 #within the parameter range
    @assert beta > 0 #within the parameter range
    @assert Ce > 0 #within the parameter range
    @assert Percolationcapacity >= 0
    @assert Ratio_Pref >= 0

    if Effective_Precipitation > 0
        # rho represents the non linear process that only part of precipitation enters soil
        # different rho??
        Ratio_Soil = 1 - (1 - (Soilstorage/Soilstoragecapacity))^beta
        @assert Ratio_Soil <= 1 and >= 0
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
        Overlandflow = 0.0
        Preferentialflow = 0.0
    end
    # Transpiration in soil, only the part that not evaporated in interception reservoir can evaporate
    Potential_Soilevaporation = max(Potential_Evaporation - Interception_Evaporation, 0)
    # transpiration can maximum be the amount stored in soil, or a percentage of potential evaporation
    Soil_Evaporation = Potential_Soilevaporation * min(Soilstorage / (Soilstoragecapacity * Ce), 1.0)
    Soil_Evaporation = min(Soilstorage, Soil_Evaporation)
    Soilstorage = Soilstorage - Soil_Evaporation
    # Part of the water stored in soil will percolate into groundwater depending on the percolation capacity
    Percolationflow = (Soilstorage / Soilstoragecapacity) * Percolationcapacity
    Soilstorage = Soilstorage - Percolationflow

    @assert Overlandflow >= 0
    @assert Percolationflow >= 0
    @assert Preferentialflow >= 0
    @assert Soil_Evaporation <= max(Potential_Evaporation - Interception_Evaporation,0)
    @assert Soil_Evaporation >= 0
    @assert Soilstorage >= 0
    @assert Soilstorage <= Soilstoragecapacity
    return Overlandflow::Float64, Percolationflow::Float64, Preferentialflow::Float64, Soil_Evaporation::Float64, Soilstorage::Float64
end

function ripariansoilstorage(Effective_Precipitation, Interception_Evaporation, Potential_Evaporation, Riparian_Discharge, Soilstorage, beta, Ce, Drainagecapacity, Soilstoragecapacity)
    @assert Effective_Precipitation >= 0
    @assert Interception_Evaporation >= 0
    @assert Potential_Evaporation >= 0
    @assert Riparian_Discharge >= 0
    #@assert Soil_Evaporation >= 0 #or should it be zero?
    @assert Soilstorage >= 0
    @assert Soilstorage <= Soilstoragecapacity
    @assert Soilstoragecapacity > 0 #within the parameter range
    @assert beta > 0 #within the parameter range
    @assert Ce > 0 #within the parameter range
    @assert Drainagecapacity >= 0

    Ratio_Soil = 1 - (1 - (Soilstorage/Soilstoragecapacity))^beta
    Q_Soil = min((1 - Ratio_Soil) * (Effective_Precipitation + Riparian_Discharge), Soilstoragecapacity - Soilstorage)
    Soilstorage = Soilstorage + Q_Soil
    # the other part does not enter the soil but flows into the fast reservoir
    Overlandflow = (Effective_Precipitation + Riparian_Discharge - Q_Soil)
    # Transpiration in soil, only the part that not evaporated in interception reservoir can evaporate
    Potential_Soilevaporation = max(Potential_Evaporation - Interception_Evaporation,0)
    # transpiration can maximum be the amount stored in soil, or a percentage of potential evaporation
    Soil_Evaporation = Potential_Soilevaporation * min(Soilstorage / (Soilstoragecapacity * Ce), 1)
    Soil_Evaporation = min(Soilstorage, Soil_Evaporation)
    Soilstorage = Soilstorage - Soil_Evaporation
    # Part of the water stored in soil will drain to a maximum capacity, which is routed into the fast response reservoir
    Fastdrainage = (Soilstorage / Soilstoragecapacity) * Drainagecapacity
    Soilstorage = Soilstorage - Fastdrainage
    Overlandflow = Overlandflow + Fastdrainage

    @assert Overlandflow >= 0
    @assert Soil_Evaporation <= max(Potential_Evaporation - Interception_Evaporation,0)
    @assert Soil_Evaporation >= 0
    @assert Soilstorage >= 0
    @assert Soilstorage <= Soilstoragecapacity
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
    @assert Fast_Discharge >= 0
    @assert Faststorage >= 0
    return Fast_Discharge, Faststorage
end

function slowstorage(GWflow, Slowstorage, Ks, Ratio_Riparian)
    @assert GWflow >= 0
    @assert Slowstorage >= 0
    @assert Ks >=0 and <= 1
    @assert Ratio_Riparian >=0 and <= 1

    Slowstorage = Slowstorage + GWflow
    Slow_Discharge = Ks * Slowstorage * (1 - Ratio_Riparian)
    Riparian_Discharge = Ks * Slowstorage * Ratio_Riparian
    Slowstorage = Slowstorage - Slow_Discharge - Riparian_Discharge

    @assert Riparian_Discharge >= 0
    @assert Slow_Discharge >= 0
    @assert Slowstorage >= 0
    return Riparian_Discharge, Slow_Discharge, Slowstorage
end

export interception
export snow
export ripariansoilstorage
export soilstorage
export faststorage
export slowstorage
