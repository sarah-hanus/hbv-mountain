using CSV
using Dates
local_path = "/home/sarah/"
# Area_Zones = [235811198.0 - 45000000, 31497403.0]
# Area_Catchment = sum(Area_Zones)
# Area_Zones_Percent = Area_Zones / Area_Catchment
# Total_Precipitation = Precipitation_All_Zones[1][:,1]*Area_Zones_Percent[1] + Precipitation_All_Zones[2][:,1]*Area_Zones_Percent[2]
# #Total_Precipitation = Total_Precipitation .* 1.1
# function convertDischarge(Discharge, Area)
#         Discharge_mm = Discharge / Area * (24 * 3600 * 1000)
#         return Discharge_mm
# end
#
# startyear = 1982
# endyear = 1987
# # timeperiod for which model should be run (look if timeseries of data has same length)
# Timeseries = collect(Date(startyear, 1, 1):Day(1):Date(endyear,12,31))
#
# Discharge = CSV.read(local_path*"HBVModel/Defreggental/Q-Tagesmittel-212100.csv", header= false, skipto=26, decimal=',', delim = ';', types=[String, Float64])
# Discharge = convert(Matrix, Discharge)
# startindex = findfirst(isequal("01.01."*string(startyear)*" 00:00:00"), Discharge)
# endindex = findfirst(isequal("31.12."*string(endyear)*" 00:00:00"), Discharge)
# Observed_Discharge = Array{Float64,1}[]
# push!(Observed_Discharge, Discharge[startindex[1]:endindex[1],2])
# Observed_Discharge = Observed_Discharge[1]
#
# Discharge_up = CSV.read(local_path*"HBVModel/Defreggental/Q15min212191.dat",  header= false, skipto=27, delim = ' ', ignorerepeated = true, types=[String, String,Float64])
# Discharge_up_daily = Discharge_up[findall(x->x=="00:30:00", Discharge_up[:,2]), :]
# Discharge_up_daily = convert(Matrix, Discharge_up_daily)
# Observed_Discharge_up = Discharge_up_daily[:,3]
#
# Observed_Discharge_diff = Observed_Discharge - Observed_Discharge_up
#
# Observed_Discharge_diff = convertDischarge(Observed_Discharge_diff, 222000000)
# Observed_Discharge = convertDischarge(Observed_Discharge, 267000000)

plot()
mean_Prec = Float64[]
for proj in 1:14
        yearly_Proj_Prec = Float64[]
        for i in 1:20
                #append!(yearly_observed_Discharge,sum(Observed_Discharge_diff[1+(i-1)*365:365*i]))
                append!(yearly_Proj_Prec,sum(All_Projections_Prec[1+(i-1)*365:365*i,proj]))
        end
        plot!(collect(1:20), yearly_Proj_Prec)
        append!(mean_Prec, mean(yearly_Proj_Prec))
end
savefig("/home/sarah/Master/Thesis/Results/Calibration/Silbertal/prec_proj.png")
