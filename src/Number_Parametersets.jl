Catchment_Name = "Gailtal"
@time begin
All_Discharges, All_GWstorage, ALl_Snowstorage, All_Snow_Elevations, All_Soilstorage, All_Snow_Cover_Modeled, All_Snow_Cover_Observed, Observed_Discharge, Timeseries, All_Faststorage, Total_Precipitation, Temperature_Mean_Elevation = run_bestparameters_gailtal("/home/sarah/Master/Thesis/Calibrations/Gailtal/Calibration8-10.5/Gailtal_Parameterfit_best10000.csv", 10000, 1983, 2005)
end
startyear = 1983
endyear = 2005
local_path = "/home/sarah/"
Discharge = CSV.read(local_path*"HBVModel/Gailtal/Q-Tagesmittel-212670.csv", header= false, skipto=23, decimal=',', delim = ';', types=[String, Float64])
Discharge = convert(Matrix, Discharge)
startindex = findfirst(isequal("01.10."*string(startyear+2)*" 00:00:00"), Discharge)
endindex = findfirst(isequal("30.09."*string(endyear)*" 00:00:00"), Discharge)
Observed_Discharge = Array{Float64,1}[]
push!(Observed_Discharge, Discharge[startindex[1]:endindex[1],2])
Observed_Discharge = Observed_Discharge[1]

#
function checkdates(Observed_Discharge, Modelled_Discharge)
    count = 0
    for i in 1:length(Observed_Discharge)
        larger = findfirst(x->x > Observed_Discharge[i], All_Discharges[i,:])
        smaller = findfirst(x->x < Observed_Discharge[i], All_Discharges[i,:])
        if larger == nothing || smaller == nothing
            count += 1
        end
    end
    return 1 - count/length(Observed_Discharge)
end

percentage_days_obs_between_modelled = checkdates(Observed_Discharge, All_Discharges)
