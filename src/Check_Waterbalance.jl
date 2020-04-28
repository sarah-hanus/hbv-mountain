# get discharge data in m3/s
using DataFrames
using Statistics
using Plots
Area_Zones = [98227533, 184294158, 83478138, 220613195]
Elevations_Catchment = Elevations(200, 400, 2800,1140, 1140)
Sunhours_Vienna = [8.83, 10.26, 11.95, 13.75, 15.28, 16.11, 15.75, 14.36, 12.63, 10.9, 9.28, 8.43]
# where to skip to in data file
Skipto = [24, 22, 22, 22]
ID_Prec_Zones = [113589, 113597, 113670, 114538]
#print(sum(Area_Zones))
Discharge = CSV.read("Gailtal/Q-Tagesmittel-212670.csv", header= 2, skipto=2, decimal=',', delim = ';', types=[String, Float64])
Discharge = convert(Matrix, Discharge)
startindex = findfirst(isequal("01.01.1987 00:00:00"), Discharge)
endindex = findfirst(isequal("31.12.2006 00:00:00"), Discharge)
Observed_Discharge = Float64[]
append!(Observed_Discharge, Discharge[startindex[1]:endindex[1],2])
# convert discharge into mm/d
Observed_Discharge_mm = Observed_Discharge * 3600 * 24 / sum(Area_Zones) * 1000

# get temperature data with min and max
Temperature_Min_Max = CSV.read("Gailtal/prenner_tag_19710.dat", header = true, skipto = 3, delim = ' ', ignorerepeated = true)
# get data for 20 years: from 1987 to end of 2006
Temperature_Min_Max = dropmissing(Temperature_Min_Max)
tmin = Temperature_Min_Max.tmin[14032: 21336] / 10
tmax = Temperature_Min_Max.tmax[14032: 21336] / 10
t = Temperature_Min_Max.t[14032: 21336] / 10

Timeseries = Date.(Temperature_Min_Max.datum[14032: 21336], Dates.DateFormat("yyyymmdd"))
# get potential evaporation hagreaves

Elevation_Zone_Catchment, t_Elevation_Catchment, Total_Elevationbands_Catchment = gettemperatureatelevation(Elevations_Catchment, t)
Elevation_Zone_Catchment, tmin_Elevation_Catchment, Total_Elevationbands_Catchment = gettemperatureatelevation(Elevations_Catchment, tmin)
Elevation_Zone_Catchment, tmax_Elevation_Catchment, Total_Elevationbands_Catchment = gettemperatureatelevation(Elevations_Catchment, tmax)
t_Mean_Elevation = t_Elevation_Catchment[:,findfirst(x-> x==1500, Elevation_Zone_Catchment)]
tmin_Mean_Elevation = tmin_Elevation_Catchment[:,findfirst(x-> x==1500, Elevation_Zone_Catchment)]
tmax_Mean_Elevation = tmax_Elevation_Catchment[:,findfirst(x-> x==1500, Elevation_Zone_Catchment)]

Latitude = 46.687991
Evaporation_Hagreaves, Radiation = getEpot(tmin_Mean_Elevation, t_Mean_Elevation, tmax_Mean_Elevation, 0.17, Timeseries, Latitude)


# get potential evaporation
Temperature = CSV.read("Gailtal/LTkont113597.csv", header=false, skipto = 20, missingstring = "L\xfccke", decimal='.', delim = ';')
Temperature_Array = convert(Matrix, Temperature)
startindex = findfirst(isequal("01.01.1987 07:00:00"), Temperature_Array)
endindex = findfirst(isequal("31.12.2006 23:45:00"), Temperature_Array)
Temperature_Array = Temperature_Array[startindex[1]: endindex[1],:]
Temperature_Array[:,1] = Date.(Temperature_Array[:,1], Dates.DateFormat("d.m.y H:M:S"))
Dates_Temperature_Daily, Temperature_Daily = daily_mean(Temperature_Array)
Elevation_Zone_Catchment, Temperature_Elevation_Catchment, Total_Elevationbands_Catchment = gettemperatureatelevation(Elevations_Catchment, Temperature_Daily)
# get the temperature data at the mean elevation to calculate the mean potential evaporation
Temperature_Mean_Elevation = Temperature_Elevation_Catchment[:,findfirst(x-> x==1500, Elevation_Zone_Catchment)]
#potential evaporation in mm
Potential_Evaporation = getEpot_thornthwaite(Temperature_Mean_Elevation, Dates_Temperature_Daily, Sunhours_Vienna)
Potential_Evaporation_Daily = getEpot_Daily_thornthwaite(Temperature_Mean_Elevation, Dates_Temperature_Daily, Sunhours_Vienna)

Monthly_Evaporation_fromDaily = Float64[]
Monthly_Evaporation = Float64[]
total_days = 1
for j in 1:20
        for i in 1:12
                startday = total_days
                print(total_days)
                days = Dates.daysinmonth(Date(1986+j,i, 1))
                endday = startday + days - 1
                Current_Potential_Evaporation = sum(Potential_Evaporation_Daily[startday : endday])
                Current = sum(Potential_Evaporation[startday : endday])
                append!(Monthly_Evaporation_fromDaily, Current_Potential_Evaporation)
                append!(Monthly_Evaporation, Current)
                global total_days += days
        end
end

scatter([Monthly_Evaporation[end-12:end], Monthly_Evaporation_fromDaily[end-12:end]], label= ["Monthly" "Daily Summed"])
xlabel!("Months")
ylabel!("Potential Evaporation Mean Monthly [mm]")
title!("Monthly Mean Potential Evaporation 2006 Gailtal")
savefig("potentialevaporation_monthlyGailtal.png")
#
plot([Potential_Evaporation[end-365:end], Potential_Evaporation_Daily[end-365:end]], label= ["Monthly" "Daily"])
xlabel!("Days")
ylabel!("Potential Evaporation [mm]")
title!("Potential Evaporation 2006 Gailtal")
savefig("potentialevaporationGailtal.png")

plot([Evaporation_Hagreaves[end-365:end], Potential_Evaporation_Daily[end-365:end]], label= ["Hagreaves" "Thornthwaite"])
xlabel!("Days")
ylabel!("Potential Evaporation [mm]")
title!("Potential Evaporation 2006 Gailtal")
savefig("HagreavesvsThornthwaiteGailtal.png")




# get precipitation data
Total_Precipitation = zeros(length(Temperature_Mean_Elevation))
for i in 1: length(ID_Prec_Zones)
        #print(ID_Prec_Zones)
        Precipitation = CSV.read("Gailtal/N-Tagessummen-"*string(ID_Prec_Zones[i])*".csv", header= false, skipto=Skipto[i], missingstring = "L\xfccke", decimal=',', delim = ';')
        Precipitation_Array = convert(Matrix, Precipitation)
        startindex = findfirst(isequal("01.01.1987 07:00:00   "), Precipitation_Array)
        endindex = findfirst(isequal("31.12.2006 07:00:00   "), Precipitation_Array)
        Precipitation_Array = Precipitation_Array[startindex[1]:endindex[1],:]
        Precipitation_Array[:,1] = Date.(Precipitation_Array[:,1], Dates.DateFormat("d.m.y H:M:S   "))
        # find duplicates and remove them
        df = DataFrame(Precipitation_Array)
        df = unique!(df)
        # drop missing values
        df = dropmissing(df)
        #print(size(df), typeof(df))
        Precipitation_Array = convert(Vector, df[:,2]) * Area_Zones[i] / sum(Area_Zones)
        global Total_Precipitation += Precipitation_Array
end

# the annual sum of precipitation, evaporation and discharge has to be given
# using dates
total_days = 0
Annual_Pot_Evap = Float64[]
Annual_Pot_Evap_Hagreaves = Float64[]
Annual_Discharge = Float64[]
Annual_Precipitation = Float64[]
for i in 1:20
        year = 1993 + i
        if i > 1
                startday = 1 + total_days
        else
                startday = 1
        end
        days = Dates.daysinyear(year)
        endday = startday + days - 1
        Current_Annual_Discharge = sum(Observed_Discharge_mm[startday : endday])
        Current_Annual_Precipitation = sum(Total_Precipitation[startday : endday])
        Current_Annual_Pot_Evap = sum(Potential_Evaporation[startday : endday])
        Current_Annual_Pot_Evap_Hag = sum(Evaporation_Hagreaves[startday : endday])
        append!(Annual_Pot_Evap, Current_Annual_Pot_Evap)
        append!(Annual_Pot_Evap_Hagreaves, Current_Annual_Pot_Evap_Hag)
        append!(Annual_Discharge, Current_Annual_Discharge)
        append!(Annual_Precipitation, Current_Annual_Precipitation)
        global total_days += days
end

Average_Annual_Precipitation = mean(Annual_Precipitation)
Average_Annual_Discharge = mean(Annual_Discharge)
Average_Annual_Pot_Evap = mean(Annual_Pot_Evap)
Average_Annual_Pot_Evap_Hagreaves = mean(Annual_Pot_Evap_Hagreaves)
# Waterbalance: Inflow - Outflow = 0
# Inflow = Precipitation, Outflow = Discharge and Actual Evaporation
# so waterbalance using Potential_Evaporation should be negative
Waterbalance = Average_Annual_Precipitation - Average_Annual_Discharge - Average_Annual_Pot_Evap
Waterbalance_Hagreaves = Average_Annual_Precipitation - Average_Annual_Discharge - Average_Annual_Pot_Evap_Hagreaves
# -80
# actual evaporation
Average_Actual_Evaporation = Average_Annual_Precipitation - Average_Annual_Discharge
#actual evaporation is 400, potential evaporation is 480

# calculate the ratio of Epot/Precipitation
Epot_Prec_Gailtal = Average_Annual_Pot_Evap / Average_Annual_Precipitation
Epot_Prec_Gailtal_Hagreaves = Average_Annual_Pot_Evap_Hagreaves / Average_Annual_Precipitation
# in order to calculate the actual evaporation according to Budyko
Budyko_Eact_P_Gailtal = ( Epot_Prec_Gailtal * tanh(1/Epot_Prec_Gailtal)* (1 - exp(-Epot_Prec_Gailtal)))^0.5
Budyko_Eact_Gailtal = Budyko_Eact_P_Gailtal * Average_Annual_Precipitation
Budyko_Eact_P_Gailtal_Hagreaves = ( Epot_Prec_Gailtal_Hagreaves * tanh(1/Epot_Prec_Gailtal_Hagreaves)* (1 - exp(-Epot_Prec_Gailtal_Hagreaves)))^0.5
Budyko_Eact_Gailtal_Hagreaves = Budyko_Eact_P_Gailtal * Average_Annual_Precipitation

plot(collect(0:1),collect(0:1), color="blue", label="Energy Limit")
plot!(collect(1:5), ones(5), color="lightblue", label="Water Limit")
Epot_Prec = collect(0:0.1:5)
Budyko_Eact_P = ( Epot_Prec .* tanh.(1 ./Epot_Prec) .* (ones(length(Epot_Prec)) - exp.(-Epot_Prec))).^0.5
part = ones(length(Epot_Prec)) - exp.(-Epot_Prec)
plot!(Epot_Prec, Budyko_Eact_P, label="Budyko")
#scatter!([Epot_Prec_Gailtal], [Budyko_Eact_P_Gailtal], markershape= :xcross, color = "black", label="Thornthwaite, Budyko")
scatter!([Epot_Prec_Gailtal], [Average_Actual_Evaporation / Average_Annual_Precipitation], markershape= :xcross, color = "black", label="Thornthwaite")
#scatter!([Epot_Prec_Gailtal_Hagreaves], [Budyko_Eact_P_Gailtal_Hagreaves], markershape= :xcross, color = "red", label="Hagreaves, Budyko")
scatter!([Epot_Prec_Gailtal_Hagreaves], [Average_Actual_Evaporation / Average_Annual_Precipitation], markershape= :xcross, color = "red", label="Hagreaves")
xlabel!("Epot/P")
ylabel!("Eact/P")
savefig("Budyko.png")
