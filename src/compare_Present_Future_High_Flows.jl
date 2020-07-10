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
relative_error(future, initial) = (future - initial) ./ initial
# ---------------------------------- ANNUAL MAXIMUM DISCHARGE --------------------------------
function circleShape(h,k,r)
    tau = LinRange(0, 2*pi, 500)
    h .+ r*sin.(tau), k .+ r*cos.(tau)
end

function AMF_circular_plot(Timing::Array{Float64,1}, Magnitude::Array{Float64,1},Timeseries, Catchment_Name)
    @assert length(Timing) == length(Magnitude)
    Years = collect(Dates.year(Timeseries[1]): Dates.year(Timeseries[end]))
    Nr_Days_Year = Dates.daysinyear.(Years)
    plot()
    for (i, current_timing) in enumerate(Timing)
        theta = current_timing * 2 * pi / Nr_Days_Year[i]
        x_vector = sin(theta) * Magnitude[i]
        y_vector = cos(theta) * Magnitude[i]
        plot!([0,x_vector], [0, y_vector])
        plot!(circleShape(0,0,Magnitude[i]), lw=0.5, c= :grey, linecolor = :grey, legend=false, apsect_ratio = 1, size=(500,500))
    end
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/Circular/test.png")
end



"""
Computes the date and magnitude of the yearly maximum discharge using calender year.

$(SIGNATURES)

The function returns the maginutde and Date as day of year of the maximum annual discharge.
    As input a discharge series and the corresponding timeseries is needed.
"""
function max_Annual_Discharge(Discharge, Timeseries)
    Years = collect(Dates.year(Timeseries[1]): Dates.year(Timeseries[end]))
    max_Annual_Discharge = Float64[]
    Date_max_Annual_Discharge = Float64[]
    for (i, Current_Year) in enumerate(Years)
            Dates_Current_Year = filter(Timeseries) do x
                              Dates.Year(x) == Dates.Year(Current_Year)
                          end
            max_Discharge = maximum(Discharge[indexin(Dates_Current_Year, Timeseries)])

            #Date_Max_Discharge = Timeseries[findfirst(x->x == max_Discharge, Discharge)]
            append!(max_Annual_Discharge, max_Discharge)
            append!(Date_max_Annual_Discharge, Dates.dayofyear(Dates_Current_Year[argmax(Discharge[indexin(Dates_Current_Year, Timeseries)])]))
    end
    return max_Annual_Discharge, Date_max_Annual_Discharge
end

"""
Computes the magnitude and timing of the yearly maximum discharge on 7 consecutive days using calender year.

$(SIGNATURES)

The function returns the magnitude and Date as day of year of the first of 7 days of maximum annual discharge.
    As input a discharge series and the corresponding timeseries is needed.
"""
function max_Annual_Discharge_7days(Discharge, Timeseries)
    days = 7
    Years = collect(Dates.year(Timeseries[1]): Dates.year(Timeseries[end]))
    max_Annual_Discharge = Float64[]
    Date_max_Annual_Discharge = Float64[]
    for (i, Current_Year) in enumerate(Years)
            Dates_Current_Year = filter(Timeseries) do x
                              Dates.Year(x) == Dates.Year(Current_Year)
                          end
            Current_Discharge = Discharge[indexin(Dates_Current_Year, Timeseries)]

            All_Discharges_7days = Float64[]
            for week in 1: length(Current_Discharge) - days
                Current_Discharge_7days = mean(Current_Discharge[week: week+days])
                append!(All_Discharges_7days, Current_Discharge_7days)
            end
            #Date_Max_Discharge = Timeseries[findfirst(x->x == max_Discharge, Discharge)]
            append!(max_Annual_Discharge, maximum(All_Discharges_7days))
            append!(Date_max_Annual_Discharge, Dates.dayofyear(Dates_Current_Year[argmax(All_Discharges_7days)]))
    end
    return max_Annual_Discharge, Date_max_Annual_Discharge
end

"""
Computes the average timing of maximum annual discharges of a multiyear timeseries using circular statistics.

$(SIGNATURES)

The function returns the mean timing of the annual maximum discharge as well as the concentration of the date of occurrence around the average date.
    (Concentration = 1, all events occur on the same day, concentration = 0, events are widely spread)
"""
function average_timing(Dates_Max_Annual_Discharge, Timeseries)
    Years = collect(Dates.year(Timeseries[1]): Dates.year(Timeseries[end]))
    @assert length(Dates_Max_Annual_Discharge) ==  length(Years)
    Days_In_Year = Float64[]
    Formula_x = Float64[]
    Formula_y = Float64[]
    for (i, current_year) in enumerate(Years)
        Current_Circular_Date = Dates_Max_Annual_Discharge[i] * 2 * pi / Dates.daysinyear(current_year)
        x = cos(Current_Circular_Date)
        y = sin(Current_Circular_Date)
        append!(Days_In_Year, Dates.daysinyear(current_year))
        append!(Formula_x, x)
        append!(Formula_y, y)
    end
    mean_x = mean(Formula_x)
    mean_y = mean(Formula_y)
    mean_DaysinYear = mean(Days_In_Year)

    if mean_x > 0 && mean_y >= 0
        Mean_Timing = atan(mean_y / mean_x) * mean_DaysinYear / (2*pi)
    elseif mean_x <= 0
        Mean_Timing = (atan(mean_y / mean_x) + pi) * mean_DaysinYear / (2*pi)
    else
        Mean_Timing = (atan(mean_y / mean_x) + 2*pi) * mean_DaysinYear / (2*pi)
    end
    concentration_floods = sqrt(mean_x^2 + mean_y^2)
    #print(mean_DaysinYear, "\n")
    #Day_Mean_Timing = Mean_Timing * ()

    return Mean_Timing, concentration_floods
end

"""
Converts the timing of circular statiscs back to days and calculates the differences in days of occurence between past and future.

$(SIGNATURES)

The function returns and array with the shift in occurences. As input an array with timing of AMF in past and future is needed.
"""
function difference_timing(Timing_Past, Timing_Future)
    Timing_Past = Timing_Past .* (2*pi) ./ 365.23333
    Timing_Future = Timing_Future .* (2*pi) ./ 365.23333
    Difference = Timing_Future - Timing_Past
    for (i,current_Difference) in enumerate(Difference)
        if current_Difference > pi
            Difference[i] = 2*pi - current_Difference
        elseif current_Difference < -pi
            Difference[i] = -(2*pi + current_Difference)
        end
    end
    return Difference .* (365.23333/(2*pi))
end

"""
Computes the average timing and magnitude of AMF for all projections for past and future.

$(SIGNATURES)

The function returns the mean timing of the mean magnitude of past and future timeseries, the mean timing of past and future
    and the concentraton of timing in past and future.

"""
function change_max_Annual_Discharge(path_to_projections, Catchment_Name)
    Name_Projections_45 = readdir(path_to_projections)
    Timeseries_Past = collect(Date(1981,1,1):Day(1):Date(2010,12,31))
    Timeseries_End = readdlm("/home/sarah/Master/Thesis/Data/Projektionen/End_Timeseries_45_85.txt",',')
    change_all_runs = Float64[]
    average_max_Discharge_past = Float64[]
    average_max_Discharge_future = Float64[]
    Timing_max_Discharge_past = Float64[]
    Timing_max_Discharge_future = Float64[]
    All_Concentration_past = Float64[]
    All_Concentration_future = Float64[]
    if path_to_projections[end-2:end-1] == "45"
        index = 1
        rcp = "45"
        print(rcp, " ", rcp)
    elseif path_to_projections[end-2:end-1] == "85"
        index = 2
        rcp="85"
        print(rcp, " ", rcp)
    end
    for (i, name) in enumerate(Name_Projections_45)
        Timeseries_Future = collect(Date(Timeseries_End[i,index]-29,1,1):Day(1):Date(Timeseries_End[i,index],12,31))
        Past_Discharge = readdlm(path_to_projections*name*"/"*Catchment_Name*"/100_model_results_discharge_past_2010.csv", ',')
        Future_Discharge = readdlm(path_to_projections*name*"/"*Catchment_Name*"/100_model_results_discharge_future_2100.csv", ',')
        #change_all_runs = Float64[]
        for run in 1:100
            max_Discharge_past, Date_max_Discharge_past = max_Annual_Discharge(Past_Discharge[run,:], Timeseries_Past)
            max_Discharge_future, Date_max_Discharge_future = max_Annual_Discharge(Future_Discharge[run,:], Timeseries_Future)
            append!(average_max_Discharge_past, mean(max_Discharge_past))
            append!(average_max_Discharge_future, mean(max_Discharge_future))
            timing_average_max_Discharge_past, Concentration_past = average_timing(Date_max_Discharge_past, Timeseries_Past)
            timing_average_max_Discharge_future, Concentration_future = average_timing(Date_max_Discharge_future, Timeseries_Past)
            #Date_max_Discharge_past = mean(Date_max_Discharge_past)
            #Date_max_Discharge_future = mean(Date_max_Discharge_future)
            #error = relative_error(max_Discharge_future, max_Discharge_past)
            #error_timing = Date_max_Discharge_future - Date_max_Discharge_past)
            #append!(change_all_runs, error)
            append!(Timing_max_Discharge_past, timing_average_max_Discharge_past)
            append!(Timing_max_Discharge_future, timing_average_max_Discharge_future)
            append!(All_Concentration_past, Concentration_past)
            append!(All_Concentration_future, Concentration_future)
        end
    end
    # scatter([Timing_max_Discharge_past, Timing_max_Discharge_future], label=["blue", "red"])
    # savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/Annual_Max_Discharge/timing_85.png")
    return average_max_Discharge_past, average_max_Discharge_future, Timing_max_Discharge_past, Timing_max_Discharge_future, All_Concentration_past, All_Concentration_future
end

"""
Computes the timing and magnitude of AMF for all projections for past and future for all years using a probability distribution.

$(SIGNATURES)

The function returns the mean timing of the mean magnitude of past and future timeseries, the mean timing of past and future
    and the concentraton of timing in past and future.

"""
function change_max_Annual_Discharge_Prob_Distribution(path_to_projections, Catchment_Name)
    Name_Projections_45 = readdir(path_to_projections)
    Timeseries_Past = collect(Date(1981,1,1):Day(1):Date(2010,12,31))
    Timeseries_End = readdlm("/home/sarah/Master/Thesis/Data/Projektionen/End_Timeseries_45_85.txt",',')
    change_all_runs = Float64[]
    average_max_Discharge_past = Float64[]
    average_max_Discharge_future = Float64[]
    Exceedance_Probability = Float64[]
    Timing_max_Discharge_past = Float64[]
    Timing_max_Discharge_future = Float64[]
    All_Concentration_past = Float64[]
    All_Concentration_future = Float64[]
    Date_Past = Float64[]
    Date_Future = Float64[]
    if path_to_projections[end-2:end-1] == "45"
        index = 1
        rcp = "45"
        print(rcp, " ", rcp)
    elseif path_to_projections[end-2:end-1] == "85"
        index = 2
        rcp="85"
        print(rcp, " ", rcp)
    end
    for (i, name) in enumerate(Name_Projections_45)
        Timeseries_Future = collect(Date(Timeseries_End[i,index]-29,1,1):Day(1):Date(Timeseries_End[i,index],12,31))
        Past_Discharge = readdlm(path_to_projections*name*"/"*Catchment_Name*"/100_model_results_discharge_past_2010.csv", ',')
        Future_Discharge = readdlm(path_to_projections*name*"/"*Catchment_Name*"/100_model_results_discharge_future_2100.csv", ',')
        #change_all_runs = Float64[]
        for run in 1:100
            max_Discharge_past, Date_max_Discharge_past = max_Annual_Discharge(Past_Discharge[run,:], Timeseries_Past)
            max_Discharge_future, Date_max_Discharge_future = max_Annual_Discharge(Future_Discharge[run,:], Timeseries_Future)
            # don't take mean of thirty years but probability distirbution
            #max_Discharge_past_sorted, Prob_Dis_past = flowdurationcurve(max_Discharge_past)
            #max_Discharge_future_sorted, Prob_Dis_future = flowdurationcurve(max_Discharge_future)
            #@assert Prob_Dis_past == Prob_Dis_future
            append!(average_max_Discharge_past, max_Discharge_past)
            append!(average_max_Discharge_future, max_Discharge_future)
            #append!(Exceedance_Probability, Prob_Dis_past)
            append!(Date_Past, Date_max_Discharge_past)
            append!(Date_Future, Date_max_Discharge_future)
            # timing_average_max_Discharge_past, Concentration_past = average_timing(Date_max_Discharge_past, Timeseries_Past)
            # timing_average_max_Discharge_future, Concentration_future = average_timing(Date_max_Discharge_future, Timeseries_Past)
            # #Date_max_Discharge_past = mean(Date_max_Discharge_past)
            # #Date_max_Discharge_future = mean(Date_max_Discharge_future)
            # #error = relative_error(max_Discharge_future, max_Discharge_past)
            # #error_timing = Date_max_Discharge_future - Date_max_Discharge_past)
            # #append!(change_all_runs, error)
            # append!(Timing_max_Discharge_past, timing_average_max_Discharge_past)
            # append!(Timing_max_Discharge_future, timing_average_max_Discharge_future)
            # append!(All_Concentration_past, Concentration_past)
            # append!(All_Concentration_future, Concentration_future)
        end
    end
    # scatter([Timing_max_Discharge_past, Timing_max_Discharge_future], label=["blue", "red"])
    # savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/Annual_Max_Discharge/timing_85.png")
    return average_max_Discharge_past, average_max_Discharge_future, Exceedance_Probability, Date_Past, Date_Future #,Timing_max_Discharge_past, Timing_max_Discharge_future, All_Concentration_past, All_Concentration_future
end


function plot_Max_Flows_new(Max_Flows_past45, Max_Flows_future45, Max_Flows_past85, Max_Flows_future85, Timing_Max_Flows_past45, Timing_Max_Flows_future45,  Timing_Max_Flows_past85, Timing_Max_Flows_future85, Catchment_Name)
    Farben45=palette(:blues)
    Farben85=palette(:reds)
    # plot lows of each projection
    # for proj in 1:14
    #     boxplot(Max_Flows_past45[1+(proj-1)*100: proj*100], color=[Farben45[1]])
    #     boxplot!(Max_Flows_future45[1+(proj-1)*100: proj*100],color=[Farben45[2]])
    #     boxplot!(Max_Flows_past85[1+(proj-1)*100: proj*100], color=[Farben85[1]])
    #     boxplot!(Max_Flows_future85[1+(proj-1)*100: proj*100], size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    #     xticks!([1:4;], ["Past 4.5", "Future 4.5", "Past 8.5", "Future 8.5"])
    #     ylabel!("mean annual maximum daily Discharge [m³/s]")
    #     ylims!((40,100))
    #     title!("Annual Maximum Discharge")
    #     savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/7days/max_yearly_discharge_"*string(Name_Projections_45[proj])*".png")
    # end
    # plot flows of all projections combined
    boxplot(Max_Flows_past45, color=[Farben45[1]])
    boxplot!(Max_Flows_future45,color=[Farben45[2]])
    #boxplot!(Max_Flows_past85, color=[Farben85[1]])
    boxplot!(Max_Flows_future85, size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    xticks!([1:4;], ["Past", "Future 4.5", "Future 8.5"])
    ylabel!("Mean annual maximum yearly Discharge [m³/s]")
    #ylims!((40,100))
    title!("Annual Maximum Discharge")
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/max_yearly_discharge_new.png")
    print("test")

    # #absolute and relative decrease
    # boxplot(Max_Flows_future45 - Max_Flows_past45,color=[Farben45[2]])
    # #boxplot!(, color=[Farben85[1]])
    # boxplot!(Max_Flows_future85 - Max_Flows_past85, size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    # xticks!([1:2;], ["RCP 4.5", "RCP 8.5"])
    # ylabel!("absolute change [m³/s]")
    # #title!("Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov (Future - Present)")
    # absolute_change = boxplot!()
    # # relative change
    # boxplot(relative_error(Max_Flows_future45, Max_Flows_past45)*100,color=[Farben45[2]])
    # #boxplot!(, color=[Farben85[1]])
    # boxplot!(relative_error(Max_Flows_future85, Max_Flows_past85)*100, size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    # xticks!([1:2;], ["RCP 4.5", "RCP 8.5"])
    # ylabel!("relative change [%]")
    # #title!("Relative Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov (Future - Present)")
    # relative_change = boxplot!()
    #
    #
    # #PyPlot.suptitle("Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov")
    # plot(absolute_change, relative_change)
    # savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/change_max_yearly_discharge.png")

    violin(Max_Flows_future45 - Max_Flows_past45,color=[Farben45[2]])
    #boxplot!(, color=[Farben85[1]])
    violin!(Max_Flows_future85 - Max_Flows_past85, size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    xticks!([1:2;], ["RCP 4.5", "RCP 8.5"])
    ylabel!("absolute change [m³/s]")
    #title!("Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov (Future - Present)")
    absolute_change = boxplot!()
    # relative change
    violin(relative_error(Max_Flows_future45, Max_Flows_past45)*100,color=[Farben45[2]])
    #boxplot!(, color=[Farben85[1]])
    violin!(relative_error(Max_Flows_future85, Max_Flows_past85)*100, size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    xticks!([1:2;], ["RCP 4.5", "RCP 8.5"])
    ylabel!("relative change [%]")
    #title!("Relative Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov (Future - Present)")
    relative_change = boxplot!()


    #PyPlot.suptitle("Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov")
    plot(absolute_change, relative_change)
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/change_max_yearly_discharge_violin_new.png")

    # ----------------- TIMING -----------------
    # plot timing of seasonal low flows of all projections combined

    boxplot(Timing_Max_Flows_past45, color=[Farben45[1]])
    boxplot!(Timing_Max_Flows_future45,color=[Farben45[2]])
    #boxplot!(Timing_Max_Flows_past85, color=[Farben85[1]])
    boxplot!(Timing_Max_Flows_future85, size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    xticks!([1:4;], ["Past", "Future 4.5", "Future 8.5"])
    ylabel!("Timing of Maximum Discharge")
    #ylims!((2,10))
    yticks!([1,32,60,91,121,152,182,213,244,274,305,335], ["1.1", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7","1.8", "1.9", "1.10", "1.11", "1.12"])
    title!("Timing of Maximum Discharge")
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/timing_max_yearly_discharge_new.png")

    # plot timing of seasonal low flows of each projection
    # for proj in 1:14
    #     boxplot(Timing_Max_Flows_past45[1+(proj-1)*100: proj*100], color=[Farben45[1]])
    #     boxplot!(Timing_Max_Flows_future45[1+(proj-1)*100: proj*100],color=[Farben45[2]])
    #     boxplot!(Timing_Max_Flows_past85[1+(proj-1)*100: proj*100], color=[Farben85[1]])
    #     boxplot!(Timing_Max_Flows_future85[1+(proj-1)*100: proj*100], size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    #     xticks!([1:4;], ["Past 4.5", "Future 4.5", "Past 8.5", "Future 8.5"])
    #     ylabel!("Timing of Maximum Discharge")
    #     yticks!([1,32,60,91,121,152,182,213,244,274,305,335], ["1.1", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7","1.8", "1.9", "1.10", "1.11", "1.12"])
    #     title!("Timing of Maximum Discharge")
    #     savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/7days/timing_max_yearly_discharge_"*string(Name_Projections_45[proj])*".png")
    # end
    #
    # #absolute and relative change in timing of low flows
    # #   dates have to be transformed to circular coordinates
    # Difference_Timing_45 = difference_timing(Timing_Max_Flows_past45, Timing_Max_Flows_future45)
    # Difference_Timing_85 = difference_timing(Timing_Max_Flows_past85, Timing_Max_Flows_future85)
    # boxplot(Difference_Timing_45,color=[Farben45[2]])
    # #boxplot!(, color=[Farben85[1]])
    # boxplot!(Difference_Timing_85, size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    # xticks!([1:2;], ["RCP 4.5", "RCP 8.5"])
    # ylabel!("absolute change [days]")
    # #title!("Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov (Future - Present)")
    # absolute_change = boxplot!()
    # # relative change
    # # boxplot(relative_error(Timing_Max_Flows_future45, Timing_Max_Flows_past45),color=[Farben45[2]])
    # # #boxplot!(, color=[Farben85[1]])
    # # boxplot!(relative_error(Timing_Max_Flows_future85, Timing_Max_Flows_past85), size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    # # xticks!([1:2;], ["RCP 4.5", "RCP 8.5"])
    # # ylabel!("relative change [%]")
    # # #title!("Relative Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov (Future - Present)")
    # # relative_change = boxplot!()
    #
    #
    # #PyPlot.suptitle("Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov")
    # plot(absolute_change)
    # savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/7days/change_timing_max_yearly_discharge.png")
    #
    # violin(Difference_Timing_45,color=[Farben45[2]])
    # #boxplot!(, color=[Farben85[1]])
    # violin!(Difference_Timing_85, size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    # xticks!([1:2;], ["RCP 4.5", "RCP 8.5"])
    # ylabel!("absolute change [days]")
    # #title!("Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov (Future - Present)")
    # absolute_change = boxplot!()
    # plot(absolute_change)
    # savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/7days/change_timing_max_yearly_discharge_violin.png")
    # # #PyPlot.suptitle("Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov")
    # plot(absolute_change, relative_change)
    # savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/LowFlows/change_timing_summerlowflows_violins.png")
end

function plot_Max_Flows_Prob_Distribution(Max_Flows_past45, Max_Flows_future45, Max_Flows_past85, Max_Flows_future85, Exceedance_Probability, Catchment_Name)
    plot()
    Farben45=palette(:blues)
    Farben85=palette(:reds)
    for exceedance in collect(5:5:30)
        index = findall(x->x == Exceedance_Probability[exceedance], Exceedance_Probability)
        boxplot!(relative_error(Max_Flows_future45[index], Max_Flows_past45[index])*100,color=[Farben45[2]])
        #boxplot!(, color=[Farben85[1]])
        boxplot!(relative_error(Max_Flows_future85[index], Max_Flows_past85[index])*100, size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    end
    xticks!([1.5:2:11.5;], ["5 years", "10 years", "15 years", "20 years", "25 years", "30 years"])
    ylabel!("relative change in discharge [%]")
    title!("Relative Change in Maximum Annual Discharge which is exceeded in x years")
    xlabel!("Years in 30 years")
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/probability_Dsitribution_relative_Change.png")
    plot()
    for exceedance in collect(5:5:30)
        index = findall(x->x == Exceedance_Probability[exceedance], Exceedance_Probability)
        change = relative_error(Max_Flows_future45[index], Max_Flows_past45[index])*100
        print(mean(change), " ", maximum(change), " ", minimum(change), "\n")
        violin!(relative_error(Max_Flows_future45[index], Max_Flows_past45[index])*100,color=[Farben45[2]])
        #boxplot!(, color=[Farben85[1]])
        violin!(relative_error(Max_Flows_future85[index], Max_Flows_past85[index])*100, size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    end
    xticks!([1.5:2:11.5;], ["5 years", "10 years", "15 years", "20 years", "25 years", "30 years"])
    ylabel!("relative change in discharge [%]")
    xlabel!("Years in 30 years")
    ylims!(-50,150)
    title!("Relative Change in Maximum Annual Discharge which is exceeded in x years of the 30 year period")
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/probability_Dsitribution_relative_Change_violin.png")

    plot()
    mean_change = Float64[]
    max_change = Float64[]
    min_change = Float64[]
    mean_change_85 = Float64[]
    max_change_85 = Float64[]
    min_change_85 = Float64[]
    for exceedance in Exceedance_Probability[1:30]
        index = findall(x->x == exceedance, Exceedance_Probability)
        change_45 = relative_error(Max_Flows_future45[index], Max_Flows_past45[index])*100
        change_85 = relative_error(Max_Flows_future85[index], Max_Flows_past85[index])*100
        append!(mean_change, mean(change_45))
        append!(max_change, maximum(change_45))
        append!(min_change, minimum(change_45))
        append!(mean_change_85, mean(change_85))
        append!(max_change_85, maximum(change_85))
        append!(min_change_85, minimum(change_85))
        #boxplot!(, color=[Farben85[1]])
        #violin!(relative_error(Max_Flows_future85[index], Max_Flows_past85[index])*100, size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    end
    plot(collect(1:30), mean_change, color=[Farben45[2]], label="RCP 4.5", ribbon = (mean_change - min_change, max_change - mean_change))
    plot!(collect(1:30), mean_change_85, color=[Farben85[2]], label="RCP 8.5", ribbon = (mean_change_85 - min_change_85, max_change_85 - mean_change_85), size=(1600,800))
    #xticks!([1.5:2:11.5;], ["5 years", "10 years", "15 years", "20 years", "25 years", "30 years"])
    ylabel!("relative change in discharge [%]")
    ylims!(-50,150)
    xlabel!("Years in 30 years")
    title!("Relative Change in Maximum Annual Discharge which is exceeded in x years of the 30 year period")
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/probability_Dsitribution_relative_Change_new.png")
    # plot differences between past and future
    return mean_change, min_change, max_change

end

#max_Discharge_Past_45, Max_Discharge_Future_45, Exceedance_Prob_45, Date_Past, Date_Future =  change_max_Annual_Discharge_Prob_Distribution(path_45)
"""
For each timeseries it calculates the number of times the maximum annual discharge occurs within a timerange (e.g. 15days)

$(SIGNATURES)

The function returns probability of occurence of AMF within a certain timerange of the year, and an array of this timerange
"""
function get_distributed_dates(Date_Past, Timerange)
    nr_yearly_max_period_15_days = Float64[]
    day_range = Float64[]
    for i in 1:1400
        Current_Date_Past = Date_Past[1+(i-1)*30:30*i]
        for days in 1:Timerange:366
            current_days = filter(Current_Date_Past) do x
                x >= days && x < days +Timerange
            end
            append!(day_range, days-1)
            if current_days == Float64[]
                append!(nr_yearly_max_period_15_days, 0)
            else
                append!(nr_yearly_max_period_15_days, length(current_days)/30)
            end
        end
    end
    return nr_yearly_max_period_15_days, day_range
end

function plot_change_timing_AMF_over_year(Date_Past, Date_Future, Timerange)
    period_15_days_past, day_range_past = get_distributed_dates(Date_Past_85)
    period_15_days_future, day_range_future = get_distributed_dates(Date_Future_85)
    #change = period_15_days_future - period_15_days_past
    plot()
    Catchment_Name = "Gailtal"
    for i in collect(0:15:366)
        current_past = period_15_days_past[findall(x->x==i, day_range_future)]
        current_future = period_15_days_future[findall(x->x==i, day_range_future)]
        boxplot!(current_past*100, leg=false, size=(1500,800), color="blue")
        boxplot!(current_future*100, leg=false, size=(1500,800), color="red", left_margin = [5mm 0mm], bottom_margin = 20px, xrotation = 60)
    end
    ylabel!("Probability of Occurence in Timeseries [%]")
    xlabel!("15 days timesteps in year")
    title!("Timing of Maximum Annual Discharge,Blue=Past Red=Future")
    xticks!([1.5:2:48.5;],["Begin Jan", "End Jan", "Begin Feb", "End Feb", "Begin Mar", "End Mar", "Begin Apr", "End Apr", "Begin May", "End May", "Begin June", "End June","Begin Jul", "End Jul", "Begin Aug", "Eng Aug", "Begin Sep", "End Sep", "Begin Oct", "End Oct", "Begin Nov", "End Nov", "Begin Dec", "End Dec"])
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/probability_Dsitribution_timing_85.png")
end
#max_Discharge_Past_45, Max_Discharge_Future_45, Exceedance_Probability_45, Date_Past_45, Date_Future_45 =  change_max_Annual_Discharge_Prob_Distribution(path_45, "Gailtal")
#plot_Max_Flows_new(max_Discharge_past_45, max_Discharge_future_45, max_Discharge_past_85, max_Discharge_future_85, Timing_max_Discharge_past_45, Timing_max_Discharge_future_45, Timing_max_Discharge_past_85, Timing_max_Discharge_future_85, "Gailtal")

#mean_change, min_change, max_change = plot_Max_Flows_Prob_Distribution(max_Discharge_Past_45, Max_Discharge_Future_45, max_Discharge_Past_85, Max_Discharge_Future_85, Exceedance_Prob_45, "Gailtal")

#changes = change_max_Annual_Discharge(path_45)
#changes85, timing_changes85_future, timing_changes85_past = change_max_Annual_Discharge(path_85)

# scatter([timing_changes85_past, timing_changes85_future], label=["past" "future"], size=(1200,800))
# ylabel!("Day of Year")
# title!("RCP 8.5")
# savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/Annual_Max_Discharge/Timing85.png")

max_Discharge_past_45, max_Discharge_future_45, Timing_max_Discharge_past_45, Timing_max_Discharge_future_45, All_Concentration_past_45, All_Concentration_future_45 = change_max_Annual_Discharge(path_45, "Gailtal")
