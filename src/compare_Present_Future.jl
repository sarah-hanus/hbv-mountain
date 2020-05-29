# timing of peak discharge
# magnitude of peak discharge
using DelimitedFiles
using Plots
using Statistics
using StatsPlots
using Plots.PlotMeasures
using CSV
using Dates
using DocStringExtensions

path_45 = "/home/sarah/Master/Thesis/Data/Projektionen/new_station_data_rcp45/rcp45/"
Name_Projections_45 = readdir(path_45)
path_85 = "/home/sarah/Master/Thesis/Data/Projektionen/new_station_data_rcp85/rcp85/"
Name_Projections_85 = readdir(path_85)
# ------------------------- PLOT MONTHLY TEMPERATURE AND PRECIPITATION PAST AND FUTURE
"""
Computes the monthly daily average of e.g. discharge or temperature.

$(SIGNATURES)

The function returns the monthly daily average and the an array of the months in the timeseries (1,2,3,4,5,6,7,8,9,10,11,12,1,2,3,4...)
"""
function monthly_discharge(Discharge, Timeseries)
    #print(size(Discharge))
    Months = collect(1:12)
    Years = collect(Dates.year(Timeseries[1]): Dates.year(Timeseries[end]))
    Monthly_Discharge = Float64[]
    All_Months = Int[]
    for (i, Current_Year) in enumerate(Years)
            for (j, Current_Month) in enumerate(Months)
                    Dates_Current_Month = filter(Timeseries) do x
                                      Dates.Year(x) == Dates.Year(Current_Year) &&
                                      Dates.Month(x) == Dates.Month(Current_Month)
                                  end
                                  #print(length(Dates_Current_Month),"\n")
                                 # print(Current_Month)
                    Current_Discharge = Discharge[indexin(Dates_Current_Month, Timeseries)]
                    #print(Current_Year, " ", Current_Month)
                    #print(Dates.daysinmonth(Current_Year, Current_Month))
                    Current_Monthly_Discharge = sum(Current_Discharge) / Dates.daysinmonth(Current_Year, Current_Month)
                    append!(Monthly_Discharge, Current_Monthly_Discharge)
                    append!(All_Months, Current_Month)
            end
    end
    return Monthly_Discharge, All_Months
end

"""
Computes the monthly average of e.g. precipitation (taking the sum over a month and averaging the results of several years)

$(SIGNATURES)

The function returns the monthly average and the an array of the months in the timeseries (1,2,3,4,5,6,7,8,9,10,11,12,1,2,3,4...)
"""
function monthly_precipitation(Discharge, Timeseries)
    #print(size(Discharge))
    Months = collect(1:12)
    Years = collect(Dates.year(Timeseries[1]): Dates.year(Timeseries[end]))
    Monthly_Discharge = Float64[]
    All_Months = Int[]
    for (i, Current_Year) in enumerate(Years)
            for (j, Current_Month) in enumerate(Months)
                    Dates_Current_Month = filter(Timeseries) do x
                                      Dates.Year(x) == Dates.Year(Current_Year) &&
                                      Dates.Month(x) == Dates.Month(Current_Month)
                                  end
                                  #print(length(Dates_Current_Month),"\n")
                                 # print(Current_Month)
                    Current_Discharge = Discharge[indexin(Dates_Current_Month, Timeseries)]
                    #print(Current_Year, " ", Current_Month)
                    #print(Dates.daysinmonth(Current_Year, Current_Month))
                    Current_Monthly_Discharge = sum(Current_Discharge) #/ Dates.daysinmonth(Current_Year, Current_Month)
                    append!(Monthly_Discharge, Current_Monthly_Discharge)
                    append!(All_Months, Current_Month)
            end
    end
    return Monthly_Discharge, All_Months
end

"""
Plots the average Monthly Temperature and Precipitation of 1980-2010 and 2070-2100 of the projections in the given path (14 projectiosn). Also plots the absolute changes.

$(SIGNATURES)

The function returns plots and arrays of the average monthly temperature and precipitation of the past and future of all projections.
"""
function plot_Monthly_Temperature_Precipitation(path_to_projections)
    plot()
    ID_Prec_Zones = [113589, 113597, 113670, 114538]
    # size of the area of precipitation zones
    Area_Zones = [98227533.0, 184294158.0, 83478138.0, 220613195.0]
    Area_Catchment = sum(Area_Zones)
    Area_Zones_Percent = Area_Zones / Area_Catchment
    Name_Projections_45 = readdir(path_to_projections)
    Timeseries_Past = collect(Date(1981,1,1):Day(1):Date(2010,12,31))
    Timeseries_End = readdlm("/home/sarah/Master/Thesis/Data/Projektionen/End_Timeseries_45_85.txt",',')

    if path_to_projections[end-2:end-1] == "45"
        index = 1
        rcp = "45"
        print(rcp, " ", path_to_projections)
    elseif path_to_projections[end-2:end-1] == "85"
        index = 2
        rcp="85"
        print(rcp, " ", path_to_projections)
    end


    all_months_all_runs = Float64[]
    average_monthly_Temperature_past = Float64[]
    average_monthly_Temperature_future = Float64[]
    average_monthly_Precipitation_past = Float64[]
    average_monthly_Precipitation_future = Float64[]
    for (i, name) in enumerate(Name_Projections_45)
        #print(name, "\n")

        Timeseries_Future = collect(Date(Timeseries_End[i,index]-29,1,1):Day(1):Date(Timeseries_End[i,index],12,31))
        #print(size(Timeseries_Past), size(Timeseries_Future))
        Timeseries_Proj = readdlm(path_to_projections*name*"/Gailtal/pr_model_timeseries.txt")
        Timeseries_Proj = Date.(Timeseries_Proj, Dates.DateFormat("y,m,d"))
        Temperature = readdlm(path_to_projections*name*"/Gailtal/tas_113597_sim1.txt", ',')[:,1]
        #print("temp", size(Temperature))

        Temp_Elevation = 1140.0
        Elevations_Catchment = Elevations(200.0, 400.0, 2800.0, Temp_Elevation, Temp_Elevation)
        Elevation_Zone_Catchment, Temperature_Elevation_Catchment, Total_Elevationbands_Catchment = gettemperatureatelevation(Elevations_Catchment, Temperature)
        # get the temperature data at the mean elevation to calculate the mean potential evaporation
        Temperature = Temperature_Elevation_Catchment[:,findfirst(x-> x==1500, Elevation_Zone_Catchment)]

        indexstart_past = findfirst(x-> x == Dates.year(Timeseries_Past[1]), Dates.year.(Timeseries_Proj))[1]
        indexend_past = findlast(x-> x == Dates.year(Timeseries_Past[end]), Dates.year.(Timeseries_Proj))[1]
        Temperature_Past = Temperature[indexstart_past:indexend_past] ./ 10
        #print(Dates.year(Timeseries_Future[end]), Dates.year.(Timeseries_Proj[end]))
        indexstart_future = findfirst(x-> x == Dates.year(Timeseries_Future[1]), Dates.year.(Timeseries_Proj))[1]
        indexend_future = findlast(x-> x == Dates.year(Timeseries_Future[end]), Dates.year.(Timeseries_Proj))[1]
        Temperature_Future = Temperature[indexstart_future:indexend_future] ./ 10

        #print(size(Temperature_Past), size(Temperature_Future))

        Monthly_Temperature_Past, Month = monthly_discharge(Temperature_Past, Timeseries_Past)
        Monthly_Temperature_Future, Month_future = monthly_discharge(Temperature_Future, Timeseries_Future)

        #-------- PRECIPITATION ------------------

        Precipitation_All_Zones = Array{Float64, 1}[]
        for j in 1: length(ID_Prec_Zones)
                # get precipitation projections for the precipitation measurement
                Precipitation_Zone = readdlm(path_to_projections*name*"/Gailtal/pr_"*string(ID_Prec_Zones[j])*"_sim1.txt", ',')[:,1]
                #print(size(Precipitation_Zone), typeof(Precipitation_Zone))
                push!(Precipitation_All_Zones, Precipitation_Zone ./10)
        end
        Total_Precipitation_Proj = Precipitation_All_Zones[1].*Area_Zones_Percent[1] + Precipitation_All_Zones[2].*Area_Zones_Percent[2] + Precipitation_All_Zones[3].*Area_Zones_Percent[3] + Precipitation_All_Zones[4].*Area_Zones_Percent[4]
        Precipitation_Past = Total_Precipitation_Proj[indexstart_past:indexend_past]
        Precipitation_Future = Total_Precipitation_Proj[indexstart_future:indexend_future]

        Monthly_Precipitation_Past, Month = monthly_precipitation(Precipitation_Past, Timeseries_Past)
        Monthly_Precipitation_Future, Month_future = monthly_precipitation(Precipitation_Future, Timeseries_Future)

        for month in 1:12
            current_Month_Temperature = Monthly_Temperature_Past[findall(x->x == month, Month)]
            current_Month_Temperature_future = Monthly_Temperature_Future[findall(x->x == month, Month_future)]
            current_Month_Temperature = mean(current_Month_Temperature)
            current_Month_Temperature_future = mean(current_Month_Temperature_future)
            #error = relative_error(current_Month_Discharge_future, current_Month_Discharge)
            append!(average_monthly_Temperature_past, current_Month_Temperature)
            append!(average_monthly_Temperature_future, current_Month_Temperature_future)
            append!(all_months_all_runs, month)
            #append!(error_average_monthly_Discharge_all_runs, error)

            current_Month_Precipitation = Monthly_Precipitation_Past[findall(x->x == month, Month)]
            current_Month_Precipitation_future = Monthly_Precipitation_Future[findall(x->x == month, Month_future)]
            current_Month_Precipitation = mean(current_Month_Precipitation)
            current_Month_Precipitation_future = mean(current_Month_Precipitation_future)
            #error = relative_error(current_Month_Discharge_future, current_Month_Discharge)
            append!(average_monthly_Precipitation_past, current_Month_Precipitation)
            append!(average_monthly_Precipitation_future, current_Month_Precipitation_future)
        end
    end
    #----------- PLOTS PRECIPITATION------------------------
    xaxis_1 = collect(1:2:23)
    xaxis_2 = collect(2:2:24)
    Farben = palette(:blues)
    for month in 1:12
        boxplot!([xaxis_1[month]], average_monthly_Precipitation_past[findall(x-> x == month, all_months_all_runs)], size=(2000,800), leg=false, color=[Farben[1]], left_margin = [5mm 0mm])
        boxplot!([xaxis_2[month]], average_monthly_Precipitation_future[findall(x-> x == month, all_months_all_runs)], size=(2000,800), leg=false, color=[Farben[2]], left_margin = [5mm 0mm])
    end
    ylabel!("Average Monthly Precipitation [mm/ month]")
    title!("Averaged Monthly Precipitation Past=blue, Future=red")
    #ylims!((0,40))
    #hline!([0], color=["grey"], linestyle = :dash)
    xticks!([1.5:2:23.5;], ["Jan", "Feb", "Mar", "Apr", "May","Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])
    plot1 = boxplot!()
    plot()
    #------------- PLOT TEMPERATURE--------------
    Farben = palette(:reds)
    for month in 1:12
        boxplot!([xaxis_1[month]], average_monthly_Temperature_past[findall(x-> x == month, all_months_all_runs)], size=(2000,800), leg=false, color=[Farben[1]])
        boxplot!([xaxis_2[month]], average_monthly_Temperature_future[findall(x-> x == month, all_months_all_runs)], size=(2000,800), leg=false, color=[Farben[2]])
    end
    ylabel!("Average Monthly Temperature [°C]")
    title!("Averaged Monthly Temperature Past=light, Future=dark")
    #ylims!((0,40))
    #hline!([0], color=["grey"], linestyle = :dash)
    xticks!([1.5:2:23.5;], ["Jan", "Feb", "Mar", "Apr", "May","Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])
    plot2 = boxplot!()

    plot()
    plot(plot1, plot2, layout= (2,1), legend = false, size=(2000,1000), left_margin = [5mm 0mm])

    savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/Inputs/Temp_Prec"*rcp*".png")

    # ---------------  ABSOLUTE CHANGES ----------------
    plot()
    xaxis_1 = collect(1:2:23)
    xaxis_2 = collect(2:2:24)
    for month in 1:12
        boxplot!(average_monthly_Precipitation_future[findall(x-> x == month, all_months_all_runs)] - average_monthly_Precipitation_past[findall(x-> x == month, all_months_all_runs)], size=(2000,800), leg=false, color=["blue"], left_margin = [5mm 0mm])
    end
    ylabel!("Average Absolute Change in Monthly Precipitation [mm/ month]")
    title!("Averaged Monthly Precipitation Future - Past")
    #ylims!((0,40))
    hline!([0], color=["grey"], linestyle = :dash)
    xticks!([1:12;], ["Jan", "Feb", "Mar", "Apr", "May","Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])
    plot1 = boxplot!()
    plot()
    #------------- PLOT TEMPERATURE--------------
    for month in 1:12
        boxplot!(average_monthly_Temperature_future[findall(x-> x == month, all_months_all_runs)] - average_monthly_Temperature_past[findall(x-> x == month, all_months_all_runs)], size=(2000,800), leg=false, color=["red"])
    end
    ylabel!("Average Change in Monthly Temperature [°C]")
    title!("Averaged Monthly Temperature Future - Past")
    #ylims!((0,40))
    #hline!([0], color=["grey"], linestyle = :dash)
    xticks!([1:12;], ["Jan", "Feb", "Mar", "Apr", "May","Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])
    plot2 = boxplot!()

    plot()
    plot(plot1, plot2, layout= (2,1), legend = false, size=(2000,1000), left_margin = [5mm 0mm])

    savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/Inputs/Absolute_Change_Temp_Prec"*rcp*".png")

    return average_monthly_Precipitation_past, average_monthly_Precipitation_future, average_monthly_Temperature_past, average_monthly_Temperature_future, all_months_all_runs
end

#Prec_past, Prec_Future,Temp_past, Temp_Future, Months = plot_Monthly_Temperature_Precipitation(path_45)


# -------------------------------- AVERAGE MONTHLY RUNOFF --------------------------

# take average monthly discharge of 30 years compare it to monthly discharge in future


"""
Computes the monthly discharges of the past and future and the relative changes, of the projections of the path and the different parameter sets

$(SIGNATURES)

The function returns relative change in monthly average discharge, the monthly mean discharge of the past, and the monthly mean discharge of the future
"""
function change_monthly_Discharge(path_45)
    Name_Projections_45 = readdir(path_45)
    Timeseries_Past = collect(Date(1981,1,1):Day(1):Date(2010,12,31))
    Timeseries_End = readdlm("/home/sarah/Master/Thesis/Data/Projektionen/End_Timeseries_45_85.txt",',')
    if path_45[end-2:end-1] == "45"
        index = 1
        rcp = "45"
        print(rcp, " ", path_to_projections)
    elseif path_45[end-2:end-1] == "85"
        index = 2
        rcp="85"
        print(rcp, " ", path_to_projections)
    end

    average_monthly_Discharge_past = Float64[]
    average_monthly_Discharge_future = Float64[]
    #all_months = Float64[]

    error_average_monthly_Discharge_all_runs = Float64[]
    #average_monthly_Discharge_future_all_runs = Float64[]
    #average_monthly_Discharge_past_all_runs = Float64[]
    all_months_all_runs = Float64[]
    for (i, name) in enumerate(Name_Projections_45)
        Timeseries_Future_45 = collect(Date(Timeseries_End[i,index]-29,1,1):Day(1):Date(Timeseries_End[i,index],12,31))
        Past_Discharge_45 = readdlm(path_45*name*"/Gailtal/100_model_results_discharge_past_2010.csv", ',')
        Future_Discharge_45 = readdlm(path_45*name*"/Gailtal/100_model_results_discharge_future_2100.csv", ',')
        #change_all_runs = Float64[]
        for run in 1:100
            Monthly_Discharge_past, Month = monthly_discharge(Past_Discharge_45[run,:], Timeseries_Past)
            Monthly_Discharge_future, Month_future = monthly_discharge(Future_Discharge_45[run,:], Timeseries_Future_45)

            for month in 1:12
                current_Month_Discharge = Monthly_Discharge_past[findall(x->x == month, Month)]
                current_Month_Discharge_future = Monthly_Discharge_future[findall(x->x == month, Month_future)]
                current_Month_Discharge = mean(current_Month_Discharge)
                current_Month_Discharge_future = mean(current_Month_Discharge_future)
                error = relative_error(current_Month_Discharge_future, current_Month_Discharge)
                append!(average_monthly_Discharge_past, current_Month_Discharge)
                append!(average_monthly_Discharge_future, current_Month_Discharge_future)
                append!(all_months_all_runs, month)
                append!(error_average_monthly_Discharge_all_runs, error)
            end


            #error_timing = Date_max_Discharge_future - Date_max_Discharge_past)
            # append!(error_average_monthly_Discharge_all_runs, error_all)
            # append!(average_monthly_Discharge_past_all_runs, average_monthly_Discharge_past)
            # append!(average_monthly_Discharge_future_all_runs, average_monthly_Discharge_future)
            # append!(all_months_all_runs, all_months)
        end
    end
    return error_average_monthly_Discharge_all_runs, average_monthly_Discharge_past, average_monthly_Discharge_future, all_months_all_runs
end
# change_45 = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/Monthly_Discharge/discharge_months_4.5_new.txt", ',')
# months_45 = change_45[:,1]
# Monthly_Discharge_past_45 = change_45[:,2] #.* (24 * 3600)
# Monthly_Discharge_future_45 = change_45[:,3] #.* (24 * 3600)
# Monthly_Discharge_relative_change_45 = change_45[:,4]
#
# change_85 = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/Monthly_Discharge/discharge_months_8.5_new.txt", ',')
# months_85 = change_85[:,1]
# Monthly_Discharge_past_85 = change_85[:,2] #.* (24 * 3600) # to get m³ / month
# Monthly_Discharge_future_85 = change_85[:,3] #.* (24 * 3600) # to get m³ / month
# Monthly_Discharge_relative_change_85 = change_85[:,4]

#Monthly_Discharge_Change, monthly_Discharge_past, monthly_Discharge_future, months = change_monthly_Discharge(path_85)
#writedlm("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/Monthly_Discharge/discharge_months_8.5_new.txt",hcat(months, monthly_Discharge_past, monthly_Discharge_future, Monthly_Discharge_Change),',')

"""
Plots the Aboslute and relative changes of both emission pathways of the discharges of the past and future

$(SIGNATURES)

"""
function plot_changes_monthly_discharge(Monthly_Discharge_past_45, Monthly_Discharge_future_45, Monthly_Discharge_past_85, Monthly_Discharge_future_85)
    Farben = palette(:tab20)

    xaxis_45 = collect(1:2:23)
    xaxis_85 = collect(2:2:24)
    # ----------------- Plot Absolute Change ------------------
    plot()
    Farben_85 = palette(:reds)
    Farben_45 = palette(:blues)
    for month in 1:12
        boxplot!([xaxis_45[month]],Monthly_Discharge_future_45[findall(x-> x == month, months_45)] - Monthly_Discharge_past_45[findall(x-> x == month, months_45)] , size=(2000,800), leg=false, color=["blue"], alpha=0.8)
        boxplot!([xaxis_85[month]],Monthly_Discharge_future_85[findall(x-> x == month, months_45)] - Monthly_Discharge_past_85[findall(x-> x == month, months_45)], size=(2000,800), leg=false, color=["red"], left_margin = [5mm 0mm])
    end
    ylabel!("Change in Average monthly Discharge [m³/s]")
    title!("Absolute Change in Discharge RCP 4.5 =blue, RCP 4.5 = red")
    #ylims!((-0.8,1.1))
    #hline!([0], color=["grey"], linestyle = :dash)
    xticks!([1.5:2:23.5;], ["Jan", "Feb", "Mar", "Apr", "May","Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])
    #xticks!([2:2:24;], ["Jan 8.5", "Feb 8.5", "Mar 8.5", "Apr 8.5", "May 8.5","Jun 8.5", "Jul 8.5", "Aug 8.5", "Sep 8.5", "Oct 8.5", "Nov 8.5", "Dec 8.5"])
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/Monthly_Discharge/absolute_change_monthly_discharge4.5_8.5_new.png")

    # ------- REALTIVE CHANGE ----------------
    plot()
    for month in 1:12
        boxplot!([xaxis_45[month]],Monthly_Discharge_relative_change_45[findall(x-> x == month, months_45)]*100, size=(2000,800), leg=false, color=["blue"], alpha=0.8)
        boxplot!([xaxis_85[month]],Monthly_Discharge_relative_change_85[findall(x-> x == month, months_45)]*100, size=(2000,800), leg=false, color=["red"], left_margin = [5mm 0mm])
    end
    ylabel!("Relative Change in Average monthly Discharge [%]")
    title!("Relative Change in Discharge RCP 4.5 =blue, RCP 4.5 = red")
    #ylims!((-0.8,1.1))
    hline!([0], color=["grey"], linestyle = :dash)
    xticks!([1.5:2:23.5;], ["Jan", "Feb", "Mar", "Apr", "May","Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])
    #xticks!([2:2:24;], ["Jan 8.5", "Feb 8.5", "Mar 8.5", "Apr 8.5", "May 8.5","Jun 8.5", "Jul 8.5", "Aug 8.5", "Sep 8.5", "Oct 8.5", "Nov 8.5", "Dec 8.5"])
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/Monthly_Discharge/change_monthly_discharge4.5_8.5_new.png")
end

## -------------- PLOT MONTHLY DISCHARGE PAST REAL DATA ---------------------------------
# Timeseries_Past = collect(Date(1981,1,1):Day(1):Date(2010,12,31))
# Discharge = CSV.read("Gailtal/Q-Tagesmittel-212670.csv", header= false, skipto=23, decimal=',', delim = ';', types=[String, Float64])
# Discharge = convert(Matrix, Discharge)
# startindex = findfirst(isequal("01.01."*string(1981)*" 00:00:00"), Discharge)
# endindex = findfirst(isequal("31.12."*string(2010)*" 00:00:00"), Discharge)
# Observed_Discharge = Array{Float64,1}[]
# push!(Observed_Discharge, Discharge[startindex[1]:endindex[1],2])
# Observed_Discharge = Observed_Discharge[1]
#
# #Monthly_Discharge_Observed, Months_Past = monthly_discharge(Observed_Discharge, Timeseries_Past)
# plot()
# for month in 1:12
#     boxplot!(Monthly_Discharge_Observed[findall(x-> x == month, Months_Past)], size=(2000,800), leg=false, color=["red"], left_margin = [5mm 0mm])
# end
# ylabel!("Averaged Monthly Discharge [m³/s]")
# title!("Averaged Measured Monthly Discharge 1981-2010")
# ylims!((0,40))
# #hline!([0], color=["grey"], linestyle = :dash)
# xticks!([1:12;], ["Jan", "Feb", "Mar", "Apr", "May","Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])
# #xticks!([2:2:24;], ["Jan 8.5", "Feb 8.5", "Mar 8.5", "Apr 8.5", "May 8.5","Jun 8.5", "Jul 8.5", "Aug 8.5", "Sep 8.5", "Oct 8.5", "Nov 8.5", "Dec 8.5"])
# savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/Monthly_Discharge/measured_monthly_discharge_test.png")


# ---------------------  LOW FLOWS ---------------------
"""
Calculates the minimum X day moving average of daily discharge (mm/d) of the months to analyse.

$(SIGNATURES)
The input of the function needs an array of discharges, and a corresponding timeseries
    and an array of the months to analyse (e.g.[4,5,6] for April to June) as well as the length of moving average.
"""
function seasonal_low_flows(Discharge, Timeseries, Months_to_analyse, days)
    #print(size(Discharge))
    Months = Months_to_analyse
    Years = collect(Dates.year(Timeseries[1]): Dates.year(Timeseries[end]))
    Seasonal_Low_Flows_7days = Float64[]
    for (i, Current_Year) in enumerate(Years)
            #for (j, Current_Month) in enumerate(Months)
            Dates_Current_Season = filter(Timeseries) do x
                              Dates.Year(x) == Dates.Year(Current_Year) &&
                              (Dates.Month(x) == Dates.Month(Months[1]) ||
                              Dates.Month(x) == Dates.Month(Months[2]) ||
                              Dates.Month(x) == Dates.Month(Months[3]) ||
                              Dates.Month(x) == Dates.Month(Months[4]) ||
                              Dates.Month(x) == Dates.Month(Months[5]) ||
                              Dates.Month(x) == Dates.Month(Months[6]))
                          end
                          #print(length(Dates_Current_Month),"\n")
                         # print(Current_Month)
            Current_Discharge = Discharge[indexin(Dates_Current_Season, Timeseries)]
            #print(Current_Year, " ", Current_Month)
            #print(Dates.daysinmonth(Current_Year, Current_Month))
            All_Discharges_7days = Float64[]
            for week in 1: length(Current_Discharge) - days
                Current_Discharge_7days = mean(Current_Discharge[week: week+days])
                append!(All_Discharges_7days, Current_Discharge_7days)
            end
            append!(Seasonal_Low_Flows_7days, minimum(All_Discharges_7days))
    end
    return Seasonal_Low_Flows_7days
end
"""
Calculates the minimum X day moving average of daily discharge (mm/d) for all climate projections with each 100 parameter sets for the given path.

$(SIGNATURES)
The function returns the low flows of the past and future. It takes as input the path to the projections and the months over which a minimum low flow is searched.
"""
function analyse_low_flows(path_to_projections, Months_Low_Flow_Summer)
    Name_Projections_45 = readdir(path_to_projections)
    Timeseries_Past = collect(Date(1981,1,1):Day(1):Date(2010,12,31))
    Timeseries_End = readdlm("/home/sarah/Master/Thesis/Data/Projektionen/End_Timeseries_45_85.txt",',')
    if path_to_projections[end-2:end-1] == "45"
        index = 1
        rcp = "45"
        print(rcp, " ", path_to_projections)
    elseif path_to_projections[end-2:end-1] == "85"
        index = 2
        rcp="85"
        print(rcp, " ", path_to_projections)
    end

    average_Low_Flows_past = Float64[]
    average_Low_Flows_future = Float64[]
    #all_months = Float64[]

    error_average_monthly_Discharge_all_runs = Float64[]
    #average_monthly_Discharge_future_all_runs = Float64[]
    #average_monthly_Discharge_past_all_runs = Float64[]
    all_months_all_runs = Float64[]
    for (i, name) in enumerate(Name_Projections_45)
        Timeseries_Future_45 = collect(Date(Timeseries_End[i,index]-29,1,1):Day(1):Date(Timeseries_End[i,index],12,31))
        Past_Discharge_45 = readdlm(path_to_projections*name*"/Gailtal/100_model_results_discharge_past_2010.csv", ',')
        Future_Discharge_45 = readdlm(path_to_projections*name*"/Gailtal/100_model_results_discharge_future_2100.csv", ',')
        #change_all_runs = Float64[]
     # determine by looking at monthly discharges
        for run in 1:100
            Seasonal_Low_Flows_Past = seasonal_low_flows(Past_Discharge_45[run,:], Timeseries_Past, Months_Low_Flow_Summer, 7)
            Seasonal_Low_Flows_Future = seasonal_low_flows(Future_Discharge_45[run,:], Timeseries_Future_45,Months_Low_Flow_Summer, 7)
            append!(average_Low_Flows_past, mean(Seasonal_Low_Flows_Past))
            append!(average_Low_Flows_future, mean(Seasonal_Low_Flows_Future))
        end
    end
    return average_Low_Flows_past, average_Low_Flows_future
end
@time begin
#Summer_Low_Flows_past85, Summer_Low_Flows_future85 = analyse_low_flows(path_85)
end

# --------- TOTAL LOW FLOWS PLOTS ---------------------
"""
Plots low flows in past and future, the relative and aboslute changes, as well as the low flows of each climate projection separately.
$(SIGNATURES)
"""
function plot_low_flows(Seasonal_Low_Flows_past45, Seasonal_Low_Flows_future45, Seasonal_Low_Flows_past85, Seasonal_Low_Flows_future85)
    Farben45=palette(:blues)
    Farben85=palette(:reds)
    for proj in 1:14
        boxplot(Seasonal_Low_Flows_past45[1+(proj-1)*100: proj*100], color=[Farben45[1]])
        boxplot!(Seasonal_Low_Flows_future45[1+(proj-1)*100: proj*100],color=[Farben45[2]])
        boxplot!(Seasonal_Low_Flows_past85[1+(proj-1)*100: proj*100], color=[Farben85[1]])
        boxplot!(Seasonal_Low_Flows_future85[1+(proj-1)*100: proj*100], size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
        xticks!([1:4;], ["Past 4.5", "Future 4.5", "Past 8.5", "Future 8.5"])
        ylabel!("minimum 7 day moving average of daily runoff [m³/s]")
        ylims!((2,10))
        title!("Winter Low Flows 30 year average of Lowest 7 day runoff from May - Nov")
        savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/LowFlows/summerlowflows_"*string(Name_Projections_45[proj])*".png")
    end

    boxplot(Seasonal_Low_Flows_past45, color=[Farben45[1]])
    boxplot!(Seasonal_Low_Flows_future45,color=[Farben45[2]])
    boxplot!(Seasonal_Low_Flows_past85, color=[Farben85[1]])
    boxplot!(Seasonal_Low_Flows_future85, size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    xticks!([1:4;], ["Past 4.5", "Future 4.5", "Past 8.5", "Future 8.5"])
    ylabel!("minimum 7 day moving average of daily runoff [m³/s]")
    ylims!((2,10))
    title!("Winter Low Flows 30 year average of Lowest 7 day runoff from May - Nov")
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/LowFlows/summerlowflows.png")

    #absolute and relative decrease
    boxplot(Seasonal_Low_Flows_future45 - Seasonal_Low_Flows_past45,color=[Farben45[2]])
    #boxplot!(, color=[Farben85[1]])
    boxplot!(Seasonal_Low_Flows_future85 - Seasonal_Low_Flows_past85, size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    xticks!([1:2;], ["RCP 4.5", "RCP 8.5"])
    ylabel!("absolute change [m³/s]")
    #title!("Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov (Future - Present)")
    absolute_change = boxplot!()
    # relative change
    boxplot((Seasonal_Low_Flows_future45 - Seasonal_Low_Flows_past45) ./ Seasonal_Low_Flows_past45,color=[Farben45[2]])
    #boxplot!(, color=[Farben85[1]])
    boxplot!((Seasonal_Low_Flows_future85 - Seasonal_Low_Flows_past85) ./ Seasonal_Low_Flows_past85, size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    xticks!([1:2;], ["RCP 4.5", "RCP 8.5"])
    ylabel!("relative change [%]")
    #title!("Relative Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov (Future - Present)")
    relative_change = boxplot!()


    #PyPlot.suptitle("Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov")
    plot(absolute_change, relative_change)
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/LowFlows/change_summerlowflows.png")

    violin(Seasonal_Low_Flows_future45 - Seasonal_Low_Flows_past45,color=[Farben45[2]])
    #boxplot!(, color=[Farben85[1]])
    violin!(Seasonal_Low_Flows_future85 - Seasonal_Low_Flows_past85, size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    xticks!([1:2;], ["RCP 4.5", "RCP 8.5"])
    ylabel!("absolute change [m³/s]")
    #title!("Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov (Future - Present)")
    absolute_change = boxplot!()
    # relative change
    violin((Seasonal_Low_Flows_future45 - Seasonal_Low_Flows_past45) ./ Seasonal_Low_Flows_past45,color=[Farben45[2]])
    #boxplot!(, color=[Farben85[1]])
    violin!((Seasonal_Low_Flows_future85 - Seasonal_Low_Flows_past85) ./ Seasonal_Low_Flows_past85, size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    xticks!([1:2;], ["RCP 4.5", "RCP 8.5"])
    ylabel!("relative change [%]")
    #title!("Relative Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov (Future - Present)")
    relative_change = boxplot!()


    #PyPlot.suptitle("Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov")
    plot(absolute_change, relative_change)
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/LowFlows/change_summerlowflows_violins.png")
end

#plot_low_flows(Summer_Low_Flows_past45, Summer_Low_Flows_future45, Summer_Low_Flows_past85, Summer_Low_Flows_future85)


#------------------- FUNCTIONS -----------------------

findnearest(A::Array{Float64,1},t::Float64) = findmin(abs.(A-t*ones(length(A))))[2]
relative_error(future::Float64, initial::Float64) = (future - initial) / initial

function plot_FDC(Past_Discharge_45, Future_Discharge_45, Past_Discharge_85, Future_Discharge_85, Name_Projection, Percentiles)
    FDC_Past_45 = flowdurationcurve((Past_Discharge_45))
    FDC_Future_45 = flowdurationcurve((Future_Discharge_45))
    FDC_Past_85 = flowdurationcurve((Past_Discharge_85))
    FDC_Future_85 = flowdurationcurve((Future_Discharge_85))
    #print("past", FDC_Future_85[2][1:10],"\n", "future", FDC_Future_45[2][1:10],"\n")
    Change_FDC_45 = Float64[]
    Change_FDC_85 = Float64[]
    #Percentiles = collect(0.1:0.1:0.9)
    for percentile in Percentiles
        index = findnearest(FDC_Past_45[2], percentile)
        error_45 = relative_error(FDC_Future_45[1][index], FDC_Past_45[1][index])
        error_85 = relative_error(FDC_Future_85[1][index], FDC_Past_85[1][index])
        append!(Change_FDC_45, error_45)
        append!(Change_FDC_85, error_85)
    end
    # plot(Percentiles, Change_FDC_45,label = "RCP 4.5", line=(1, :solid), color=["blue"])
    # plot!(Percentiles, Change_FDC_85, label = "RCP 8.5", line=(1, :solid), color=["orange"], size=(1200,800))
    # xlabel!("Percentiles of 30 years")
    # ylabel!("Relative Change in Discharge [%]")
    # title!("Relative Change in Discharge")
    # savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/FDC/FDC_Change_Gailtal_"*string(Name_Projection)*".png")


    #print(FDC_Future_45[1][index_01], FDC_Future_85[1][index_01], "\n")
    #print(FDC_Past_45[1][index_01], " ", FDC_Past_85[2][index_01], " ", FDC_Past_85[1][index_01], "\n")


    # plot(FDC_Past_45[2], FDC_Past_45[1], label = "Past RCP4.5", line=(1, :dash), color=["blue"])
    # plot!(FDC_Past_85[2], FDC_Past_85[1], label = "Past RCP8.5", line=(1, :dash), color=["orange"])
    # plot!(FDC_Future_45[2], FDC_Future_45[1], label = "Future RCP4.5", line=(1, :solid), color=["blue"])
    # plot!(FDC_Future_85[2], FDC_Future_85[1], label = "Future RCP8.5", line=(1, :solid), color=["orange"], size=(1200,800))
    # xlabel!("Exceedance Probability")
    # ylabel!("log(Discharge) [m3/s]")
    # title!("Gailtal "*string(Name_Projection))
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/FDC/log/FDC_Gailtal_"*string(Name_Projection)*".png")
    #return Change_FDC_45, Change_FDC_85
end

# function plot_percentiles(Percentiles)
#     All_Change_45 = zeros(length(Percentiles))
#     All_Change_85 = zeros(length(Percentiles))
#     for i in 1:14
#         name = Name_Projections_45[i]
#         Past_Discharge_45 = readdlm(path_45*name*"/Gailtal/100_model_results_discharge_past_2010.csv", ',')
#         Future_Discharge_45 = readdlm(path_45*name*"/Gailtal/100_model_results_discharge_future_2100.csv", ',')
#
#         # ----------- LOAD DISCHARGES FROM RCP 8.5 --------------
#         name = Name_Projections_85[i]
#         Past_Discharge_85 = readdlm(path_85*name*"/Gailtal/100_model_results_discharge_past_2010.csv", ',')
#         Future_Discharge_85 = readdlm(path_85*name*"/Gailtal/100_model_results_discharge_future_2100.csv", ',')
#         #print(size(Past_Discharge_45[1,:]), size(Future_Discharge_45), size(Future_Discharge_85), size(Past_Discharge_85))
#         # for all 100 model runs
#         for run in 1:100
#             Change_45, Change_85 = plot_FDC(Past_Discharge_45[run,:], Future_Discharge_45[run,:], Past_Discharge_85[run,:], Future_Discharge_85[run,:], name, Percentiles)
#             global All_Change_45 = hcat(All_Change_45, Change_45)
#             global All_Change_85 = hcat(All_Change_85, Change_85)
#         end
#     end
#     All_Change_85 = All_Change_85[:,2:end]
#     All_Change_45 = All_Change_45[:,2:end]
#     print(size(All_Change_45), size(All_Change_85))
#     plot()
#     boxplots = []
#     for percentile in 1:9
#         box_45 = boxplot!([string(Percentiles[percentile])], All_Change_45[percentile,:], leg=false)
#         title!("RCP 4.5")
#         #savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/FDC/log/Change_Box45_Gailtal_"*string(Name_Projections_45[i])*".png")
#     end
#     push!(boxplots, boxplot!([string(Percentiles[1])], All_Change_45[1,:], leg=false))
#     plot()
#     for percentile in 1:9
#         box_85 = boxplot!([string(Percentiles[percentile])], All_Change_85[percentile,:], leg=false)
#         title!("RCP 8.5")
#         #savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/FDC/log/Change_Box85_Gailtal_"*string(Name_Projections_85[i])*".png")
#     end
#     push!(boxplots, boxplot!([string(Percentiles[1])], All_Change_85[1,:], leg=false))
#     plot(boxplots[1], boxplots[2], layout= (1,2), legend = false, size=(2000,1000))
#     savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/FDC/Change_FDC_Gailtal_All_Proj_100runs.png")
# end

# ----------- LOAD DISCHARGES FROM RCP 4.5 --------------

#name = Name_Projections[1]



# -------------- PLOT PERCENTILES OF FDC -------------------------
Percentiles = collect(0.1:0.1:0.9)


#monthly average discharges (or winter summer

function max_Annual_Discharge(Discharge, Timeseries)
    Years = collect(Dates.year(Timeseries[1]): Dates.year(Timeseries[end]))
    max_Annual_Discharge = Float64[]
    Date_max_Annual_Discharge = Float64[]
    for (i, Current_Year) in enumerate(Years)
            Dates_Current_Year = filter(Timeseries) do x
                              Dates.Year(x) == Dates.Year(Current_Year)
                          end
            max_Discharge = maximum(Discharge[indexin(Dates_Current_Year, Timeseries)])
            Date_Max_Discharge = Timeseries[findfirst(x->x == max_Discharge, Discharge)]
            append!(max_Annual_Discharge, max_Discharge)
            append!(Date_max_Annual_Discharge, Dates.dayofyear(Date_Max_Discharge))
    end
    return max_Annual_Discharge, Date_max_Annual_Discharge
end

function change_max_Annual_Discharge(path_45)
    Name_Projections_45 = readdir(path_45)
    Timeseries_Past = collect(Date(1981,1,1):Day(1):Date(2010,12,31))
    Timeseries_End = readdlm("/home/sarah/Master/Thesis/Data/Projektionen/End_Timeseries_45_85.txt",',')
    change_all_runs = Float64[]
    timing_change_all_runs = Float64[]
    timing_change_all_runs2 = Float64[]
    for (i, name) in enumerate(Name_Projections_45)
        Timeseries_Future_45 = collect(Date(Timeseries_End[i,2]-29,1,1):Day(1):Date(Timeseries_End[i,2],12,31))
        Past_Discharge_45 = readdlm(path_45*name*"/Gailtal/100_model_results_discharge_past_2010.csv", ',')
        Future_Discharge_45 = readdlm(path_45*name*"/Gailtal/100_model_results_discharge_future_2100.csv", ',')
        #change_all_runs = Float64[]
        for run in 1:100
            max_Discharge_past, Date_max_Discharge_past = max_Annual_Discharge(Past_Discharge_45[run,:], Timeseries_Past)
            max_Discharge_future, Date_max_Discharge_future = max_Annual_Discharge(Future_Discharge_45[run,:], Timeseries_Future_45)
            max_Discharge_past = mean(max_Discharge_past)
            max_Discharge_future = mean(max_Discharge_future)
            Date_max_Discharge_past = mean(Date_max_Discharge_past)
            Date_max_Discharge_future = mean(Date_max_Discharge_future)
            error = relative_error(max_Discharge_future, max_Discharge_past)
            #error_timing = Date_max_Discharge_future - Date_max_Discharge_past)
            append!(change_all_runs, error)
            append!(timing_change_all_runs, Date_max_Discharge_future)
            append!(timing_change_all_runs2, Date_max_Discharge_past)
        end
    end
    return change_all_runs, timing_change_all_runs, timing_change_all_runs2
end


#changes = change_max_Annual_Discharge(path_45)
#changes85, timing_changes85_future, timing_changes85_past = change_max_Annual_Discharge(path_85)

# scatter([timing_changes85_past, timing_changes85_future], label=["past" "future"], size=(1200,800))
# ylabel!("Day of Year")
# title!("RCP 8.5")
# savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/Annual_Max_Discharge/Timing85.png")
