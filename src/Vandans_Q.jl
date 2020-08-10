Gaschurn_Q = CSV.read("Montafon/Q15min200022.dat", header = 0, skipto = 28, delim = ' ', ignorerepeated = true, types=[String, String, Float64])
startyear = 1988
endyear = 2009
Timeseries_Q = Date.(Gaschurn_Q.Column1, Dates.DateFormat("dd.mm.yyyy"))
startindex = findfirst(isequal(Date(startyear, 1, 1)), Timeseries_Q)
endindex = findfirst(isequal(Date(endyear, 12, 31)), Timeseries_Q)
Gaschurn_Q_new = Gaschurn_Q[startindex[1]:endindex[1], 3]
Timeseries_Q = Timeseries_Q[startindex[1]:endindex[1]]

#Vandans_Q_new = float.(Vandans_Q_new)
#Vandans_Q_new[:,1] = Date.(Vandans_Q_new[:,1], Dates.DateFormat("dd.mm.yyyy"))
Gaschurn_Q_Array = hcat(Timeseries_Q, Gaschurn_Q_new)
#
#
# startindex = findfirst(isequal("01.01."*string(startyear)*" 07:00:00"), Temperature_Array)
# endindex = findfirst(isequal("31.12."*string(endyear)*" 23:00:00"), Temperature_Array)
# Temperature_Array = Temperature_Array[startindex[1]:endindex[1],:]
# Temperature_Array[:,1] = Date.(Temperature_Array[:,1], Dates.DateFormat("d.m.y H:M:S"))
Dates_Q_Daily_Gaschurn, Q_Daily_Gaschurn = daily_mean(Gaschurn_Q_Array)

for i in 4:25
   plot(Discharge[1+(365*(i-1)):365*i,2], label="Loerens")
   plot!(Q_Daily_Vandans[1+(365*(i-1)):365*i], label="Vandans")
   plot!(Q_Daily_Gaschurn[1+(365*(i-4)):365*(i-3)], label="Gaschurn", size=(1400,800))
   xlabel!("Days in Year")
   ylabel!("Discharge in m³/s")
   title!("Discharge Montafon Year: "*string(1984+i))
   savefig("/home/sarah/Master/Thesis/Results/Calibration/Montafon/Discharge_Loere/Discharge_year_"*string(1984+i)*".png")
end
