using CSV
using Plots
using DelimitedFiles


#Dischare_Dot = replace(read("Montafon/Q-Tagesmittel-200097.csv", String), ",", ".")
#discharge data in m3/s from river Alvier
#Discharge_Alvier  = CSV.read("Montafon/Q-Tagesmittel-200097.csv", skipto=22, delim=';', decimal=',', types=[String, Float64], header=["Date", "Discharge"])

#discharge data in m3/s from river Alvier
#Discharge_Ill  = CSV.read("Montafon/Q-Tagesmittel-231662.csv", skipto=22, delim=';', decimal=',', types=[String, Float64], header=["Date", "Discharge"])
Discharge_Ill_Array = convert(Matrix, Discharge_Ill)
Discharge_Alvier_Array = convert(Matrix, Discharge_Alvier)
#Discharge_Ill.Day= [Discharge_Ill.Date[:][1:2]]
index = findfirst(isequal("01.01.1990 00:00:00"), Discharge_Ill_Array)
#Discharge of Montafon Region
print()
#Discharge = zeros(length(Discharge_Alvier_Array[:,1]) - 1,2)

Discharge = Array{Any,2}(undef, length(Discharge_Alvier_Array[:,1]) - 1, 2)
Discharge[:,2]= Discharge_Alvier_Array[1:end-1,2] + Discharge_Ill_Array[index[1]:end-1,2]
Discharge[:,1] = Discharge_Alvier_Array[1:end-1,1]

writedlm( "Montafon/Discharge_Montafon.csv",  Discharge, ',')

# dates can be read using: y = DateTime("01.01.1990 00:00:00", dateformat"d.m.y HH:MM:SS")
