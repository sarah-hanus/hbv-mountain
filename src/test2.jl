startyear = 1981
endyear = 2010
Discharge = CSV.read("/home/sarah/HBVModel/Palten/Q-Tagesmittel-210815.csv", header= false, skipto=21, decimal=',', delim = ';', types=[String, Float64])
Discharge = convert(Matrix, Discharge)
startindex = findfirst(isequal("01.01."*string(startyear)*" 00:00:00"), Discharge)
endindex = findfirst(isequal("31.12."*string(endyear)*" 00:00:00"), Discharge)
Observed_Discharge = Array{Float64,1}[]
push!(Observed_Discharge, Discharge[startindex[1]:endindex[1],2])
Observed_Discharge = Observed_Discharge[1]
Timeseries_Past = collect(Date(1981,1,1):Day(1):Date(2010,12,31))

# Monthly_Discharge_Observed, Months_Past = monthly_discharge(Observed_Discharge, Timeseries_Past)
plot()
for month in 1:12
    boxplot!(convertDischarge(average_motnhly_Discharge_observed[findall(x-> x == month, Months)], Area_Catchment_Palten), size=(2000,800), leg=false, color=["red"], left_margin = [5mm 0mm])
    #ylims!((1,4))
end
ylabel!("Averaged Monthly Discharge [mm/d]")
title!("Averaged Measured Monthly Discharge 1981-2010 modelled with 300 best parameter sets")
#ylims!((0,40))
#hline!([0], color=["grey"], linestyle = :dash)
xticks!([1:12;], ["Jan", "Feb", "Mar", "Apr", "May","Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])
#xticks!([2:2:24;], ["Jan 8.5", "Feb 8.5", "Mar 8.5", "Apr 8.5", "May 8.5","Jun 8.5", "Jul 8.5", "Aug 8.5", "Sep 8.5", "Oct 8.5", "Nov 8.5", "Dec 8.5"])
savefig("/home/sarah/Master/Thesis/Results/Projektionen/Palten/PastvsFuture/Monthly_Discharge/modelled_monthly_discharge_observed_input.png")

function monthly_discharge_modelled_past(All_Discharges, Timeseries)
    average_monthly_Discharge_observed = Float64[]
    for run in 1:300
        print(run)
        Monthly_Discharge_Observed, Month = monthly_discharge(All_Discharges[:,run], Timeseries)
        for month in 1:12
            current_Month_Discharge = Monthly_Discharge_Observed[findall(x->x == month, Month)]
            current_Month_Discharge = mean(current_Month_Discharge)
            append!(average_monthly_Discharge_observed, current_Month_Discharge)
        end
    end
    return average_monthly_Discharge_observed
end
Timeseries_Past = collect(Date(1980,10,1):Day(1):Date(2010,9,30))
#average_motnhly_Discharge_observed = monthly_discharge_modelled_past(All_Discharges, Timeseries_Past)
