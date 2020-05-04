# bare rock/sparsely vegetated HRU
# catchments specific elevation data
Mean_Elevation = 2238 # elevation for which temp and prec data is known
Lowest_Elevation = 1093
Highest_Elevation = 3527
Thickness_Band = 250
Nr_Elevationbands = Int(ceil((Highest_Elevation - Lowest_Elevation) / 250))
# AREA HAS TO BE CHANGED ACCORDING TO REAL CONDITIONS
Area = ones(Nr_Elevationbands)
# evaluate snow and interception at different elevation ranges because input depends on elevation
# Temperature and Precipitation change at different altitude, therefore also potential Evaporation changes

#Parameters Global
Area_Glacier = 0.02
Prec_Gradient = 0.0035 #mm/m
Meltfactor = 2
Mm = 0.5
Temp_Thresh = 0
Ce = 0.4
Percolationcapacity = 0.2
Ratio_Pref = 0.3
Kf = 0.7
Ks = 0.01

# Parameters Bare Rock
Interceptionstoragecapacity = 2
Soilstoragecapacity = 200
beta = 1.2

Ratio_Riparian = 0.1

#Variables
Precipitation_Mean = 10
Temperature = 0
Potential_Evaporation = 5

#Storage Components

Interceptionstorage = zeros(Nr_Elevationbands)
Snowstorage = zeros(Nr_Elevationbands)
Soilstorage = 0
Faststorage = 0
Total_Effective_Precipitation = 0
Total_Interception_Evaporation = 0
Total_Melt = 0

for i in 1 : Nr_Elevationbands
    Elevation = (Lowest_Elevation + Thickness_Band/2) + Thickness_Band * (i - 1)
    Temp_Elevation = Temperature - 0.0065 * (Elevation - Mean_Elevation)
    Precipitation = Precipitation_Mean + Prec_Gradient * (Elevation - Mean_Elevation)

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

#fast storage
Fast_Discharge, Faststorage = faststorage(Overlandflow, Faststorage, Kf)

#slow storage
#Riparian_Discharge, Slow_Discharge, Slostorage = slowstorage(Percolationflow, Preferentialflow, Slowstorage[j], Ks, Ratio_Riparian)
