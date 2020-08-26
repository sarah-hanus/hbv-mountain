
using DelimitedFiles
using Plots
using Statistics
using StatsPlots
using Plots.PlotMeasures
using CSV
using Dates
using DocStringExtensions

relative_error(future, initial) = (future - initial) ./ initial
# ------------------------- PLOT MONTHLY TEMPERATURE AND PRECIPITATION PAST AND FUTURE
"""
Computes the monthly daily average of e.g. discharge or temperature.

$(SIGNATURES)

The function returns the monthly daily average and an array of the months in the timeseries (1,2,3,4,5,6,7,8,9,10,11,12,1,2,3,4...)
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
                    Current_Discharge = Discharge[indexin(Dates_Current_Month, Timeseries)]
                    Current_Monthly_Discharge = sum(Current_Discharge) / Dates.daysinmonth(Current_Year, Current_Month)
                    append!(Monthly_Discharge, Current_Monthly_Discharge)
                    append!(All_Months, Current_Month)
            end
    end
    return Monthly_Discharge, All_Months
end

"""
Computes the monthly sum of e.g. precipitation (taking the sum over a month)

$(SIGNATURES)

The function returns the monthly sum and the an array of the months in the timeseries (1,2,3,4,5,6,7,8,9,10,11,12,1,2,3,4...)
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
                    Current_Discharge = Discharge[indexin(Dates_Current_Month, Timeseries)]
                    Current_Monthly_Discharge = sum(Current_Discharge)
                    append!(Monthly_Discharge, Current_Monthly_Discharge)
                    append!(All_Months, Current_Month)
            end
    end
    return Monthly_Discharge, All_Months
end

# ----------------  AVERAGE MONTHLY INPUTS ------------------
"""
Plots the average Monthly Temperature and Precipitation of 1980-2010 and 2070-2100 of the projections in the given path (14 projectiosn). Also plots the absolute changes.

$(SIGNATURES)

The function returns plots and arrays of the average monthly temperature and precipitation of the past and future of all projections.
    It saves plots under "Projections/Catchment_Name/PastvsFuture/Inputs/"
"""
function plot_Monthly_Temperature_Precipitation(path_to_projections, Catchment_Name)
    plot()
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

    if Catchment_Name == "Gailtal"
        ID_Prec_Zones = [113589, 113597, 113670, 114538]
        # size of the area of precipitation zones
        Area_Zones = [98227533.0, 184294158.0, 83478138.0, 220613195.0]
        Temp_Elevation = 1140.0
        Mean_Elevation_Catchment = 1500
        ID_temp = "tas_113597_sim1"
        Elevations_Catchment = Elevations(200.0, 400.0, 2800.0, Temp_Elevation, Temp_Elevation)
    elseif Catchment_Name == "Palten"
        ID_Prec_Zones = [106120, 111815, 9900]
        Area_Zones = [198175943.0, 56544073.0, 115284451.3]
        ID_temp = 106120
        Temp_Elevation = 1265.0
        Mean_Elevation_Catchment = 1300 # in reality 1314
        Elevations_Catchment = Elevations(200.0, 600.0, 2600.0, Temp_Elevation, Temp_Elevation)
    elseif Catchment_Name == "Pitten"
        ID_Prec_Zones = [109967]
        Area_Zones = [115496400.]
        ID_temp = 10510
        Mean_Elevation_Catchment = 900 # in reality 917
        Temp_Elevation = 488.0
        Elevations_Catchment = Elevations(200.0, 400.0, 1600.0, Temp_Elevation, Temp_Elevation)
    elseif Catchment_Name == "Defreggental"
        ID_Prec_Zones = [17700, 114926]
        Area_Zones = [235811198.0, 31497403.0]
        ID_temp = 17700
        Mean_Elevation_Catchment =  2300 # in reality 2233.399986
        Temp_Elevation = 1385.
        Elevations_Catchment = Elevations(200.0, 1000.0, 3600.0, Temp_Elevation, Temp_Elevation)
    elseif Catchment_Name == "IllSugadin"
        ID_Prec_Zones = [100206]
        Area_Zones = [100139168.]
        ID_temp = 14200
        Mean_Elevation_Catchment = 1700
        Temp_Elevation = 670.
        Elevations_Catchment = Elevations(200.0, 600.0, 2800.0, Temp_Elevation, Temp_Elevation)
    elseif Catchment_Name == "Pitztal"
        ID_Prec_Zones = [102061, 102046]
        Area_Zones = [20651736.0, 145191864.0]
        ID_temp = 14620
        Mean_Elevation_Catchment =  2500 # in reality 2233.399986
        Temp_Elevation = 1410.
        Elevations_Catchment = Elevations(200.0, 1200.0, 3800.0, Temp_Elevation, Temp_Elevation)
    end
    Area_Catchment = sum(Area_Zones)
    Area_Zones_Percent = Area_Zones / Area_Catchment
    for (i, name) in enumerate(Name_Projections_45)
        Timeseries_Future = collect(Date(Timeseries_End[i,index]-29,1,1):Day(1):Date(Timeseries_End[i,index],12,31))
        #print(size(Timeseries_Past), size(Timeseries_Future))
        Timeseries_Proj = readdlm(path_to_projections*name*"/"*Catchment_Name*"/pr_model_timeseries.txt")
        Timeseries_Proj = Date.(Timeseries_Proj, Dates.DateFormat("y,m,d"))
        Temperature = readdlm(path_to_projections*name*"/"*Catchment_Name*"/tas_"*string(ID_temp)*"_sim1.txt", ',')[:,1]
        Elevation_Zone_Catchment, Temperature_Elevation_Catchment, Total_Elevationbands_Catchment = gettemperatureatelevation(Elevations_Catchment, Temperature)
        # get the temperature data at the mean elevation to calculate the mean potential evaporation
        Temperature = Temperature_Elevation_Catchment[:,findfirst(x-> x==Mean_Elevation_Catchment, Elevation_Zone_Catchment)]

        indexstart_past = findfirst(x-> x == Dates.year(Timeseries_Past[1]), Dates.year.(Timeseries_Proj))[1]
        indexend_past = findlast(x-> x == Dates.year(Timeseries_Past[end]), Dates.year.(Timeseries_Proj))[1]
        Temperature_Past = Temperature[indexstart_past:indexend_past] ./ 10
        #print(Dates.year(Timeseries_Future[end]), Dates.year.(Timeseries_Proj[end]))
        indexstart_future = findfirst(x-> x == Dates.year(Timeseries_Future[1]), Dates.year.(Timeseries_Proj))[1]
        indexend_future = findlast(x-> x == Dates.year(Timeseries_Future[end]), Dates.year.(Timeseries_Proj))[1]
        Temperature_Future = Temperature[indexstart_future:indexend_future] ./ 10
        # calculate monthly mean temperature
        Monthly_Temperature_Past, Month = monthly_discharge(Temperature_Past, Timeseries_Past)
        Monthly_Temperature_Future, Month_future = monthly_discharge(Temperature_Future, Timeseries_Future)

        #-------- PRECIPITATION ------------------
        Precipitation_All_Zones = Array{Float64, 1}[]
        Total_Precipitation_Proj = zeros(length(Timeseries_Proj))
        for j in 1: length(ID_Prec_Zones)
                # get precipitation projections for the precipitation measurement
                Precipitation_Zone = readdlm(path_to_projections*name*"/"*Catchment_Name*"/pr_"*string(ID_Prec_Zones[j])*"_sim1.txt", ',')[:,1]
                #print(size(Precipitation_Zone), typeof(Precipitation_Zone))
                push!(Precipitation_All_Zones, Precipitation_Zone ./10)
                Total_Precipitation_Proj += Precipitation_All_Zones[j].*Area_Zones_Percent[j]
        end
        #Total_Precipitation_Proj = Precipitation_All_Zones[1].*Area_Zones_Percent[1] + Precipitation_All_Zones[2].*Area_Zones_Percent[2] + Precipitation_All_Zones[3].*Area_Zones_Percent[3] + Precipitation_All_Zones[4].*Area_Zones_Percent[4]
        Precipitation_Past = Total_Precipitation_Proj[indexstart_past:indexend_past]
        Precipitation_Future = Total_Precipitation_Proj[indexstart_future:indexend_future]

        Monthly_Precipitation_Past, Month = monthly_precipitation(Precipitation_Past, Timeseries_Past)
        Monthly_Precipitation_Future, Month_future = monthly_precipitation(Precipitation_Future, Timeseries_Future)

        # take average over all months in timeseries
        for month in 1:12
            current_Month_Temperature = Monthly_Temperature_Past[findall(x->x == month, Month)]
            current_Month_Temperature_future = Monthly_Temperature_Future[findall(x->x == month, Month_future)]
            current_Month_Temperature = mean(current_Month_Temperature)
            current_Month_Temperature_future = mean(current_Month_Temperature_future)
            append!(average_monthly_Temperature_past, current_Month_Temperature)
            append!(average_monthly_Temperature_future, current_Month_Temperature_future)
            append!(all_months_all_runs, month)

            current_Month_Precipitation = Monthly_Precipitation_Past[findall(x->x == month, Month)]
            current_Month_Precipitation_future = Monthly_Precipitation_Future[findall(x->x == month, Month_future)]
            current_Month_Precipitation = mean(current_Month_Precipitation)
            current_Month_Precipitation_future = mean(current_Month_Precipitation_future)
            #error = relative_error(current_Month_Discharge_future, current_Month_Discharge)
            append!(average_monthly_Precipitation_past, current_Month_Precipitation)
            append!(average_monthly_Precipitation_future, current_Month_Precipitation_future)
        end
    end
    println("yearly prec past", sum(average_monthly_Precipitation_past)/14)
    println("yearly prec past", sum(average_monthly_Precipitation_future)/14)
    #----------- PLOTS PRECIPITATION------------------------
    xaxis_1 = collect(1:2:23)
    xaxis_2 = collect(2:2:24)
    Farben = palette(:blues)
    for month in 1:12
        boxplot!([xaxis_1[month]], average_monthly_Precipitation_past[findall(x-> x == month, all_months_all_runs)], size=(2000,800), leg=false, color=[Farben[1]], left_margin = [5mm 0mm])
        boxplot!([xaxis_2[month]], average_monthly_Precipitation_future[findall(x-> x == month, all_months_all_runs)], size=(2000,800), leg=false, color=[Farben[2]], left_margin = [5mm 0mm])
    end
    ylabel!("Average Monthly Precipitation [mm/ month]")
    ylims!((0,300))
    yticks!([0:50:300;])
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
    ylims!((-10,25))
    yticks!([-10:5:25;])
    ylabel!("Average Monthly Temperature [°C]")
    title!("Averaged Monthly Temperature Past=light, Future=dark")
    #ylims!((0,40))
    #hline!([0], color=["grey"], linestyle = :dash)
    xticks!([1.5:2:23.5;], ["Jan", "Feb", "Mar", "Apr", "May","Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])
    plot2 = boxplot!()

    plot()
    plot(plot1, plot2, layout= (2,1), legend = false, size=(2000,1000), left_margin = [5mm 0mm])

    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Inputs/"*Catchment_Name*"_Temp_Prec"*rcp*".png")

    # ---------------  ABSOLUTE CHANGES ----------------
    plot()
    xaxis_1 = collect(1:2:23)
    xaxis_2 = collect(2:2:24)
    for month in 1:12
        boxplot!(average_monthly_Precipitation_future[findall(x-> x == month, all_months_all_runs)] - average_monthly_Precipitation_past[findall(x-> x == month, all_months_all_runs)], size=(2000,800), leg=false, color=["blue"], left_margin = [5mm 0mm])
    end
    ylabel!("Average Absolute Change in Monthly Precipitation [mm/ month]")
    title!("Averaged Monthly Precipitation Future - Past")
    ylims!((-100,150))
    yticks!([-100:25:150;])
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
    ylims!((0,8))
    yticks!([0:2:8;])
    #ylims!((0,40))
    #hline!([0], color=["grey"], linestyle = :dash)
    xticks!([1:12;], ["Jan", "Feb", "Mar", "Apr", "May","Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])
    plot2 = boxplot!()

    plot()
    plot(plot1, plot2, layout= (2,1), legend = false, size=(2000,1000), left_margin = [5mm 0mm])

    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Inputs/"*Catchment_Name*"_Absolute_Change_Temp_Prec"*rcp*".png")

    return average_monthly_Precipitation_past, average_monthly_Precipitation_future, average_monthly_Temperature_past, average_monthly_Temperature_future, all_months_all_runs
end

# -------------------------------- AVERAGE MONTHLY RUNOFF --------------------------
"""
Computes the monthly discharges of the past and future and the relative changes, of the projections of the path and the different parameter sets

$(SIGNATURES)

The function returns relative change in monthly average discharge, the monthly mean discharge of the past, and the monthly mean discharge of the future
"""
function change_monthly_Discharge(path_to_projections, Catchment_Name)
    Name_Projections_45 = readdir(path_to_projections)
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
    error_average_monthly_Discharge_all_runs = Float64[]
    all_months_all_runs = Float64[]
    for (i, name) in enumerate(Name_Projections_45)
        Timeseries_Future_45 = collect(Date(Timeseries_End[i,index]-29,1,1):Day(1):Date(Timeseries_End[i,index],12,31))
        Past_Discharge_45 = readdlm(path_to_projections*name*"/"*Catchment_Name*"/300_model_results_discharge_past_2010_without_loss.csv", ',')
        Future_Discharge_45 = readdlm(path_to_projections*name*"/"*Catchment_Name*"/300_model_results_discharge_future_20100_without_loss.csv", ',')
        println(size(Past_Discharge_45)[1])
        for run in 1:size(Past_Discharge_45)[1]
            # computes mean monthly discharge of each month
            Monthly_Discharge_past, Month = monthly_discharge(Past_Discharge_45[run,:], Timeseries_Past)
            Monthly_Discharge_future, Month_future = monthly_discharge(Future_Discharge_45[run,:], Timeseries_Future_45)
            for month in 1:12
                # computes the average mean monthly discharge over all years for each month
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
        end
    end
    return error_average_monthly_Discharge_all_runs, average_monthly_Discharge_past, average_monthly_Discharge_future, all_months_all_runs
end

"""
Calculates the mean annual discharge using the monthly Discharge that is already calculated.

$(SIGNATURES)

"""
function annual_discharge_new(monthly_Discharge_past, monthly_Discharge_future, Area_Catchment, nr_runs)
    yearly_discharge_past = Float64[]
    yearly_discharge_future = Float64[]
    relative_change = Float64[]
    days_in_month = [31,28.25, 31,30,31, 30, 31, 31, 30, 31, 30,31]
    for run in 1: 14*nr_runs
        current_average_yearly_discharge_past = sum(monthly_Discharge_past[1+((run-1)*12):run*12] .* days_in_month)
        current_average_yearly_discharge_future = sum(monthly_Discharge_future[1+((run-1)*12):run*12] .* days_in_month)
        current_relative_change = relative_error(current_average_yearly_discharge_future, current_average_yearly_discharge_past)
        append!(yearly_discharge_past, convertDischarge(current_average_yearly_discharge_past, Area_Catchment))
        append!(yearly_discharge_future, convertDischarge(current_average_yearly_discharge_future, Area_Catchment))
        append!(relative_change, current_relative_change)
    end
    return relative_change, yearly_discharge_past, yearly_discharge_future
end

"""
Plots the Aboslute and relative changes of both emission pathways of the monthly discharges of the past and future in m³/s,
plots the relative change for each projection to see the uncertainty in parameter sets

$(SIGNATURES)

"""
function plot_changes_monthly_discharge(Monthly_Discharge_past_45, Monthly_Discharge_future_45, Monthly_Discharge_past_85, Monthly_Discharge_future_85, months_45, Catchment_Name, nr_runs)
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
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Monthly_Discharge/"*Catchment_Name*"_absolute_change_monthly_discharge4.5_8.5.png")

    # ------- REALTIVE CHANGE ----------------
    plot()
    for month in 1:12
        boxplot!([xaxis_45[month]],relative_error(Monthly_Discharge_future_45[findall(x-> x == month, months_45)], Monthly_Discharge_past_45[findall(x-> x == month, months_45)])*100, size=(2000,800), leg=false, color=["blue"], alpha=0.8)
        boxplot!([xaxis_85[month]],relative_error(Monthly_Discharge_future_85[findall(x-> x == month, months_45)], Monthly_Discharge_past_85[findall(x-> x == month, months_45)])*100, size=(2000,800), leg=false, color=["red"], left_margin = [5mm 0mm])
    end
    ylabel!("Relative Change in Average monthly Discharge [%]", yguidefontsize=20)
    title!("Relative Change in Discharge RCP 4.5 =blue, RCP 4.5 = red")
    boxplot!(left_margin = [5mm 0mm], bottom_margin = 20px, xtickfont = font(20), ytickfont = font(20))
    #ylims!((-0.8,1.1))
    hline!([0], color=["grey"], linestyle = :dash)
    xticks!([1.5:2:23.5;], ["Jan", "Feb", "Mar", "Apr", "May","Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])

    #xticks!([2:2:24;], ["Jan 8.5", "Feb 8.5", "Mar 8.5", "Apr 8.5", "May 8.5","Jun 8.5", "Jul 8.5", "Aug 8.5", "Sep 8.5", "Oct 8.5", "Nov 8.5", "Dec 8.5"])
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Monthly_Discharge/"*Catchment_Name*"_relative_change_monthly_discharge4.5_8.5.png")

    # ------------ EACH PROJECTION ----------------
    plot()
    for proj in 1:14
        months_proj = repeat([1,2,3,4,5,6,7,8,9,10,11,12], nr_runs)
        Monthly_Discharge_future_45_proj = Monthly_Discharge_future_45[1+(proj-1)*nr_runs*12: proj*nr_runs*12]
        Monthly_Discharge_future_85_proj = Monthly_Discharge_future_85[1+(proj-1)*nr_runs*12: proj*nr_runs*12]
        Monthly_Discharge_past_45_proj = Monthly_Discharge_past_45[1+(proj-1)*nr_runs*12: proj*nr_runs*12]
        Monthly_Discharge_past_85_proj = Monthly_Discharge_past_85[1+(proj-1)*nr_runs*12: proj*nr_runs*12]
        plot()
        for month in 1:12
            boxplot!([xaxis_45[month]],relative_error(Monthly_Discharge_future_45_proj[findall(x-> x == month, months_proj)], Monthly_Discharge_past_45_proj[findall(x-> x == month, months_proj)])*100, size=(2000,800), leg=false, color=["blue"], alpha=0.8)
            boxplot!([xaxis_85[month]],relative_error(Monthly_Discharge_future_85_proj[findall(x-> x == month, months_proj)], Monthly_Discharge_past_85_proj[findall(x-> x == month, months_proj)])*100, size=(2000,800), leg=false, color=["red"], left_margin = [5mm 0mm])
        end
        ylabel!("Relative Change in Average monthly Discharge [%]", yguidefontsize=20)
        title!("Relative Change in Discharge RCP 4.5 =blue, RCP 4.5 = red")
        ylims!((-75,275))
        boxplot!(left_margin = [5mm 0mm], bottom_margin = 20px, xtickfont = font(20), ytickfont = font(20))
        #ylims!((-0.8,1.1))
        hline!([0], color=["grey"], linestyle = :dash)
        xticks!([1.5:2:23.5;], ["Jan", "Feb", "Mar", "Apr", "May","Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])

        #xticks!([2:2:24;], ["Jan 8.5", "Feb 8.5", "Mar 8.5", "Apr 8.5", "May 8.5","Jun 8.5", "Jul 8.5", "Aug 8.5", "Sep 8.5", "Oct 8.5", "Nov 8.5", "Dec 8.5"])
        savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Monthly_Discharge/"*Catchment_Name*"_relative_change_monthly_discharge4.5_8.5_proj_"*string(proj)*".png")
    end
end
"""
Plots the Aboslute and relative changes of both emission pathways of the monthly discharges of the past and future in mm

$(SIGNATURES)

"""
function plot_changes_monthly_discharge_mm(Monthly_Discharge_past_45, Monthly_Discharge_future_45, Monthly_Discharge_past_85, Monthly_Discharge_future_85, months_45, Area_Catchment, Catchment_Name)
    Farben = palette(:tab20)

    xaxis_45 = collect(1:2:23)
    xaxis_85 = collect(2:2:24)
    # ----------------- Plot Absolute Change ------------------
    plot()
    Farben_85 = palette(:reds)
    Farben_45 = palette(:blues)
    # convert discharges to mm/d
    Monthly_Discharge_past_45 = convertDischarge(Monthly_Discharge_past_45, Area_Catchment)
    Monthly_Discharge_future_45 = convertDischarge(Monthly_Discharge_future_45, Area_Catchment)
    Monthly_Discharge_past_85 = convertDischarge(Monthly_Discharge_past_85, Area_Catchment)
    Monthly_Discharge_future_85 = convertDischarge(Monthly_Discharge_future_85, Area_Catchment)

    for month in 1:12
        boxplot!([xaxis_45[month]],Monthly_Discharge_future_45[findall(x-> x == month, months_45)] - Monthly_Discharge_past_45[findall(x-> x == month, months_45)] , size=(2000,800), leg=false, color=["blue"], alpha=0.8)
        boxplot!([xaxis_85[month]],Monthly_Discharge_future_85[findall(x-> x == month, months_45)] - Monthly_Discharge_past_85[findall(x-> x == month, months_45)], size=(2000,800), leg=false, color=["red"], left_margin = [5mm 0mm])
    end
    ylabel!("Change in Average monthly Discharge [mm/d]")
    #title!("Absolute Change in Discharge RCP 4.5 =blue, RCP 4.5 = red")
    title!(Catchment_Name)
    ylims!((-3.5,3))
    yticks!([-3.5:0.5:3;])
    hline!([0], color=["grey"], linestyle = :dash)
    #hline!([0], color=["grey"], linestyle = :dash)
    xticks!([1.5:2:23.5;], ["Jan", "Feb", "Mar", "Apr", "May","Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])
    #xticks!([2:2:24;], ["Jan 8.5", "Feb 8.5", "Mar 8.5", "Apr 8.5", "May 8.5","Jun 8.5", "Jul 8.5", "Aug 8.5", "Sep 8.5", "Oct 8.5", "Nov 8.5", "Dec 8.5"])
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Monthly_Discharge/"*Catchment_Name*"_absolute_change_monthly_discharge4.5_8.5_mm_scaled.png")

    # --------- PLOT VALUES PAST VS FUTURE ---------------------
    plot()
    for month in 1:12
        boxplot!([xaxis_45[month]],Monthly_Discharge_past_45[findall(x-> x == month, months_45)] , size=(2000,800), leg=false, color=[Farben_45[1]], alpha=0.8)
        boxplot!([xaxis_85[month]],Monthly_Discharge_future_45[findall(x-> x == month, months_45)], size=(2000,800), leg=false, color=[Farben_45[2]], left_margin = [5mm 0mm])
    end
    ylabel!("Monthly Mean Discharge [mm/d]")
    title!("Monthly Mean Discharges RCP 4.5 (Past=light, Future=dark)")
    #ylims!((-0.8,1.1))
    #hline!([0], color=["grey"], linestyle = :dash)
    xticks!([1.5:2:23.5;], ["Jan", "Feb", "Mar", "Apr", "May","Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])
    #xticks!([2:2:24;], ["Jan 8.5", "Feb 8.5", "Mar 8.5", "Apr 8.5", "May 8.5","Jun 8.5", "Jul 8.5", "Aug 8.5", "Sep 8.5", "Oct 8.5", "Nov 8.5", "Dec 8.5"])
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Monthly_Discharge/"*Catchment_Name*"_monthly_discharge4.5_mm.png")

    plot()
    for month in 1:12
        boxplot!([xaxis_45[month]],Monthly_Discharge_past_85[findall(x-> x == month, months_45)] , size=(2000,800), leg=false, color=[Farben_85[1]], alpha=0.8)
        boxplot!([xaxis_85[month]],Monthly_Discharge_future_85[findall(x-> x == month, months_45)], size=(2000,800), leg=false, color=[Farben_85[2]], left_margin = [5mm 0mm])
    end
    ylabel!("Monthly Mean Discharge [mm/d]")
    title!("Monthly Mean Discharges RCP 8.5 (Past=light, Future=dark)")
    #ylims!((-0.8,1.1))
    #hline!([0], color=["grey"], linestyle = :dash)
    xticks!([1.5:2:23.5;], ["Jan", "Feb", "Mar", "Apr", "May","Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])
    #xticks!([2:2:24;], ["Jan 8.5", "Feb 8.5", "Mar 8.5", "Apr 8.5", "May 8.5","Jun 8.5", "Jul 8.5", "Aug 8.5", "Sep 8.5", "Oct 8.5", "Nov 8.5", "Dec 8.5"])
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Monthly_Discharge/"*Catchment_Name*"_monthly_discharge8.5_mm.png")

    # ------- REALTIVE CHANGE ----------------
    plot()
    for month in 1:12
        boxplot!([xaxis_45[month]],relative_error(Monthly_Discharge_future_45[findall(x-> x == month, months_45)], Monthly_Discharge_past_45[findall(x-> x == month, months_45)])*100, size=(2000,800), leg=false, color=["blue"], alpha=0.8)
        boxplot!([xaxis_85[month]],relative_error(Monthly_Discharge_future_85[findall(x-> x == month, months_45)], Monthly_Discharge_past_85[findall(x-> x == month, months_45)])*100, size=(2000,800), leg=false, color=["red"], left_margin = [5mm 0mm])
    end
    ylabel!("Relative Change in Average monthly Discharge [%]", yguidefontsize=20)
    #title!("Relative Change in Discharge RCP 4.5 =blue, RCP 4.5 = red")
    title!(Catchment_Name)
    boxplot!(left_margin = [5mm 0mm], bottom_margin = 20px, xtickfont = font(20), ytickfont = font(20))
    ylims!((-100,275))
    yticks!([-100:25:275;])
    hline!([0], color=["grey"], linestyle = :dash)
    hline!([100], color=["grey"], linestyle = :dash)
    hline!([50], color=["grey"], linestyle = :dash)
    hline!([-25], color=["grey"], linestyle = :dash)
    xticks!([1.5:2:23.5;], ["Jan", "Feb", "Mar", "Apr", "May","Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])

    #xticks!([2:2:24;], ["Jan 8.5", "Feb 8.5", "Mar 8.5", "Apr 8.5", "May 8.5","Jun 8.5", "Jul 8.5", "Aug 8.5", "Sep 8.5", "Oct 8.5", "Nov 8.5", "Dec 8.5"])
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Monthly_Discharge/"*Catchment_Name*"_relative_change_monthly_discharge4.5_8.5_scaled.png")
end

function plot_change_total_discharge(path_to_projections_45, path_to_projections_85, Name_Catchment, Area_Catchment)
    Name_Projections_45 = readdir(path_to_projections_45)
    Name_Projections_85 = readdir(path_to_projections_85)
    relative_change_45 = Float64[]
    relative_change_85 = Float64[]
    Total_Discharge_Past_45 = Float64[]
    Total_Discharge_Future_45 = Float64[]
    Total_Discharge_Past_85 = Float64[]
    Total_Discharge_Future_85 = Float64[]
    for (i, name) in enumerate(Name_Projections_45)
        Past_Discharge = readdlm(path_to_projections_45*name*"/"*Name_Catchment*"/300_model_results_discharge_past_2010.csv", ',')
        Future_Discharge = readdlm(path_to_projections_45*name*"/"*Name_Catchment*"/300_model_results_discharge_future_2100.csv", ',')
        # get FDCs from each discharge
        for run in 1: size(Past_Discharge)[1]
            # for each run get the total discharge
            Discharge_Past = sum(convertDischarge(Past_Discharge[run,:], Area_Catchment))
            Discharge_Future = sum(convertDischarge(Future_Discharge[run,:], Area_Catchment))
            relative_change = relative_error(Discharge_Future, Discharge_Past)*100
            append!(relative_change_45, relative_change)
            append!(Total_Discharge_Past_45, Discharge_Past)
            append!(Total_Discharge_Future_45, Discharge_Future)
        end
    end
    for (i, name) in enumerate(Name_Projections_85)
        Past_Discharge = readdlm(path_to_projections_85*name*"/"*Name_Catchment*"/300_model_results_discharge_past_2010.csv", ',')
        Future_Discharge = readdlm(path_to_projections_85*name*"/"*Name_Catchment*"300__model_results_discharge_future_2100.csv", ',')
        # get FDCs from each discharge
        for run in 1: size(Past_Discharge)[1]
            # for each run get the total discharge
            Discharge_Past = sum(convertDischarge(Past_Discharge[run,:], Area_Catchment))
            Discharge_Future = sum(convertDischarge(Future_Discharge[run,:], Area_Catchment))
            relative_change = relative_error(Discharge_Future, Discharge_Past)*100
            append!(relative_change_85, relative_change)
            append!(Total_Discharge_Past_85, Discharge_Past)
            append!(Total_Discharge_Future_85, Discharge_Future)
        end
    end

    Farben45=palette(:blues)
    Farben85=palette(:reds)
    rcps = ["RCP 4.5", "RCP 8.5"]

    # plot relative change
    plot()
    boxplot!([rcps[1]], relative_change_45, size=(2000,800), leg=false, color=[Farben45[2]])
    boxplot!([rcps[2]], relative_change_85, size=(2000,800), left_margin = [5mm 0mm], leg=false, color=[Farben85[2]])
    violin!([rcps[1]], relative_change_45, size=(2000,800), leg=false, color=[Farben45[2]], alpha=0.6)
    violin!([rcps[2]], relative_change_85,size=(2000,800), left_margin = [5mm 0mm], leg=false, color=[Farben85[2]], alpha=0.6)
    ylabel!("Relative Change in Total Discharge [%]")
    title!("Relative Change in total Discharge in "*Catchment_Name)
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/"*Catchment_Name*"_Relative_Change_Total_Discharge.png")
    #plot absolut change
    plot()
    boxplot!([rcps[1]], Total_Discharge_Future_45 - Total_Discharge_Past_45, size=(2000,800), leg=false, color=[Farben45[2]])
    boxplot!([rcps[2]], Total_Discharge_Future_85 - Total_Discharge_Past_85, size=(2000,800), left_margin = [5mm 0mm], leg=false, color=[Farben85[2]])
    violin!([rcps[1]], Total_Discharge_Future_45 - Total_Discharge_Past_45, size=(2000,800), leg=false, color=[Farben45[2]], alpha=0.6)
    violin!([rcps[2]], Total_Discharge_Future_85 - Total_Discharge_Past_85,size=(2000,800), left_margin = [5mm 0mm], leg=false, color=[Farben85[2]], alpha=0.6)
    ylabel!("Change in Total Discharge [mm]")
    title!("Absolute Change in total Discharge in "*Catchment_Name)
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/"*Catchment_Name*"_Absolute_Change_Total_Discharge.png")


    plot()
    boxplot!([rcps[1]], Total_Discharge_Past_45, size=(2000,800), leg=false, color=[Farben45[1]])
    boxplot!([rcps[2]], Total_Discharge_Future_45, size=(2000,800), left_margin = [5mm 0mm], leg=false, color=[Farben45[2]])
    violin!([rcps[1]], Total_Discharge_Past_45, size=(2000,800), leg=false, color=[Farben45[1]], alpha=0.6)
    violin!([rcps[2]], Total_Discharge_Future_45,size=(2000,800), left_margin = [5mm 0mm], leg=false, color=[Farben45[2]], alpha=0.6)
    ylabel!("Total Discharge [mm]")
    title!("Total Discharge over 30 years RCP 4.5 in "*Catchment_Name)
    ylims!(20000, 35000)
    rcp45 = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Snow_Cover/rel_change_snow_storage.png")

    plot()
    boxplot!([rcps[1]], Total_Discharge_Past_85, size=(2000,800), leg=false, color=[Farben85[1]])
    boxplot!([rcps[2]], Total_Discharge_Future_85 ,size=(2000,800), left_margin = [5mm 0mm], leg=false, color=[Farben85[2]])
    violin!([rcps[1]], Total_Discharge_Past_85, size=(2000,800), leg=false, color=[Farben85[1]], alpha=0.6)
    violin!([rcps[2]], Total_Discharge_Future_85,size=(2000,800), left_margin = [5mm 0mm], leg=false, color=[Farben85[2]], alpha=0.6)
    ylabel!("Total Discharge [mm]")
    title!("Total Discharge over 30 years RCP 8.5 in "*Catchment_Name)
    ylims!(20000, 35000)
    rcp85 = boxplot!()
    plot(rcp45, rcp85, size=(2000,800), left_margin = [5mm 0mm])
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/"*Catchment_Name*"_Total_Discharge_Comparison_Future_Past.png")
end

"""
Calculates the mean yearly discharges of all years in the time series [mm/year]

$(SIGNATURES)

Takes as input the discharge, the corresponding timeseries and the area of the catchment, returns the average yearly discharge over the timeperiod
"""
function average_annual_discharge(Discharge, Timeseries, Area_Catchment)
    Years = collect(Dates.year(Timeseries[1]): Dates.year(Timeseries[end]))
    Yearly_Discharges = Float64[]
    for (i, Current_Year) in enumerate(Years)
            Dates_Current_Year = filter(Timeseries) do x
                              Dates.Year(x) == Dates.Year(Current_Year)
                          end
            Current_Discharge = Discharge[indexin(Dates_Current_Year, Timeseries)]
            append!(Yearly_Discharges, sum(convertDischarge(Current_Discharge, Area_Catchment)))
    end
    Mean_Yearly_Discharge = mean(Yearly_Discharges)
    return Mean_Yearly_Discharge
end

"""
Calculates the mean yearly discharge of all runs and projections of both emission pathways [mm/year]

$(SIGNATURES)

Returns the relative change, the mean annual discharge of the past and future for both emission scenarios
"""
function change_annual_discharge(path_to_projections_45, path_to_projections_85, Catchment_Name, Area_Catchment)
    Name_Projections_45 = readdir(path_to_projections_45)
    Name_Projections_85 = readdir(path_to_projections_85)
    Timeseries_Past = collect(Date(1981,1,1):Day(1):Date(2010,12,31))
    Timeseries_End = readdlm("/home/sarah/Master/Thesis/Data/Projektionen/End_Timeseries_45_85.txt",',')

    relative_change_45 = Float64[]
    relative_change_85 = Float64[]
    Total_Discharge_Past_45 = Float64[]
    Total_Discharge_Future_45 = Float64[]
    Total_Discharge_Past_85 = Float64[]
    Total_Discharge_Future_85 = Float64[]
    # ---------- RCP 4.5 --------------
    for (i, name) in enumerate(Name_Projections_45)
        Past_Discharge = readdlm(path_to_projections_45*name*"/"*Catchment_Name*"/300_model_results_discharge_past_2010.csv", ',')
        Future_Discharge = readdlm(path_to_projections_45*name*"/"*Catchment_Name*"/300_model_results_discharge_future_2100.csv", ',')
        Timeseries_Future_45 = collect(Date(Timeseries_End[i,1]-29,1,1):Day(1):Date(Timeseries_End[i,1],12,31))
        # get FDCs from each discharge
        for run in 1: size(Past_Discharge)[1]
            # for each run get the total discharge
            Discharge_Past = average_annual_discharge(Past_Discharge[run,:], Timeseries_Past, Area_Catchment)
            Discharge_Future = average_annual_discharge(Future_Discharge[run,:], Timeseries_Future_45, Area_Catchment)
            relative_change = relative_error(Discharge_Future, Discharge_Past)*100
            append!(relative_change_45, relative_change)
            append!(Total_Discharge_Past_45, Discharge_Past)
            append!(Total_Discharge_Future_45, Discharge_Future)
        end
    end
    # ---------- RCP 8.5 --------------
    for (i, name) in enumerate(Name_Projections_85)
        Past_Discharge = readdlm(path_to_projections_85*name*"/"*Catchment_Name*"/300_model_results_discharge_past_2010.csv", ',')
        Future_Discharge = readdlm(path_to_projections_85*name*"/"*Catchment_Name*"/300_model_results_discharge_future_2100.csv", ',')
        Timeseries_Future_85 = collect(Date(Timeseries_End[i,2]-29,1,1):Day(1):Date(Timeseries_End[i,2],12,31))
        # get FDCs from each discharge
        for run in 1: size(Past_Discharge)[1]
            # for each run get the total discharge
            Discharge_Past = average_annual_discharge(Past_Discharge[run,:], Timeseries_Past, Area_Catchment)
            Discharge_Future = average_annual_discharge(Future_Discharge[run,:], Timeseries_Future_85, Area_Catchment)
            relative_change = relative_error(Discharge_Future, Discharge_Past)*100
            append!(relative_change_85, relative_change)
            append!(Total_Discharge_Past_85, Discharge_Past)
            append!(Total_Discharge_Future_85, Discharge_Future)
        end
    end
    return relative_change_45, Total_Discharge_Past_45, Total_Discharge_Future_45, relative_change_85, Total_Discharge_Past_85, Total_Discharge_Future_85
end

"""
Plots the absolute and relative change in average annual discharge [mm/year] and the values of past and future

$(SIGNATURES)

"""
function plot_change_annual_discharge(relative_change_45, Total_Discharge_Past_45, Total_Discharge_Future_45, relative_change_85, Total_Discharge_Past_85, Total_Discharge_Future_85, Area_Catchment, Catchment_Name)
    Farben45=palette(:blues)
    Farben85=palette(:reds)
    rcps = ["RCP 4.5", "RCP 8.5"]
    # plot relative change
    plot()
    boxplot!([rcps[1]], relative_change_45*100, size=(2000,800), leg=false, color=[Farben45[2]])
    boxplot!([rcps[2]], relative_change_85*100, size=(2000,800), left_margin = [5mm 0mm], leg=false, color=[Farben85[2]])
    violin!([rcps[1]], relative_change_45*100, size=(2000,800), leg=false, color=[Farben45[2]], alpha=0.6)
    violin!([rcps[2]], relative_change_85*100,size=(2000,800), left_margin = [5mm 0mm], leg=false, color=[Farben85[2]], alpha=0.6)
    ylims!((-35,35))
    yticks!([-35:5:35;])
    hline!([0], color=["grey"], linestyle = :dash)
    ylabel!("Relative Change in Average Annual Discharge [%]")
    title!("Relative Change in Average Annual Discharge in "*Catchment_Name)
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Discharge/"*Catchment_Name*"_Relative_Change_Annual_Discharge_scaled.png")
    #plot absolut change
    plot()
    boxplot!([rcps[1]], Total_Discharge_Future_45 - Total_Discharge_Past_45, size=(2000,800), leg=false, color=[Farben45[2]])
    boxplot!([rcps[2]], Total_Discharge_Future_85 - Total_Discharge_Past_85, size=(2000,800), left_margin = [5mm 0mm], leg=false, color=[Farben85[2]])
    violin!([rcps[1]], Total_Discharge_Future_45 - Total_Discharge_Past_45, size=(2000,800), leg=false, color=[Farben45[2]], alpha=0.6)
    violin!([rcps[2]], Total_Discharge_Future_85 - Total_Discharge_Past_85,size=(2000,800), left_margin = [5mm 0mm], leg=false, color=[Farben85[2]], alpha=0.6)
    ylabel!("Change in Average Annual Discharge [mm]")
    title!("Absolute Change in Average Annual Discharge in "*Catchment_Name)
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Discharge/"*Catchment_Name*"_Absolute_Change_Annual_Discharge.png")


    plot()
    boxplot!([rcps[1]], Total_Discharge_Past_45, size=(2000,800), leg=false, color=[Farben45[1]])
    boxplot!([rcps[2]], Total_Discharge_Future_45, size=(2000,800), left_margin = [5mm 0mm], leg=false, color=[Farben45[2]])
    violin!([rcps[1]], Total_Discharge_Past_45, size=(2000,800), leg=false, color=[Farben45[1]], alpha=0.6)
    violin!([rcps[2]], Total_Discharge_Future_45,size=(2000,800), left_margin = [5mm 0mm], leg=false, color=[Farben45[2]], alpha=0.6)
    ylabel!("Annual Discharge [mm]")
    title!("Annual Discharge over 30 years RCP 4.5 in "*Catchment_Name)
    #ylims!(20000, 35000)
    rcp45 = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Snow_Cover/rel_change_snow_storage.png")

    plot()
    boxplot!([rcps[1]], Total_Discharge_Past_85, size=(2000,800), leg=false, color=[Farben85[1]])
    boxplot!([rcps[2]], Total_Discharge_Future_85 ,size=(2000,800), left_margin = [5mm 0mm], leg=false, color=[Farben85[2]])
    violin!([rcps[1]], Total_Discharge_Past_85, size=(2000,800), leg=false, color=[Farben85[1]], alpha=0.6)
    violin!([rcps[2]], Total_Discharge_Future_85,size=(2000,800), left_margin = [5mm 0mm], leg=false, color=[Farben85[2]], alpha=0.6)
    ylabel!("Annual Discharge [mm]")
    title!("Annual Discharge over 30 years RCP 8.5 in "*Catchment_Name)
    #ylims!(20000, 35000)
    rcp85 = boxplot!()
    plot(rcp45, rcp85, size=(2000,800), left_margin = [5mm 0mm])
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Discharge/"*Catchment_Name*"_Annual_Discharge_Comparison_Future_Past.png")
end

#---------------- FDC --------------------------

findnearest(A::Array{Float64,1},t::Float64) = findmin(abs.(A-t*ones(length(A))))[2]

"""
Calculates the corresponding discharge of a certain percentile of the FDC for the past and the future.

$(SIGNATURES)

"""
function FDC_compare_percentile(path_to_projections, percentile, Name_Catchment)
    Name_Projections = readdir(path_to_projections)
    discharge_percentile_past = Float64[]
    discharge_percentile_future = Float64[]
    relative_change = Float64[]

    if path_to_projections[end-2:end-1] == "45"
        index = 1
        rcp = "45"
        print(rcp, " ", rcp)
    elseif path_to_projections[end-2:end-1] == "85"
        index = 2
        rcp="85"
        print(rcp, " ", rcp)
    end
    for (i, name) in enumerate(Name_Projections)
        Past_Discharge = readdlm(path_to_projections*name*"/"*Name_Catchment*"/300_model_results_discharge_past_2010.csv", ',')
        Future_Discharge = readdlm(path_to_projections*name*"/"*Name_Catchment*"/300_model_results_discharge_future_2100.csv", ',')
        # get FDCs from each discharge
        for run in 1: size(Past_Discharge)[1]
            # for each run get the Flow duration curves
            FDC_Past = flowdurationcurve(Past_Discharge[run,:])
            FDC_Future = flowdurationcurve(Future_Discharge[run,:])
            index_Past = findnearest(FDC_Past[2], percentile)
            index_Future = findnearest(FDC_Future[2], percentile)
            append!(discharge_percentile_past, FDC_Past[1][index_Past])
            append!(discharge_percentile_future, FDC_Future[1][index_Future])
        end
    end
    return discharge_percentile_past, discharge_percentile_future
end

"""
Plots the change of the corresponding discharge of a certain percentile of the FDC for the past and the future.

$(SIGNATURES)

"""
function plot_FDC_Percentile(path_to_projection_45, path_to_projection_85, Catchment_Name, percentile)
    # get data
    discharge_past_45, discharge_future_45= FDC_compare_percentile(path_to_projection_45, percentile, Catchment_Name)
    discharge_past_85, discharge_future_85= FDC_compare_percentile(path_to_projection_85, percentile, Catchment_Name)
    # plot change
    rcps = ["RCP 4.5", "RCP 8.5"]
    boxplot([rcps[1]], discharge_future_45 - discharge_past_45, color="blue", leg=false)
    boxplot!([rcps[2]], discharge_future_85 - discharge_past_85, color="red", size=(1000,600), leg=false)
    title!("Change in Discharge which is exceeded "*string(percentile*100)*"%")
    ylabel!("Discharge [m³/s]")
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/FDC/change_Discharge_"*string(percentile)*"_percentile.png")
    violin([rcps[1]], discharge_future_45 - discharge_past_45, color="blue", leg=false)
    violin!([rcps[2]], discharge_future_85 - discharge_past_85, color="red", size=(1000,600), leg=false)
    title!("Change in Discharge which is exceeded "*string(percentile*100)*"%")
    ylabel!("Discharge [m³/s]")
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/FDC/change_Discharge_"*string(percentile)*"_percentile_violin.png")

    #plot relative change
    error_45 = relative_error(discharge_future_45, discharge_past_45)
    error_85 = relative_error(discharge_future_85, discharge_past_85)
    # plot change
    rcps = ["RCP 4.5", "RCP 8.5"]
    boxplot([rcps[1]], error_45, color="blue", leg=false)
    boxplot!([rcps[2]], error_85, color="red", size=(1000,600), leg=false)
    title!("Relative Change in Discharge which is exceeded "*string(percentile*100)*"%")
    ylabel!("Discharge [m³/s]")
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/FDC/relative_change_Discharge_"*string(percentile)*"_percentile.png")
    violin([rcps[1]], error_45, color="blue", leg=false)
    violin!([rcps[2]], error_85, color="red", size=(1000,600), leg=false)
    title!("Relative Change in Discharge which is exceeded "*string(percentile*100)*"%")
    ylabel!("Discharge [m³/s]")
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/FDC/relative_change_Discharge_"*string(percentile)*"_percentile_violin.png")

    # plot real data
    Farben_85 = palette(:reds)
    Farben_45 = palette(:blues)
    boxplot([rcps[1]*" Past"], discharge_past_45, color=[Farben_45[1]], leg=false)
    boxplot!([rcps[1]*" Future"], discharge_future_45, color=[Farben_45[2]], leg=false)
    boxplot!([rcps[2]*" Past"],  discharge_past_85, color=[Farben_85[1]], size=(1000,600), leg=false)
    boxplot!([rcps[2]*" Future"], discharge_future_85, color=[Farben_85[2]], size=(1000,600), leg=false)
    title!("Discharge which is exceeded "*string(percentile*100)*"%")
    ylabel!("Discharge [m³/s]")
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/FDC/Discharge_"*string(percentile)*"_percentile.png")

    Farben_85 = palette(:reds)
    Farben_45 = palette(:blues)
    violin([rcps[1]*" Past"], discharge_past_45, color=[Farben_45[1]], leg=false)
    violin!([rcps[1]*" Future"], discharge_future_45, color=[Farben_45[2]], leg=false)
    violin!([rcps[2]*" Past"],  discharge_past_85, color=[Farben_85[1]], size=(1000,600), leg=false)
    violin!([rcps[2]*" Future"], discharge_future_85, color=[Farben_85[2]], size=(1000,600), leg=false)
    title!("Discharge which is exceeded "*string(percentile*100)*"%")
    ylabel!("Discharge [m³/s]")
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/FDC/Discharge_"*string(percentile)*"_percentile_violin.png")
end

"""
Calculates and plots the change of the corresponding discharge of a certain percentile of the FDC for the past and the future.

$(SIGNATURES)

As input a range of percentiles is needed
"""
function plot_FDC_Percentile_relative_change(path_to_projection_45, path_to_projection_85, Catchment_Name, percentiles)
    plot()
    for percentile in percentiles
        discharge_past_45, discharge_future_45= FDC_compare_percentile(path_to_projection_45, percentile, Catchment_Name)
        discharge_past_85, discharge_future_85= FDC_compare_percentile(path_to_projection_85, percentile, Catchment_Name)
        # plot change
        rcps = ["RCP 4.5", "RCP 8.5"]
        #plot relative change
        error_45 = relative_error(discharge_future_45, discharge_past_45)*100
        error_85 = relative_error(discharge_future_85, discharge_past_85)*100
    # plot change
        rcps = ["RCP 4.5", "RCP 8.5"]
        violin!( error_45, color="blue", leg=false)
        violin!(error_85, color="red", size=(2000,600), leg=false, left_margin = [5mm 0mm])
    end
    title!("Relative Change in Discharge which is exceeded for each percentile, RCP 4.5= Blue, RCP 8.5= Red")
    xticks!([1.5:2:17.5;], string.(percentiles))
    hline!([0], color=["grey"], linestyle = :dash)
    ylabel!("Realtive Change in Discharge [%]")
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/FDC/"*Catchment_Name*"_relative_change_Discharge__percentile_violin.png")
end

# ------------------- BUDYKO ------------------------------
"""
Calculates the aridity and evaporative index for all climate projections with best parameter sets for the given path.
For the calculations the mean discharge, potential evaporation and precipitation over the whole time period is taken.
$(SIGNATURES)
The function returns the past and future aridity index (Array length: Number of climate projections) and past and future evaporative index (Array Length: Number Climate Projections x Number Parameter Sets).
    It takes as input the path to the projections.
"""
function aridity_evaporative_index(path_to_projections, Area_Catchment, Catchment_Name)

    Name_Projections = readdir(path_to_projections)
    Timeseries_Past = collect(Date(1981,1,1):Day(1):Date(2010,12,31))
    Timeseries_End = readdlm("/home/sarah/Master/Thesis/Data/Projektionen/End_Timeseries_45_85.txt",',')
    Evaporative_Index_past_all_runs = Float64[] # will be 100x14
    Evaporative_Index_future_all_runs = Float64[] # will be 100x14
    Aridity_Index_past = Float64[] # will be 14 long
    Aridity_Index_future = Float64[] # will be 14 long
    Past_Precipitation_all_runs = Float64[]
    Future_Precipitation_all_runs = Float64[]
    if path_to_projections[end-2:end-1] == "45"
        index = 1
        rcp = "45"
        print(rcp, " ", rcp)
    elseif path_to_projections[end-2:end-1] == "85"
        index = 2
        rcp="85"
        print(rcp, " ", rcp)
    end
    for (i, name) in enumerate(Name_Projections)
        Timeseries_Future = collect(Date(Timeseries_End[i,index]-29,1,1):Day(1):Date(Timeseries_End[i,index],12,31))
        Past_Discharge = readdlm(path_to_projections*name*"/"*Catchment_Name*"/300_model_results_discharge_past_2010_without_loss.csv", ',')
        Future_Discharge = readdlm(path_to_projections*name*"/"*Catchment_Name*"/300_model_results_discharge_future_20100_without_loss.csv", ',')
        Past_Precipitation = readdlm(path_to_projections*name*"/"*Catchment_Name*"/results_precipitation_past_2010.csv", ',')
        Future_Precipitation = readdlm(path_to_projections*name*"/"*Catchment_Name*"/results_precipitation_future_2100.csv", ',')
        Past_Epot = readdlm(path_to_projections*name*"/"*Catchment_Name*"/results_epot_past_2010.csv", ',')
        Future_Epot = readdlm(path_to_projections*name*"/"*Catchment_Name*"/results_epot_future_2100.csv", ',')
        println("mean Epot", mean(Past_Epot))
        println("mean prec", mean(Past_Precipitation))
        Current_Aridity_Index_past = mean(Past_Epot) / mean(Past_Precipitation)
        Current_Aridity_Index_future = mean(Future_Epot) / mean(Future_Precipitation)
        append!(Aridity_Index_past, Current_Aridity_Index_past)
        append!(Aridity_Index_future, Current_Aridity_Index_future)
        append!(Past_Precipitation_all_runs, mean(Past_Precipitation))
        append!(Future_Precipitation_all_runs, mean(Future_Precipitation))
        println(size(Past_Discharge)[1])
        # if Catchment_Name == "Pitztal"
        #     Past_Discharge =
        for run in 1:size(Past_Discharge)[1]
            Evaporative_Index_past = 1 - mean(convertDischarge(Past_Discharge[run,:], Area_Catchment)) / mean(Past_Precipitation)
            Evaporative_Index_future = 1 - mean(convertDischarge(Future_Discharge[run,:], Area_Catchment))/ mean(Future_Precipitation)
            append!(Evaporative_Index_past_all_runs, Evaporative_Index_past)
            append!(Evaporative_Index_future_all_runs, Evaporative_Index_future)
        end
    end
    return Aridity_Index_past, Aridity_Index_future, Evaporative_Index_past_all_runs, Evaporative_Index_future_all_runs, Past_Precipitation_all_runs, Future_Precipitation_all_runs
end
"""
Plots the catchment in the Budyko framework (past and future for RCP 4.5 and RCP 8.5).

$(SIGNATURES)
The input are aridity and evaporative index of past and future for RCP 4.5 and RCP 8.5
"""
function plot_Budyko(Aridity_Index_past_45, Aridity_Index_future_45, Evaporative_Index_past_45, Evaporative_Index_future_45, Aridity_Index_past_85, Aridity_Index_future_85, Evaporative_Index_past_85, Evaporative_Index_future_85, path_to_projections, Catchment_Name, nr_runs)
    # plot the water and energy limit
    # aridity past and future each 14 elements
    # evaporative index each 1400 elements
    Name_Projections = readdir(path_to_projections)
    budyko_wrong45 = []
    budyko_wrong85 = []
    for proj in 1:14
        plot(collect(0:1),collect(0:1), color="darkblue", label="Energy Limit")
        plot!(collect(1:5), ones(5), color="lightblue", label="Water Limit")
        scatter!([Aridity_Index_past_45[proj], Aridity_Index_past_85[proj]], [mean(Evaporative_Index_past_45[1+(proj-1)*nr_runs: nr_runs*proj]), mean(Evaporative_Index_past_85[1+(proj-1)*100: 100*proj])], label="Past", color="black")
        scatter!([Aridity_Index_future_45[proj]], [mean(Evaporative_Index_future_45[1+(proj-1)*nr_runs: nr_runs*proj])], label = "RCP 4.5", color="blue")
        scatter!([Aridity_Index_future_85[proj]], [mean(Evaporative_Index_future_85[1+(proj-1)*nr_runs: nr_runs*proj])], label = "RCP 8.5", color="red")
        Epot_Prec = collect(0:0.1:5)
        Budyko_Eact_P = ( Epot_Prec .* tanh.(1 ./Epot_Prec) .* (ones(length(Epot_Prec)) - exp.(-Epot_Prec))).^0.5
        plot!(Epot_Prec, Budyko_Eact_P, label="Budyko", color="grey")
        xlabel!("Epot/P")
        ylabel!("Eact/P")
        vline!([0.406])
        #xlims!((0,1))
        ylims!((0,1))
        savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Budyko/"*Catchment_Name*"_budykoframework"*string(Name_Projections[proj])*".png")
        # difference_epot_eact = Aridity_Index_past_45[proj] .- Evaporative_Index_past_45[1+(proj-1)*nr_runs: nr_runs*proj]
        # difference_epot_eact85 = Aridity_Index_past_85[proj] .- Evaporative_Index_past_85[1+(proj-1)*nr_runs: nr_runs*proj]
        # append!(budyko_wrong45, findall(x->x <0, difference_epot_eact))
        # append!(budyko_wrong85, findall(x->x <0, difference_epot_eact85))

    end
    #return budyko_wrong45, budyko_wrong85
end


function circleShape(h,k,r)
    tau = LinRange(0, 2*pi, 500)
    h .+ r*sin.(tau), k .+ r*cos.(tau)
end
"""
Plots the changes in the Budyko framework of future and present for RCP 4.5 and 8.5.

$(SIGNATURES)
The input are the path to the projection and the size of the catchment in (m²)
"""
function plot_changes_Budyko(aridity_past45, aridity_future_45, evaporative_past_45, evaporative_future_45, aridity_past85, aridity_future_85, evaporative_past_85, evaporative_future_85, Area_Catchment, Catchment_Name, nr_runs)
    # aridity_past45, aridity_future_45, evaporative_past_45, evaporative_future_45 = aridity_evaporative_index(path_to_projections_45, Area_Catchment, Catchment_Name)
    # aridity_past85, aridity_future_85, evaporative_past_85, evaporative_future_85 = aridity_evaporative_index(path_to_projections_85, Area_Catchment, Catchment_Name)
    #plot aboslute changes in aridity index
    scatter(aridity_future_45 - aridity_past45, color="blue")
    scatter!(aridity_future_85 - aridity_past85, color="red")
    title!("Change in Aridity Index: Future - Past")
    ylabel!("Aridity Index (Epot/P)")
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Budyko/"*Catchment_Name*"_change_aridity.png")

    boxplot(aridity_future_45 - aridity_past45, color="blue")
    boxplot!(aridity_future_85 - aridity_past85, color="red")
    title!("Change in Aridity Index: Future - Past")
    ylabel!("Aridity Index (Epot/P)")
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Budyko/"*Catchment_Name*"_change_aridity_boxplot.png")

    violin(aridity_future_45 - aridity_past45, color="blue")
    violin!(aridity_future_85 - aridity_past85, color="red")
    title!("Change in Aridity Index: Future - Past")
    ylabel!("Aridity Index (Epot/P)")
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Budyko/"*Catchment_Name*"_change_aridity_violin.png")

    boxplot(["RCP 4.5"],evaporative_future_45 - evaporative_past_45, color="blue", legend=false)
    boxplot!(["RCP 8.5"],evaporative_future_85 - evaporative_past_85, color="red", legend=false)
    title!("Change in Evaporative Index: Future - Past")
    ylabel!("Evaporative Index (Eact/P)")
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Budyko/"*Catchment_Name*"_change_evaporative.png")

    violin(["RCP 4.5"],evaporative_future_45 - evaporative_past_45, color="blue", legend=false)
    violin!(["RCP 8.5"],evaporative_future_85 - evaporative_past_85, color="red", legend=false)
    title!("Change in Evaporative Index: Future - Past")
    ylabel!("Evaporative Index (Eact/P)")
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Budyko/"*Catchment_Name*"_change_evaporative_violin.png")

    # plot changes in Budyko space
    plot(circleShape(0,0,0.05), lw=0.5, c= :grey, linecolor = :grey, legend=false, apsect_ratio = 1, size=(500,500))
    plot!(circleShape(0,0,0.1), lw=0.5, c= :grey, linecolor = :grey, legend=false, apsect_ratio = 1, size=(500,500))
    plot!(circleShape(0,0,0.15), lw=0.5, c= :grey, linecolor = :grey, legend=false, apsect_ratio = 1, size=(500,500))
    plot!(circleShape(0,0,0.2), lw=0.5, c= :grey, linecolor = :grey, legend=false, apsect_ratio = 1, size=(500,500))
    plot!(circleShape(0,0,0.25), lw=0.5, c= :grey, linecolor = :grey, legend=false, apsect_ratio = 1, size=(500,500))
    plot!(circleShape(0,0,0.3), lw=0.5, c= :grey, linecolor = :grey, legend=false, apsect_ratio = 1, size=(500,500))
    for proj in 1:14
        change_vector_x = ones(nr_runs) * (aridity_future_45[proj] - aridity_past45[proj])
        change_vector_y = evaporative_future_45[1+(proj-1)*nr_runs: nr_runs*proj] - evaporative_past_45[1+(proj-1)*nr_runs: nr_runs*proj]
        for i in 1:nr_runs
            plot!([0, change_vector_x[i]], [0, change_vector_y[i]], color = "blue", legend=false)
        end
    end
    title!("RCP 4.5")
    xlabel!("change in Epot/P")
    ylabel!("change in Eact/P")
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/Budyko/change_budyko4.5.png")
    rcp45 = plot!()

    plot(circleShape(0,0,0.05), lw=0.5, c= :grey, linecolor = :grey, legend=false, apsect_ratio = 1, size=(500,500))
    plot!(circleShape(0,0,0.1), lw=0.5, c= :grey, linecolor = :grey, legend=false, apsect_ratio = 1, size=(500,500))
    plot!(circleShape(0,0,0.15), lw=0.5, c= :grey, linecolor = :grey, legend=false, apsect_ratio = 1, size=(500,500))
    plot!(circleShape(0,0,0.2), lw=0.5, c= :grey, linecolor = :grey, legend=false, apsect_ratio = 1, size=(500,500))
    plot!(circleShape(0,0,0.25), lw=0.5, c= :grey, linecolor = :grey, legend=false, apsect_ratio = 1, size=(500,500))
    plot!(circleShape(0,0,0.3), lw=0.5, c= :grey, linecolor = :grey, legend=false, apsect_ratio = 1, size=(500,500))
    for proj in 1:14
        change_vector_x = ones(nr_runs) * (aridity_future_85[proj] - aridity_past85[proj])
        change_vector_y = evaporative_future_85[1+(proj-1)*nr_runs: nr_runs*proj] - evaporative_past_85[1+(proj-1)*nr_runs: nr_runs*proj]
        for i in 1:nr_runs
            plot!([0, change_vector_x[i]], [0, change_vector_y[i]], color = "red", legend=false)
        end
    end
    title!("RCP 8.5")
    xlabel!("change in Epot/P")
    ylabel!("change in Eact/P")
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/Budyko/change_budyko8.5.png")
    rcp85 = plot!()
    plot(rcp45, rcp85, size=(1200,600))
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Budyko/"*Catchment_Name*"_change_budyko4.5_8.5.png")
end
