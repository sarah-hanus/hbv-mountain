# function to get the elevation data of each elevation
function getelevationdata(Thickness_Band, Lowest_Elevation, Mean_Elevation, Highest_Elevation, Prec_Gradient, Temperature, Precipitation_Mean)
    Nr_Elevationbands = Int(ceil((Highest_Elevation - Lowest_Elevation) / Thickness_Band))
    # make an array with number of rows equal to number of days, and columns equal to number of elevations
    Temp_Elevation = zeros(length(Temperature), Nr_Elevationbands)
    Precipitation = zeros(length(Temperature),Nr_Elevationbands)
    Elevation = Float64[]

    for i in 1 : Nr_Elevationbands
        Current_Elevation = (Lowest_Elevation + Thickness_Band/2) + Thickness_Band * (i - 1)
        for j in 1: length(Temperature)
            global Temp_Elevation[j,i] = Temperature[j] - 0.006 * (Current_Elevation - Mean_Elevation)
            global Precipitation[j,i] = max((Precipitation_Mean[j] + Prec_Gradient * (Current_Elevation - Mean_Elevation)),0)
        end
        push!(Elevation, Current_Elevation)
    end
    return Elevation, Precipitation, Temp_Elevation, Nr_Elevationbands
end

function getelevationbands(Thickness_Band, Lowest_Elevation, Highest_Elevation, Elevation_Catchment)
    Nr_Elevationbands = Int(ceil((Highest_Elevation - Lowest_Elevation) / Thickness_Band))
    Elevation = Float64[]
    Elevation_Count = Float64[]
    for i in 1 : Nr_Elevationbands
        Current_Elevation = (Lowest_Elevation + Thickness_Band/2) + Thickness_Band * (i - 1)
        push!(Elevation, Current_Elevation)
    end
    j = 1
    for (i,elevation) in enumerate(Elevation_Catchment)
            if j <= length(Elevation) && elevation == Elevation[j]
                    Count = i
                    #print(i,"\n")
                    j += 1
                    push!(Elevation_Count, Count)
            end
    end
    #Area_Elevations = ones(length(Elevation_Count))/ length(Elevation_Count)
    return Elevation_Count
end
