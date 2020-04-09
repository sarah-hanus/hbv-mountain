using CSV
using Plots
using Statistics
#Timeseries  = CSV.read("Pitztal/pr_model_timeseries.txt", header=["Year", "Month", "Day"])
#Timeseries = readdlm("Defreggental/tas_model_timeseries.txt")
Precipitation  = CSV.read("Defreggental/pr_sim1.txt", header=false)
Temperature = CSV.read("Defreggental/tas_sim1.txt", header=false)


#at outlet at 1000
grid_point = 68

# Temperature and Precipiation Data at Measured Elevation
#Precipitation_Sample = Precipitation[:,grid_point]/10
Temp_Sample_Low = Temperature[1:730,grid_point]/10 #makes a vector
Precipitation_Sample_Low = Precipitation[1:730,grid_point]/10
#grid point 23 at around 2300
Temp_Sample_High = Temperature[1:730,23]/10 #makes a vector
Precipitation_Sample_High = Precipitation[1:730,23]/10

plot([Temp_Sample_Low, Temp_Sample_High], title="DIfference")

Elevation, Prec_Elevation_Low, Temp_Elevation_Low = getelevationdata(100, 1000, 1000, 3500, 0.003, Temp_Sample_Low, Precipitation_Sample_Low)
Elevation, Prec_Elevation_High, Temp_Elevation_High = getelevationdata(100, 1000, 2600, 3500, 0.003, Temp_Sample_High, Precipitation_Sample_High)

#plot([Temp_Elevation_Low[:,1], Temp_Elevation_High[:,1]])

Difference = mean(Temp_Sample_High - Temp_Sample_Low)
