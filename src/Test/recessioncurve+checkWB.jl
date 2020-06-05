using DataFrames
using Plots
using GLM

# Discharge = CSV.read(local_path*"HBVModel/Feistritz/Q-Tagesmittel-214353.csv", header= false, skipto=388, decimal=',', delim = ';', types=[String, Float64])
# Discharge = convert(Matrix, Discharge)
# startindex = findfirst(isequal("01.01.1994 00:00:00"), Discharge)
# endindex = findfirst(isequal("31.12.2005 00:00:00"), Discharge)
# Observed_Discharge = Float64[]
# append!(Observed_Discharge, Discharge[startindex[1]:endindex[1],2])
# Area_Zones = [198175943.0, 56544073.0, 115284451.3]
# # ID_Prec_Zones = [113589, 113597, 113670, 114538]
# # Skipto = [24, 22, 22, 22]
# # Area_Zones = [98227533, 184294158, 83478138, 220613195]
#
# #Timeseries = Array{Date, 1}
# Timeseries = collect(Date(startyear, 1, 1):Day(1):Date(endyear,12,31))
#
# Total_Precipitation = check_waterbalance[findfirst(x->x == Date(1994,1,1), Timeseries):end,1]
# for i in 1: length(ID_Prec_Zones)
#         #print(ID_Prec_Zones)
#         Precipitation = CSV.read("Gailtal/N-Tagessummen-"*string(ID_Prec_Zones[i])*".csv", header= false, skipto=Skipto[i], missingstring = "L\xfccke", decimal=',', delim = ';')
#         Precipitation_Array = convert(Matrix, Precipitation)
#         startindex = findfirst(isequal("01.01.1994 07:00:00   "), Precipitation_Array)
#         endindex = findfirst(isequal("31.12.2006 07:00:00   "), Precipitation_Array)
#         Precipitation_Array = Precipitation_Array[startindex[1]:endindex[1],:]
#         Precipitation_Array[:,1] = Date.(Precipitation_Array[:,1], Dates.DateFormat("d.m.y H:M:S   "))
#         # find duplicates and remove them
#         df = DataFrame(Precipitation_Array)
#         df = unique!(df)
#         # drop missing values
#         df = dropmissing(df)
#         #print(size(df), typeof(df))
#         Precipitation_Array = convert(Vector, df[:,2]) * Area_Zones[i] / sum(Area_Zones)
#         Dates_Array = convert(Vector, df[:,1])
#         global Total_Precipitation += Precipitation_Array
#         global Timeseries = Dates_Array
# end
"""
Determines the summer dry spells from 1980 to 1990.

$(SIGNATURES)

The function needs as input, Precipitation data and the corresponding timeseries. It returns an array with the length of dry spells and arrays with the starting and end dates.
"""
function dryspells(Precipitation, Timeseries)
        count = 0
        startindex = Int64[]
        endindex = Int64[]
        length_dryspell = Float64[]
        last_prec = 0.1
        for (i, prec) in enumerate(Precipitation)
                if 5 <= Dates.month(Timeseries[i]) <= 10 && 1980 <= Dates.year(Timeseries[i]) <= 1990
                        if i == 1 && prec == 0
                                count += 1
                                append!(startindex, i)
                        elseif i == 1 && prec != 0
                                count = 0
                        elseif prec == 0 && last_prec != 0
                                count+=1
                                append!(startindex, i)
                        elseif prec == 0 && last_prec == 0
                                count+= 1
                        elseif prec != 0 && last_prec == 0
                                append!(endindex, i-1)
                                append!(length_dryspell, count)
                                count = 0
                        end
                        last_prec = prec
                else
                        if last_prec == 0
                                count+= 1
                        end
                end

        end
        return length_dryspell, startindex, endindex
end

"""
Convertes discharge from m³/s to mm.

$(SIGNATURES)

"""
function convertDischarge(Discharge, Area)
        Discharge_mm = Discharge / Area * (24 * 3600 * 1000)
        return Discharge_mm
end

"""
Plots the recession curves of the discharge during dry spells and determines the amount og water in the GW reservoir.

$(SIGNATURES)

The input besides, Precipitation and Discharge data with corresponding timeseries, is the area of the catchment,
the minimum length of the dry spell to include, as well as the number of days to omit at the beginning of dry spell to avoid including steep declines in regression.
"""
function plot_recessioncurve(Area_Zones, Observed_Discharge, Precipitation, Timeseries, Length_Dryspell, Omit_Days)
        length_dry, start, ending = dryspells(Total_Precipitation, Timeseries)
        index_14daysdry = findall(x -> x >= Length_Dryspell && x < 30, length_dry)
        print("Number of Dry Spells for Timeperiod: ", length(index_14daysdry), "\n")
        Interception = Float64[]
        kvalue = Float64[]
        plot()
        for z in index_14daysdry
                start_dryperiod = start[z]
                ending_dryperiod = ending[z]
                #print(z)
                @assert ending_dryperiod - start_dryperiod + 1 == length_dry[z]
                Current_Observed_Discharge = convertDischarge(Observed_Discharge[start_dryperiod+Omit_Days:ending_dryperiod], sum(Area_Zones))
                Timespan = collect(1:length_dry[z]-Omit_Days)
                # plot!(Timespan, Current_Observed_Discharge)
                # savefig("recessioncurves.png")
                #linear regression
                Data = DataFrame([Timespan, Current_Observed_Discharge])
                rename!(Data, Symbol.(["Days", "Discharge"]))
                # predicts values of dependend variables
                linearRegressor = lm(@formula(Discharge ~ Days), Data)
                #print(linearRegressor)
                append!(Interception, coeftable(linearRegressor).cols[1][1])
                append!(kvalue, coeftable(linearRegressor).cols[1][2])
                linearFit = predict(linearRegressor)
                plot!(Timespan, linearFit)
                plot!(Timespan, Current_Observed_Discharge)
                xlabel!("Days")
                ylabel!("Discharge")
                #savefig("/home/sarah/Master/Thesis/Results/Calibration/Feistritz/recessioncurves.png")

        end

        GWstorage = Interception ./ kvalue
        GWstorage = GWstorage[findall(x -> x < 0, GWstorage)]
        print("mean GW Storage", round(mean(GWstorage)), " min ", round(minimum(GWstorage)), " max ",round(maximum(GWstorage)),"\n")
        kvalue = kvalue[findall(x -> x < 0, kvalue)]
        print(mean(kvalue))
        mean_GW = abs(mean(GWstorage))
        title!("Mean GW: "*string(round(mean_GW))* " ks: "*string(round(mean(kvalue), digits=3)))
        savefig("/home/sarah/Master/Thesis/Results/Calibration/Feistritz/recessioncurves_Dryspelllength_"*string(Length_Dryspell)*"_"*string(Omit_Days)*".png")
end


"""
Checks the long term water balance.

$(SIGNATURES)

As input Discharge, Precipitation and Potential Evaporation Data for the same time period is needed as well as area of the catchment.
The output is average yearly water balance, an array with all yearly water balances, an array with yearly precipitation and an array with annual potential evaporation.
"""
function checkwaterbalance(Total_Precipitation, Discharge, Potential_Evaporation, Area)
        total_days = 0
        Annual_Pot_Evap = Float64[]
        Annual_Pot_Evap_Thorn_Daily = Float64[]
        Annual_Pot_Evap_Hagreaves = Float64[]
        Annual_Discharge = Float64[]
        Annual_Precipitation = Float64[]
        Observed_Discharge_mm = convertDischarge(Discharge, Area)
        for i in 1:20
                year = 1985 + i
                if i > 1
                        startday = 1 + total_days
                else
                        startday = 300
                end
                #days = Dates.daysinyear(year)
                days = 365
                endday = startday + days - 1
                Current_Annual_Discharge = sum(Observed_Discharge_mm[startday : endday])
                Current_Annual_Precipitation = sum(Total_Precipitation[startday : endday])
                Current_Annual_Pot_Evap_Daily = sum(Potential_Evaporation[startday : endday])
                #Current_Annual_Pot_Evap_Hag = sum(Evaporation_Hagreaves[startday : endday])
                append!(Annual_Pot_Evap_Thorn_Daily, Current_Annual_Pot_Evap_Daily)
                append!(Annual_Discharge, Current_Annual_Discharge)
                append!(Annual_Precipitation, Current_Annual_Precipitation)
                total_days += days
        end
        Average_Annual_Precipitation = mean(Annual_Precipitation)
        Average_Annual_Discharge = mean(Annual_Discharge)
        Average_Annual_Pot_Evap_Thorn_Daily = mean(Annual_Pot_Evap_Thorn_Daily)
        #Average_Annual_Pot_Evap_Hagreaves = mean(Annual_Pot_Evap_Hagreaves)
        Waterbalance_Thorn_Daily = Average_Annual_Precipitation - Average_Annual_Discharge - Average_Annual_Pot_Evap_Thorn_Daily
        Waterbalance_Yearly = Annual_Precipitation - Annual_Discharge - Annual_Pot_Evap_Thorn_Daily
        return Waterbalance_Thorn_Daily, Waterbalance_Yearly, Annual_Precipitation, Annual_Pot_Evap_Thorn_Daily
end

# daily_WB, WB, Annual_Prec, Annual_Epot = checkwaterbalance(Total_Precipitation, Observed_Discharge, Potential_Evaporation, Area_Catchment)
#
# scatter(Annual_Prec)
# xlabel!("Years")
# ylabel!("Yearly Precipitation [mm]")
# title!("Yearly Precipitation Feistritz: Mean= "*string(round(mean(Annual_Prec))))
# savefig("/home/sarah/Master/Thesis/Results/Calibration/Feistritz/check_precipitation.png")
#
# scatter(Annual_Epot)
# xlabel!("Years")
# ylabel!("Yearly Potential Evporation [mm]")
# title!("Yearly Potential Evaporation Feistritz: Mean= "*string(round(mean(Annual_Epot))))
# savefig("/home/sarah/Master/Thesis/Results/Calibration/Feistritz/check_evaporation.png")
