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
