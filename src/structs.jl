mutable struct HRU_Input
    #inputs (alphabetic order)
    Area_Elevations::Array{Float64,1}
    Area_HRU:: Float64
    Area_Glacier:: Float64 # smaller than 1
    Nr_Elevationbands:: Int8
    Potential_Evaporation::Array{Float64,1} #muss später auch Array werden!!! average Epot for soiL!!!
    Potential_Evaporation_Mean:: Float64
    Precipitation::Array{Float64,1}
    Riparian_Discharge:: Float64 #only necessary for riparian HRU
    Temp_Elevation::Array{Float64,1}
    Total_Effective_Precipitation::Float64
    Total_Interception_Evaporation::Float64
end

mutable struct Parameters
    # parameters (alphabetic order)
    beta:: Float64
    Ce:: Float64
    Drainagecapacity:: Float64 #only necessary for riparian HRU
    Interceptionstoragecapacity:: Float64
    Kf:: Float64
    Meltfactor:: Float64
    Mm:: Float64
    #Percolationcapacity:: Float64 #only necessary for hillslope HRU
    Ratio_Pref:: Float64 #only necessary for hillslope HRU
    Soilstoragecapacity:: Float64
    Temp_Thresh:: Float64
end

mutable struct Storages
    Fast:: Float64
    Interception::Array{Float64,1}
    Snow::Array{Float64,1}
    Soil:: Float64
end

mutable struct Outflows
    Fast_Discharge:: Float64
    GWflow:: Float64 #only necessary for hillslope HRU
    Soil_Evaporation:: Float64
    Interception_Evaporation:: Float64
end


#
# mutable struct HRU_Output
#     Fast_Discharge:: Float64
#     GWflow:: Float64 #only necessary for hillslope HRU
#     Soil_Evaporation:: Float64
#     Total_Interception_Evaporation:: Float64
#     #storages
#     Faststorage:: Float64
#     Interceptionstorage::Array{Float64,1}
#     Snowstorage::Array{Float64,1}
#     Soilstorage:: Float64
# end
