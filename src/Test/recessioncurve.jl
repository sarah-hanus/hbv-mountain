Discharge = CSV.read("Gailtal/Q-Tagesmittel-212670.csv", header= 2, skipto=2, decimal=',', delim = ';', types=[String, Float64])
Discharge = convert(Matrix, Discharge)
startindex = findfirst(isequal("01.01.1985 00:00:00"), Discharge)
endindex = findfirst(isequal("31.12.2006 00:00:00"), Discharge)
Observed_Discharge = Float64[]
append!(Observed_Discharge, Discharge[startindex[1]:endindex[1],2])


Total_Precipitation = zeros(length(Observed_Discharge))
for i in 1: length(ID_Prec_Zones)
        #print(ID_Prec_Zones)
        Precipitation = CSV.read("Gailtal/N-Tagessummen-"*string(ID_Prec_Zones[i])*".csv", header= false, skipto=Skipto[i], missingstring = "L\xfccke", decimal=',', delim = ';')
        Precipitation_Array = convert(Matrix, Precipitation)
        startindex = findfirst(isequal("01.01.1985 07:00:00   "), Precipitation_Array)
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
function dryspells(Precipitation)
        count = 0
        startindex = Int64[]
        endindex = Int64[]
        length_dryspell = Float64[]
        last_prec = 0.1
        for (i, prec) in enumerate(Total_Precipitation)
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
        end
        return length_dryspell, startindex, endindex
end

length_dry, start, ending = dryspells(Total_Precipitation)
index_14daysdry = findall(x -> x > 20, length_dry)
plot()
for z in index_14daysdry
        start_dryperiod = start[z]
        ending_dryperiod = ending[z]
        @assert ending_dryperiod - start_dryperiod + 1 == length_dry[z]

        plot!(Observed_Discharge[start_dryperiod:ending_dryperiod] * 3600 * 24 / sum(Area_Zones) * 1000)
        savefig("recessioncurves.png")
end
savefig


ks = 0.001
Sslow = collect(250:300)
Qslow = ks * Sslow
plot(Qslow)
