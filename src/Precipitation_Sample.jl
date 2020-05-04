using Dates
using DelimitedFiles
using CSV
using Plots

Precipitation_Data = ["Gailtal/N-Tagessummen-113589.csv","Gailtal/N-Tagessummen-113597.csv","Gailtal/N-Tagessummen-113670.csv", "Gailtal/N-Tagessummen-114538.csv"]
# where to skip to in data file
Skipto = [24, 22, 22, 22]
# Lücken only at 01.01.2017 and for Defreggen at 01.01.1966
Precipitation_Gailtal = Array{Float64}[]

for i in 1:4
        Precipitation = CSV.read(Precipitation_Data[i], header= false, skipto=Skipto[i], missingstring = "L\xfccke", decimal=',', delim = ';')
        Precipitation_Array = convert(Matrix, Precipitation)
        startindex = findfirst(isequal("01.01.1980 07:00:00   "), Precipitation_Array)
        endindex = findfirst(isequal("31.12.2016 07:00:00   "), Precipitation_Array)
        Precipitation_Array = Precipitation_Array[startindex[1]:endindex[1],2]
        push!(Precipitation_Gailtal, Precipitation_Array)
end
i = 20

plot((Precipitation_Gailtal[1][1 + (i * 365): (i + 1) * 365]))
plot!((Precipitation_Gailtal[2][1 + (i * 365): (i + 1) * 365]))
plot!((Precipitation_Gailtal[3][1 + (i * 365): (i + 1) * 365]))
plot!((Precipitation_Gailtal[4][1 + (i * 365): (i + 1) * 365]))
# for i in 1:4
#         plot(Precipitation_Gailtal[i][1:365])
# end
