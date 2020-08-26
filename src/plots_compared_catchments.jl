using Plots
using StatsPlots
using DelimitedFiles
using Plots.PlotMeasures
relative_error(future, initial) = (future - initial) ./ initial

Area_Catchment_Gailtal = sum([98227533.0, 184294158.0, 83478138.0, 220613195.0])
Area_Catchment_Palten = sum([198175943.0, 56544073.0, 115284451.3])
Area_Catchment_Pitten = 115496400.
Area_Catchment_Silbertal = 100139168.
Area_Catchment_Defreggental = sum([235811198.0, 31497403.0])
Area_Catchment_Pitztal = sum([20651736.0, 145191864.0])

Catchment_Names = ["Pitten", "Palten", "Gailtal", "IllSugadin", "Defreggental", "Pitztal"]
Catchment_Height = [917, 1315, 1476, 1776, 2233, 2558]
Area_Catchments = [Area_Catchment_Pitten, Area_Catchment_Palten, Area_Catchment_Gailtal, Area_Catchment_Silbertal, Area_Catchment_Defreggental, Area_Catchment_Pitztal]
nr_runs = [300,300,298,300, 300, 300]

function plot_changes_monthly_discharge_all_catchments_past(All_Catchment_Names, Elevation, Area_Catchments)
    xaxis_45 = collect(1:12)
    #xaxis_85 = collect(2:2:24)
    # ----------------- Plot Absolute Change ------------------
    plot()
    Farben_85 = palette(:reds)
    Farben_45 = palette(:blues)
    all_boxplots = []


    for (i,Catchment_Name) in enumerate(All_Catchment_Names)
        monthly_changes_85 = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Monthly_Discharge/discharge_months_8.5.txt", ',')
        months_85 = monthly_changes_85[:,1]
        Monthly_Discharge_past_85 = monthly_changes_85[:,2]
        Monthly_Discharge_future_85  = monthly_changes_85[:,3]
        monthly_changes_45 = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Monthly_Discharge/discharge_months_4.5.txt", ',')
        months_45 = monthly_changes_45[:,1]
        Monthly_Discharge_past_45 = monthly_changes_45[:,2]
        Monthly_Discharge_future_45  = monthly_changes_45[:,3]
        Monthly_Discharge_Change_45  = monthly_changes_45[:,4]
        plot()
        box = []
        Monthly_Discharge_past_45 = convertDischarge(Monthly_Discharge_past_45, Area_Catchments[i])
        for month in 1:12
            #boxplot!([xaxis_45[month]],relative_error(Monthly_Discharge_future_45[findall(x-> x == month, months_45)], Monthly_Discharge_past_45[findall(x-> x == month, months_45)])*100, size=(2000,800), leg=false, color=["blue"], alpha=0.8)
            #boxplot!([xaxis_85[month]],relative_error(Monthly_Discharge_future_85[findall(x-> x == month, months_45)], Monthly_Discharge_past_85[findall(x-> x == month, months_45)])*100, size=(2000,800), leg=false, color=["red"], left_margin = [5mm 0mm], minorticks = true, gridlinewidth=2, framestyle = :box)
            boxplot!([xaxis_45[month]], Monthly_Discharge_past_45[findall(x-> x == month, months_45)], size=(2000,800), leg=false, color=["blue"], alpha=0.8)
        end
        #ylabel!("Relative Change in Average monthly Discharge [%]", yguidefontsize=20)
        ylabel!("[mm/d]", yguidefontsize=20)
        #title!("Relative Change in Discharge RCP 4.5 =blue, RCP 4.5 = red")
        if Catchment_Name == "Pitten"
            title!("Feistritztal ("*string(Elevation[i])*"m)", titlefont = font(20))
        elseif Catchment_Name == "IllSugadin"
            title!("Silbertal ("*string(Elevation[i])*"m)", titlefont = font(20))
        else
            title!(Catchment_Name*" ("*string(Elevation[i])*"m)", titlefont = font(20))
        end
        boxplot!(left_margin = [5mm 0mm], bottom_margin = 20px, xtickfont = font(20), ytickfont = font(20))
        # ylims!((-100,275))
        # yticks!([-100:50:275;])
        ylims!((0,7))
        yticks!([0:1:7;])
        #hline!([0], color=["grey"], linestyle = :dash)
        #hline!([100], color=["grey"], linestyle = :dash)
        #hline!([50], color=["grey"], linestyle = :dash)
        #hline!([-25], color=["grey"], linestyle = :dash)
        xticks!([1:12;], ["Jan", "Feb", "Mar", "Apr", "May","Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])
        box = boxplot!()
        push!(all_boxplots, box)
    end
    plot(all_boxplots[1], all_boxplots[2], all_boxplots[3], all_boxplots[4], all_boxplots[5], all_boxplots[6], layout= (3,2), legend = false, size=(2000,1500), left_margin = [5mm 0mm], bottom_margin = 20px, yguidefontsize=20, xtickfont = font(20), ytickfont = font(20), dpi=300)
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/monthly_discharges_all_catchments_past_new.png")
end

function plot_changes_monthly_discharge_all_catchments(All_Catchment_Names, Elevation)
    xaxis_45 = collect(1:2:23)
    xaxis_85 = collect(2:2:24)
    # ----------------- Plot Absolute Change ------------------
    plot()
    Farben_85 = palette(:reds)
    Farben_45 = palette(:blues)
    all_boxplots = []


    for (i,Catchment_Name) in enumerate(All_Catchment_Names)
        monthly_changes_85 = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Monthly_Discharge/discharge_months_8.5.txt", ',')
        months_85 = monthly_changes_85[:,1]
        Monthly_Discharge_past_85 = monthly_changes_85[:,2]
        Monthly_Discharge_future_85  = monthly_changes_85[:,3]
        monthly_changes_45 = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Monthly_Discharge/discharge_months_4.5.txt", ',')
        months_45 = monthly_changes_45[:,1]
        Monthly_Discharge_past_45 = monthly_changes_45[:,2]
        Monthly_Discharge_future_45  = monthly_changes_45[:,3]
        Monthly_Discharge_Change_45  = monthly_changes_45[:,4]
        plot()
        box = []
        for month in 1:12
            boxplot!([xaxis_45[month]],relative_error(Monthly_Discharge_future_45[findall(x-> x == month, months_45)], Monthly_Discharge_past_45[findall(x-> x == month, months_45)])*100, size=(2000,800), leg=false, color=["blue"], alpha=0.8)
            boxplot!([xaxis_85[month]],relative_error(Monthly_Discharge_future_85[findall(x-> x == month, months_45)], Monthly_Discharge_past_85[findall(x-> x == month, months_45)])*100, size=(2000,800), leg=false, color=["red"], left_margin = [5mm 0mm], minorticks = true, gridlinewidth=2, framestyle = :box)
        end
        ylabel!("[%]", yguidefontsize=20)
        #title!("Relative Change in Discharge RCP 4.5 =blue, RCP 4.5 = red")
        if Catchment_Name == "Pitten"
            title!("Feistritztal ("*string(Elevation[i])*"m)", titlefont = font(20))
        elseif Catchment_Name == "IllSugadin"
            title!("Silbertal ("*string(Elevation[i])*"m)", titlefont = font(20))
        else
            title!(Catchment_Name*" ("*string(Elevation[i])*"m)", titlefont = font(20))
        end
        boxplot!(left_margin = [5mm 0mm], bottom_margin = 20px, xtickfont = font(20), ytickfont = font(20))
        if Catchment_Name == "Defreggental" || Catchment_Name == "Pitztal"
            ylims!((-100,525))
            yticks!([-100:100:525;])
        else
            ylims!((-100,275))
            yticks!([-100:50:275;])
        end
        hline!([0], color=["grey"], linestyle = :dash)
        #hline!([100], color=["grey"], linestyle = :dash)
        #hline!([50], color=["grey"], linestyle = :dash)
        #hline!([-25], color=["grey"], linestyle = :dash)
        xticks!([1.5:2:23.5;], ["Jan", "Feb", "Mar", "Apr", "May","Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])
        box = boxplot!()
        push!(all_boxplots, box)
    end
    plot(all_boxplots[1], all_boxplots[2], all_boxplots[3], all_boxplots[4], all_boxplots[5], all_boxplots[6], layout= (3,2), legend = false, size=(2000,1500), left_margin = [5mm 0mm], bottom_margin = 20px, yguidefontsize=20, xtickfont = font(20), ytickfont = font(20), dpi=300)
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/monthly_discharges_all_catchments_new2.png")
end

function plot_changes_monthly_discharge_all_catchments_absolute(All_Catchment_Names, Elevation, Area_Catchments)
    xaxis_45 = collect(1:2:23)
    xaxis_85 = collect(2:2:24)
    # ----------------- Plot Absolute Change ------------------
    plot()
    Farben_85 = palette(:reds)
    Farben_45 = palette(:blues)
    all_boxplots = []


    for (i,Catchment_Name) in enumerate(All_Catchment_Names)
        monthly_changes_85 = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Monthly_Discharge/discharge_months_8.5.txt", ',')
        months_85 = monthly_changes_85[:,1]
        Monthly_Discharge_past_85 = monthly_changes_85[:,2]
        Monthly_Discharge_future_85  = monthly_changes_85[:,3]
        monthly_changes_45 = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Monthly_Discharge/discharge_months_4.5.txt", ',')
        months_45 = monthly_changes_45[:,1]
        Monthly_Discharge_past_45 = monthly_changes_45[:,2]
        Monthly_Discharge_future_45  = monthly_changes_45[:,3]
        Monthly_Discharge_Change_45  = monthly_changes_45[:,4]
        Monthly_Discharge_past_45 = convertDischarge(Monthly_Discharge_past_45, Area_Catchments[i])
        Monthly_Discharge_past_85 = convertDischarge(Monthly_Discharge_past_85, Area_Catchments[i])
        Monthly_Discharge_future_45 = convertDischarge(Monthly_Discharge_future_45, Area_Catchments[i])
        Monthly_Discharge_future_85 = convertDischarge(Monthly_Discharge_future_85, Area_Catchments[i])
        plot()
        box = []
        for month in 1:12
            boxplot!([xaxis_45[month]],Monthly_Discharge_future_45[findall(x-> x == month, months_45)] - Monthly_Discharge_past_45[findall(x-> x == month, months_45)] , size=(2000,800), leg=false, color=["blue"], alpha=0.8)
            boxplot!([xaxis_85[month]],Monthly_Discharge_future_85[findall(x-> x == month, months_45)] - Monthly_Discharge_past_85[findall(x-> x == month, months_45)], size=(2000,800), leg=false, color=["red"], left_margin = [5mm 0mm], minorticks = true, gridlinewidth=2, framestyle = :box)
        end
        ylabel!("[mm/d]", yguidefontsize=20)
        #title!("Relative Change in Discharge RCP 4.5 =blue, RCP 4.5 = red")
        if Catchment_Name == "Pitten"
            title!("Feistritztal ("*string(Elevation[i])*"m)", titlefont = font(20))
        elseif Catchment_Name == "IllSugadin"
            title!("Silbertal ("*string(Elevation[i])*"m)", titlefont = font(20))
        else
            title!(Catchment_Name*" ("*string(Elevation[i])*"m)", titlefont = font(20))
        end
        boxplot!(left_margin = [5mm 0mm], bottom_margin = 20px, xtickfont = font(20), ytickfont = font(20))

        ylims!((-3.5,3.5))
        yticks!([-3:1:3;])

        hline!([0], color=["grey"], linestyle = :dash)
        #hline!([100], color=["grey"], linestyle = :dash)
        #hline!([50], color=["grey"], linestyle = :dash)
        #hline!([-25], color=["grey"], linestyle = :dash)
        xticks!([1.5:2:23.5;], ["Jan", "Feb", "Mar", "Apr", "May","Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])
        box = boxplot!()
        push!(all_boxplots, box)
    end
    plot(all_boxplots[1], all_boxplots[2], all_boxplots[3], all_boxplots[4], all_boxplots[5], all_boxplots[6], layout= (3,2), legend = false, size=(2000,1500), left_margin = [5mm 0mm], bottom_margin = 20px, yguidefontsize=20, xtickfont = font(20), ytickfont = font(20), dpi=300)
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/monthly_discharges_all_catchments_absolute_change.png")
end

function plot_changes_monthly_temp_all_catchments(All_Catchment_Names, Elevation)
    xaxis_45 = collect(1:2:23)
    xaxis_85 = collect(2:2:24)
    # ----------------- Plot Absolute Change ------------------
    plot()
    Farben_85 = palette(:reds)
    Farben_45 = palette(:blues)
    all_boxplots_prec = []
    all_boxplots_temp = []
    for (h,Catchment_Name) in enumerate(All_Catchment_Names)
        Timeseries_Past = collect(Date(1981,1,1):Day(1):Date(2010,12,31))
        Timeseries_End = readdlm("/home/sarah/Master/Thesis/Data/Projektionen/End_Timeseries_45_85.txt",',')
        path_45 = "/home/sarah/Master/Thesis/Data/Projektionen/new_station_data_rcp45/rcp45/"
        path_85 = "/home/sarah/Master/Thesis/Data/Projektionen/new_station_data_rcp85/rcp85/"
        Name_Projections_45 = readdir(path_45)
        Name_Projections_85 = readdir(path_85)
        # if path_to_projections[end-2:end-1] == "45"
        #     index = 1
        #     rcp = "45"
        #     print(rcp, " ", path_to_projections)
        # elseif path_to_projections[end-2:end-1] == "85"
        #     index = 2
        #     rcp="85"
        #     print(rcp, " ", path_to_projections)
        # end

        all_months_all_runs = Float64[]
        average_monthly_Precipitation_past45 = Float64[]
        average_monthly_Precipitation_future45 = Float64[]
        average_monthly_Precipitation_past85 = Float64[]
        average_monthly_Precipitation_future85 = Float64[]
        average_monthly_Temperature_past45 = Float64[]
        average_monthly_Temperature_past85 = Float64[]
        average_monthly_Temperature_future45 = Float64[]
        average_monthly_Temperature_future85 = Float64[]

        if Catchment_Name == "Gailtal"
            ID_Prec_Zones = [113589, 113597, 113670, 114538]
            # size of the area of precipitation zones
            Area_Zones = [98227533.0, 184294158.0, 83478138.0, 220613195.0]
            Temp_Elevation = 1140.0
            Mean_Elevation_Catchment = 1500
            ID_temp = 113597
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
            Timeseries_Future = collect(Date(Timeseries_End[i,1]-29,1,1):Day(1):Date(Timeseries_End[i,1],12,31))
            #print(size(Timeseries_Past), size(Timeseries_Future))
            Timeseries_Proj = readdlm(path_45*name*"/"*Catchment_Name*"/pr_model_timeseries.txt")
            Timeseries_Proj = Date.(Timeseries_Proj, Dates.DateFormat("y,m,d"))
            Temperature = readdlm(path_45*name*"/"*Catchment_Name*"/tas_"*string(ID_temp)*"_sim1.txt", ',')[:,1]
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
                    Precipitation_Zone = readdlm(path_45*name*"/"*Catchment_Name*"/pr_"*string(ID_Prec_Zones[j])*"_sim1.txt", ',')[:,1]
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
                append!(average_monthly_Temperature_past45, current_Month_Temperature)
                append!(average_monthly_Temperature_future45, current_Month_Temperature_future)
                append!(all_months_all_runs, month)

                current_Month_Precipitation = Monthly_Precipitation_Past[findall(x->x == month, Month)]
                current_Month_Precipitation_future = Monthly_Precipitation_Future[findall(x->x == month, Month_future)]
                current_Month_Precipitation = mean(current_Month_Precipitation)
                current_Month_Precipitation_future = mean(current_Month_Precipitation_future)
                #error = relative_error(current_Month_Discharge_future, current_Month_Discharge)
                append!(average_monthly_Precipitation_past45, current_Month_Precipitation)
                append!(average_monthly_Precipitation_future45, current_Month_Precipitation_future)
            end
        end
        for (i, name) in enumerate(Name_Projections_85)
            Timeseries_Future = collect(Date(Timeseries_End[i,2]-29,1,1):Day(1):Date(Timeseries_End[i,2],12,31))
            #print(size(Timeseries_Past), size(Timeseries_Future))
            Timeseries_Proj = readdlm(path_85*name*"/"*Catchment_Name*"/pr_model_timeseries.txt")
            Timeseries_Proj = Date.(Timeseries_Proj, Dates.DateFormat("y,m,d"))
            Temperature = readdlm(path_85*name*"/"*Catchment_Name*"/tas_"*string(ID_temp)*"_sim1.txt", ',')[:,1]
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
                    Precipitation_Zone = readdlm(path_85*name*"/"*Catchment_Name*"/pr_"*string(ID_Prec_Zones[j])*"_sim1.txt", ',')[:,1]
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
                append!(average_monthly_Temperature_past85, current_Month_Temperature)
                append!(average_monthly_Temperature_future85, current_Month_Temperature_future)
                #append!(all_months_all_runs, month)

                current_Month_Precipitation = Monthly_Precipitation_Past[findall(x->x == month, Month)]
                current_Month_Precipitation_future = Monthly_Precipitation_Future[findall(x->x == month, Month_future)]
                current_Month_Precipitation = mean(current_Month_Precipitation)
                current_Month_Precipitation_future = mean(current_Month_Precipitation_future)
                #error = relative_error(current_Month_Discharge_future, current_Month_Discharge)
                append!(average_monthly_Precipitation_past85, current_Month_Precipitation)
                append!(average_monthly_Precipitation_future85, current_Month_Precipitation_future)
            end
        end
        plot()
        box_prec = []
        xaxis_1 = collect(1:1:12)
        for month in 1:12
            boxplot!([xaxis_45[month]], average_monthly_Precipitation_future45[findall(x-> x == month, all_months_all_runs)] - average_monthly_Precipitation_past45[findall(x-> x == month, all_months_all_runs)], size=(2000,800), leg=false, color=[Farben_45[1]], alpha=0.8)
            boxplot!([xaxis_85[month]],average_monthly_Precipitation_future85[findall(x-> x == month, all_months_all_runs)] - average_monthly_Precipitation_past85[findall(x-> x == month, all_months_all_runs)], size=(2000,800), leg=false, color=[Farben_45[2]], left_margin = [5mm 0mm], minorticks = true, gridlinewidth=2, framestyle = :box)
        end
        ylabel!("[mm/month]", yguidefontsize=20)
        #title!("Relative Change in Discharge RCP 4.5 =blue, RCP 4.5 = red")
        if Catchment_Name == "Pitten"
            title!("Feistritztal ("*string(Elevation[h])*"m)", titlefont = font(20))
        elseif Catchment_Name == "IllSugadin"
            title!("Silbertal ("*string(Elevation[h])*"m)", titlefont = font(20))
        else
            title!(Catchment_Name*" ("*string(Elevation[h])*"m)", titlefont = font(20))
        end
        boxplot!(left_margin = [5mm 0mm], bottom_margin = 20px, xtickfont = font(20), ytickfont = font(20))
        ylims!((-100,75))
        yticks!([-100:25:75;])
        hline!([0], color=["grey"], linestyle = :dash)
        xticks!([1.5:2:23.5;], ["Jan", "Feb", "Mar", "Apr", "May","Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])
        box_prec = boxplot!()
        push!(all_boxplots_prec, box_prec)
        # ------------ temp ------------
        plot()
        box_temp = []
        xaxis_1 = collect(1:1:12)
        for month in 1:12
            boxplot!([xaxis_45[month]], average_monthly_Temperature_future45[findall(x-> x == month, all_months_all_runs)] - average_monthly_Temperature_past45[findall(x-> x == month, all_months_all_runs)], size=(2000,800), leg=false, color=[Farben_85[1]], alpha=0.8)
            boxplot!([xaxis_85[month]],average_monthly_Temperature_future85[findall(x-> x == month, all_months_all_runs)] - average_monthly_Temperature_past85[findall(x-> x == month, all_months_all_runs)], size=(2000,800), leg=false, color=[Farben_85[2]], left_margin = [5mm 0mm], minorticks = true, gridlinewidth=2, framestyle = :box)
        end
        ylabel!("[°C]", yguidefontsize=20)
        #title!("Relative Change in Discharge RCP 4.5 =blue, RCP 4.5 = red")
        if Catchment_Name == "Pitten"
            title!("Feistritztal ("*string(Elevation[h])*"m)", titlefont = font(20))
        elseif Catchment_Name == "IllSugadin"
            title!("Silbertal ("*string(Elevation[h])*"m)", titlefont = font(20))
        else
            title!(Catchment_Name*" ("*string(Elevation[h])*"m)", titlefont = font(20))
        end
        boxplot!(left_margin = [5mm 0mm], bottom_margin = 20px, xtickfont = font(20), ytickfont = font(20))
        ylims!((0,8))
        yticks!([0:2:8;])
        hline!([0], color=["grey"], linestyle = :dash)
        xticks!([1.5:2:23.5;], ["Jan", "Feb", "Mar", "Apr", "May","Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])
        box_temp = boxplot!()
        push!(all_boxplots_temp, box_temp)
    end
    plot(all_boxplots_prec[1], all_boxplots_prec[2], all_boxplots_prec[3], all_boxplots_prec[4], all_boxplots_prec[5], all_boxplots_prec[6], layout= (3,2), legend = false, size=(2000,1500), left_margin = [5mm 0mm], bottom_margin = 20px, yguidefontsize=20, xtickfont = font(20), ytickfont = font(20), dpi=300)
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/monthly_precipitation_all_catchments_absolute_change_new.png")
    plot()
    plot(all_boxplots_temp[1], all_boxplots_temp[2], all_boxplots_temp[3], all_boxplots_temp[4], all_boxplots_temp[5], all_boxplots_temp[6], layout= (3,2), legend = false, size=(2000,1500), left_margin = [5mm 0mm], bottom_margin = 20px, yguidefontsize=20, xtickfont = font(20), ytickfont = font(20), dpi=300)
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/monthly_temperature_all_catchments_absolute_change.png")
end

#plot_changes_monthly_discharge_all_catchments_past(Catchment_Names, Catchment_Height, Area_Catchments)
#plot_changes_monthly_discharge_all_catchments(Catchment_Names, Catchment_Height)
#plot_changes_monthly_discharge_all_catchments_absolute(Catchment_Names, Catchment_Height, Area_Catchments)
#plot_changes_monthly_temp_all_catchments(Catchment_Names, Catchment_Height)
function plot_changes_annual_discharge_all_catchments(All_Catchment_Names, Area_Catchments, nr_runs)
    plot()
    for (i,Catchment_Name) in enumerate(All_Catchment_Names)
        monthly_changes_85 = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Monthly_Discharge/discharge_months_8.5.txt", ',')
        months_85 = monthly_changes_85[:,1]
        Monthly_Discharge_past_85 = monthly_changes_85[:,2]
        Monthly_Discharge_future_85  = monthly_changes_85[:,3]
        monthly_changes_45 = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Monthly_Discharge/discharge_months_4.5.txt", ',')
        months_45 = monthly_changes_45[:,1]
        Monthly_Discharge_past_45 = monthly_changes_45[:,2]
        Monthly_Discharge_future_45  = monthly_changes_45[:,3]
        Monthly_Discharge_Change_45  = monthly_changes_45[:,4]

        # for annual discharge
        relative_change_45, Total_Discharge_Past_45, Total_Discharge_Future_45 = annual_discharge_new(Monthly_Discharge_past_45, Monthly_Discharge_future_45, Area_Catchments[i], nr_runs[i])
        #relative_change_85, Total_Discharge_Past_85, Total_Discharge_Future_85 = annual_discharge_new(Monthly_Discharge_past_85, Monthly_Discharge_future_85, Area_Catchment, nr_runs)
        #boxplot!([Catchment_Name], relative_change_45*100, size=(2000,800), leg=false, color=["blue"]
        if Catchment_Name == "Pitten"
            Catchment_Name = "Feistritz"
        elseif Catchment_Name == "IllSugadin"
            Catchment_Name = "Silbertal"
        end
        violin!([Catchment_Name], relative_change_45*100, size=(2000,800), leg=false, color=["blue"], left_margin = [5mm 0mm], minorticks = true, gridlinewidth=2, framestyle = :box)
        boxplot!([Catchment_Name], relative_change_45*100, size=(2000,800), leg=false, color=["blue"], alpha=0.4)
        #boxplot!([rcps[2]], relative_change_85*100, size=(2000,800), left_margin = [5mm 0mm], leg=false, color=[Farben85[2]])
        #violin!([rcps[1]], relative_change_45*100, size=(2000,800), leg=false, color=[Farben45[2]], alpha=0.6)
        #violin!([rcps[2]], relative_change_85*100,size=(2000,800), left_margin = [5mm 0mm], leg=false, color=[Farben85[2]], alpha=0.6)
        ylims!((-35,35))
        yticks!([-35:10:35;])
        hline!([0], color=["grey"], linestyle = :dash)
        #ylabel!("Relative Change in Average Annual Discharge [%]")
        ylabel!("[%]")
        title!("Relative Change in Average Annual Discharge for RCP 4.5")
    end
    box_45 = boxplot!(left_margin = [5mm 0mm], bottom_margin = 70px, yguidefontsize=20, xtickfont = font(20), ytickfont = font(20), xrotation = 60)
    plot()
    for (i,Catchment_Name) in enumerate(All_Catchment_Names)
        monthly_changes_85 = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Monthly_Discharge/discharge_months_8.5.txt", ',')
        months_85 = monthly_changes_85[:,1]
        Monthly_Discharge_past_85 = monthly_changes_85[:,2]
        Monthly_Discharge_future_85  = monthly_changes_85[:,3]
        monthly_changes_45 = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Monthly_Discharge/discharge_months_4.5.txt", ',')
        months_45 = monthly_changes_45[:,1]
        Monthly_Discharge_past_45 = monthly_changes_45[:,2]
        Monthly_Discharge_future_45  = monthly_changes_45[:,3]
        Monthly_Discharge_Change_45  = monthly_changes_45[:,4]

        # for annual discharge
        #relative_change_45, Total_Discharge_Past_45, Total_Discharge_Future_45 = annual_discharge_new(Monthly_Discharge_past_45, Monthly_Discharge_future_45, Area_Catchments[i], nr_runs[i])
        relative_change_85, Total_Discharge_Past_85, Total_Discharge_Future_85 = annual_discharge_new(Monthly_Discharge_past_85, Monthly_Discharge_future_85, Area_Catchments[i], nr_runs[i])
        #boxplot!([Catchment_Name], relative_change_45*100, size=(2000,800), leg=false, color=["blue"]
        if Catchment_Name == "Pitten"
            Catchment_Name = "Feistritz"
            println("works")
        elseif Catchment_Name == "IllSugadin"
            Catchment_Name = "Silbertal"
        end
        violin!([Catchment_Name], relative_change_85*100, size=(2000,800), leg=false, color=["red"], left_margin = [5mm 0mm], minorticks = true, gridlinewidth=2, framestyle = :box)
        boxplot!([Catchment_Name], relative_change_85*100, size=(2000,800), leg=false, color=["red"], alpha=0.4)
        #boxplot!([rcps[2]], relative_change_85*100, size=(2000,800), left_margin = [5mm 0mm], leg=false, color=[Farben85[2]])
        #violin!([rcps[1]], relative_change_45*100, size=(2000,800), leg=false, color=[Farben45[2]], alpha=0.6)
        #violin!([rcps[2]], relative_change_85*100,size=(2000,800), left_margin = [5mm 0mm], leg=false, color=[Farben85[2]], alpha=0.6)
        ylims!((-35,35))
        yticks!([-35:10:35;])
        hline!([0], color=["grey"], linestyle = :dash)
        #ylabel!("Relative Change in Average Annual Discharge [%]")
        ylabel!("[%]")
        title!("Relative Change in Average Annual Discharge for RCP 4.5")
    end
    box_85 = boxplot!(left_margin = [5mm 0mm], bottom_margin = 70px, yguidefontsize=20, xtickfont = font(20), ytickfont = font(20), xrotation = 60)
    plot(box_45,box_85, layout=(2,1), size=(2200,1200))

    savefig("/home/sarah/Master/Thesis/Results/Projektionen/annual_discharges_all_catchments_45_85.png")
end
# @time begin
# plot_changes_annual_discharge_all_catchments(Catchment_Names, Area_Catchments, nr_runs)
# end

function plot_magnitude_changes_AMF_all_catchments(All_Catchment_Names)
    plot()
    for (i,Catchment_Name) in enumerate(All_Catchment_Names)
        annual_max_flow_45 = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/change_max_Annual_Discharge_4.5.txt",',')
        average_max_Discharge_past_45 = annual_max_flow_45[:,1]
        average_max_Discharge_future_45 = annual_max_flow_45[:,2]
        Timing_max_Discharge_past_45 = annual_max_flow_45[:,3]
        Timing_max_Discharge_future_45 = annual_max_flow_45[:,4]
        All_Concentration_past_45 = annual_max_flow_45[:,5]
        All_Concentration_future_45 = annual_max_flow_45[:,6]

        if Catchment_Name == "Pitten"
            Catchment_Name = "Feistritz"
            println("works")
        elseif Catchment_Name == "IllSugadin"
            Catchment_Name = "Silbertal"
        end
        violin!([Catchment_Name], relative_error(average_max_Discharge_future_45, average_max_Discharge_past_45)*100,color=["blue"])
        boxplot!([Catchment_Name], relative_error(average_max_Discharge_future_45, average_max_Discharge_past_45)*100, size=(2000,800), leg=false, color=["blue"], alpha=0.4, minorticks=true)
        ylims!((-35,50))
        yticks!([-30:10:50;])
        ylabel!("[%]")
        hline!([0], color=["grey"], linestyle = :dash)
        title!("Relative Change in Average Magnitude of Maximum Annual Flow for RCP 4.5")
    end
    box_45 = boxplot!(left_margin = [5mm 0mm], bottom_margin = 70px, yguidefontsize=20, xtickfont = font(20), ytickfont = font(20), xrotation = 60)
    plot()
    for (i,Catchment_Name) in enumerate(All_Catchment_Names)
        annual_max_flow_85 = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/change_max_Annual_Discharge_8.5.txt",',')
        average_max_Discharge_past_85 = annual_max_flow_85[:,1]
        average_max_Discharge_future_85 = annual_max_flow_85[:,2]
        Timing_max_Discharge_past_85 = annual_max_flow_85[:,3]
        Timing_max_Discharge_future_85 = annual_max_flow_85[:,4]
        All_Concentration_past_85 = annual_max_flow_85[:,5]
        All_Concentration_future_85 = annual_max_flow_85[:,6]

        if Catchment_Name == "Pitten"
            Catchment_Name = "Feistritz"
            println("works")
        elseif Catchment_Name == "IllSugadin"
            Catchment_Name = "Silbertal"
        end
        violin!([Catchment_Name], relative_error(average_max_Discharge_future_85, average_max_Discharge_past_85)*100,color=["red"])
        boxplot!([Catchment_Name], relative_error(average_max_Discharge_future_85, average_max_Discharge_past_85)*100, size=(2000,800), leg=false, color=["red"], alpha=0.4,  minorticks=true)
        ylims!((-35,55))
        yticks!([-30:10:55;])
        ylabel!("[%]")
        hline!([0], color=["grey"], linestyle = :dash)
        title!("Relative Change in Average Magnitude of Maximum Annual Flow for RCP 8.5")
    end
    box_85 = boxplot!(left_margin = [5mm 0mm], bottom_margin = 70px, yguidefontsize=20, xtickfont = font(20), ytickfont = font(20), xrotation = 60)
    plot(box_45,box_85, layout=(2,1), size=(2200,1200))
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/max_annual_discharges_all_catchments_45_85_new.png")
end

function plot_max_magnitude_changes_AMF_all_catchments(All_Catchment_Names, nr_runs)
    plot()
    for (i,Catchment_Name) in enumerate(All_Catchment_Names)
        max_discharge_prob_45 = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/change_max_Annual_Discharge_prob_distr_4.5.txt",',')
        max_Discharge_Past_45 = max_discharge_prob_45[:,1]
        max_Discharge_Future_45 = max_discharge_prob_45[:,2]
        Exceedance_Probability_45 = max_discharge_prob_45[:,3]
        Date_Past_45 = max_discharge_prob_45[:,4]
        Date_Future_45 = max_discharge_prob_45[:,5]
        max_discharge_past = Float64[]
        max_discharge_future = Float64[]
        for run in 1:14*nr_runs[i]
            append!(max_discharge_past, maximum(max_Discharge_Past_45[1+(run-1)*30:30*run]))
            append!(max_discharge_future, maximum(max_Discharge_Future_45[1+(run-1)*30:30*run]))
        end
        if Catchment_Name == "Pitten"
            Catchment_Name = "Feistritz"
            println("works")
        elseif Catchment_Name == "IllSugadin"
            Catchment_Name = "Silbertal"
        end
        violin!([Catchment_Name], relative_error(max_discharge_future, max_discharge_past)*100,color=["blue"])
        boxplot!([Catchment_Name], relative_error(max_discharge_future, max_discharge_past)*100, size=(2000,800), leg=false, color=["blue"], alpha=0.4, minorticks=true)
        ylims!((-35,50))
        yticks!([-30:10:50;])
        ylabel!("[%]")
        hline!([0], color=["grey"], linestyle = :dash)
        title!("Relative Change in Average Magnitude of Maximum Annual Flow for RCP 4.5")
    end
    box_45 = boxplot!(left_margin = [5mm 0mm], bottom_margin = 70px, yguidefontsize=20, xtickfont = font(20), ytickfont = font(20), xrotation = 60)
    plot()
    for (i,Catchment_Name) in enumerate(All_Catchment_Names)
        max_discharge_prob_45 = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/change_max_Annual_Discharge_prob_distr_8.5.txt",',')
        max_Discharge_Past_45 = max_discharge_prob_45[:,1]
        max_Discharge_Future_45 = max_discharge_prob_45[:,2]
        Exceedance_Probability_45 = max_discharge_prob_45[:,3]
        Date_Past_45 = max_discharge_prob_45[:,4]
        Date_Future_45 = max_discharge_prob_45[:,5]
        max_discharge_past = Float64[]
        max_discharge_future = Float64[]
        for run in 1:14*nr_runs[i]
            append!(max_discharge_past, maximum(max_Discharge_Past_45[1+(run-1)*30:30*run]))
            append!(max_discharge_future, maximum(max_Discharge_Future_45[1+(run-1)*30:30*run]))
        end

        if Catchment_Name == "Pitten"
            Catchment_Name = "Feistritz"
            println("works")
        elseif Catchment_Name == "IllSugadin"
            Catchment_Name = "Silbertal"
        end
        violin!([Catchment_Name], relative_error(max_discharge_future, max_discharge_past)*100,color=["red"])
        boxplot!([Catchment_Name], relative_error(max_discharge_future, max_discharge_past)*100, size=(2000,800), leg=false, color=["red"], alpha=0.4,  minorticks=true)
        ylims!((-35,55))
        yticks!([-30:10:55;])
        ylabel!("[%]")
        hline!([0], color=["grey"], linestyle = :dash)
        title!("Relative Change in Average Magnitude of Maximum Annual Flow for RCP 8.5")
    end
    box_85 = boxplot!(left_margin = [5mm 0mm], bottom_margin = 70px, yguidefontsize=20, xtickfont = font(20), ytickfont = font(20), xrotation = 60)
    plot(box_45,box_85, layout=(2,1), size=(2200,1200))
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/maxHQ_annual_discharges_all_catchments_45_85.png")
end

function plot_timing_changes_AMF_all_catchments(All_Catchment_Names)
    plot()
    for (i,Catchment_Name) in enumerate(All_Catchment_Names)
        annual_max_flow_45 = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/change_max_Annual_Discharge_4.5.txt",',')
        Timing_max_Discharge_past_45 = annual_max_flow_45[:,3]
        Timing_max_Discharge_future_45 = annual_max_flow_45[:,4]

        if Catchment_Name == "Pitten"
            Catchment_Name = "Feistritz"
            println("works")
        elseif Catchment_Name == "IllSugadin"
            Catchment_Name = "Silbertal"
        end
        Difference_Timing_45 = difference_timing(Timing_max_Discharge_past_45, Timing_max_Discharge_future_45)
        violin!([Catchment_Name], Difference_Timing_45,color=["blue"])
        boxplot!([Catchment_Name], Difference_Timing_45, size=(2000,800), leg=false, color=["blue"], alpha=0.4, minorticks=true)
        ylims!((-180,180))
        yticks!([-150:50:150;])
        ylabel!("[days]")
        hline!([0], color=["grey"], linestyle = :dash)
        title!("Absolute Change in Average Timing of Maximum Annual Flow for RCP 4.5")
    end
    box_45 = boxplot!(left_margin = [5mm 0mm], bottom_margin = 70px, yguidefontsize=20, xtickfont = font(20), ytickfont = font(20), xrotation = 60)
    plot()
    for (i,Catchment_Name) in enumerate(All_Catchment_Names)
        annual_max_flow_85 = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/change_max_Annual_Discharge_8.5.txt",',')
        Timing_max_Discharge_past_85 = annual_max_flow_85[:,3]
        Timing_max_Discharge_future_85 = annual_max_flow_85[:,4]

        if Catchment_Name == "Pitten"
            Catchment_Name = "Feistritz"
            println("works")
        elseif Catchment_Name == "IllSugadin"
            Catchment_Name = "Silbertal"
        end
        Difference_Timing_85 = difference_timing(Timing_max_Discharge_past_85, Timing_max_Discharge_future_85)
        violin!([Catchment_Name], Difference_Timing_85,color=["red"])
        boxplot!([Catchment_Name], Difference_Timing_85, size=(2000,800), leg=false, color=["red"], alpha=0.4, minorticks=true)
        ylims!((-180,180))
        yticks!([-150:50:150;])
        ylabel!("[days]")
        hline!([0], color=["grey"], linestyle = :dash)
        title!("Absolute Change in Average Timing of Maximum Annual Flow for RCP 8.5")
    end
    box_85 = boxplot!(left_margin = [5mm 0mm], bottom_margin = 70px, yguidefontsize=20, xtickfont = font(20), ytickfont = font(20), xrotation = 60)
    plot(box_45,box_85, layout=(2,1), size=(2200,1200))
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/timing_max_annual_discharges_all_catchments_45_85_new.png")
end

function plot_timing_changes_AMF_all_Catchments_fraction(All_Catchment_Names, Elevation, nr_runs, rcp_name)
    all_boxplots = []
    plot()
    for (j,Catchment_Name) in enumerate(All_Catchment_Names)
        if rcp_name == "45"
            max_discharge_prob = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/change_max_Annual_Discharge_prob_distr_4.5.txt", ',')
            Farben = palette(:blues)
        elseif rcp_name == "85"
            max_discharge_prob = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/change_max_Annual_Discharge_prob_distr_8.5.txt", ',')
            Farben = palette(:reds)
        end
        Date_Past = max_discharge_prob[:,4]
        Date_Future = max_discharge_prob[:,5]
        period_15_days_past, day_range_past = get_distributed_dates(Date_Past, 15, nr_runs[j])
        period_15_days_future, day_range_future = get_distributed_dates(Date_Future, 15, nr_runs[j])

        plot()
        for i in collect(0:15:366)
            current_past = period_15_days_past[findall(x->x==i, day_range_future)]
            current_future = period_15_days_future[findall(x->x==i, day_range_future)]
            #print(current_past[1:10])
            #plot!(mean(current_past)*100, leg=false, size=(1500,800), color=[Farben[1]])
            #scatter!([count, mean(current_past)*100], leg=false, size=(1500,800), color=[Farben[1]], left_margin = [5mm 0mm], bottom_margin = 20px, xrotation = 60)
            #plot!(mean(current_future)*100, leg=false, size=(1500,800), color=[Farben[2]])
            #scatter!([count+1,mean(current_future)*100], leg=false, size=(1500,800), color=[Farben[2]], left_margin = [5mm 0mm], bottom_margin = 20px, xrotation = 60)
            boxplot!(current_past*100, leg=false, size=(1500,800), color=[Farben[1]])
            boxplot!(current_future*100, leg=false, size=(1500,800), color=[Farben[2]], left_margin = [5mm 0mm], bottom_margin = 20px, xrotation = 60)
            #count+=2
        end
        ylabel!("[%]", yguidefontsize=12)
        #title!("Relative Change in Discharge RCP 4.5 =blue, RCP 4.5 = red")
        if Catchment_Name == "Pitten"
            title!("Feistritztal ("*string(Elevation[j])*"m)")
        elseif Catchment_Name == "IllSugadin"
            title!("Silbertal ("*string(Elevation[j])*"m)")
        else
            title!(Catchment_Name*" ("*string(Elevation[j])*"m)")
        end
        boxplot!(left_margin = [5mm 0mm], bottom_margin = 20px, minorticks = true, xtickfont = font(12), ytickfont = font(12), gridlinewidth=2, framestyle = :box)
        if Catchment_Name == "Defreggental" || Catchment_Name == "Pitztal"
            ylims!((0,65))
            yticks!([0:10:60;])
        else
            ylims!((0,45))
            yticks!([0:10:40;])
        end
        xticks!([2.5:4:47.5;], ["Jan", "Feb", "Mar", "Apr", "May","Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])
        xlims!((0,52))
        #xticks!([1.5:2:48.5;],["Begin Jan", "End Jan", "Begin Feb", "End Feb", "Begin Mar", "End Mar", "Begin Apr", "End Apr", "Begin May", "End May", "Begin June", "End June","Begin Jul", "End Jul", "Begin Aug", "Eng Aug", "Begin Sep", "End Sep", "Begin Oct", "End Oct", "Begin Nov", "End Nov", "Begin Dec", "End Dec"])
        box = boxplot!()
        push!(all_boxplots, box)
    end
    plot(all_boxplots[1], all_boxplots[2], all_boxplots[3], all_boxplots[4], all_boxplots[5], all_boxplots[6], layout= (3,2), legend = false, size=(2200,1500), left_margin = [5mm 0mm], bottom_margin = 20px)#, yguidefontsize=20, xtickfont = font(15), ytickfont = font(15))
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/AMF_timing_all_catchments_"*rcp_name*"_new.png")
end
#plot_magnitude_changes_AMF_all_catchments(Catchment_Names)
#plot_timing_changes_AMF_all_catchments(Catchment_Names)
#plot_max_magnitude_changes_AMF_all_catchments(Catchment_Names, nr_runs)
function plot_timing_changes_AMF_all_Catchments_fraction_new(All_Catchment_Names, Elevation, nr_runs, rcp_name)
    all_boxplots = []
    plot()
    for (j,Catchment_Name) in enumerate(All_Catchment_Names)
        if rcp_name == "45"
            max_discharge_prob = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/change_max_Annual_Discharge_prob_distr_4.5.txt", ',')
            Farben = palette(:blues)
        elseif rcp_name == "85"
            max_discharge_prob = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/change_max_Annual_Discharge_prob_distr_8.5.txt", ',')
            Farben = palette(:reds)
        end
        Date_Past = max_discharge_prob[:,4]
        Date_Future = max_discharge_prob[:,5]
        period_15_days_past, day_range_past = get_distributed_dates(Date_Past, 15, nr_runs[j])
        period_15_days_future, day_range_future = get_distributed_dates(Date_Future, 15, nr_runs[j])

        plot()
        #print(size(period_15_days_future))
        mean_per_15_days_past = Float64[]
        mean_per_15_days_future = Float64[]
        for i in collect(0:15:366)
            current_past = period_15_days_past[findall(x->x==i, day_range_future)]
            current_future = period_15_days_future[findall(x->x==i, day_range_future)]
            append!(mean_per_15_days_past, mean(current_past)*100)
            append!(mean_per_15_days_future, mean(current_future)*100)
        end
        print(size(mean_per_15_days_past))
        plot!(mean_per_15_days_past, leg=false, size=(1500,800), linestyle = :dash, color=[Farben[1]])
        scatter!(mean_per_15_days_past, leg=false, size=(1500,800), markercolor=[Farben[1]], markersize=7, markerstrokecolor=[Farben[1]],left_margin = [5mm 0mm], bottom_margin = 20px, xrotation = 60)
        plot!(mean_per_15_days_future, leg=false, size=(1500,800), linestyle = :dash,color=[Farben[2]])
        scatter!(mean_per_15_days_future, leg=false, size=(1500,800), color=[Farben[2]],markersize=7, markerstrokecolor=[Farben[2]], left_margin = [5mm 0mm], bottom_margin = 20px, xrotation = 60)


        ylabel!("[%]", yguidefontsize=12)
        #title!("Relative Change in Discharge RCP 4.5 =blue, RCP 4.5 = red")
        if Catchment_Name == "Pitten"
            title!("Feistritztal ("*string(Elevation[j])*"m)")
        elseif Catchment_Name == "IllSugadin"
            title!("Silbertal ("*string(Elevation[j])*"m)")
        else
            title!(Catchment_Name*" ("*string(Elevation[j])*"m)")
        end
        #boxplot!(left_margin = [5mm 0mm], bottom_margin = 20px, minorticks = true, xtickfont = font(12), ytickfont = font(12), gridlinewidth=2, framestyle = :box)
        ylims!((0,35))
        yticks!([0:5:35;])
        xticks!([1.5:2:23.5;], ["Jan", "Feb", "Mar", "Apr", "May","Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])
        xlims!((0,25))
        #xticks!([1.5:2:48.5;],["Begin Jan", "End Jan", "Begin Feb", "End Feb", "Begin Mar", "End Mar", "Begin Apr", "End Apr", "Begin May", "End May", "Begin June", "End June","Begin Jul", "End Jul", "Begin Aug", "Eng Aug", "Begin Sep", "End Sep", "Begin Oct", "End Oct", "Begin Nov", "End Nov", "Begin Dec", "End Dec"])
        box = plot!(left_margin = [5mm 0mm], bottom_margin = 20px, minorticks = true, xtickfont = font(12), ytickfont = font(12), gridlinewidth=2, framestyle = :box)
        push!(all_boxplots, box)
    end
    plot(all_boxplots[1], all_boxplots[2], all_boxplots[3], all_boxplots[4], all_boxplots[5], all_boxplots[6], layout= (3,2), legend = false, size=(2200,1500), left_margin = [5mm 0mm], bottom_margin = 20px)#, yguidefontsize=20, xtickfont = font(15), ytickfont = font(15))
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/AMF_timing_all_catchments_"*rcp_name*"_different_new.png")
end

#plot_timing_changes_AMF_all_Catchments_fraction(Catchment_Names, Catchment_Height, nr_runs, "85")
#plot_timing_changes_AMF_all_Catchments_fraction_new(Catchment_Names, Catchment_Height, nr_runs, "45")
function plot_magnitude_changes_AMF_all_catchments_scatter(All_Catchment_Names, Elevation, Area_Catchments, nr_runs)
    plot()
    all_scatterplots = []
    for (i,Catchment_Name) in enumerate(All_Catchment_Names)
        annual_max_flow_45 = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/change_max_Annual_Discharge_4.5.txt",',')
        average_max_Discharge_past_45 = annual_max_flow_45[:,1]
        average_max_Discharge_future_45 = annual_max_flow_45[:,2]
        average_max_Discharge_past_45 = convertDischarge(average_max_Discharge_past_45, Area_Catchments[i])
        average_max_Discharge_future_45 = convertDischarge(average_max_Discharge_future_45, Area_Catchments[i])
        plot()
        current_plot = scatter!(average_max_Discharge_past_45, average_max_Discharge_future_45,color=["blue"],leg=false, alpha=0.4,markerstrokewidth= 0, minorticks=true, framestyle = :box)
        ylabel!("Future")
        xlabel!("Past")
        # ylims!((0,20))
        # yticks!([0:5:20;])
        # xlims!((0,20))
        # xticks!([0:5:20;])
        min_value = min(minimum(average_max_Discharge_past_45), minimum(average_max_Discharge_future_45))
        max_value = max(maximum(average_max_Discharge_past_45), maximum(average_max_Discharge_future_45))
        plot!([min_value,max_value],[min_value,max_value], color=["black"])
        if Catchment_Name == "Pitten"
            title!("Feistritztal ("*string(Elevation[i])*"m)")
        elseif Catchment_Name == "IllSugadin"
            title!("Silbertal ("*string(Elevation[i])*"m)")
        else
            title!(Catchment_Name*" ("*string(Elevation[i])*"m)")
        end
        push!(all_scatterplots, current_plot)
        #title!("Relative Change in Average Magnitude of Maximum Annual Flow for RCP 4.5")
    end
    plot45 = plot(all_scatterplots[1], all_scatterplots[2], all_scatterplots[3], all_scatterplots[4], all_scatterplots[5], all_scatterplots[6], layout= (3,2), legend = false, left_margin = [5mm 0mm], xguidefontsize=20, yguidefontsize=20, xtickfont = font(20), ytickfont = font(20), size=(2000,3000))
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/max_annual_discharges_magnitude_scatter_45_new.png")
    all_scatterplots = []
    plot()
    for (i,Catchment_Name) in enumerate(All_Catchment_Names)
        annual_max_flow_45 = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/change_max_Annual_Discharge_8.5.txt",',')
        average_max_Discharge_past_45 = annual_max_flow_45[:,1]
        average_max_Discharge_future_45 = annual_max_flow_45[:,2]
        average_max_Discharge_past_45 = convertDischarge(average_max_Discharge_past_45, Area_Catchments[i])
        average_max_Discharge_future_45 = convertDischarge(average_max_Discharge_future_45, Area_Catchments[i])
        plot()
        current_plot = scatter!(average_max_Discharge_past_45, average_max_Discharge_future_45,color=["red"],leg=false, alpha=0.4, markerstrokewidth= 0,minorticks=true, framestyle = :box)
        ylabel!("Future")
        xlabel!("Past")
        # ylims!((0,20))
        # yticks!([0:5:20;])
        # xlims!((0,20))
        # xticks!([0:5:20;])
        min_value = min(minimum(average_max_Discharge_past_45), minimum(average_max_Discharge_future_45))
        max_value = max(maximum(average_max_Discharge_past_45), maximum(average_max_Discharge_future_45))
        plot!([min_value,max_value],[min_value,max_value], color=["black"])
        if Catchment_Name == "Pitten"
            title!("Feistritztal ("*string(Elevation[i])*"m)")
        elseif Catchment_Name == "IllSugadin"
            title!("Silbertal ("*string(Elevation[i])*"m)")
        else
            title!(Catchment_Name*" ("*string(Elevation[i])*"m)")
        end
        push!(all_scatterplots, current_plot)
        #title!("Relative Change in Average Magnitude of Maximum Annual Flow for RCP 4.5")
    end
    plot85 = plot(all_scatterplots[1], all_scatterplots[2], all_scatterplots[3], all_scatterplots[4], all_scatterplots[5], all_scatterplots[6], layout= (3,2), legend = false, left_margin = [5mm 0mm], xguidefontsize=20, yguidefontsize=20, xtickfont = font(20), ytickfont = font(20), size=(2000,3000))
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/max_annual_discharges_magnitude_scatter_85.png")
end
function plot_magnitude_changes_AMF_all_catchments_scatter_gcm(All_Catchment_Names, Elevation, Area_Catchments, nr_runs)
    plot()
    all_scatterplots = []
    gcm_names = ["CNRM-CM5", "EC-EARTH", "CM5A-MR", "HadGEM2-ES", "MPI-ESM-LR"]
    Farben_gcm = ["green", "blue", "red", "grey", "yellow"]
    simulation_start = [1,4,8,10,13]
    simulation_end = [3,7,9,12,14]
    for (i,Catchment_Name) in enumerate(All_Catchment_Names)
        annual_max_flow_45 = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/change_max_Annual_Discharge_4.5.txt",',')
        average_max_Discharge_past_45 = annual_max_flow_45[:,1]
        average_max_Discharge_future_45 = annual_max_flow_45[:,2]
        average_max_Discharge_past_45 = convertDischarge(average_max_Discharge_past_45, Area_Catchments[i])
        average_max_Discharge_future_45 = convertDischarge(average_max_Discharge_future_45, Area_Catchments[i])
        plot()

        for gcm in 1:5
            println(simulation_start[gcm])
            println(simulation_start[gcm])
            scatter!(average_max_Discharge_past_45[1+(simulation_start[gcm]-1)*nr_runs[i]:simulation_end[gcm]*nr_runs[i]], average_max_Discharge_future_45[1+(simulation_start[gcm]-1)*nr_runs[i]:simulation_end[gcm]*nr_runs[i]],label = gcm_names[gcm], markerstrokewidth= 0, color =[Farben_gcm[gcm]], alpha=0.8, minorticks=true, framestyle = :box)
        end
        current_plot = scatter!()
        ylabel!("Future")
        xlabel!("Past")
        # ylims!((0,20))
        # yticks!([0:5:20;])
        # xlims!((0,20))
        # xticks!([0:5:20;])
        min_value = min(minimum(average_max_Discharge_past_45), minimum(average_max_Discharge_future_45))
        max_value = max(maximum(average_max_Discharge_past_45), maximum(average_max_Discharge_future_45))
        plot!([min_value,max_value],[min_value,max_value], color=["black"], leg=false)
        if Catchment_Name == "Pitten"
            title!("Feistritztal ("*string(Elevation[i])*"m)")
        elseif Catchment_Name == "IllSugadin"
            title!("Silbertal ("*string(Elevation[i])*"m)")
        else
            title!(Catchment_Name*" ("*string(Elevation[i])*"m)")
        end
        push!(all_scatterplots, current_plot)
        #title!("Relative Change in Average Magnitude of Maximum Annual Flow for RCP 4.5")
    end
    plot45 = plot(all_scatterplots[1], all_scatterplots[2], all_scatterplots[3], all_scatterplots[4], all_scatterplots[5], all_scatterplots[6], layout= (3,2), left_margin = [5mm 0mm], xguidefontsize=20, yguidefontsize=20, legend=:bottomright, xtickfont = font(20), ytickfont = font(20), size=(2000,3000), dpi=150)
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/max_annual_discharges_magnitude_scatter_45_gcm.png")
    all_scatterplots = []
    plot()
    for (i,Catchment_Name) in enumerate(All_Catchment_Names)
        annual_max_flow_45 = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/change_max_Annual_Discharge_8.5.txt",',')
        average_max_Discharge_past_45 = annual_max_flow_45[:,1]
        average_max_Discharge_future_45 = annual_max_flow_45[:,2]
        average_max_Discharge_past_45 = convertDischarge(average_max_Discharge_past_45, Area_Catchments[i])
        average_max_Discharge_future_45 = convertDischarge(average_max_Discharge_future_45, Area_Catchments[i])
        plot()
        for gcm in 1:5
            println(simulation_start[gcm])
            println(simulation_start[gcm])
            scatter!(average_max_Discharge_past_45[1+(simulation_start[gcm]-1)*nr_runs[i]:simulation_end[gcm]*nr_runs[i]], average_max_Discharge_future_45[1+(simulation_start[gcm]-1)*nr_runs[i]:simulation_end[gcm]*nr_runs[i]],label = gcm_names[gcm], markerstrokewidth= 0, color =[Farben_gcm[gcm]], alpha=0.8, minorticks=true, framestyle = :box)
        end
        current_plot = scatter!()
        ylabel!("Future")
        xlabel!("Past")
        # ylims!((0,20))
        # yticks!([0:5:20;])
        # xlims!((0,20))
        # xticks!([0:5:20;])
        min_value = min(minimum(average_max_Discharge_past_45), minimum(average_max_Discharge_future_45))
        max_value = max(maximum(average_max_Discharge_past_45), maximum(average_max_Discharge_future_45))
        plot!([min_value,max_value],[min_value,max_value], color=["black"], leg=false)
        if Catchment_Name == "Pitten"
            title!("Feistritztal ("*string(Elevation[i])*"m)")
        elseif Catchment_Name == "IllSugadin"
            title!("Silbertal ("*string(Elevation[i])*"m)")
        else
            title!(Catchment_Name*" ("*string(Elevation[i])*"m)")
        end
        push!(all_scatterplots, current_plot)
        #title!("Relative Change in Average Magnitude of Maximum Annual Flow for RCP 4.5")
    end
    plot45 = plot(all_scatterplots[1], all_scatterplots[2], all_scatterplots[3], all_scatterplots[4], all_scatterplots[5], all_scatterplots[6], layout= (3,2), left_margin = [5mm 0mm], xguidefontsize=20, yguidefontsize=20, legend=:bottomright, xtickfont = font(20), ytickfont = font(20), size=(2000,3000), dpi=150)
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/max_annual_discharges_magnitude_scatter_85_gcm.png")
end
#plot_magnitude_changes_AMF_all_catchments_scatter(Catchment_Names, Catchment_Height, Area_Catchments, nr_runs)
#plot_magnitude_changes_AMF_all_catchments_scatter_gcm(Catchment_Names, Catchment_Height, Area_Catchments, nr_runs)

function plot_magnitude_changes_max_AMF_all_catchments_scatter_gcm(All_Catchment_Names, Elevation, Area_Catchments, nr_runs)
    plot()
    all_scatterplots = []
    gcm_names = ["CNRM-CM5", "EC-EARTH", "CM5A-MR", "HadGEM2-ES", "MPI-ESM-LR"]
    Farben_gcm = ["green", "blue", "red", "grey", "yellow"]
    simulation_start = [1,4,8,10,13]
    simulation_end = [3,7,9,12,14]
    for (i,Catchment_Name) in enumerate(All_Catchment_Names)
        max_discharge_prob_45 = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/change_max_Annual_Discharge_prob_distr_4.5.txt",',')
        max_Discharge_Past_45 = max_discharge_prob_45[:,1]
        max_Discharge_Future_45 = max_discharge_prob_45[:,2]
        max_Discharge_Past_45 = convertDischarge(max_Discharge_Past_45, Area_Catchments[i])
        max_Discharge_Future_45 = convertDischarge(max_Discharge_Future_45, Area_Catchments[i])
        max_discharge_past = Float64[]
        max_discharge_future = Float64[]
        for run in 1:14*nr_runs[i]
            append!(max_discharge_past, maximum(max_Discharge_Past_45[1+(run-1)*30:30*run]))
            append!(max_discharge_future, maximum(max_Discharge_Future_45[1+(run-1)*30:30*run]))
        end
        plot()

        for gcm in 1:5
            println(simulation_start[gcm])
            println(simulation_start[gcm])
            scatter!(max_discharge_past[1+(simulation_start[gcm]-1)*nr_runs[i]:simulation_end[gcm]*nr_runs[i]], max_discharge_future[1+(simulation_start[gcm]-1)*nr_runs[i]:simulation_end[gcm]*nr_runs[i]],label = gcm_names[gcm], markerstrokewidth= 0, color =[Farben_gcm[gcm]], alpha=0.8, minorticks=true, framestyle = :box)
        end
        current_plot = scatter!()
        ylabel!("Future")
        xlabel!("Past")
        # ylims!((0,20))
        # yticks!([0:5:20;])
        # xlims!((0,20))
        # xticks!([0:5:20;])
        min_value = min(minimum(max_discharge_past), minimum(max_discharge_future))
        max_value = max(maximum(max_discharge_past), maximum(max_discharge_future))
        plot!([min_value,max_value],[min_value,max_value], color=["black"], leg=false)
        if Catchment_Name == "Pitten"
            title!("Feistritztal ("*string(Elevation[i])*"m)")
        elseif Catchment_Name == "IllSugadin"
            title!("Silbertal ("*string(Elevation[i])*"m)")
        else
            title!(Catchment_Name*" ("*string(Elevation[i])*"m)")
        end
        push!(all_scatterplots, current_plot)
        #title!("Relative Change in Average Magnitude of Maximum Annual Flow for RCP 4.5")
    end
    plot45 = plot(all_scatterplots[1], all_scatterplots[2], all_scatterplots[3], all_scatterplots[4], all_scatterplots[5], all_scatterplots[6], layout= (3,2), left_margin = [5mm 0mm], xguidefontsize=20, yguidefontsize=20, legend=:bottomright, xtickfont = font(20), ytickfont = font(20), size=(2000,3000), dpi=150)
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/HQmax_max_annual_discharges_magnitude_scatter_45_gcm.png")
    all_scatterplots = []
    plot()
    for (i,Catchment_Name) in enumerate(All_Catchment_Names)
        max_discharge_prob_45 = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/change_max_Annual_Discharge_prob_distr_8.5.txt",',')
        max_Discharge_Past_45 = max_discharge_prob_45[:,1]
        max_Discharge_Future_45 = max_discharge_prob_45[:,2]
        max_Discharge_Past_45 = convertDischarge(max_Discharge_Past_45, Area_Catchments[i])
        max_Discharge_Future_45 = convertDischarge(max_Discharge_Future_45, Area_Catchments[i])
        max_discharge_past = Float64[]
        max_discharge_future = Float64[]
        for run in 1:14*nr_runs[i]
            append!(max_discharge_past, maximum(max_Discharge_Past_45[1+(run-1)*30:30*run]))
            append!(max_discharge_future, maximum(max_Discharge_Future_45[1+(run-1)*30:30*run]))
        end
        plot()

        for gcm in 1:5
            println(simulation_start[gcm])
            println(simulation_start[gcm])
            scatter!(max_discharge_past[1+(simulation_start[gcm]-1)*nr_runs[i]:simulation_end[gcm]*nr_runs[i]], max_discharge_future[1+(simulation_start[gcm]-1)*nr_runs[i]:simulation_end[gcm]*nr_runs[i]],label = gcm_names[gcm], markerstrokewidth= 0, color =[Farben_gcm[gcm]], alpha=0.8, minorticks=true, framestyle = :box)
        end
        current_plot = scatter!()
        ylabel!("Future")
        xlabel!("Past")
        # ylims!((0,20))
        # yticks!([0:5:20;])
        # xlims!((0,20))
        # xticks!([0:5:20;])
        min_value = min(minimum(max_discharge_past), minimum(max_discharge_future))
        max_value = max(maximum(max_discharge_past), maximum(max_discharge_future))
        plot!([min_value,max_value],[min_value,max_value], color=["black"], leg=false)
        if Catchment_Name == "Pitten"
            title!("Feistritztal ("*string(Elevation[i])*"m)")
        elseif Catchment_Name == "IllSugadin"
            title!("Silbertal ("*string(Elevation[i])*"m)")
        else
            title!(Catchment_Name*" ("*string(Elevation[i])*"m)")
        end
        push!(all_scatterplots, current_plot)
        #title!("Relative Change in Average Magnitude of Maximum Annual Flow for RCP 4.5")
    end
    plot45 = plot(all_scatterplots[1], all_scatterplots[2], all_scatterplots[3], all_scatterplots[4], all_scatterplots[5], all_scatterplots[6], layout= (3,2), left_margin = [5mm 0mm], xguidefontsize=20, yguidefontsize=20, legend=:bottomright, xtickfont = font(20), ytickfont = font(20), size=(2000,3000), dpi=150)
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/HQ_max_max_annual_discharges_magnitude_scatter_85_gcm.png")
end

function plot_magnitude_changes_max_AMF_all_catchments_scatter(All_Catchment_Names, Elevation, Area_Catchments, nr_runs)
    plot()
    all_scatterplots = []
    for (i,Catchment_Name) in enumerate(All_Catchment_Names)
        max_discharge_prob_45 = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/change_max_Annual_Discharge_prob_distr_4.5.txt",',')
        max_Discharge_Past_45 = max_discharge_prob_45[:,1]
        max_Discharge_Future_45 = max_discharge_prob_45[:,2]
        max_Discharge_Past_45 = convertDischarge(max_Discharge_Past_45, Area_Catchments[i])
        max_Discharge_Future_45 = convertDischarge(max_Discharge_Future_45, Area_Catchments[i])
        max_discharge_past = Float64[]
        max_discharge_future = Float64[]
        for run in 1:14*nr_runs[i]
            append!(max_discharge_past, maximum(max_Discharge_Past_45[1+(run-1)*30:30*run]))
            append!(max_discharge_future, maximum(max_Discharge_Future_45[1+(run-1)*30:30*run]))
        end
        plot()
        current_plot = scatter!(max_discharge_past, max_discharge_future,color=["blue"],leg=false, alpha=0.4,markerstrokewidth= 0, minorticks=true, framestyle = :box)
        ylabel!("Future")
        xlabel!("Past")
        # ylims!((0,20))
        # yticks!([0:5:20;])
        # xlims!((0,20))
        # xticks!([0:5:20;])
        min_value = min(minimum(max_discharge_past), minimum(max_discharge_future))
        max_value = max(maximum(max_discharge_past), maximum(max_discharge_future))
        plot!([min_value,max_value],[min_value,max_value], color=["black"])
        if Catchment_Name == "Pitten"
            title!("Feistritztal ("*string(Elevation[i])*"m)")
        elseif Catchment_Name == "IllSugadin"
            title!("Silbertal ("*string(Elevation[i])*"m)")
        else
            title!(Catchment_Name*" ("*string(Elevation[i])*"m)")
        end
        push!(all_scatterplots, current_plot)
        #title!("Relative Change in Average Magnitude of Maximum Annual Flow for RCP 4.5")
    end
    plot45 = plot(all_scatterplots[1], all_scatterplots[2], all_scatterplots[3], all_scatterplots[4], all_scatterplots[5], all_scatterplots[6], layout= (3,2), legend = false, left_margin = [5mm 0mm], xguidefontsize=20, yguidefontsize=20, xtickfont = font(20), ytickfont = font(20), size=(2000,3000))
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/maxHQ_max_annual_discharges_magnitude_scatter_45_new.png")
    all_scatterplots = []
    plot()
    for (i,Catchment_Name) in enumerate(All_Catchment_Names)
        max_discharge_prob_45 = readdlm("/home/sarah/Master/Thesis/Results/Projektionen/"*Catchment_Name*"/PastvsFuture/Annual_Max_Discharge/change_max_Annual_Discharge_prob_distr_8.5.txt",',')
        max_Discharge_Past_45 = max_discharge_prob_45[:,1]
        max_Discharge_Future_45 = max_discharge_prob_45[:,2]
        max_Discharge_Past_45 = convertDischarge(max_Discharge_Past_45, Area_Catchments[i])
        max_Discharge_Future_45 = convertDischarge(max_Discharge_Future_45, Area_Catchments[i])
        max_discharge_past = Float64[]
        max_discharge_future = Float64[]
        for run in 1:14*nr_runs[i]
            append!(max_discharge_past, maximum(max_Discharge_Past_45[1+(run-1)*30:30*run]))
            append!(max_discharge_future, maximum(max_Discharge_Future_45[1+(run-1)*30:30*run]))
        end
        plot()
        current_plot = scatter!(max_discharge_past, max_discharge_future,color=["red"],leg=false, alpha=0.4,markerstrokewidth= 0, minorticks=true, framestyle = :box)
        ylabel!("Future")
        xlabel!("Past")
        # ylims!((0,20))
        # yticks!([0:5:20;])
        # xlims!((0,20))
        # xticks!([0:5:20;])
        min_value = min(minimum(max_discharge_past), minimum(max_discharge_future))
        max_value = max(maximum(max_discharge_past), maximum(max_discharge_future))
        plot!([min_value,max_value],[min_value,max_value], color=["black"])
        if Catchment_Name == "Pitten"
            title!("Feistritztal ("*string(Elevation[i])*"m)")
        elseif Catchment_Name == "IllSugadin"
            title!("Silbertal ("*string(Elevation[i])*"m)")
        else
            title!(Catchment_Name*" ("*string(Elevation[i])*"m)")
        end
        push!(all_scatterplots, current_plot)
        #title!("Relative Change in Average Magnitude of Maximum Annual Flow for RCP 4.5")
    end
    plot85 = plot(all_scatterplots[1], all_scatterplots[2], all_scatterplots[3], all_scatterplots[4], all_scatterplots[5], all_scatterplots[6], layout= (3,2), legend = false, left_margin = [5mm 0mm], xguidefontsize=20, yguidefontsize=20, xtickfont = font(20), ytickfont = font(20), size=(2000,3000))
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/maxHQ_max_annual_discharges_magnitude_scatter_85.png")
end

#plot_magnitude_changes_max_AMF_all_catchments_scatter(Catchment_Names, Catchment_Height, Area_Catchments, nr_runs)
plot_magnitude_changes_max_AMF_all_catchments_scatter_gcm(Catchment_Names, Catchment_Height, Area_Catchments, nr_runs)
