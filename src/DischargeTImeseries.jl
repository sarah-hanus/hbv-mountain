using Dates
using DelimitedFiles
using CSV
using Plots

Discharge_Pitztal = CSV.read("Discharge/Q-Tagesmittel-201335.csv", header= false, skipto=23, decimal=',', delim = ';', types=[String, Float64])

print(typeof(Discharge_Pitztal[1,2]))
Discharge_Pitztal_Array = convert(Matrix, Discharge_Pitztal)

startindex = findfirst(isequal("01.01.1990 00:00:00"), Discharge_Pitztal_Array)
endindex = findfirst(isequal("01.01.2000 00:00:00"), Discharge_Pitztal_Array)



# for i in 1
#     t = 365 * i
#     Q = Discharge_Pitztal_Array[startindex[1] + (365 * (i-1)): startindex[1] + t,2]
#     plot(Q)
# end
i = 4
Discharge1993 = Discharge_Pitztal_Array[startindex[1] + (365 * (i-1)): startindex[1] + 365 * i,2]

plot([Discharge1990, Discharge1991, Discharge1992, Discharge1993], title= "Discharge Pitztal",label=["1990" "1991" "1992" "1993" "1994"])
xlabel!("Days of Year")
ylabel!("Discharge [m3/s]")
savefig("Discharge_Pitztal.png")
