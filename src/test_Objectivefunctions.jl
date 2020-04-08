using Dates
using DelimitedFiles
using CSV
using Plots
using Statistics

Discharge_Defreggental = CSV.read("Defreggental/Q-Tagesmittel-212100.csv", header= false, skipto=26, decimal=',', delim = ';', types=[String, Float64])
Discharge_Palten = CSV.read("Palten/Q-Tagesmittel-210815.csv", header = false, skipto= 21, decimal = ',', delim= ';', types=[String, Float64])
Discharge_Feistritz = CSV.read("Feistritz/Q-Tagesmittel-208843.csv", header = false, skipto =1119, decimal = ',', delim= ';', types=[String, Float64])

Discharge_Defreggental_Array = convert(Matrix, Discharge_Defreggental)
Discharge_Palten_Array = convert(Matrix, Discharge_Palten)
Discharge_Feistritz_Array = convert(Matrix, Discharge_Feistritz)
Days = 3657
Discharge51_Defreggen = convert(Array{Float64}, Discharge_Defreggental_Array[:,2][1:Days])
Discharge51_Palten = convert(Array{Float64}, Discharge_Palten_Array[:,2][1:365])
Discharge79_Feistritz = convert(Array{Float64}, Discharge_Feistritz_Array[:,2][1:365])
#Discharge_Sorted = sort(Discharge51_Defreggen, rev = true)
#
#Ranks = collect(1 : length(Discharge51_Defreggen))

SortedQ, Exceedance = flowdurationcurve(Discharge51_Defreggen)
SortedQ_Palten, Exceedance_Palten = flowdurationcurve(Discharge51_Palten)
SortedQ_Feistritz, Exceedance_Feistritz = flowdurationcurve(Discharge79_Feistritz)

plot(Exceedance, SortedQ, seriestype = :scatter, title = "Flow Duration Curve", label = "Defreggen")
plot!(Exceedance, SortedQ_Palten, seriestype = :scatter, label = "Palten")
plot!(Exceedance, SortedQ_Feistritz, seriestype = :scatter, label = "Feistritz")
xlabel!("Exceedance Probability")
ylabel!("Discharge [m3/s]")

# Nash_Value = nse(SortedQ_Palten, SortedQ)
# Nash_Value2 = nse(SortedQ_Feistritz, SortedQ)
# Nash_Value_3 = nse(SortedQ_Feistritz, SortedQ_Palten)
# it is better if the observed flow is larger than the modelled flow



AC1 = autocorrelation(Discharge79_Feistritz, 1)
AC2 = autocorrelation2(Discharge79_Feistritz, 1)
Timelag = 30
ACcurve, Lags = autocorrelationcurve(Discharge79_Feistritz, Timelag)
ACcurve_2, Lags2 = autocorrelationcurve2(Discharge79_Feistritz, Timelag)

plot(Lags, ACcurve, label = "Defreggen")
plot!(Lags2, ACcurve_2)
#plot!(autocorrelationcurve(Discharge51_Palten, Timelag)[2], autocorrelationcurve(Discharge51_Palten, Timelag)[1], label = "Palten")
#plot!(autocorrelationcurve(Discharge79_Feistritz, Timelag)[2], autocorrelationcurve(Discharge79_Feistritz, Timelag)[1], label = "Feistritz")

Nash_AC_new= nse(ACcurve, autocorrelationcurve2(Discharge51_Palten, Timelag)[1])
Nash_AC2_new= nse(ACcurve, autocorrelationcurve2(Discharge79_Feistritz, Timelag)[1])

print(sum(ACcurve - ACcurve_2))

#test runoff

Timeseries = readdlm("Defreggental/tas_model_timeseries.txt")[366: 365 + Days]
Precipitation  = CSV.read("Defreggental/pr_sim1.txt", header=false)[366: 365 + Days ,49]/10
Precipitation_Defreggen = convert(Array{Float64}, Precipitation)
Area = 267.46 * 10^6
Runoff, Months= monthlyrunoff(Area, Precipitation_Defreggen, Discharge51_Defreggen, Timeseries)
Average_Runoff = averagemonthlyrunoff(Runoff, Months)
