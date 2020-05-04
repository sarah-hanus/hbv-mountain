using CSV
using Plots
using Statistics

Precipitation1  = CSV.read("Defreggental/Projections_Defreggen/1_pr_sim1.txt", header=false)
Precipitation2  = CSV.read("Defreggental/Projections_Defreggen/2_pr_sim1.txt", header=false)
Precipitation3  = CSV.read("Defreggental/Projections_Defreggen/3_pr_sim1.txt", header=false)
Precipitation4  = CSV.read("Defreggental/Projections_Defreggen/4_pr_sim1.txt", header=false)
Precipitation5  = CSV.read("Defreggental/Projections_Defreggen/5_pr_sim1.txt", header=false)
Precipitation6  = CSV.read("Defreggental/Projections_Defreggen/6_pr_sim1.txt", header=false)
Observed_Prec = convert(Matrix, CSV.read("Defreggental/N-Tagessummen-114926.csv", header=false, skipto = 24,  decimal=',', delim = ';', types=[String, Float64]))

# start in 1980
Start = 10593

Days = 365
#get the data at the outlet point
grid_point = 68
Precipitation1 = Precipitation1[Start: Start + Days-1,grid_point]/10
Precipitation2 = Precipitation2[Start: Start + Days-1,grid_point]/10
Precipitation3 = Precipitation3[Start: Start + Days-1,grid_point]/10
Precipitation4 = Precipitation4[Start: Start + Days-1,grid_point]/10
Precipitation5 = Precipitation5[Start: Start + Days-1,grid_point]/10
Precipitation6 = Precipitation6[Start: Start + Days-1,grid_point]/10
Observed_Prec = convert(Array{Float64}, Observed_Prec[:,2][1:Days])

#calculate the correlation

#plot([Precipitation1, Precipitation2, Precipitation3, Precipitation4, Precipitation5, Precipitation6])

plot([Precipitation1, Observed_Prec])
# plot([Precipitation4, Precipitation5, Precipitation6])

print(cor(Precipitation6, Observed_Prec))

# print("\n",sum(Precipitation1),"\n", sum(Precipitation2))
# print("\n",sum(Precipitation3),"\n", sum(Precipitation4))
# print("\n",sum(Precipitation5),"\n", sum(Precipitation6))
# print("\n", sum(Observed_Prec))
