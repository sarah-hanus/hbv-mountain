using DelimitedFiles
using Plots
using Dates
# epot_past_45_3spinup = aridity_past45 .* prec_past45
# #epot_future_45 = aridity_future_45 .* prec_future_45
# #epot_future_45 = epot_future_45 * 365.25
# epot_past_45_3spinup = epot_past_45_3spinup * 365.25
# eact_past_45_3spinup = Float64[]
# for proj in 1:14
#     eact_past_45_current = evaporative_past_45[1+(proj-1)*nr_runs: nr_runs*proj] * prec_past45[proj]
#     append!(eact_past_45_3spinup, eact_past_45_current*365.25)
# end
#
# difference_epot_eact_3spinup = Float64[]
# for proj in 1:14
#     append!(difference_epot_eact_3spinup, epot_past_45_3spinup[proj] .- eact_past_45_3spinup[1+(proj-1)*nr_runs: nr_runs*proj])
#end
# append!(budyko_wrong45, findall(x->x <0, difference_epot_eact))
# append!(budyko_wrong85, findall(x->x <0, difference_epot_eact85))

function plot_snowstorage(path)
        Timeseries = collect(Date(1971,1,1):Day(1):Date(2100,12, 31))
        Timeseries_End = readdlm("/home/sarah/Master/Thesis/Data/Projektionen/End_Timeseries_45_85.txt",',')
        # 14 different projections
        if path[end-2:end-1] == "45"
            index = 1
            rcp = "45"
            print(rcp, " ", rcp)
        elseif path[end-2:end-1] == "85"
            index = 2
            rcp="85"
            print(rcp, " ", rcp)
        end
        Name_Projections = readdir(path)
        for (i, name) in enumerate(Name_Projections)
                Timeseries_Future = collect(Date(Timeseries_End[i,index]-29,1,1):Day(1):Date(Timeseries_End[i,index],12,31))
                #println(i)
                name = Name_Projections[i]
                plot()
                Snowstorage = readdlm(path*name*"/Pitztal/300_model_results_snow_storage_future_2100.csv", ',')
                print(size(Snowstorage))
                for h in 1:300
                        plot!(Timeseries_Future, Snowstorage[h,:], color = ["black"], legend=false, size=(1800,1000))
                end
        #plot!(Timeseries[indexfirstday:indexlasttday], Observed_Discharge[indexfirstday:indexlasttday], label="Observed",size=(1800,1000), color = ["red"])
                ylabel!("Snow Storage [mm]")
                xlabel!("Time in Year")
                savefig("/home/sarah/Master/Thesis/Results/Projektionen/Pitztal/Comparison_Real_Proj/Snowstorage/"*name*"_Snow_Storage_all_years_future.png")
        end
end

path = "/home/sarah/Master/Thesis/Data/Projektionen/new_station_data_rcp85/rcp85/"
plot_snowstorage(path)
