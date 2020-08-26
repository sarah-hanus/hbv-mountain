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
        Timeseries = collect(Date(1981,1,1):Day(1):Date(2010,12, 31))
        # 14 different projections
        Name_Projections = readdir(path)
        for (i, name) in enumerate(Name_Projections)
                println(i)
                plot()
                Snowstorage = readdlm(path*name*"/Gailtal/100_model_results_snow_storage_past_2010.csv", ',')
                print(size(Snowstorage))
                for h in 1:298
                        plot!(Timeseries, Snowstorage[h,:], color = ["black"], legend=false, size=(1800,1000))
                end
        #plot!(Timeseries[indexfirstday:indexlasttday], Observed_Discharge[indexfirstday:indexlasttday], label="Observed",size=(1800,1000), color = ["red"])
                ylabel!("Snow Storage [mm]")
                xlabel!("Time in Year")
                savefig("/home/sarah/Master/Thesis/Results/Projektionen/Gailtal/Comparison_Real_Proj/Snowstorage/"*name*"_Snow_Storage_all_years_past.png")
        end
end

path = "/home/sarah/Master/Thesis/Data/Projektionen/new_station_data_rcp45/rcp45/"
plot_snowstorage(path)
