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

findnearest(A::Array{Float64,1},t::Float64) = findmin(abs.(A-t*ones(length(A))))[2]
relative_error(future, initial) = (future - initial) ./ initial
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
    Timing_Seasonal_Low_Flows_7days = Float64[]
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
            Current_Discharge = Discharge[indexin(Dates_Current_Season, Timeseries)]
            #print(Current_Year, " ", Current_Month)
            #print(Dates.daysinmonth(Current_Year, Current_Month))
            All_Discharges_7days = Float64[]
            for week in 1: length(Current_Discharge) - days
                Current_Discharge_7days = mean(Current_Discharge[week: week+days])
                append!(All_Discharges_7days, Current_Discharge_7days)
            end
            append!(Seasonal_Low_Flows_7days, minimum(All_Discharges_7days))
            append!(Timing_Seasonal_Low_Flows_7days, Dates.dayofyear(Dates_Current_Season[argmin(All_Discharges_7days)]))
    end
    return Seasonal_Low_Flows_7days, Timing_Seasonal_Low_Flows_7days
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
    average_Low_Flows_past_Timing = Float64[]
    average_Low_Flows_future_Timing = Float64[]
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
            Seasonal_Low_Flows_Past, Timing_Seasonal_Low_Flows_Past = seasonal_low_flows(Past_Discharge_45[run,:], Timeseries_Past, Months_Low_Flow_Summer, 7)
            Seasonal_Low_Flows_Future, Timing_Seasonal_Low_Flows_Future = seasonal_low_flows(Future_Discharge_45[run,:], Timeseries_Future_45,Months_Low_Flow_Summer, 7)
            append!(average_Low_Flows_past, mean(Seasonal_Low_Flows_Past))
            append!(average_Low_Flows_future, mean(Seasonal_Low_Flows_Future))
            append!(average_Low_Flows_past_Timing, mean(Timing_Seasonal_Low_Flows_Past))
            append!(average_Low_Flows_future_Timing, mean(Timing_Seasonal_Low_Flows_Future))
        end
    end
    return average_Low_Flows_past, average_Low_Flows_future, average_Low_Flows_past_Timing, average_Low_Flows_future_Timing
end
# @time begin
#Summer_Low_Flows_past85, Summer_Low_Flows_future85, Timing_Summer_Low_Flows_Past_85, Timing_Summer_Low_Flows_Future_85 = analyse_low_flows(path_85, [5,6,7,8,9,10])
# end

# --------- TOTAL LOW FLOWS PLOTS ---------------------
"""
Plots low flows in past and future, the relative and aboslute changes, as well as the low flows of each climate projection separately.
$(SIGNATURES)
"""
function plot_low_flows(Seasonal_Low_Flows_past45, Seasonal_Low_Flows_future45, Seasonal_Low_Flows_past85, Seasonal_Low_Flows_future85, Timing_Seasonal_Low_Flows_past45, Timing_Seasonal_Low_Flows_future45,  Timing_Seasonal_Low_Flows_past85, Timing_Seasonal_Low_Flows_future85)
    Farben45=palette(:blues)
    Farben85=palette(:reds)
    # plot seasonal low flows of each projection
    # for proj in 1:14
    #     boxplot(Seasonal_Low_Flows_past45[1+(proj-1)*100: proj*100], color=[Farben45[1]])
    #     boxplot!(Seasonal_Low_Flows_future45[1+(proj-1)*100: proj*100],color=[Farben45[2]])
    #     boxplot!(Seasonal_Low_Flows_past85[1+(proj-1)*100: proj*100], color=[Farben85[1]])
    #     boxplot!(Seasonal_Low_Flows_future85[1+(proj-1)*100: proj*100], size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    #     xticks!([1:4;], ["Past 4.5", "Future 4.5", "Past 8.5", "Future 8.5"])
    #     ylabel!("minimum 7 day moving average of daily runoff [m³/s]")
    #     ylims!((2,10))
    #     title!("Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov")
    #     savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/LowFlows/summerlowflows_"*string(Name_Projections_45[proj])*".png")
    # end
    # # plot seasonal low flows of all projections combined
    # boxplot(Seasonal_Low_Flows_past45, color=[Farben45[1]])
    # boxplot!(Seasonal_Low_Flows_future45,color=[Farben45[2]])
    # boxplot!(Seasonal_Low_Flows_past85, color=[Farben85[1]])
    # boxplot!(Seasonal_Low_Flows_future85, size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    # xticks!([1:4;], ["Past 4.5", "Future 4.5", "Past 8.5", "Future 8.5"])
    # ylabel!("minimum 7 day moving average of daily runoff [m³/s]")
    # ylims!((2,10))
    # title!("Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov")
    # savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/LowFlows/summerlowflows.png")
    #
    # # plot timing of seasonal low flows of all projections combined
    # boxplot(Timing_Seasonal_Low_Flows_past45, color=[Farben45[1]])
    # boxplot!(Timing_Seasonal_Low_Flows_future45,color=[Farben45[2]])
    # boxplot!(Timing_Seasonal_Low_Flows_past85, color=[Farben85[1]])
    # boxplot!(Timing_Seasonal_Low_Flows_future85, size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    # xticks!([1:4;], ["Past 4.5", "Future 4.5", "Past 8.5", "Future 8.5"])
    # ylabel!("Timing of minimum 7 day moving average of daily runoff")
    # #ylims!((2,10))
    # yticks!([213, 227, 244, 258, 274], ["1.8", "15.8", "1.9", "15.9", "1.10"])
    # title!("Timing of Summer Low Flows 30 year average of lowest 7 day runoff from May - Nov")
    # savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/LowFlows/timing_summerlowflows.png")
    #
    # # plot timing of seasonal low flows of each projection
    # for proj in 1:14
    #     boxplot(Timing_Seasonal_Low_Flows_past45[1+(proj-1)*100: proj*100], color=[Farben45[1]])
    #     boxplot!(Timing_Seasonal_Low_Flows_future45[1+(proj-1)*100: proj*100],color=[Farben45[2]])
    #     boxplot!(Timing_Seasonal_Low_Flows_past85[1+(proj-1)*100: proj*100], color=[Farben85[1]])
    #     boxplot!(Timing_Seasonal_Low_Flows_future85[1+(proj-1)*100: proj*100], size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    #     xticks!([1:4;], ["Past 4.5", "Future 4.5", "Past 8.5", "Future 8.5"])
    #     ylabel!("Timing of minimum 7 day moving average of daily runoff")
    #     yticks!([213, 227, 244, 258, 274], ["1.8", "15.8", "1.9", "15.9", "1.10"])
    #     title!("Timing of Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov")
    #     savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/LowFlows/timing_summerlowflows_"*string(Name_Projections_45[proj])*".png")
    # end

    # #absolute and relative decrease
    # boxplot(Seasonal_Low_Flows_future45 - Seasonal_Low_Flows_past45,color=[Farben45[2]])
    # #boxplot!(, color=[Farben85[1]])
    # boxplot!(Seasonal_Low_Flows_future85 - Seasonal_Low_Flows_past85, size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    # xticks!([1:2;], ["RCP 4.5", "RCP 8.5"])
    # ylabel!("absolute change [m³/s]")
    # #title!("Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov (Future - Present)")
    # absolute_change = boxplot!()
    # # relative change
    # boxplot(relative_error(Seasonal_Low_Flows_future45, Seasonal_Low_Flows_past45)*100,color=[Farben45[2]])
    # #boxplot!(, color=[Farben85[1]])
    # boxplot!(relative_error(Seasonal_Low_Flows_future85, Seasonal_Low_Flows_past85)*100, size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    # xticks!([1:2;], ["RCP 4.5", "RCP 8.5"])
    # ylabel!("relative change [%]")
    # #title!("Relative Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov (Future - Present)")
    # relative_change = boxplot!()
    #
    #
    # #PyPlot.suptitle("Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov")
    # plot(absolute_change, relative_change)
    # savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/LowFlows/change_summerlowflows.png")

    violin(Seasonal_Low_Flows_future45 - Seasonal_Low_Flows_past45,color=[Farben45[2]])
    #boxplot!(, color=[Farben85[1]])
    violin!(Seasonal_Low_Flows_future85 - Seasonal_Low_Flows_past85, size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    xticks!([1:2;], ["RCP 4.5", "RCP 8.5"])
    ylabel!("absolute change [m³/s]")
    #title!("Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov (Future - Present)")
    absolute_change = boxplot!()
    # relative change
    violin(relative_error(Seasonal_Low_Flows_future45, Seasonal_Low_Flows_past45)*100,color=[Farben45[2]])
    #boxplot!(, color=[Farben85[1]])
    violin!(relative_error(Seasonal_Low_Flows_future85, Seasonal_Low_Flows_past85)*100, size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    xticks!([1:2;], ["RCP 4.5", "RCP 8.5"])
    ylabel!("relative change [%]")
    title!("Magnitude of Low Flows")
    #title!("Relative Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov (Future - Present)")
    relative_change = boxplot!()


    #PyPlot.suptitle("Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov")
    plot(absolute_change, relative_change)
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/LowFlows/change_summerlowflows_violins.png")

    #
    # #absolute and relative change in timing of low flows
    # boxplot(Timing_Seasonal_Low_Flows_future45 - Timing_Seasonal_Low_Flows_past45,color=[Farben45[2]])
    # #boxplot!(, color=[Farben85[1]])
    # boxplot!(Timing_Seasonal_Low_Flows_future85 - Timing_Seasonal_Low_Flows_past85, size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    # xticks!([1:2;], ["RCP 4.5", "RCP 8.5"])
    # ylabel!("absolute change [days]")
    # #title!("Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov (Future - Present)")
    # absolute_change_timing = boxplot!()
    # # relative change
    # boxplot(relative_error(Timing_Seasonal_Low_Flows_future45, Timing_Seasonal_Low_Flows_past45),color=[Farben45[2]])
    # #boxplot!(, color=[Farben85[1]])
    # boxplot!(relative_error(Timing_Seasonal_Low_Flows_future85, Timing_Seasonal_Low_Flows_past85), size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    # xticks!([1:2;], ["RCP 4.5", "RCP 8.5"])
    # ylabel!("relative change [%]")
    # #title!("Relative Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov (Future - Present)")
    # relative_change_timing = boxplot!()
    #
    #
    # #PyPlot.suptitle("Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov")
    # plot(absolute_change_timing)
    # savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/LowFlows/change_timing_summerlowflows.png")

    violin(Timing_Seasonal_Low_Flows_future45 - Timing_Seasonal_Low_Flows_past45,color=[Farben45[2]])
    #boxplot!(, color=[Farben85[1]])
    violin!(Timing_Seasonal_Low_Flows_future85 - Timing_Seasonal_Low_Flows_past85, size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    xticks!([1:2;], ["RCP 4.5", "RCP 8.5"])
    ylabel!("absolute change [days]")
    title!("Timing of Low Flows")
    #title!("Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov (Future - Present)")
    absolute_change_timing = boxplot!()
    # relative change
    violin(relative_error(Timing_Seasonal_Low_Flows_future45, Timing_Seasonal_Low_Flows_past45),color=[Farben45[2]])
    #boxplot!(, color=[Farben85[1]])
    violin!(relative_error(Timing_Seasonal_Low_Flows_future85, Timing_Seasonal_Low_Flows_past85), size=(1000,500), leg=false, left_margin = [5mm 0mm], xrotation = 60, color=[Farben85[2]], bottom_margin = 20px)
    xticks!([1:2;], ["RCP 4.5", "RCP 8.5"])
    ylabel!("relative change [%]")

    #title!("Relative Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov (Future - Present)")
    relative_change_timing = boxplot!()


    #PyPlot.suptitle("Change in Summer Low Flows 30 year average of Lowest 7 day runoff from May - Nov")
    plot(relative_change, absolute_change_timing)
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/PastvsFuture/LowFlows/change_timing_magnitude_summerlowflows_violins.png")
end

#plot_low_flows(Summer_Low_Flows_past45, Summer_Low_Flows_future45, Summer_Low_Flows_past85, Summer_Low_Flows_future85,  Timing_Summer_Low_Flows_Past_45, Timing_Summer_Low_Flows_Future_45,  Timing_Summer_Low_Flows_Past_85, Timing_Summer_Low_Flows_Future_85)


# ---------------- HYDROLOGICAL DROUGHTS --------------------------
function get_threshold_hydrological_drought(startyear, endyear, percentile)
    Discharge = CSV.read("/home/sarah/HBVModel/Gailtal/Q-Tagesmittel-212670.csv", header= false, skipto=23, decimal=',', delim = ';', types=[String, Float64])
    Discharge = convert(Matrix, Discharge)
    startindex = findfirst(isequal("01.01."*string(startyear)*" 00:00:00"), Discharge)
    endindex = findfirst(isequal("31.12."*string(endyear)*" 00:00:00"), Discharge)
    Observed_Discharge = Array{Float64,1}[]
    push!(Observed_Discharge, Discharge[startindex[1]:endindex[1],2])
    Observed_Discharge = Observed_Discharge[1]

    FDC = flowdurationcurve(Observed_Discharge)
    index = findnearest(FDC[2], percentile)
    return FDC[1][index]
end

"""
Calculates statistics for hydrological drought per year.

$(SIGNATURES)
The function returns the mean annual number of drought days, the mean annual number of drought events and the mean annual maximum drought length.
    As input multi annual discharge measurements, the corresponding timeseries and a threshold value are needed.
    Also the season is needed "none" refers to whole years will be used, otherwise use "summer" or "winter"
"""
function hydrological_drought_statistics_yearly(Discharge, Timeseries, Threshold, season)
    # get number of days of drought in each year
    # get number of drought events in each year
    # get yearly maximum duration of drought events
    Years = collect(Dates.year(Timeseries[1]): Dates.year(Timeseries[end]))
    Nr_Drought_Days = Float64[]
    Nr_Drought_Events = Float64[]
    Max_Drought_Length = Float64[]
    #Date_max_Annual_Discharge = Float64[]
    for (i, Current_Year) in enumerate(Years)
            if season == "none"
                Dates_Current_Year = filter(Timeseries) do x
                                  Dates.Year(x) == Dates.Year(Current_Year)
                              end
            elseif season == "summer"
                Dates_Current_Year = filter(Timeseries) do x
                                  Dates.Year(x) == Dates.Year(Current_Year) &&
                                  (Dates.Month(x) == Dates.Month(5) ||
                                  Dates.Month(x) == Dates.Month(6) ||
                                  Dates.Month(x) == Dates.Month(7) ||
                                  Dates.Month(x) == Dates.Month(8) ||
                                  Dates.Month(x) == Dates.Month(9) ||
                                  Dates.Month(x) == Dates.Month(10))
                              end
            elseif season == "winter"
                       Dates_Current_Year = filter(Timeseries) do x
                                                         Dates.Year(x) == Dates.Year(Current_Year) &&
                                                         (Dates.Month(x) == Dates.Month(11) ||
                                                         Dates.Month(x) == Dates.Month(12))
                                                   end
                       Dates_Next_Year = filter(Timeseries) do x
                                                         Dates.Year(x) == Dates.Year(Current_Year+1) &&
                                                         (Dates.Month(x) == Dates.Month(1) ||
                                                         Dates.Month(x) == Dates.Month(2) ||
                                                         Dates.Month(x) == Dates.Month(3) ||
                                                         Dates.Month(x) == Dates.Month(4))
                                                   end                              #&&
                                                         # (Dates.Month(x) == Dates.Month(1) ||
                                                         # Dates.Month(x) == Dates.Month(2) ||
                                                         # Dates.Month(x) == Dates.Month(3) ||
                                                         # Dates.Month(x) == Dates.Month(4)))
                       append!(Dates_Current_Year, Dates_Next_Year)
            end

            Current_Discharge = Discharge[indexin(Dates_Current_Year, Timeseries)]
            index_drought = findall(x->x < Threshold, Current_Discharge)
            append!(Nr_Drought_Days, length(index_drought))
            count = 0
            startindex = Int64[]
            endindex = Int64[]
            length_drought = Float64[]
            last_daily_discharge = 0.1
            for (j,daily_discharge) in enumerate(Current_Discharge)
                if j == 1 && daily_discharge < Threshold
                    count += 1
                    append!(startindex, j)
                elseif j == 1 && daily_discharge >= Threshold
                    count = 0
                elseif j == length(Current_Discharge) && daily_discharge < Threshold && last_daily_discharge < Threshold
                    count += 1
                    append!(endindex, j)
                    append!(length_drought, count)
                elseif daily_discharge < Threshold && last_daily_discharge >= Threshold
                    count+=1
                    append!(startindex, j)
                    if j == length(Current_Discharge)
                        append!(endindex, j)
                        append!(length_drought, count)
                    end
                elseif daily_discharge < Threshold && last_daily_discharge < Threshold
                    count += 1
                elseif daily_discharge >= Threshold && last_daily_discharge < Threshold
                    append!(endindex, j-1)
                    append!(length_drought, count)
                    count = 0
                # if the last day of the year is part of a hydrological drought it is assumed that this is the end of the hydrological drought
                end
                last_daily_discharge = daily_discharge
            end
            if startindex != Int64[]
                append!(Nr_Drought_Events, length(startindex))
            else
                append!(Nr_Drought_Events, 0)
                @assert endindex == Int64[]
            end
            if length_drought != Float64[]
                append!(Max_Drought_Length, maximum(length_drought))
            else
                append!(Max_Drought_Length, 0)
                @assert startindex == Int64[]
            end

    end
    if season == "winter"
        return mean(Nr_Drought_Days[1:end-1]), mean(Nr_Drought_Events[1:end-1]), mean(Max_Drought_Length[1:end-1])
    else
        return mean(Nr_Drought_Days), mean(Nr_Drought_Events), mean(Max_Drought_Length)
    end
end


# for the whole timeseries
function hydrological_drought_statistics(Discharge, Timeseries, Threshold, season)
    if season == "none"
        Dates_Current_Year = Timeseries
    elseif season == "summer"
        Dates_Current_Year = filter(Timeseries) do x
                          Dates.Month(x) == Dates.Month(5) ||
                          Dates.Month(x) == Dates.Month(6) ||
                          Dates.Month(x) == Dates.Month(7) ||
                          Dates.Month(x) == Dates.Month(8) ||
                          Dates.Month(x) == Dates.Month(9) ||
                          Dates.Month(x) == Dates.Month(10)
                      end
    elseif season == "winter"
        Dates_Current_Year = Date[]
        Years = collect(Dates.year(Timeseries[1]): Dates.year(Timeseries[end]))
        for (i, Current_Year) in enumerate(Years[1:end-1])
            Dates_This_Year = filter(Timeseries) do x
                                              Dates.Year(x) == Dates.Year(Current_Year) &&
                                              (Dates.Month(x) == Dates.Month(11) ||
                                              Dates.Month(x) == Dates.Month(12))
                                        end
            Dates_Next_Year = filter(Timeseries) do x
                                              Dates.Year(x) == Dates.Year(Current_Year+1) &&
                                              (Dates.Month(x) == Dates.Month(1) ||
                                              Dates.Month(x) == Dates.Month(2) ||
                                              Dates.Month(x) == Dates.Month(3) ||
                                              Dates.Month(x) == Dates.Month(4))
                                        end                              #&&
                                              # (Dates.Month(x) == Dates.Month(1) ||
                                              # Dates.Month(x) == Dates.Month(2) ||
                                              # Dates.Month(x) == Dates.Month(3) ||
                                              # Dates.Month(x) == Dates.Month(4)))
            this_year = append!(Dates_This_Year, Dates_Next_Year)
            append!(Dates_Current_Year, this_year)
        end

    end
    Current_Discharge = Discharge[indexin(Dates_Current_Year, Timeseries)]
    index_drought = findall(x->x < Threshold, Current_Discharge)
    # appends the total number of drought days over the timeseries (30 years)
    Nr_Drought_Days = length(index_drought)
    count = 0
    startindex = Int64[]
    endindex = Int64[]
    length_drought = Float64[]
    last_daily_discharge = 0.1
    for (j,daily_discharge) in enumerate(Current_Discharge)
        if j == 1 && daily_discharge < Threshold
            count += 1
            append!(startindex, j)
        elseif j == 1 && daily_discharge >= Threshold
            count = 0
        elseif j == length(Current_Discharge) && daily_discharge < Threshold && last_daily_discharge < Threshold
            count += 1
            append!(endindex, j)
            append!(length_drought, count)
        elseif daily_discharge < Threshold && last_daily_discharge >= Threshold
            count+=1
            append!(startindex, j)
            if j == length(Current_Discharge)
                append!(endindex, j)
                append!(length_drought, count)
            end
        elseif daily_discharge < Threshold && last_daily_discharge < Threshold
            count += 1
        elseif daily_discharge >= Threshold && last_daily_discharge < Threshold
            append!(endindex, j-1)
            append!(length_drought, count)
            count = 0
        # if the last day of the year is part of a hydrological drought it is assumed that this is the end of the hydrological drought
        end
        last_daily_discharge = daily_discharge
    end
    # get deficit by calculating the deficit sum over the days of one drought event
    Deficit = Float64[]
    @assert length(startindex) == length(endindex)
    for index in 1:length(startindex)
        Current_Deficit = sum(Threshold .- Current_Discharge[startindex[index]:endindex[index]])
        append!(Deficit, Current_Deficit)
    end


    if startindex != Int64[]
        Nr_Drought_Events = length(startindex)
        Max_Deficit = maximum(Deficit)
        Mean_Deficit = mean(Deficit)
        Total_Deficit = sum(Deficit)
        Max_Intensity = maximum(Deficit ./ length_drought)
        Mean_Intensity = mean(Deficit ./ length_drought)
    else
        Nr_Drought_Events = 0
        @assert endindex == Int64[]
    end
    if length_drought != Float64[]
        Max_Drought_Length = maximum(length_drought)
        Mean_Drought_Length = mean(length_drought)
    else
        Max_Drought_Length = 0
        Mean_Drought_Length = 0
        @assert startindex == Int64[]
    end



    return Nr_Drought_Days, Nr_Drought_Events, Max_Drought_Length, Mean_Drought_Length, Max_Deficit, Mean_Deficit, Total_Deficit,  Max_Intensity, Mean_Intensity
end
"""
Provides statistics for hydrological drought for every climate projection.

$(SIGNATURES)
The function returns the mean annual number of drought days, the mean annual number of drought events and the mean annual maximum drought length for past and future.
    As input the path to the projections and a threshold value are needed.
    The season can be set to "none" using whole years or "summer" or "winter"
"""
function compare_hydrological_drought(path_to_projections, Threshold, season, Area_Catchment, Catchment_Name)
    Name_Projections = readdir(path_to_projections)
    Timeseries_Past = collect(Date(1981,1,1):Day(1):Date(2010,12,31))
    Timeseries_End = readdlm("/home/sarah/Master/Thesis/Data/Projektionen/End_Timeseries_45_85.txt",',')
    Threshold = convertDischarge(Threshold, Area_Catchment)
    Nr_Drought_Days_Past = Float64[]
    Nr_Drought_Days_Future  = Float64[]
    Nr_Drought_Events_Past = Float64[]
    Nr_Drought_Events_Future = Float64[]
    Max_Drought_Length_Past = Float64[]
    Max_Drought_Length_Future = Float64[]
    Mean_Drought_Length_Past = Float64[]
    Mean_Drought_Length_Future = Float64[]
    Max_Deficit_Past = Float64[]
    Max_Deficit_Future = Float64[]
    Mean_Deficit_Past = Float64[]
    Mean_Deficit_Future = Float64[]
    Max_Intensity_Past = Float64[]
    Max_Intensity_Future = Float64[]
    Mean_Intensity_Past = Float64[]
    Mean_Intensity_Future = Float64[]
    Total_Deficit_Past = Float64[]
    Total_Deficit_Future = Float64[]
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
        Past_Discharge = readdlm(path_to_projections*name*"/"*Catchment_Name*"/100_model_results_discharge_past_2010.csv", ',')
        Future_Discharge = readdlm(path_to_projections*name*"/"*Catchment_Name*"/100_model_results_discharge_future_2100.csv", ',')
        for run in 1:100
            #print(size(Past_Discharge), size(Timeseries_Past), threshold, season, size(Future_Discharge[run,:]), size(Timeseries_Future), "\n")
            Current_Nr_Drought_Days_Past, Current_Nr_Drought_Events_Past, Current_Max_Drought_Length_Past, Current_Mean_Drought_Length_Past, Current_Max_Deficit_Past, Current_Mean_Deficit_Past, Current_Total_Deficit_Past, Current_Max_Intensity_Past, Current_Mean_Intensity_Past = hydrological_drought_statistics(convertDischarge(Past_Discharge[run,:], Area_Catchment), Timeseries_Past, Threshold, season)
            Current_Nr_Drought_Days_Future, Current_Nr_Drought_Events_Future, Current_Max_Drought_Length_Future, Current_Mean_Drought_Length_Future, Current_Max_Deficit_Future, Current_Mean_Deficit_Future, Current_Total_Deficit_Future, Current_Max_Intensity_Future, Current_Mean_Intensity_Future = hydrological_drought_statistics(convertDischarge(Future_Discharge[run,:], Area_Catchment), Timeseries_Future, Threshold, season)
            append!(Nr_Drought_Days_Past, Current_Nr_Drought_Days_Past)
            append!(Nr_Drought_Days_Future, Current_Nr_Drought_Days_Future)
            append!(Nr_Drought_Events_Past, Current_Nr_Drought_Events_Past)
            append!(Nr_Drought_Events_Future, Current_Nr_Drought_Events_Future)
            append!(Max_Drought_Length_Past, Current_Max_Drought_Length_Past)
            append!(Max_Drought_Length_Future, Current_Max_Drought_Length_Future)
            append!(Mean_Drought_Length_Past, Current_Mean_Drought_Length_Past)
            append!(Mean_Drought_Length_Future, Current_Mean_Drought_Length_Future)
            append!(Max_Deficit_Past, Current_Max_Deficit_Past)
            append!(Max_Deficit_Future, Current_Max_Deficit_Future)
            append!(Mean_Deficit_Past, Current_Mean_Deficit_Past)
            append!(Mean_Deficit_Future, Current_Mean_Deficit_Future)
            append!(Max_Intensity_Past, Current_Max_Intensity_Past)
            append!(Max_Intensity_Future, Current_Max_Intensity_Future)
            append!(Mean_Intensity_Past, Current_Mean_Intensity_Past)
            append!(Mean_Intensity_Future, Current_Mean_Intensity_Future)
            append!(Total_Deficit_Past, Current_Total_Deficit_Past)
            append!(Total_Deficit_Future, Current_Total_Deficit_Future)
        end
    end
    Drought_Statistics = Drought(Nr_Drought_Days_Past, Nr_Drought_Days_Future, Nr_Drought_Events_Past, Nr_Drought_Events_Future, Max_Drought_Length_Past, Max_Drought_Length_Future, Mean_Drought_Length_Past, Mean_Drought_Length_Future, Max_Deficit_Past, Max_Deficit_Future, Mean_Deficit_Past, Mean_Deficit_Future,  Total_Deficit_Past, Total_Deficit_Future, Max_Intensity_Past, Max_Intensity_Future, Mean_Intensity_Past, Mean_Intensity_Future)
    return Drought_Statistics
end

function plot_drought_statistics_yearly(Drought_45, Drought_85, Threshold, Catchment_Name, season)
    rcps = ["RCP 4.5", "RCP 8.5"]
    # plot change in Number of Drought days in year
    boxplot([rcps[1]], Nr_Drought_Days_Future_45 - Nr_Drought_Days_Past_45, color="blue")
    boxplot!([rcps[2]], Nr_Drought_Days_Future_85 - Nr_Drought_Days_Past_85, color="red", size=(1000,800), leg=false)
    title!("Change in Mean Yearly Number of Drought Days "*season*", Threshold= " *string(Threshold))
    ylabel!("Days")
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_length_Threshold"*string(Threshold)*"_"*season*".png")
    #plot change in number of drought events per year
    boxplot([rcps[1]], Nr_Drought_Events_Future_45 - Nr_Drought_Events_Past_45, color="blue")
    boxplot!([rcps[2]], Nr_Drought_Events_Future_85 - Nr_Drought_Events_Past_85, color="red",  size=(1000,800), leg=false)
    title!("Change in Mean Yearly Number of Drought Events "*season*", Threshold= " *string(Threshold))
    ylabel!("Nr. of Events")
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_nr_events_Threshold"*string(Threshold)*"_"*season*".png")
    # plot cahnge in maximum  drought length per year
    boxplot([rcps[1]], Max_Drought_Length_Future_45 - Max_Drought_Length_Past_45, color="blue")
    boxplot!([rcps[2]], Max_Drought_Length_Future_85 - Max_Drought_Length_Past_45, color="red",  size=(1000,800), leg=false)
    title!("Change in Mean Maximum Yearly Drought Length "*season*", Threshold= " *string(Threshold))
    ylabel!("Days")
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_max_length_Threshold"*string(Threshold)*"_"*season*".png")
    # make violin plots
    violin([rcps[1]], Nr_Drought_Days_Future_45 - Nr_Drought_Days_Past_45, color="blue")
    violin!([rcps[2]], Nr_Drought_Days_Future_85 - Nr_Drought_Days_Past_85, color="red", size=(1000,800), leg=false)
    title!("Change in Mean Yearly Number of Drought Days "*season*", Threshold= " *string(Threshold))
    ylabel!("Days")
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_length_Threshold"*string(Threshold)*"_violin_"*season*".png")
    #plot change in number of drought events per year
    violin([rcps[1]], Nr_Drought_Events_Future_45 - Nr_Drought_Events_Past_45, color="blue")
    violin!([rcps[2]], Nr_Drought_Events_Future_85 - Nr_Drought_Events_Past_85, color="red",  size=(1000,800), leg=false)
    title!("Change in Mean Yearly Number of Drought Events "*season*", Threshold= " *string(Threshold))
    ylabel!("Nr. of Events")
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_nr_events_Threshold"*string(Threshold)*"_violin_"*season*".png")
    # plot cahnge in maximum  drought length per year
    violin([rcps[1]], Max_Drought_Length_Future_45 - Max_Drought_Length_Past_45, color="blue")
    violin!([rcps[2]], Max_Drought_Length_Future_85 - Max_Drought_Length_Past_45, color="red",  size=(1000,800), leg=false)
    title!("Change in Mean Maximum Yearly Drought Length "*season*", Threshold= " *string(Threshold))
    ylabel!("Days")
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_max_length_Threshold"*string(Threshold)*"_violin_"*season*".png")
end


function plot_drought_statistics(Drought_45, Drought_85, Threshold, Catchment_Name, season)
    rcps = ["RCP 4.5 past", "RCP 4.5 future", "RCP 8.5 past", "RCP 8.5 future"]
    Farben45=palette(:blues)
    Farben85=palette(:reds)
    # plot change in Number of Drought days in year
    boxplot([rcps[1]], Drought_45.Nr_Drought_Days_Past, color=[Farben45[1]])
    boxplot!([rcps[2]], Drought_45.Nr_Drought_Days_Future , color=[Farben45[2]])
    boxplot!([rcps[3]], Drought_85.Nr_Drought_Days_Past, color=[Farben85[1]], size=(1200,800), leg=false)
    boxplot!([rcps[4]], Drought_85.Nr_Drought_Days_Future, color=[Farben85[2]], size=(1200,800), leg=false)
    title!("Change in Number of Drought Days "*season*", Threshold= " *string(Threshold))
    ylabel!("Days")
    Nr_Drought_Days = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_length_Threshold"*string(Threshold)*"_all_years_"*season*".png")
    #plot change in number of drought events per year
    boxplot([rcps[1]], Drought_45.Nr_Drought_Events_Past, color=[Farben45[1]])
    boxplot!([rcps[2]], Drought_45.Nr_Drought_Events_Future , color=[Farben45[2]])
    boxplot!([rcps[3]], Drought_85.Nr_Drought_Events_Past, color=[Farben85[1]],  size=(1200,800), leg=false)
    boxplot!([rcps[4]], Drought_85.Nr_Drought_Events_Future, color=[Farben85[2]],  size=(1200,800), leg=false)
    title!("Change in Number of Drought Events "*season*", Threshold= " *string(Threshold))
    ylabel!("Nr. of Events")
    Nr_Drought_Events = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_nr_events_Threshold"*string(Threshold)*"_all_years_"*season*".png")
    # plot cahnge in maximum  drought length per year
    boxplot([rcps[1]], Drought_45.Max_Drought_Length_Past, color=[Farben45[1]])
    boxplot!([rcps[2]], Drought_45.Max_Drought_Length_Future, color=[Farben45[2]])
    boxplot!([rcps[3]], Drought_85.Max_Drought_Length_Future, color=[Farben85[1]],  size=(1200,800), leg=false)
    boxplot!([rcps[4]], Drought_85.Max_Drought_Length_Future, color=[Farben85[2]],  size=(1200,800), leg=false)
    title!("Change in Maximum Drought Length "*season*", Threshold= " *string(Threshold))
    ylabel!("Days")
    Max_Drought_Length = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_max_length_Threshold"*string(Threshold)*"_all_years_"*season*".png")
    # plot change mean drought length
    boxplot([rcps[1]], Drought_45.Mean_Drought_Length_Past, color=[Farben45[1]])
    boxplot!([rcps[2]], Drought_45.Mean_Drought_Length_Future, color=[Farben45[2]])
    boxplot!([rcps[3]], Drought_85.Mean_Drought_Length_Past, color=[Farben85[1]],  size=(1200,800), leg=false)
    boxplot!([rcps[4]], Drought_85.Mean_Drought_Length_Future, color=[Farben85[2]],  size=(1200,800), leg=false)
    title!("Change in Mean Drought Length "*season*", Threshold= " *string(Threshold))
    ylabel!("Days")
    Mean_Drought_Length = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_mean_length_Threshold"*string(Threshold)*"_all_years_"*season*".png")

    # plot change max deficit
    boxplot([rcps[1]], Drought_45.Max_Deficit_Past, color=[Farben45[1]])
    boxplot!([rcps[2]], Drought_45.Max_Deficit_Future, color=[Farben45[2]])
    boxplot!([rcps[3]],  Drought_85.Max_Deficit_Past, color=[Farben85[1]],  size=(1200,800), leg=false)
    boxplot!([rcps[4]], Drought_85.Max_Deficit_Future, color=[Farben85[2]],  size=(1200,800), leg=false)
    title!("Change in Maximum Deficit "*season*", Threshold= " *string(Threshold))
    ylabel!("Discharge [m³/s]")
    Max_Deficit = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_max_deficit"*string(Threshold)*"_all_years_"*season*".png")
    # plot change mean deficit
    boxplot([rcps[1]], Drought_45.Mean_Deficit_Past, color=[Farben45[1]])
    boxplot!([rcps[2]], Drought_45.Mean_Deficit_Future, color=[Farben45[2]])
    boxplot!([rcps[3]], Drought_85.Mean_Deficit_Past, color=[Farben85[1]],  size=(1200,800), leg=false)
    boxplot!([rcps[4]], Drought_85.Mean_Deficit_Future, color=[Farben85[2]],  size=(1200,800), leg=false)
    title!("Change in MeanDeficit "*season*", Threshold= " *string(Threshold))
    ylabel!("Discharge [m³/s]")
    Mean_Deficit = boxplot!()

    # plot change max Intensity
    boxplot([rcps[1]], Drought_45.Max_Intensity_Past, color=[Farben45[1]])
    boxplot!([rcps[2]], Drought_45.Max_Intensity_Future, color=[Farben45[2]])
    boxplot!([rcps[3]],  Drought_85.Max_Intensity_Past, color=[Farben85[1]],  size=(1200,800), leg=false)
    boxplot!([rcps[4]], Drought_85.Max_Intensity_Future, color=[Farben85[2]],  size=(1200,800), leg=false)
    title!("Change in Maximum Intensity "*season*", Threshold= " *string(Threshold))
    ylabel!("Intensity [m³/s/d]")
    Max_Intensity = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_max_Intensity"*string(Threshold)*"_all_years_"*season*".png")
    # plot change mean Intensity
    boxplot([rcps[1]], Drought_45.Mean_Intensity_Past, color=[Farben45[1]])
    boxplot!([rcps[2]], Drought_45.Mean_Intensity_Future, color=[Farben45[2]])
    boxplot!([rcps[3]], Drought_85.Mean_Intensity_Past, color=[Farben85[1]],  size=(1200,800), leg=false)
    boxplot!([rcps[4]], Drought_85.Mean_Intensity_Future, color=[Farben85[2]],  size=(1200,800), leg=false)
    title!("Change in MeanIntensity "*season*", Threshold= " *string(Threshold))
    ylabel!("Intensity [m³/s/d]")
    Mean_Intensity = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_mean_deficit"*string(Threshold)*"_all_years_"*season*".png")

    plot(Nr_Drought_Days, Nr_Drought_Events, Max_Drought_Length, Mean_Drought_Length, Max_Deficit, Mean_Deficit, Max_Intensity, Mean_Intensity, layout= (2,4), legend = false, size=(2400,1200), left_margin = [5mm 0mm], bottom_margin = 20px)
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/drought_statistics_comparison"*string(Threshold)*"_all_years_"*season*".png")
    # make violin plots
    # plot change in Number of Drought days in year
    violin([rcps[1]], Drought_45.Nr_Drought_Days_Past, color=[Farben45[1]])
    violin!([rcps[2]], Drought_45.Nr_Drought_Days_Future , color=[Farben45[2]])
    violin!([rcps[3]], Drought_85.Nr_Drought_Days_Past, color=[Farben85[1]], size=(1200,800), leg=false)
    violin!([rcps[4]], Drought_85.Nr_Drought_Days_Future, color=[Farben85[2]], size=(1200,800), leg=false)
    title!("Change in Number of Drought Days "*season*", Threshold= " *string(Threshold))
    ylabel!("Days")
    Nr_Drought_Days = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_length_Threshold"*string(Threshold)*"_all_years_"*season*".png")
    #plot change in number of drought events per year
    violin([rcps[1]], Drought_45.Nr_Drought_Events_Past, color=[Farben45[1]])
    violin!([rcps[2]], Drought_45.Nr_Drought_Events_Future , color=[Farben45[2]])
    violin!([rcps[3]], Drought_85.Nr_Drought_Events_Past, color=[Farben85[1]],  size=(1200,800), leg=false)
    violin!([rcps[4]], Drought_85.Nr_Drought_Events_Future, color=[Farben85[2]],  size=(1200,800), leg=false)
    title!("Change in Number of Drought Events "*season*", Threshold= " *string(Threshold))
    ylabel!("Nr. of Events")
    Nr_Drought_Events = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_nr_events_Threshold"*string(Threshold)*"_all_years_"*season*".png")
    # plot cahnge in maximum  drought length per year
    violin([rcps[1]], Drought_45.Max_Drought_Length_Past, color=[Farben45[1]])
    violin!([rcps[2]], Drought_45.Max_Drought_Length_Future, color=[Farben45[2]])
    violin!([rcps[3]], Drought_85.Max_Drought_Length_Past, color=[Farben85[1]],  size=(1200,800), leg=false)
    violin!([rcps[4]], Drought_85.Max_Drought_Length_Future, color=[Farben85[2]],  size=(1200,800), leg=false)
    title!("Change in Maximum Drought Length "*season*", Threshold= " *string(Threshold))
    ylabel!("Days")
    Max_Drought_Length = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_max_length_Threshold"*string(Threshold)*"_all_years_"*season*".png")
    # plot change mean drought length
    violin([rcps[1]], Drought_45.Mean_Drought_Length_Past, color=[Farben45[1]])
    violin!([rcps[2]], Drought_45.Mean_Drought_Length_Future, color=[Farben45[2]])
    violin!([rcps[3]], Drought_85.Mean_Drought_Length_Past, color=[Farben85[1]],  size=(1200,800), leg=false)
    violin!([rcps[4]], Drought_85.Mean_Drought_Length_Future, color=[Farben85[2]],  size=(1200,800), leg=false)
    title!("Change in Mean Drought Length "*season*", Threshold= " *string(Threshold))
    ylabel!("Days")
    Mean_Drought_Length = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_mean_length_Threshold"*string(Threshold)*"_all_years_"*season*".png")

    # plot change max deficit
    violin([rcps[1]], Drought_45.Max_Deficit_Past, color=[Farben45[1]])
    violin!([rcps[2]], Drought_45.Max_Deficit_Future, color=[Farben45[2]])
    violin!([rcps[3]],  Drought_85.Max_Deficit_Past, color=[Farben85[1]],  size=(1200,800), leg=false)
    violin!([rcps[4]], Drought_85.Max_Deficit_Future, color=[Farben85[2]],  size=(1200,800), leg=false)
    title!("Change in Maximum Deficit "*season*", Threshold= " *string(Threshold))
    ylabel!("Discharge [m³/s]")
    Max_Deficit = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_max_deficit"*string(Threshold)*"_all_years_"*season*".png")
    # plot change mean deficit
    violin([rcps[1]], Drought_45.Mean_Deficit_Past, color=[Farben45[1]])
    violin!([rcps[2]], Drought_45.Mean_Deficit_Future, color=[Farben45[2]])
    violin!([rcps[3]], Drought_85.Mean_Deficit_Past, color=[Farben85[1]],  size=(1200,800), leg=false)
    violin!([rcps[4]], Drought_85.Mean_Deficit_Future, color=[Farben85[2]],  size=(1200,800), leg=false)
    title!("Change in MeanDeficit "*season*", Threshold= " *string(Threshold))
    ylabel!("Discharge [m³/s]")
    Mean_Deficit = boxplot!()

    # plot change max Intensity
    violin([rcps[1]], Drought_45.Max_Intensity_Past, color=[Farben45[1]])
    violin!([rcps[2]], Drought_45.Max_Intensity_Future, color=[Farben45[2]])
    violin!([rcps[3]],  Drought_85.Max_Intensity_Past, color=[Farben85[1]],  size=(1200,800), leg=false)
    violin!([rcps[4]], Drought_85.Max_Intensity_Future, color=[Farben85[2]],  size=(1200,800), leg=false)
    title!("Change in Maximum Intensity "*season*", Threshold= " *string(Threshold))
    ylabel!("Intensity [m³/s/d]")
    Max_Intensity = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_max_Intensity"*string(Threshold)*"_all_years_"*season*".png")
    # plot change mean Intensity
    violin([rcps[1]], Drought_45.Mean_Intensity_Past, color=[Farben45[1]])
    violin!([rcps[2]], Drought_45.Mean_Intensity_Future, color=[Farben45[2]])
    violin!([rcps[3]], Drought_85.Mean_Intensity_Past, color=[Farben85[1]],  size=(1200,800), leg=false)
    violin!([rcps[4]], Drought_85.Mean_Intensity_Future, color=[Farben85[2]],  size=(1200,800), leg=false)
    title!("Change in Mean Intensity "*season*", Threshold= " *string(Threshold))
    ylabel!("Intensity [m³/s/d]")
    Mean_Intensity = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_mean_deficit"*string(Threshold)*"_violin_all_years_"*season*".png")
    plot(Nr_Drought_Days, Nr_Drought_Events, Max_Drought_Length, Mean_Drought_Length, Max_Deficit, Mean_Deficit, Max_Intensity, Mean_Intensity, layout= (2,4), legend = false, size=(2400,1200), left_margin = [5mm 0mm], bottom_margin = 20px, yguidefontsize=20, xtickfont = font(20), ytickfont = font(20), guidefontsize=20)
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/drought_statistics_comparison"*string(Threshold)*"_all_years_"*season*"_violin_font.png")
end

function plot_drought_statistics_rel_change(Drought_45, Drought_85, Threshold, Catchment_Name, season)
    rcps = ["RCP 4.5", "RCP 8.5"]
    # plot change in Number of Drought days in year
    boxplot([rcps[1]], relative_error(Drought_45.Nr_Drought_Days_Future, Drought_45.Nr_Drought_Days_Past)*100, color="blue")
    boxplot!([rcps[2]], relative_error(Drought_85.Nr_Drought_Days_Future, Drought_85.Nr_Drought_Days_Past)*100, color="red", size=(1200,800), leg=false)
    title!("Relative Change in Number of Drought Days "*season*", Threshold= " *string(Threshold))
    ylabel!("[%]")
    hline!([0], color=["grey"], linestyle = :dash)
    Nr_Drought_Days = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_length_Threshold"*string(Threshold)*"_all_years_"*season*".png")
    #plot change in number of drought events per year
    boxplot([rcps[1]], relative_error(Drought_45.Nr_Drought_Events_Future, Drought_45.Nr_Drought_Events_Past)*100, color="blue")
    boxplot!([rcps[2]], relative_error(Drought_85.Nr_Drought_Events_Future, Drought_85.Nr_Drought_Events_Past)*100, color="red",  size=(1200,800), leg=false)
    title!("Relative Change in Number of Drought Events "*season*", Threshold= " *string(Threshold))
    ylabel!("[%]")
    hline!([0], color=["grey"], linestyle = :dash)
    Nr_Drought_Events = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_nr_events_Threshold"*string(Threshold)*"_all_years_"*season*".png")
    # plot cahnge in maximum  drought length per year
    boxplot([rcps[1]], relative_error(Drought_45.Max_Drought_Length_Future, Drought_45.Max_Drought_Length_Past)*100, color="blue")
    boxplot!([rcps[2]], relative_error(Drought_85.Max_Drought_Length_Future, Drought_85.Max_Drought_Length_Past)*100, color="red",  size=(1200,800), leg=false)
    title!("Relative Change in Maximum Drought Length "*season*", Threshold= " *string(Threshold))
    ylabel!("[%]")
    hline!([0], color=["grey"], linestyle = :dash)
    Max_Drought_Length = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_max_length_Threshold"*string(Threshold)*"_all_years_"*season*".png")
    # plot change mean drought length
    boxplot([rcps[1]], relative_error(Drought_45.Mean_Drought_Length_Future,  Drought_45.Mean_Drought_Length_Past)*100, color="blue")
    boxplot!([rcps[2]], relative_error(Drought_85.Mean_Drought_Length_Future, Drought_85.Mean_Drought_Length_Past)*100, color="red",  size=(1200,800), leg=false)
    title!("Relative Change in Mean Drought Length "*season*", Threshold= " *string(Threshold))
    ylabel!("[%]")
    hline!([0], color=["grey"], linestyle = :dash)
    Mean_Drought_Length = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_mean_length_Threshold"*string(Threshold)*"_all_years_"*season*".png")

    # plot change max deficit
    boxplot([rcps[1]], relative_error(Drought_45.Max_Deficit_Future, Drought_45.Max_Deficit_Past)*100, color="blue")
    boxplot!([rcps[2]], relative_error(Drought_85.Max_Deficit_Future, Drought_85.Max_Deficit_Past)*100, color="red",  size=(1200,800), leg=false)
    title!("Relative Change in Maximum Deficit "*season*", Threshold= " *string(Threshold))
    ylabel!("[%]")
    hline!([0], color=["grey"], linestyle = :dash)
    Max_Deficit = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_max_deficit"*string(Threshold)*"_all_years_"*season*".png")
    # plot change mean deficit
    boxplot([rcps[1]], relative_error(Drought_45.Mean_Deficit_Future, Drought_45.Mean_Deficit_Past)*100, color="blue")
    boxplot!([rcps[2]], relative_error(Drought_85.Mean_Deficit_Future, Drought_85.Mean_Deficit_Past)*100, color="red",  size=(1200,800), leg=false)
    title!("Relativ Change in MeanDeficit "*season*", Threshold= " *string(Threshold))
    ylabel!("[%]")
    hline!([0], color=["grey"], linestyle = :dash)
    Mean_Deficit = boxplot!()

    # plot change max Intensity
    boxplot([rcps[1]], relative_error(Drought_45.Max_Intensity_Future, Drought_45.Max_Intensity_Past)*100, color="blue")
    boxplot!([rcps[2]], relative_error(Drought_85.Max_Intensity_Future, Drought_85.Max_Intensity_Past)*100, color="red",  size=(1200,800), leg=false)
    title!("Relative Change in Maximum Intensity "*season*", Threshold= " *string(Threshold))
    ylabel!("[%]")
    Max_Intensity = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_max_Intensity"*string(Threshold)*"_all_years_"*season*".png")
    # plot change mean Intensity
    boxplot([rcps[1]], relative_error(Drought_45.Mean_Intensity_Future, Drought_45.Mean_Intensity_Past)*100, color="blue")
    boxplot!([rcps[2]], relative_error(Drought_85.Mean_Intensity_Future, Drought_85.Mean_Intensity_Past)*100, color="red",  size=(1200,800), leg=false)
    title!("Relative Change in MeanIntensity "*season*", Threshold= " *string(Threshold))
    ylabel!("[%]")
    hline!([0], color=["grey"], linestyle = :dash)
    Mean_Intensity = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_mean_deficit"*string(Threshold)*"_all_years_"*season*".png")
    plot(Nr_Drought_Days, Mean_Drought_Length, Mean_Deficit, Mean_Intensity, layout= (2,2), legend = false, size=(2400,1200), left_margin = [5mm 0mm], bottom_margin = 20px)
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/drought_statistics"*string(Threshold)*"_all_years_"*season*"_rel_change_4metrics.png")
    # plot(Nr_Drought_Days, Nr_Drought_Events, Max_Drought_Length, Mean_Drought_Length, Max_Deficit, Mean_Deficit, Max_Intensity, Mean_Intensity, layout= (2,4), legend = false, size=(2400,1200), left_margin = [5mm 0mm], bottom_margin = 20px)
    # savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/drought_statistics"*string(Threshold)*"_all_years_"*season*"_rel_change.png")
    # make violin plots
    violin([rcps[1]], relative_error(Drought_45.Nr_Drought_Days_Future, Drought_45.Nr_Drought_Days_Past)*100, color="blue")
    violin!([rcps[2]], relative_error(Drought_85.Nr_Drought_Days_Future, Drought_85.Nr_Drought_Days_Past)*100, color="red", size=(1200,800), leg=false)
    title!("Relative Change in Number of Drought Days")# "*season*", Threshold= " *string(Threshold))
    ylabel!("[%]")
    hline!([0], color=["grey"], linestyle = :dash)
    Nr_Drought_Days = violin!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_length_Threshold"*string(Threshold)*"_violin_all_years_"*season*".png")
    #plot change in number of drought events per year
    violin([rcps[1]], relative_error(Drought_45.Nr_Drought_Events_Future, Drought_45.Nr_Drought_Events_Past)*100, color="blue")
    violin!([rcps[2]], relative_error(Drought_85.Nr_Drought_Events_Future, Drought_85.Nr_Drought_Events_Past)*100, color="red",  size=(1200,800), leg=false)
    title!("Relative Change in Number of Drought Events "*season*", Threshold= " *string(Threshold))
    ylabel!("[%]")
    hline!([0], color=["grey"], linestyle = :dash)
    Nr_Drought_Events = violin!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_nr_events_Threshold"*string(Threshold)*"_violin_all_years_"*season*".png")
    # plot cahnge in maximum  drought length per year
    violin([rcps[1]], relative_error(Drought_45.Max_Drought_Length_Future, Drought_45.Max_Drought_Length_Past)*100, color="blue")
    violin!([rcps[2]], relative_error(Drought_85.Max_Drought_Length_Future, Drought_85.Max_Drought_Length_Past)*100, color="red",  size=(1200,800), leg=false)
    title!("Relative Change in Maximum Drought Length "*season*", Threshold= " *string(Threshold))
    ylabel!("[%]")
    hline!([0], color=["grey"], linestyle = :dash)
    Max_Drought_Length = violin!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_max_length_Threshold"*string(Threshold)*"_violin_all_years_"*season*".png")

    # plot change mean drought length
    violin([rcps[1]], relative_error(Drought_45.Mean_Drought_Length_Future, Drought_45.Mean_Drought_Length_Past)*100, color="blue")
    violin!([rcps[2]], relative_error(Drought_85.Mean_Drought_Length_Future, Drought_85.Mean_Drought_Length_Past)*100, color="red",  size=(1200,800), leg=false)
    title!("Relative Change in Mean Drought Length")# "*season*", Threshold= " *string(Threshold))
    ylabel!("[%]")
    hline!([0], color=["grey"], linestyle = :dash)
    Mean_Drought_Length = violin!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_mean_length_Threshold"*string(Threshold)*"_violin_all_years_"*season*".png")

    # plot change max deficit
    violin([rcps[1]], relative_error(Drought_45.Max_Deficit_Future, Drought_45.Max_Deficit_Past)*100, color="blue")
    violin!([rcps[2]], relative_error(Drought_85.Max_Deficit_Future, Drought_85.Max_Deficit_Past)*100, color="red",  size=(1200,800), leg=false)
    title!("Relative Change in Maximum Deficit "*season*", Threshold= " *string(Threshold))
    ylabel!("[%]")
    hline!([0], color=["grey"], linestyle = :dash)
    Max_Deficit = violin!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_max_deficit"*string(Threshold)*"_violin_all_years_"*season*".png")
    # plot change mean deficit
    violin([rcps[1]], relative_error(Drought_45.Mean_Deficit_Future, Drought_45.Mean_Deficit_Past)*100, color="blue")
    violin!([rcps[2]], relative_error(Drought_85.Mean_Deficit_Future, Drought_85.Mean_Deficit_Past)*100, color="red",  size=(1200,800), leg=false)
    title!("Relative Change in Mean Deficit")# "*season*", Threshold= " *string(Threshold))
    ylabel!("[%]")
    hline!([0], color=["grey"], linestyle = :dash)
    Mean_Deficit = violin!()

    # plot change max Intensity
    violin([rcps[1]], relative_error(Drought_45.Max_Intensity_Future, Drought_45.Max_Intensity_Past)*100, color="blue")
    violin!([rcps[2]], relative_error(Drought_85.Max_Intensity_Future, Drought_85.Max_Intensity_Past)*100, color="red",  size=(1200,800), leg=false)
    title!("Relative Change in Maximum Intensity "*season*", Threshold= " *string(Threshold))
    ylabel!("[%]")
    hline!([0], color=["grey"], linestyle = :dash)
    Max_Intensity = violin!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_max_Intensity"*string(Threshold)*"_violin_all_years_"*season*".png")
    # plot change mean Intensity
    violin([rcps[1]], relative_error(Drought_45.Mean_Intensity_Future, Drought_45.Mean_Intensity_Past)*100, color="blue")
    violin!([rcps[2]], relative_error(Drought_85.Mean_Intensity_Future, Drought_85.Mean_Intensity_Past)*100, color="red",  size=(1200,800), leg=false)
    title!("Relative Change in Mean Intensity", guidefontsize=(20))# "*season*", Threshold= " *string(Threshold))
    ylabel!("[%]")
    hline!([0], color=["grey"], linestyle = :dash)
    Mean_Intensity = violin!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_mean_deficit"*string(Threshold)*"_violin_all_years_"*season*".png")
    plot(Nr_Drought_Days, Mean_Drought_Length, Mean_Deficit, Mean_Intensity, layout= (2,2), legend = false, size=(2000,1200), left_margin = [5mm 0mm], bottom_margin = 20px, yguidefontsize=20, xtickfont = font(20), ytickfont = font(20))
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/drought_statistics"*string(Threshold)*"_all_years_"*season*"_rel_change_violin_4metrics_font.png")
    # plot(Nr_Drought_Days, Nr_Drought_Events, Max_Drought_Length, Mean_Drought_Length, Max_Deficit, Mean_Deficit, Max_Intensity, Mean_Intensity, layout= (2,4), legend = false, size=(2400,1200), left_margin = [5mm 0mm], bottom_margin = 20px)
    # savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/drought_statistics"*string(Threshold)*"_all_years_"*season*"_rel_change_violin.png")
end

function plot_drought_statistics_change(Drought_45, Drought_85, Threshold, Catchment_Name, season)
    rcps = ["RCP 4.5", "RCP 8.5"]
    # plot change in Number of Drought days in year
    boxplot([rcps[1]], Drought_45.Nr_Drought_Days_Future - Drought_45.Nr_Drought_Days_Past, color="blue")
    boxplot!([rcps[2]], Drought_85.Nr_Drought_Days_Future - Drought_85.Nr_Drought_Days_Past, color="red", size=(1200,800), leg=false)
    title!("Change in Number of Drought Days "*season*", Threshold= " *string(Threshold))
    ylabel!("Days")
    Nr_Drought_Days = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_length_Threshold"*string(Threshold)*"_all_years_"*season*".png")
    #plot change in number of drought events per year
    boxplot([rcps[1]], Drought_45.Nr_Drought_Events_Future - Drought_45.Nr_Drought_Events_Past, color="blue")
    boxplot!([rcps[2]], Drought_85.Nr_Drought_Events_Future - Drought_85.Nr_Drought_Events_Past, color="red",  size=(1200,800), leg=false)
    title!("Change in Number of Drought Events "*season*", Threshold= " *string(Threshold))
    ylabel!("Nr. of Events")
    Nr_Drought_Events = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_nr_events_Threshold"*string(Threshold)*"_all_years_"*season*".png")
    # plot cahnge in maximum  drought length per year
    boxplot([rcps[1]], Drought_45.Max_Drought_Length_Future - Drought_45.Max_Drought_Length_Past, color="blue")
    boxplot!([rcps[2]], Drought_85.Max_Drought_Length_Future - Drought_85.Max_Drought_Length_Past, color="red",  size=(1200,800), leg=false)
    title!("Change in Maximum Drought Length "*season*", Threshold= " *string(Threshold))
    ylabel!("Days")
    Max_Drought_Length = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_max_length_Threshold"*string(Threshold)*"_all_years_"*season*".png")
    # plot change mean drought length
    boxplot([rcps[1]], Drought_45.Mean_Drought_Length_Future - Drought_45.Mean_Drought_Length_Past, color="blue")
    boxplot!([rcps[2]], Drought_85.Mean_Drought_Length_Future - Drought_85.Mean_Drought_Length_Past, color="red",  size=(1200,800), leg=false)
    title!("Change in Mean Drought Length "*season*", Threshold= " *string(Threshold))
    ylabel!("Days")
    Mean_Drought_Length = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_mean_length_Threshold"*string(Threshold)*"_all_years_"*season*".png")

    # plot change max deficit
    boxplot([rcps[1]], Drought_45.Max_Deficit_Future - Drought_45.Max_Deficit_Past, color="blue")
    boxplot!([rcps[2]], Drought_85.Max_Deficit_Future - Drought_85.Max_Deficit_Past, color="red",  size=(1200,800), leg=false)
    title!("Change in Maximum Deficit "*season*", Threshold= " *string(Threshold))
    ylabel!("Deficit [mm]")
    Max_Deficit = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_max_deficit"*string(Threshold)*"_all_years_"*season*".png")
    # plot change mean deficit
    boxplot([rcps[1]], Drought_45.Mean_Deficit_Future - Drought_45.Mean_Deficit_Past, color="blue")
    boxplot!([rcps[2]], Drought_85.Mean_Deficit_Future - Drought_85.Mean_Deficit_Past, color="red",  size=(1200,800), leg=false)
    title!("Change in MeanDeficit "*season*", Threshold= " *string(Threshold))
    ylabel!("Deficit [mm]")
    Mean_Deficit = boxplot!()

    # plot change max Intensity
    boxplot([rcps[1]], Drought_45.Max_Intensity_Future - Drought_45.Max_Intensity_Past, color="blue")
    boxplot!([rcps[2]], Drought_85.Max_Intensity_Future - Drought_85.Max_Intensity_Past, color="red",  size=(1200,800), leg=false)
    title!("Change in Maximum Intensity "*season*", Threshold= " *string(Threshold))
    ylabel!("Intensity [mm/d]")
    Max_Intensity = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_max_Intensity"*string(Threshold)*"_all_years_"*season*".png")
    # plot change mean Intensity
    boxplot([rcps[1]], Drought_45.Mean_Intensity_Future - Drought_45.Mean_Intensity_Past, color="blue")
    boxplot!([rcps[2]], Drought_85.Mean_Intensity_Future - Drought_85.Mean_Intensity_Past, color="red",  size=(1200,800), leg=false)
    title!("Change in MeanIntensity "*season*", Threshold= " *string(Threshold))
    ylabel!("Intensity [mm/d]")
    Mean_Intensity = boxplot!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_mean_deficit"*string(Threshold)*"_all_years_"*season*".png")
    plot(Nr_Drought_Days, Mean_Drought_Length, Mean_Deficit, Mean_Intensity, layout= (2,2), legend = false, size=(2400,1200), left_margin = [5mm 0mm], bottom_margin = 20px)
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/drought_statistics"*string(Threshold)*"_all_years_"*season*"_4metrics.png")
    # plot(Nr_Drought_Days, Nr_Drought_Events, Max_Drought_Length, Mean_Drought_Length, Max_Deficit, Mean_Deficit, Max_Intensity, Mean_Intensity, layout= (2,4), legend = false, size=(2400,1200), left_margin = [5mm 0mm], bottom_margin = 20px)
    # savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/drought_statistics"*string(Threshold)*"_all_years_"*season*".png")
    # make violin plots
    violin([rcps[1]], Drought_45.Nr_Drought_Days_Future - Drought_45.Nr_Drought_Days_Past, color="blue")
    violin!([rcps[2]], Drought_85.Nr_Drought_Days_Future - Drought_85.Nr_Drought_Days_Past, color="red", size=(1200,800), leg=false)
    title!("Change in Number of Drought Days")# "*season*", Threshold= " *string(Threshold))
    ylabel!("Days")
    hline!([0], color=["grey"], linestyle = :dash)
    Nr_Drought_Days = violin!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_length_Threshold"*string(Threshold)*"_violin_all_years_"*season*".png")
    #plot change in number of drought events per year
    violin([rcps[1]], Drought_45.Nr_Drought_Events_Future - Drought_45.Nr_Drought_Events_Past, color="blue")
    violin!([rcps[2]], Drought_85.Nr_Drought_Events_Future - Drought_85.Nr_Drought_Events_Past, color="red",  size=(1200,800), leg=false)
    title!("Change in Number of Drought Events "*season*", Threshold= " *string(Threshold))
    ylabel!("Nr. of Events")
    hline!([0], color=["grey"], linestyle = :dash)
    Nr_Drought_Events = violin!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_nr_events_Threshold"*string(Threshold)*"_violin_all_years_"*season*".png")
    # plot cahnge in maximum  drought length per year
    violin([rcps[1]], Drought_45.Max_Drought_Length_Future - Drought_45.Max_Drought_Length_Past, color="blue")
    violin!([rcps[2]], Drought_85.Max_Drought_Length_Future - Drought_85.Max_Drought_Length_Past, color="red",  size=(1200,800), leg=false)
    title!("Change in Maximum Drought Length "*season*", Threshold= " *string(Threshold))
    ylabel!("Days")
    hline!([0], color=["grey"], linestyle = :dash)
    Max_Drought_Length = violin!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_max_length_Threshold"*string(Threshold)*"_violin_all_years_"*season*".png")

    # plot change mean drought length
    violin([rcps[1]], Drought_45.Mean_Drought_Length_Future - Drought_45.Mean_Drought_Length_Past, color="blue")
    violin!([rcps[2]], Drought_85.Mean_Drought_Length_Future - Drought_85.Mean_Drought_Length_Past, color="red",  size=(1200,800), leg=false)
    title!("Change in Mean Drought Length")# "*season*", Threshold= " *string(Threshold))
    ylabel!("Days")
    hline!([0], color=["grey"], linestyle = :dash)
    Mean_Drought_Length = violin!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_mean_length_Threshold"*string(Threshold)*"_violin_all_years_"*season*".png")

    # plot change max deficit
    violin([rcps[1]], Drought_45.Max_Deficit_Future - Drought_45.Max_Deficit_Past, color="blue")
    violin!([rcps[2]], Drought_85.Max_Deficit_Future - Drought_85.Max_Deficit_Past, color="red",  size=(1200,800), leg=false)
    title!("Change in Maximum Deficit "*season*", Threshold= " *string(Threshold))
    ylabel!("Deficit [mm]")
    Max_Deficit = violin!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_max_deficit"*string(Threshold)*"_violin_all_years_"*season*".png")
    # plot change mean deficit
    violin([rcps[1]], Drought_45.Mean_Deficit_Future - Drought_45.Mean_Deficit_Past, color="blue")
    violin!([rcps[2]], Drought_85.Mean_Deficit_Future - Drought_85.Mean_Deficit_Past, color="red",  size=(1200,800), leg=false)
    title!("Change in Mean Deficit")# "*season*", Threshold= " *string(Threshold))
    ylabel!("Deficit [mm]")
    hline!([0], color=["grey"], linestyle = :dash)
    Mean_Deficit = violin!()

    # plot change max Intensity
    violin([rcps[1]], Drought_45.Max_Intensity_Future - Drought_45.Max_Intensity_Past, color="blue")
    violin!([rcps[2]], Drought_85.Max_Intensity_Future - Drought_85.Max_Intensity_Past, color="red",  size=(1200,800), leg=false)
    title!("Change in Maximum Intensity "*season*", Threshold= " *string(Threshold))
    ylabel!("Intensity [mm/d]")
    hline!([0], color=["grey"], linestyle = :dash)
    Max_Intensity = violin!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_max_Intensity"*string(Threshold)*"_violin_all_years_"*season*".png")
    # plot change mean Intensity
    violin([rcps[1]], Drought_45.Mean_Intensity_Future - Drought_45.Mean_Intensity_Past, color="blue")
    violin!([rcps[2]], Drought_85.Mean_Intensity_Future - Drought_85.Mean_Intensity_Past, color="red",  size=(1200,800), leg=false)
    title!("Change in Mean Intensity")# "*season*", Threshold= " *string(Threshold))
    ylabel!("Intensity [mm/d]")
    hline!([0], color=["grey"], linestyle = :dash)
    Mean_Intensity = violin!()
    #savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/change_mean_deficit"*string(Threshold)*"_violin_all_years_"*season*".png")
    plot(Nr_Drought_Days, Mean_Drought_Length, Mean_Deficit, Mean_Intensity, layout= (2,2), legend = false, size=(2000,1200), left_margin = [5mm 0mm], bottom_margin = 20px, yguidefontsize=20, xtickfont = font(20), ytickfont = font(20), titlefontsize=20)
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/drought_statistics"*string(Threshold)*"_all_years_"*season*"_violin_4metrics_font.png")
    # plot(Nr_Drought_Days, Nr_Drought_Events, Max_Drought_Length, Mean_Drought_Length, Max_Deficit, Mean_Deficit, Max_Intensity, Mean_Intensity, layout= (2,4), legend = false, size=(2400,1200), left_margin = [5mm 0mm], bottom_margin = 20px)
    # savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/drought_statistics"*string(Threshold)*"_all_years_"*season*"_violin.png")
end

function plot_drought_total_deficit(Drought_45, Drought_85, Threshold, Catchment_Name, season)
    rcps = ["RCP 4.5", "RCP 8.5"]
    # plot change in Number of Drought days in year
    boxplot([rcps[1]], relative_error(Drought_45.Total_Deficit_Future, Drought_45.Total_Deficit_Past)*100, color="blue")
    boxplot!([rcps[2]], relative_error(Drought_85.Total_Deficit_Future, Drought_85.Total_Deficit_Past)*100, color="red", size=(1200,800), leg=false)
    violin!([rcps[1]], relative_error(Drought_45.Total_Deficit_Future, Drought_45.Total_Deficit_Past)*100, color="blue", alpha=0.6)
    violin!([rcps[2]], relative_error(Drought_85.Total_Deficit_Future, Drought_85.Total_Deficit_Past)*100, color="red", size=(1200,800), leg=false, alpha=0.6)
    title!("Relative Change in Total Deficit due to Droughts "*season*", Threshold= " *string(Threshold))
    ylabel!("[%]")
    relativ_change = boxplot!()

    boxplot([rcps[1]], Drought_45.Total_Deficit_Future - Drought_45.Total_Deficit_Past, color="blue")
    boxplot!([rcps[2]], Drought_85.Total_Deficit_Future- Drought_85.Total_Deficit_Past, color="red", size=(1200,800), leg=false)
    violin!([rcps[1]], Drought_45.Total_Deficit_Future- Drought_45.Total_Deficit_Past, color="blue", alpha=0.6)
    violin!([rcps[2]], Drought_85.Total_Deficit_Future- Drought_85.Total_Deficit_Past, color="red", size=(1200,800), leg=false, alpha=0.6)
    title!("Change in Total Deficit due to droughts "*season*", Threshold= " *string(Threshold))
    ylabel!("[m³/s]")
    absolute_change = boxplot!()

    plot(relativ_change, absolute_change, layout= (1,2), legend = false, size=(2400,1200), left_margin = [5mm 0mm], bottom_margin = 20px)
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Drought/drought_statistics_total_deficit"*string(Threshold)*"_all_years_"*season*".png")
end

Area_Zones = [98227533.0, 184294158.0, 83478138.0, 220613195.0]
Area_Catchment = sum(Area_Zones)
threshold = get_threshold_hydrological_drought(1981,2010, 0.9)
#Drought_45 = compare_hydrological_drought(path_45, threshold, "summer", Area_Catchment, "Gailtal")
#Drought_85 = compare_hydrological_drought(path_85, threshold, "summer", Area_Catchment, "Gailtal")
# #plot_drought_total_deficit(Drought_45, Drought_85, threshold, "Gailtal", "summer")
plot_drought_statistics_change(Drought_45, Drought_85, threshold, "Gailtal", "summer")
#plot_drought_statistics_rel_change(Drought_45, Drought_85, threshold, "Gailtal", "summer")
