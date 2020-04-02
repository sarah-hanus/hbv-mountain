using Dates
using DelimitedFiles
using CSV
using Plots

Discharge_Pitztal = CSV.read("Pitztal/pr_sim1.txt", header= false)

Precipitation = Discharge_Pitztal[1:365,20]
Precipitation2 = Discharge_Pitztal[366:366+365,20]
Precipitation3 = Discharge_Pitztal[732:1097,20]
Precipitation4 = Discharge_Pitztal[1098:1463,20]

plot([Precipitation, Precipitation2, Precipitation3, Precipitation4])
