using DelimitedFiles
using Plots
using Dates
using Statistics
Coordinates_Gailtal = readdlm("Gailtal/Projections/pr_model_lonlat.txt", ',')

# read coordinates precipitation zones
# get the index of the coordinates for the real projection data
Coordinates_Prec_Zones = Array{Float64,2}[]
index_Coordinates_Prec_Zones = Array{Int64,1}[]
for i in 1:6
    Coordinates = readdlm("/media/sarah/Sarahs HDD/Thesis_Data/Projections/Gailtal/GIS/prec"*string(i)*".csv", ',', skipstart=1)
    push!(Coordinates_Prec_Zones, Coordinates)
    #print(typeof(Coordinates))
    #print("\n", i,"\n")
    index_Coordinates = Float64[]
    for i in 1:size(Coordinates)[1]
        current_index = findall(x-> x == Coordinates[i,1], Coordinates_Gailtal[:,1])
        append!(index_Coordinates, current_index[1])
    end
    push!(index_Coordinates_Prec_Zones, index_Coordinates)
    writedlm("Gailtal/Projections/index_coordinates.csv", index_Coordinates_Prec_Zones, ',')
end



function getPrec(path_to_prec, ID_Prec_Zones)
    Projections_Precipitation = readdlm(path_to_prec, ',')
    Precipitation_Zone = zeros(size(Projections_Precipitation)[1])
    for i in 1: length(index_Coordinates_Prec_Zones[prec_Zone])
        Current_Precipitation = Projections_Precipitation[:,index_Coordinates_Prec_Zones[prec_Zone][i]]
        Precipitation_Zone = hcat(Precipitation_Zone, Current_Precipitation)
    end
    Precipitation_Zone = Precipitation_Zone[:,2:end] ./ 10
    mean_Prec = mean(Precipitation_Zone, dims=2)
    writedlm("Gailtal/Projections/Prec"*string(prec_Zone)*".csv", mean_Prec, ',')
    return Precipitation_Zone
end

Timeseries = readdlm("Gailtal/Projections/tas_model_timeseries.txt")
Timeseries = Date.(Timeseries, Dates.DateFormat("y,m,d"))
for i in 1:6
    ID = i
    Precipitation_Zone = getPrec(ID)
end
# plot(Timeseries[12785:12785+365],Precipitation_Zone[12785:12785+365,:], size=(1800,1000))
# xlabel!("Timeseries")
# ylabel!("Temperature [°C]")
# title!("Temperature Projection Gailtal Zone"*string(ID))
# savefig("Temp_Proj_Gailttal_Zone"*string(ID)*".png")


function getTemp()
    # given the coordinates of the temperature measurement used for each precipitation zone, gets the temperature of the current projections
    # gives the elevation of each temperature
    Temp_Coordinates = readdlm("Gailtal/Projections/Temp_Coordinates.csv", ',')
    Projections_Temperature = readdlm("Gailtal/Projections/tas_sim1.txt", ',')
    Temperature_Zone = zeros(size(Projections_Temperature)[1])
    Temperature_Prec_Zones = Array{Float64,2}[]
    for i in 1:size(Temp_Coordinates)[1]
        print(i, "\n",Temp_Coordinates[i,2], "\n")
        current_index = findall(x-> x == Temp_Coordinates[i,2], Coordinates_Gailtal[:,1])
        Current_Temperature = Projections_Temperature[:,current_index] ./ 10
        push!(Temperature_Prec_Zones, Current_Temperature)
    end
    Elevation = Temp_Coordinates[:,4]
    return(Temperature_Prec_Zones, Elevation)
end

Temperature_Prec_Zones, Elevation = getTemp()
