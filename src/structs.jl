mutable struct Interception
    Potential_Evaporation:: Float64
    Precipitation:: Float64
    Temp:: Float64
    Interceptionstorage:: Float64
    Interceptionstoragecapacity:: Float64
    Temp_Thresh:: Float64
end

bare = Interception(5,4,3,1,2,0)

function testInterception(v::Interception)
    print(v.Potential_Evaporation)
end

testInterception(bare)

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
    #storages (alphabetic order)
    Faststorage:: Float64
    Interceptionstorage::Array{Float64,1}
    Snowstorage::Array{Float64,1}
    Soilstorage:: Float64
    # parameters (alphabetic order)
    beta:: Float64
    Ce:: Float64
    Drainagecapacity:: Float64 #only necessary for riparian HRU
    Interceptionstoragecapacity:: Float64
    Kf:: Float64
    Meltfactor:: Float64
    Mm:: Float64
    Percolationcapacity:: Float64 #only necessary for hillslope HRU
    Ratio_Pref:: Float64 #only necessary for hillslope HRU
    Soilstoragecapacity:: Float64
    Temp_Thresh:: Float64
end



mutable struct HRU_Output
    Fast_Discharge:: Float64
    GWflow:: Float64 #only necessary for hillslope HRU
    Soil_Evaporation:: Float64
    Total_Interception_Evaporation:: Float64
    #storages
    Faststorage:: Float64
    Interceptionstorage::Array{Float64,1}
    Snowstorage::Array{Float64,1}
    Soilstorage:: Float64
end
