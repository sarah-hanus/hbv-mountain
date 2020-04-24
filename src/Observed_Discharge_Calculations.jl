using Statistics
using DelimitedFiles
using Dates
using Plots
using CSV
#string with location of data
Discharge_Data = ["Montafon/Q-Tagesmittel-231662.csv","Pitztal/Q-Tagesmittel-201335.csv","Defreggental/Q-Tagesmittel-212100.csv", "Gailtal/Q-Tagesmittel-212670.csv",
                    "Palten/Q-Tagesmittel-210815.csv", "Pitten/Q-Tagesmittel-208843.csv", "Feistritz/Q-Tagesmittel-214353.csv"]
# where to skip to in data file
Skipto = [21, 23, 26, 23, 21, 1119, 388]
# Lücken only at 01.01.2017 and for Defreggen at 01.01.1966
Discharge_Catchments = Array{Float64}[]
for i in 1:7
    Discharge = CSV.read(Discharge_Data[i], header= false, skipto=Skipto[i], decimal=',', delim = ';', types=[String, Float64])

    Discharge = convert(Matrix, Discharge)
    print(Discharge[end,:])

    startindex = findfirst(isequal("01.01.1985 00:00:00"), Discharge)
    endindex = findfirst(isequal("31.12.2014 00:00:00"), Discharge)
    Discharge = Discharge[startindex[1]:endindex[1],2]
    push!(Discharge_Catchments, Discharge)
end
plot()
Catchment_Names = ["Montafon", "Pitztal", "Defreggental", "Gailtal", "Paltental", "Pittental", "Feistritz"]
Linestyle = [:solid, :solid, :solid, :solid, :solid, :solid, :dash]
Farben = [:black, :orange, :red, :green, :blue, :purple, :purple]
# for i in 1:7
#     Sorted_Discharge, Exceedance = flowdurationcurve(Discharge_Catchments[i,1])
#     plot(Exceedance, Sorted_Discharge, title= "FDC 30 years \n"* Catchment_Names[i], label = Catchment_Names[i], line=(1, Linestyle[i]), color=[Farben[i]])
#     xlabel!("Exceedance Probability")
#     ylabel!("Discharge [m3/s]")
#     savefig("FDC_"* Catchment_Names[i] *".png")
# end
#
# plot()
# Catchment_Names = ["Montafon", "Pitztal", "Defreggental", "Gailtal", "Paltental", "Pittental", "Feistritz"]
# Linestyle = [:solid, :solid, :solid, :solid, :solid, :solid, :dash]
# Farben = [:black, :orange, :red, :green, :blue, :purple, :purple]
# for i in 1:7
#     Sorted_Discharge, Exceedance = flowdurationcurve(Discharge_Catchments[i,1])
#     plot!(Exceedance, Sorted_Discharge, title= "FDC 30 years", label = Catchment_Names[i], line=(1, Linestyle[i]), color=[Farben[i]])
#     xlabel!("Exceedance Probability")
#     ylabel!("Discharge [m3/s]")
#     #savefig("FDC_"* Catchment_Names[i] *".png")
# end
# xlabel!("Exceedance Probability")
# ylabel!("Discharge [m3/s]")
# savefig("FDC_All_Catchments.png")

for i in 1:7
    AC,Lags = autocorrelationcurve2(Discharge_Catchments[i,1], 100)
    plot!(Lags, AC, title= "Autocorrelation Function 100 days", label = Catchment_Names[i], line=(1, Linestyle[i]), color=[Farben[i]])

end
xlabel!("Lag [d]")
ylabel!("Correlation Coefficient")
savefig("AC_All_Catchments2.png")

AC, Lags = autocorrelationcurve(Discharge_Catchments[1,1],10)
print(AC)
AC, Lags = autocorrelationcurve2(Discharge_Catchments[1,1],10)
print(AC)
