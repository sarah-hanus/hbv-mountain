using DataFrames
using Plots
using GLM

Discharge = CSV.read("Gailtal/Q-Tagesmittel-212670.csv", header= 2, skipto=2, decimal=',', delim = ';', types=[String, Float64])
Discharge = convert(Matrix, Discharge)
startindex = findfirst(isequal("01.01.1994 00:00:00"), Discharge)
endindex = findfirst(isequal("31.12.2006 00:00:00"), Discharge)
Observed_Discharge = Float64[]
append!(Observed_Discharge, Discharge[startindex[1]:endindex[1],2])
ID_Prec_Zones = [113589, 113597, 113670, 114538]
Skipto = [24, 22, 22, 22]
Area_Zones = [98227533, 184294158, 83478138, 220613195]

Timeseries = Array{Date, 1}
Total_Precipitation = zeros(length(Observed_Discharge))
for i in 1: length(ID_Prec_Zones)
        #print(ID_Prec_Zones)
        Precipitation = CSV.read("Gailtal/N-Tagessummen-"*string(ID_Prec_Zones[i])*".csv", header= false, skipto=Skipto[i], missingstring = "L\xfccke", decimal=',', delim = ';')
        Precipitation_Array = convert(Matrix, Precipitation)
        startindex = findfirst(isequal("01.01.1994 07:00:00   "), Precipitation_Array)
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
        Dates_Array = convert(Vector, df[:,1])
        global Total_Precipitation += Precipitation_Array
        global Timeseries = Dates_Array
end
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

length_dry, start, ending = dryspells(Total_Precipitation, Timeseries)
index_14daysdry = findall(x -> x >= 10 && x < 30, length_dry)
Interception = Float64[]
kvalue = Float64[]
plot()
for z in index_14daysdry
        start_dryperiod = start[z]
        ending_dryperiod = ending[z]
        print(z)
        @assert ending_dryperiod - start_dryperiod + 1 == length_dry[z]
        Current_Observed_Discharge = Observed_Discharge[start_dryperiod:ending_dryperiod] * 3600 * 24 / sum(Area_Zones) * 1000
        Timespan = collect(1:length_dry[z])
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
        plot(Timespan, linearFit)
        plot!(Timespan, Current_Observed_Discharge)
        xlabel!("Days")
        ylabel!("Discharge")
        savefig("recessioncurves.png")
end

GWstorage = Interception ./ kvalue
GWstorage = GWstorage[findall(x -> x < 0, GWstorage)]
print(mean(GWstorage), " min ", minimum(GWstorage), " max ",maximum(GWstorage),"\n")

kvalue = kvalue[findall(x -> x < 0, kvalue)]
print(mean(kvalue))

#plot(Observed_Discharge * 3600 * 24 / sum(Area_Zones) * 1000, xylims = (0,1000),ylims = (0,10))
#xaxis!()

# ks = 0.001 # 1/day
# Sslow = collect(250:300)
# Qslow = ks * Sslow
# plot(Sslow,Qslow)
# ylabel!("Discharge from GW")
# xlabel!("STorage of GW")
