using DocStringExtensions
"""
Computes the temperature at different elevations

$(SIGNATURES)

The Temperature should be an array of different days of measurements. The height of the station where temperature was measured should be given (Measured_Temp_Elevation)
as well as the min and maximum elevation using the Elevation struct.
"""
function gettemperatureatelevation(Elevations::Elevations, Temperature::Array{Float64,1})
    Nr_Elevationbands = Int((Elevations.Max_elevation - Elevations.Min_elevation) / Elevations.Thickness_Band)
    # make an array with number of rows equal to number of days, and columns equal to number of elevations
    Temp_Elevation = zeros(length(Temperature), Nr_Elevationbands)
    Elevation = Float64[]
    for i in 1 : Nr_Elevationbands
        Current_Elevation = (Elevations.Min_elevation + Elevations.Thickness_Band/2) + Elevations.Thickness_Band * (i - 1)
        for j in 1: length(Temperature)
            Temp_Elevation[j,i] = Temperature[j] - 0.006 * (Current_Elevation - Elevations.Measured_Temp_Elevation)
        end
        push!(Elevation, Current_Elevation)
    end
    return Elevation::Array{Float64, 1}, Temp_Elevation::Array{Float64,2}, Nr_Elevationbands::Int64
end
"""
Computes the precipitation at different elevations assuming a precipitation gradient with altitude

$(SIGNATURES)

The precipitation should be an array of different days of measurements. The height of the station where percipitation was measured should be given (Elevations.Measured_Prec_Elevation)
as well as the min and maximum elevation using the Elevation struct.
"""
function getprecipitationatelevation(Elevations::Elevations, Prec_Gradient::Float64, Precipitation)
    Nr_Elevationbands = Int((Elevations.Max_elevation - Elevations.Min_elevation) / Elevations.Thickness_Band)
    # make an array with number of rows equal to number of days, and columns equal to number of elevations
    Precipitation_Elevation = zeros(length(Precipitation),Nr_Elevationbands)
    Elevation = Float64[]
    for i in 1 : Nr_Elevationbands
        Current_Elevation = (Elevations.Min_elevation + Elevations.Thickness_Band/2) + Elevations.Thickness_Band * (i - 1)
        for j in 1: length(Precipitation)
            Precipitation_Elevation[j,i] = max((Precipitation[j] + Prec_Gradient * (Current_Elevation - Elevations.Measured_Prec_Elevation)),0)
        end
        push!(Elevation, Current_Elevation)
    end
    return Elevation::Array{Float64, 1}, Precipitation_Elevation::Array{Float64, 2}, Nr_Elevationbands::Int64
end

# function getelevationbands(Thickness_Band, Lowest_Elevation, Highest_Elevation, Elevation_Catchment)
#     Nr_Elevationbands = Int(ceil((Highest_Elevation - Lowest_Elevation) / Thickness_Band))
#     Elevation = Float64[]
#     Elevation_Count = Float64[]
#     for i in 1 : Nr_Elevationbands
#         Current_Elevation = (Lowest_Elevation + Thickness_Band/2) + Thickness_Band * (i - 1)
#         push!(Elevation, Current_Elevation)
#     end
#     j = 1
#     for (i,elevation) in enumerate(Elevation_Catchment)
#             if j <= length(Elevation) && elevation == Elevation[j]
#                     Count = i
#                     #print(i,"\n")
#                     j += 1
#                     push!(Elevation_Count, Count)
#             end
#     end
#     #Area_Elevations = ones(length(Elevation_Count))/ length(Elevation_Count)
#     return Elevation_Count
# end

"""
Computes the elevations for a given HRU

$(SIGNATURES)

Returns the elevations of each HRU and the corresponding percentage of area.
"""
function getelevationsperHRU(Areal_Percentage::Array{Float64,1}, Elevation_Catchment, Elevation_Zone)
        Elevation_HRU = Float64[]
        Area = Float64[]
        j = 1
        for (i, elevation) in enumerate(Elevation_Catchment)
                if j <= length(Elevation_Zone) && elevation == Elevation_Zone[j]
                        if Areal_Percentage[i] != 0
                                push!(Area, Areal_Percentage[i])
                                push!(Elevation_HRU, j)
                        end
                        j+= 1
                end
        end
        return Area, Elevation_HRU
end


"""
Computes the daily mean temperature

$(SIGNATURES)

x has to be given as an array of Dates and Temperature Measurements.
Compute the mean daily temperature, assuming that the times of measurement are representatively distributed over the day

"""
function daily_mean(Temperature_Array)
        Temperature_Daily::Array{Float64, 1} = Array{Float64, 1}[]
        Date_Daily::Array{Date,1} = Array{Date, 1}[]
        # to make it correct when a value is missing the mean should not just be taken from the other values (Different times of day)
        # skips days with missing values
        measurement_count::Int16 = 0
        temperature_day_total = 0
        lastvalue = length(Temperature_Array[:,1])
        #Temperature_Array_Iterator = skipmissing(Temperature_Array)
        for i in 1:length(Temperature_Array[:,1])
        # sum up all measurements for a day and count the measurements
                if (i > 1 && Temperature_Array[i, 1] != Temperature_Array[i-1, 1])
                        mean_Temp = temperature_day_total / measurement_count
                        measurement_count = 0
                        temperature_day_total = 0

                        push!(Date_Daily, Temperature_Array[i - 1, 1])
                        push!(Temperature_Daily, mean_Temp)
                elseif i == lastvalue
                        if ismissing(Temperature_Array[i,2]) != true
                                temperature_day_total += Temperature_Array[i, 2]
                                measurement_count += 1
                        end
                        mean_Temp = temperature_day_total / measurement_count
                        push!(Date_Daily, Temperature_Array[i, 1])
                        push!(Temperature_Daily, mean_Temp)
                end

                if ismissing(Temperature_Array[i,2]) != true
                        temperature_day_total += Temperature_Array[i, 2]
                        measurement_count += 1
                end
        end

        return Date_Daily, Temperature_Daily
end

#
# function load_precipitation_data(Areas_HRUs, Area_Zones, Elevations_All_Zones, Elevation_Catchment, ID_Prec_Zones, Precipitation_Gradient)
#         Inputs_All_Zones = Array{HRU_Input, 1}[]
#         Storages_All_Zones = Array{Storages, 1}[]
#         Precipitation_All_Zones = Array{Float64, 1}[]
#         Elevation_Percentage = Array{Float64, 1}[]
#         Nr_Elevationbands_All_Zones = Int64[]
#         Elevations_Each_Precipitation_Zone = Array{Float64, 1}[]
#         for i in 1: length(ID_Prec_Zones)
#                 #print(ID_Prec_Zones)
#                 Precipitation = CSV.read("Gailtal/N-Tagessummen-"*string(ID_Prec_Zones[i])*".csv", header= false, skipto=Skipto[i], missingstring = "L\xfccke", decimal=',', delim = ';')
#                 Precipitation_Array = convert(Matrix, Precipitation)
#                 startindex = findfirst(isequal("01.01.1985 07:00:00   "), Precipitation_Array)
#                 endindex = findfirst(isequal("31.12.2009 07:00:00   "), Precipitation_Array)
#                 Precipitation_Array = Precipitation_Array[startindex[1]:endindex[1],:]
#                 Precipitation_Array[:,1] = Date.(Precipitation_Array[:,1], Dates.DateFormat("d.m.y H:M:S   "))
#                 # find duplicates and remove them
#                 df = DataFrame(Precipitation_Array)
#                 df = unique!(df)
#                 # drop missing values
#                 df = dropmissing(df)
#                 Precipitation_Array = convert(Matrix, df)
#
#                 Elevation_HRUs, Precipitation, Nr_Elevationbands = getprecipitationatelevation(Elevations_All_Zones[i], Precipitation_Gradient, Precipitation_Array[:,2])
#                 push!(Precipitation_All_Zones, Precipitation)
#                 push!(Nr_Elevationbands_All_Zones, Nr_Elevationbands)
#                 push!(Elevations_Each_Precipitation_Zone, Elevation_HRUs)
#
#                 index_HRU = (findall(x -> x==ID_Prec_Zones[i], Areas_HRUs[1,2:end]))
#                 # for each precipitation zone get the relevant areal extentd
#                 Current_Areas_HRUs = convert(Matrix, Areas_HRUs[2: end, index_HRU])
#                 # the elevations of each HRU have to be known in order to get the right temperature data for each elevation
#                 Area_Bare_Elevations, Bare_Elevation_Count = getelevationsperHRU(Current_Areas_HRUs[:,1], Elevation_Catchment, Elevation_HRUs)
#                 Area_Forest_Elevations, Forest_Elevation_Count = getelevationsperHRU(Current_Areas_HRUs[:,2], Elevation_Catchment, Elevation_HRUs)
#                 Area_Grass_Elevations, Grass_Elevation_Count = getelevationsperHRU(Current_Areas_HRUs[:,3], Elevation_Catchment, Elevation_HRUs)
#                 Area_Rip_Elevations, Rip_Elevation_Count = getelevationsperHRU(Current_Areas_HRUs[:,4], Elevation_Catchment, Elevation_HRUs)
#                 #print(Bare_Elevation_Count, Forest_Elevation_Count, Grass_Elevation_Count, Rip_Elevation_Count)
#                 @assert 1 - eps(Float64) <= sum(Area_Bare_Elevations) <= 1 + eps(Float64)
#                 @assert 1 - eps(Float64) <= sum(Area_Forest_Elevations) <= 1 + eps(Float64)
#                 @assert 1 - eps(Float64) <= sum(Area_Grass_Elevations) <= 1 + eps(Float64)
#                 @assert 1 - eps(Float64) <= sum(Area_Rip_Elevations) <= 1 + eps(Float64)
#
#                 Area = Area_Zones[i]
#                 Current_Percentage_HRU = Percentage_HRU[:,1 + i]/Area
#                 # calculate percentage of elevations
#                 Perc_Elevation = zeros(Total_Elevationbands_Catchment)
#                 for j in 1 : Total_Elevationbands_Catchment
#                         for h in 1:4
#                                 Perc_Elevation[j] += Current_Areas_HRUs[j,h] * Current_Percentage_HRU[h]
#                         end
#                 end
#                 Perc_Elevation = Perc_Elevation[(findall(x -> x!= 0, Perc_Elevation))]
#                 push!(Elevation_Percentage, Perc_Elevation)
#                 # calculate the inputs once for every precipitation zone because they will stay the same during the Monte Carlo Sampling
#                 bare_input = HRU_Input(Area_Bare_Elevations, Current_Percentage_HRU[1], 0.0, Bare_Elevation_Count, length(Bare_Elevation_Count), 0, [0], 0, [0], 0, 0)
#                 forest_input = HRU_Input(Area_Forest_Elevations, Current_Percentage_HRU[2], 0, Forest_Elevation_Count, length(Forest_Elevation_Count), 0, [0], 0, [0],  0, 0)
#                 grass_input = HRU_Input(Area_Grass_Elevations, Current_Percentage_HRU[3], 0, Grass_Elevation_Count,length(Grass_Elevation_Count), 0, [0], 0, [0],  0, 0)
#                 rip_input = HRU_Input(Area_Rip_Elevations, Current_Percentage_HRU[4], 0, Rip_Elevation_Count, length(Rip_Elevation_Count), 0, [0], 0, [0],  0, 0)
#
#                 all_inputs = [bare_input, forest_input, grass_input, rip_input]
#                 #print(typeof(all_inputs))
#                 push!(Inputs_All_Zones, all_inputs)
#
#                 bare_storage = Storages(0, zeros(length(Bare_Elevation_Count)), zeros(length(Bare_Elevation_Count)), zeros(length(Bare_Elevation_Count)), 0)
#                 forest_storage = Storages(0, zeros(length(Forest_Elevation_Count)), zeros(length(Forest_Elevation_Count)), zeros(length(Bare_Elevation_Count)), 0)
#                 grass_storage = Storages(0, zeros(length(Grass_Elevation_Count)), zeros(length(Grass_Elevation_Count)), zeros(length(Bare_Elevation_Count)), 0)
#                 rip_storage = Storages(0, zeros(length(Rip_Elevation_Count)), zeros(length(Rip_Elevation_Count)), zeros(length(Bare_Elevation_Count)), 0)
#
#                 all_storages = [bare_storage, forest_storage, grass_storage, rip_storage]
#                 push!(Storages_All_Zones, all_storages)
#         end
#         return  Inputs_All_Zones::Array{Array{HRU_Input,1},1}, Storages_All_Zones::Array{Array{Storages,1},1}, Precipitation_All_Zones::Array{Array{Float64,1},1},
#                 Nr_Elevationbands_All_Zones::Array{Int64, 1}, Elevations_Each_Precipitation_Zone::Array{Array{Float64,1},1}
# end
