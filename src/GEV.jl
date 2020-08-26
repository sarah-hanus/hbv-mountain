# get annual amxima of past series of Gailtal

#MF, timing_AMF = max_Annual_Discharge(Observed_Discharge_m3s, Timeseries_Past)

#writedlm("/home/sarah/Master/Thesis/GEV/Gailtal/1981_2010_observed.csv", AMF, ',')

#Gailtal_Discharge

path_45 = "/home/sarah/Master/Thesis/Data/Projektionen/new_station_data_rcp45/rcp45/"
Name_Projections_45 = readdir(path_45)
path_85 = "/home/sarah/Master/Thesis/Data/Projektionen/new_station_data_rcp85/rcp85/"
Name_Projections_85 = readdir(path_85)


Timeseries_Past = collect(Date(1983,1,1):Day(1):Date(2012,12,31))
# Discharge = convert(Matrix, Discharge_Gailtal)
# startindex = findfirst(isequal("01.01."*string(1983)*" 00:00:00"), Discharge)
# endindex = findfirst(isequal("31.12."*string(2012)*" 00:00:00"), Discharge)
# Observed_Discharge = Array{Float64,1}[]
# push!(Observed_Discharge, Discharge[startindex[1]:endindex[1],2])
# Observed_Discharge_m3s = Observed_Discharge[1]
#
# AMF, timing_AMF = max_Annual_Discharge(Observed_Discharge_m3s, Timeseries_Past)
Discharge_AMF = Float64[]
for i in 1:298
    max_Discharge_past, Date_max_Discharge_past = max_Annual_Discharge(All_Discharges[:,i], Timeseries_Past)
    append!(Discharge_AMF, sort(max_Discharge_past, rev = true))
end
# Timeseries_End = readdlm("/home/sarah/Master/Thesis/Data/Projektionen/End_Timeseries_45_85.txt",',')
# for (i, name) in enumerate(Name_Projections_45)
#     Timeseries_Future = collect(Date(Timeseries_End[i,index]-29,1,1):Day(1):Date(Timeseries_End[i,index],12,31))
#     Past_Discharge = readdlm(path_to_projections*name*"/"*Catchment_Name*"/300_model_results_discharge_past_2010.csv", ',')
#     println(size(Past_Discharge)[1])
#     Future_Discharge = readdlm(path_to_projections*name*"/"*Catchment_Name*"/300_model_results_discharge_future_2100.csv", ',')
#     #change_all_runs = Float64[]
#     for run in 1:size(Past_Discharge)[1]
#         max_Discharge_past, Date_max_Discharge_past = max_Annual_Discharge(Past_Discharge[run,:], Timeseries_Past)
#         max_Discharge_future, Date_max_Discharge_future = max_Annual_Discharge(Future_Discharge[run,:], Timeseries_Future)
#         append!(average_max_Discharge_past, mean(max_Discharge_past))
#         append!(average_max_Discharge_future, mean(max_Discharge_future))
#
