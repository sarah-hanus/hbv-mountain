function soilstorage(Soilstorage, Potential_Evaporation, Interception_Evaporation, effective_Precipitation, beta, Soilstoragecapacity, Ce, Percolationcapacity)
    if effective_Precipitation > 0
        # rho represents the non linear process that only part of precipitation enters soil
        # different rho??
        rho = (Soilstorage/Soilstoragecapacity)^beta
        # part of precipitation doesn't enters soil, but flows directly to fast reservoir
        Overlandflow = rho * effective_Precipitation #flow into fast reservoir
        # the rest of the water enters the soil reservoir
        Soilstorage = Soilstorage + (1 - rho)* effective_Precipitation #flow into unsaturated zone
    else
        # if it does not rain no overland flow occurs
        Overlandflow = 0
    end
    # Transpiration in soil, only the part that not evaporated in interception reservoir can evaporate
    Potential_Soilevaporation = max(0, Potential_Evaporation - Interception_Evaporation)
    # transpiration can maximum be the amount stored in soil, or a percentage of potential evaporation
    # possibly WRONG because more can evaporate than it is present
    Soil_Evaporation = Potential_Soilevaporation * (Soilstorage / (Soilstoragecapacity * Ce))
    Soil_Evaporation = min(Soilstorage, Soil_Evaporation)
    Soilstorage = Soilstorage - Soil_Evaporation
    # Part of the water stored in soil will percolate into groundwater depending on the percolation capacity
    Percolationflow = (Soilstorage / Soilstoragecapacity) * Percolationcapacity
    Soilstorage = Soilstorage - Percolationflow #??

    return Soilstorage, Overlandflow, Percolationflow, Soil_Evaporation
end
