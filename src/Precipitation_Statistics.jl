using Dates
using CSV
using DataFrames
using DocStringExtensions
using Statistics
using Plots
using StatsPlots
using Plots.PlotMeasures
using DelimitedFiles
# compare the precipitation statistics of real data to modeled data
# look at total precipitation, storm duration, interstorm duration and storm intensity pre month
# date of highest precipitation
# --------- LOAD HISTORIC DATA ---------
ID_Prec_Zones = [113589, 113597, 113670, 114538]
Area_Zones = [98227533.0, 184294158.0, 83478138.0, 220613195.0]
Area_Catchment = sum(Area_Zones)
Area_Zones_Percent = Area_Zones / Area_Catchment
Precipitation_All_Zones = Array{Float64, 1}[]
local_path = "/home/sarah/"
Skipto = [24, 22, 22, 22]
startyear = 1983
endyear = 2005
for i in 1: length(ID_Prec_Zones)
        #print(ID_Prec_Zones)
        Precipitation = CSV.read(local_path*"HBVModel/Gailtal/N-Tagessummen-"*string(ID_Prec_Zones[i])*".csv", header= false, skipto=Skipto[i], missingstring = "L\xfccke", decimal=',', delim = ';')
        Precipitation_Array = convert(Matrix, Precipitation)
        startindex = findfirst(isequal("01.01."*string(startyear)*" 07:00:00   "), Precipitation_Array)
        endindex = findfirst(isequal("31.12."*string(endyear)*" 07:00:00   "), Precipitation_Array)
        Precipitation_Array = Precipitation_Array[startindex[1]:endindex[1],:]
        Precipitation_Array[:,1] = Date.(Precipitation_Array[:,1], Dates.DateFormat("d.m.y H:M:S   "))
        # find duplicates and remove them
        df = DataFrame(Precipitation_Array)
        df = unique!(df)
        # drop missing values
        df = dropmissing(df)
        Precipitation = convert(Vector, df[:,2])
        push!(Precipitation_All_Zones, Precipitation)
end

Total_Precipitation = Precipitation_All_Zones[1].*Area_Zones_Percent[1] + Precipitation_All_Zones[2].*Area_Zones_Percent[2] + Precipitation_All_Zones[3].*Area_Zones_Percent[3] + Precipitation_All_Zones[4].*Area_Zones_Percent[4]
Timeseries = collect(Date(startyear,1,1):Day(1):Date(endyear,12,31))


#---------------- LOAD PROJECTION DATA -----------------
path = "/home/sarah/Master/Thesis/Data/Projektionen/new_station_data_rcp85/rcp85/"
# # 14 different projections
Name_Projections = readdir(path)
All_Projections_Precipitation = zeros(8401)
for i in 1:14
        path_to_projection = path*Name_Projections[i]*"/Gailtal/"
        Timeseries_Proj = readdlm(path_to_projection*"pr_model_timeseries.txt")
        Timeseries_Proj = Date.(Timeseries_Proj, Dates.DateFormat("y,m,d"))
        indexstart_Proj = findfirst(x-> x == startyear, Dates.year.(Timeseries_Proj))[1]
        indexend_Proj = findlast(x-> x == endyear, Dates.year.(Timeseries_Proj))[1]
        Precipitation_All_Zones = Array{Float64, 1}[]

        for j in 1: length(ID_Prec_Zones)
                # get precipitation projections for the precipitation measurement
                Precipitation_Zone = readdlm(path_to_projection*"pr_"*string(ID_Prec_Zones[j])*"_sim1.txt", ',')

                Precipitation_Zone = Precipitation_Zone[indexstart_Proj:indexend_Proj] ./ 10
                push!(Precipitation_All_Zones, Precipitation_Zone)
        end
        Total_Precipitation_Proj = Precipitation_All_Zones[1].*Area_Zones_Percent[1] + Precipitation_All_Zones[2].*Area_Zones_Percent[2] + Precipitation_All_Zones[3].*Area_Zones_Percent[3] + Precipitation_All_Zones[4].*Area_Zones_Percent[4]
        global All_Projections_Precipitation = hcat(All_Projections_Precipitation, Total_Precipitation_Proj)
end
All_Projections_Precipitation = All_Projections_Precipitation[:, 2:end]

"""
Computes storm statistics for the storm events.

$(SIGNATURES)

The function returns the length of the storms, the inter storm durations and the storm intensity and the total precipitation.
The first and last entries are not taken into account for calculating the storm / inter storm duration and storm intensities because their length is unkown.
It is taken into account for calculating the total precipitation.
"""
function storm_statistics(Precipitation::Array{Float64,1})
        dry_days = findall(x -> x == 0.0, Precipitation)
        rainy_days = findall(x -> x != 0.0, Precipitation)
        length_interstorm = Float64[]
        length_storm = Float64[]
        storm_intensity = Float64[]
        # calculate length of interstorm periods
        count = 1
        for i in 1 : length(dry_days)
                if i < length(dry_days) && dry_days[i+1] == dry_days[i] + 1
                        count += 1
                elseif dry_days[i] != length(Precipitation)
                        append!(length_interstorm, count)
                        count = 1
                end
        end
        # calculate length of storm period
        count = 1
        # only calculate rain statistics if there are rainy days in the precipitation data
        if rainy_days != Int64[]
                current_Prec = Precipitation[rainy_days[1]]
                for i in 1 : length(rainy_days)
                        if i < length(rainy_days) && rainy_days[i+1] == rainy_days[i] + 1
                                count += 1
                                current_Prec += Precipitation[rainy_days[i+1]]
                        elseif rainy_days[i] != length(Precipitation)
                                append!(length_storm, count)
                                append!(storm_intensity, current_Prec / count)
                                count = 1
                                if i != length(rainy_days)
                                        current_Prec = Precipitation[rainy_days[i+1]]
                                end
                        end
                end
        else
                append!(length_storm, 0)
                append!(storm_intensity, 0)
        end
        Total_Precipitation = sum(Precipitation)
        if Precipitation[1] != 0
                length_storm = length_storm[2:end]
                storm_intensity = storm_intensity[2:end]
        else
                length_interstorm = length_interstorm[2:end]
        end
        # make sure there are no Nan values
        if length_interstorm == Array{Float64,1}[]
                length_interstorm = [0.]
        end
        if length_storm == Array{Float64,1}[]
                length_storm = [0.]
        end
        if storm_intensity == Array{Float64,1}[]
                storm_intensity = [0.]
        end
        return length_storm::Array{Float64,1}, length_interstorm::Array{Float64,1}, storm_intensity::Array{Float64,1}, Total_Precipitation::Float64
end
"""
Computes monthly mean storm statistics for a timeseries of precipitation.

$(SIGNATURES)

The function returns the month and the year and the corresponding mean length of the storms, the inter storm durations and the storm intensity and the total precipitation.
The first and last entries are not taken into account for calculating the storm / inter storm duration and storm intensities because their length is unkown.
It is taken into account for calculating the total precipitation.
"""
function monthly_storm_statistics(Precipitation::Array{Float64,1}, Timeseries::Array{Date,1})
        # calculate the monthly statistics for each year
        Months = collect(1:12)
        Years = collect(Dates.year(Timeseries[1]): Dates.year(Timeseries[end]))
        statistics = zeros(6)
        for (i, Current_Year) in enumerate(Years)
                for (j, Current_Month) in enumerate(Months)
                        Dates_Current_Month = filter(Timeseries) do x
                                          Dates.Year(x) == Dates.Year(Current_Year) &&
                                          Dates.Month(x) == Dates.Month(Current_Month)
                                      end
                                      #print(length(Dates_Current_Month),"\n")
                                     # print(Current_Month)
                        Current_Precipitation = Precipitation[indexin(Dates_Current_Month, Timeseries)]
                        #print(Current_Precipitation,"\n")
                        #print("Prec", length(Precipitation[indexin(Dates_Current_Month, Timeseries)]), "\n")

                        storm_length, interstorm_length, storm_intensity, Total_Precipitation = storm_statistics(Current_Precipitation)
                        #print(storm_length, interstorm_length, storm_intensity, Total_Precipitation, "\n")
                        #print([Current_Month, Current_Year, mean(storm_length), mean(interstorm_length), mean(storm_intensity), Total_Precipitation],"\n")
                        Current_Statistics = [Current_Month, Current_Year, mean(storm_length), mean(interstorm_length), mean(storm_intensity), Total_Precipitation]
                        statistics = hcat(statistics, Current_Statistics)
                end
        end
        return transpose(statistics[:, 2:end])
end



function plot_Prec_Statistics(statistics_all_Zones, statistics_all_Zones_Proj, name_projection)

        statistics_names = ["Mean Storm Length [d]", "Mean Interstorm Length [d]", "Mean Storm Intensity [mm/d]", "Total Precipitation [mm/month]"]
        months = ["Jan", "Feb", "Mar", "Apr", "May","Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        months_proj = ["Jan Proj", "Feb Proj", "Mar Proj", "Apr Proj", "May Proj","Jun Proj", "Jul Proj", "Aug Proj", "Sep Proj", "Oct Proj", "Nov Proj", "Dec Proj"]
        all_boxplots = []
        Farben = palette(:tab20)
        for j in 1:4
                ID = 2+j

                plot()
                box = []
                for i in 1:12
                        current_month_statistics = statistics_all_Zones[findall(x-> x == i, statistics_all_Zones[:,1]),:]
                        current_month_statistics_proj = statistics_all_Zones_Proj[findall(x-> x == i, statistics_all_Zones_Proj[:,1]),:]
                        #print(current_month_statistics)
                        box = boxplot!([months[i]],current_month_statistics[:,ID], color = [Farben[i]], leg=false, outliers=false)
                        box = boxplot!([months_proj[i]],current_month_statistics_proj[:,ID],  color = [Farben[i]], leg=false, outliers=false)
                end
                ylabel!(statistics_names[j])
                push!(all_boxplots, box)
        end
        plot(all_boxplots[1], all_boxplots[2], all_boxplots[3], all_boxplots[4], layout= (2,2), legend = false, size=(2000,1000), left_margin = [5mm 0mm], bottom_margin = 20px, xrotation = 60)
        # xlabel!("Months")
        # ylabel!("Inter-Storm Lengths [d]")
        # title!("Monthly Mean Inter-Storm Length [d] 1983-2005")
        savefig("/home/sarah/Master/Thesis/Results/Calibration/Gailtal/Precipitation/Precipitation_Statistics_Proj"*string(name_projection)*".png")
end

# statistics_all_Zones = monthly_storm_statistics(Total_Precipitation, Timeseries)
# for i in 1:14
#         statistics_all_Zones_Proj = monthly_storm_statistics(All_Projections_Precipitation[:,i], Timeseries)
#         plot_Prec_Statistics(statistics_all_Zones, statistics_all_Zones_Proj, Name_Projections[i])
# end

function max_Annual_Precipitation(Precipitation, Timeseries)
        Years = collect(Dates.year(Timeseries[1]): Dates.year(Timeseries[end]))
        statistics = zeros(3)
        statistics_7days = zeros(3)
        for (i, Current_Year) in enumerate(Years)
                Dates_Current_Year = filter(Timeseries) do x
                                  Dates.Year(x) == Dates.Year(Current_Year)
                              end
                Current_Precipitation = Precipitation[indexin(Dates_Current_Year, Timeseries)]
                # find maximum precipitation
                max_Prec = maximum(Current_Precipitation)
                Date_max_Prec = Dates_Current_Year[findfirst(x-> x == max_Prec, Current_Precipitation)]
                statistics = hcat(statistics, [max_Prec, Dates.month(Date_max_Prec), Dates.day(Date_max_Prec)])

                # get the 7 days with most rainfall
                Precipitation_7days = Float64[]
                for current_day in 1: daysinyear(Current_Year) - 6
                        append!(Precipitation_7days, sum(Current_Precipitation[current_day: current_day+6]))
                end
                max_Precipitation_7days = maximum(Precipitation_7days)
                Date_max_Prec_7days = Dates_Current_Year[findfirst(x-> x == max_Precipitation_7days, Precipitation_7days)]
                statistics_7days = hcat(statistics_7days, [max_Precipitation_7days, Dates.month(Date_max_Prec_7days), Dates.day(Date_max_Prec_7days)])
        end
        return transpose(statistics[:, 2:end]), transpose(statistics_7days[:, 2:end])
end

plot()
timing_amount = 1
Farben = palette(:tab20)
for i in 1:14
        max_Prec, max_Prec_7 = max_Annual_Precipitation(All_Projections_Precipitation[:,i], Timeseries)
        print(max_Prec_7[:,1], "\n")
        violin!(["Proj " *string(i)], max_Prec[:,timing_amount], color=[Farben[i]])
        boxplot!(["Proj " *string(i)], max_Prec[:,timing_amount], alpha=0.8, color=[Farben[i]])
end
max_Prec, max_Prec_7 = max_Annual_Precipitation(Total_Precipitation, Timeseries)
violin!(["Obs"], max_Prec[:,timing_amount], xrotation = 60, leg=false, size=(1000,700), color=[Farben[15]])
boxplot!(["Obs"], max_Prec[:,timing_amount], xrotation = 60, leg=false, size=(1000,700), alpha=0.8, color=[Farben[15]])
#plot()
#max_Prec, max_Prec_7 = max_Annual_Precipitation(Total_Precipitation, Timeseries)
#
#boxplot!(max_Prec_7[:,1])

#xlabel!("Precipitation Zones")
ylabel!("Amount [mm/d]")
title!("Maximum Annual Precipitation RCP 8.5")
savefig("/home/sarah/Master/Thesis/Results/Calibration/Gailtal/Precipitation/Max_Annual_Precipitation_Proj_Amount_RCP8.5.png")
