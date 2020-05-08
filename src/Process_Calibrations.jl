# get values for 10 best parameter sets of each run
# get number of saved values
using DelimitedFiles
using Plots


function calibration_statistics(path_to_file, number_best)
    max_Obj = Float64[]
    max_NSE = Float64[]
    max_NSElog = Float64[]
    max_VE = Float64[]
    max_NSE_FDC = Float64[]
    max_Reative_Error_AC_1day = Float64[]
    max_NSE_AC_90day = Float64[]
    max_Relative_Error_Runoff = Float64[]
    max_Snow_Cover = Float64[]
    names_obj = ["NSE", "NSElog", "VE", "NSE_FDC", "Reative_Error_AC_1day", "NSE_AC_90day", "Relative_Error_Runoff", "Snow_Cover"]
    Parameters = ["beta_Bare", "beta_Forest", "beta_Grass", "beta_Rip", "Ce", "Interceptioncapacity_Forest", "Interceptioncapacity_Grass", "Interceptioncapacity_Rip", "Kf_Rip", "Kf", "Ks", "Meltfactor", "Mm", "Ratio_Pref", "Ratio_Riparian", "Soilstoaragecapacity_Bare", "Soilstoaragecapacity_Forest", "Soilstoaragecapacity_Grass", "Soilstoaragecapacity_Rip", "Temp_Thresh"]
    #Objective_Functions = [max_NSE, max_NSElog, max_VE, max_NSE_FDC, max_Reative_Error_AC_1day, max_NSE_AC_90day, max_Relative_Error_Runoff, max_Snow_Cover]
    # get array with all calibtation data
    calibration = readdlm(path_to_file, ',')
    # sort the calibration according to the euclidean distance
    calibration_sorted = sortslices(calibration, dims=1)
    #number_best = 10
    calibration_best = calibration_sorted[1:number_best,:]
    ED_best = calibration_best[:,1]
    plots_obj = []
    for i in 1:8
        #scatter(ED_best, calibration_best[:,i+1], xlabel = "Euclidean Distance", ylabel= names_obj[i])
        # xlabel!("Euclidean Distance")
        # ylabel!(names_obj[i])
        #savefig(names_obj[i]*".png")
        push!(plots_obj, scatter(ED_best, calibration_best[:,i+1], xlabel = "Euclidean Distance", ylabel= names_obj[i]))
    end
    plot(plots_obj[1], plots_obj[2], plots_obj[3], plots_obj[4], plots_obj[5], plots_obj[6], plots_obj[7], plots_obj[8], layout= (2,4), legend = false, size=(1400,800))
    savefig("objbestfit_"*string(number_best)*".png")
    #plot the parameter distribution
    plots_par = []
    for i in 1:20
        #scatter(ED_best, calibration_best[:,i+9], xlabel = "Euclidean Distance", ylabel= string(Parameters[i]))
        # xlabel!("Euclidean Distance")
        # ylabel!(names_obj[i])
        #savefig(names_obj[i]*".png")
        push!(plots_par, scatter(ED_best, calibration_best[:,i+9], xlabel = "Euclidean Distance", ylabel= Parameters[i]))
    end
    print(size(plots_par), typeof(plots_par))
    plot(plots_par[1], plots_par[2], plots_par[3], plots_par[4], plots_par[5], plots_par[6], plots_par[7], plots_par[8], plots_par[9], plots_par[10], plots_par[11], plots_par[12], layout= (3,4), legend=false, size=(1400,1000))
    savefig("parametersbestfit1_"*string(number_best)*".png")
    plot(plots_par[13], plots_par[14], plots_par[15], plots_par[16], plots_par[17], plots_par[18], plots_par[19], plots_par[20], layout= (2,4), legend=false, size=(1400,1000))
    savefig("parametersbestfit2_"*string(number_best)*".png")

    # calculate Euclidean Distance without snow
    # Sum = zeros(size(calibration)[1])
    # for obj in 2:8
    #     Sum+= (ones(size(calibration)[1]) - calibration[:,obj]).^2
    # end
    # Euclidean_Distance1 = (Sum ./ (ones(size(calibration)[1]) * 7)).^0.5
    # ED = zeros((size(calibration)[1], 1))
    # ED+= Euclidean_Distance1
    # calibration_ED_without_snow = hcat(ED, calibration)
    # #sort the calibration according to the euclidean distance
    # calibration_sorted = sortslices(calibration_ED_without_snow, dims=1)
    # number_best = 1000
    # calibration_best = calibration_sorted[1:number_best,:]
    # ED_best = calibration_best[:,1]
    # plots_obj = []
    # for i in 1:8
    #     push!(plots_obj, scatter(ED_best, calibration_best[:,i+2], xlabel = "Euclidean Distance", ylabel= names_obj[i]))
    # end
    # plot(plots_obj[1], plots_obj[2], plots_obj[3], plots_obj[4], plots_obj[5], plots_obj[6], plots_obj[7], plots_obj[8], layout= (2,4), legend = false, size=(1400,800))
    # savefig("objbestfit_withoutsnow"*string(number_best)*".png")
    # plot the parameter distribution
    # plots_par = []
    # for i in 1:20
    #     push!(plots_par, scatter(ED_best, calibration_best[:,i+10], xlabel = "Euclidean Distance", ylabel= Parameters[i]))
    # end
    # print(size(plots_par), typeof(plots_par))
    # plot(plots_par[1], plots_par[2], plots_par[3], plots_par[4], plots_par[5], plots_par[6], plots_par[7], plots_par[8], plots_par[9], plots_par[10], plots_par[11], plots_par[12], layout= (3,4), legend=false, size=(1400,1000))
    # savefig("parametersbestfit1_withoutsnow"*string(number_best)*".png")
    # plot(plots_par[13], plots_par[14], plots_par[15], plots_par[16], plots_par[17], plots_par[18], plots_par[19], plots_par[20], layout= (2,4), legend=false, size=(1400,1000))
    # savefig("parametersbestfit2_withoutsnow"*string(number_best)*".png")

    return calibration_best
end

function combine_calibrations()
    all_calibrations = Array{Float64,2}[]
    total_saved = 0
    all_calibrations = zeros((1,29))
    print(size(all_calibrations))
    for i in 0:4
        calibration1 = readdlm("Gailtal/Calibration_6.05/Jan_Laptop/Gailtal_Parameterfit_1_"*string(i)*".csv", ',')
        calibration2 = readdlm("Gailtal/Calibration_6.05/Jan_Laptop/Gailtal_Parameterfit_2_"*string(i)*".csv", ',')
        calibration3 = readdlm("Gailtal/Calibration_6.05/Jan_Laptop/Gailtal_Parameterfit_3_"*string(i)*".csv", ',')
        # calibration4 = readdlm("Gailtal/Calibration_6.05/Desktop/Gailtal_Parameterfit_4_"*string(i)*".csv", ',')
        # calibration5 = readdlm("Gailtal/Calibration_6.05/Desktop/Gailtal_Parameterfit_5_"*string(i)*".csv", ',')
        # calibration6 = readdlm("Gailtal/Calibration_6.05/Desktop/Gailtal_Parameterfit_6_"*string(i)*".csv", ',')
        # calibration7 = readdlm("Gailtal/Calibration_6.05/Desktop/Gailtal_Parameterfit_7_"*string(i)*".csv", ',')
        #adds the new array to former array
        all_calibrations = vcat(all_calibrations, calibration1)
        all_calibrations = vcat(all_calibrations, calibration2)
        all_calibrations = vcat(all_calibrations, calibration3)
        # all_calibrations = vcat(all_calibrations, calibration4)
        # all_calibrations = vcat(all_calibrations, calibration5)
        # all_calibrations = vcat(all_calibrations, calibration6)
        # all_calibrations = vcat(all_calibrations, calibration7)
        #total_saved+= size(calibration2)[1] + size(calibration1)[1]
        # if i <= 3
        #     calibration3 = readdlm("Gailtal/Calibration_4.05/Gailtal_Parameterfit_"*string(i)*"_laptop2.csv", ',')
        #     all_calibrations = vcat(all_calibrations, calibration3)
        #     total_saved+= size(calibration3)[1]
        # end
    end
    # calibration0 = readdlm("Gailtal/Calibration_6.05/Gailtal_Parameterfit_7_11.csv", ',')
    # calibration1 = readdlm("Gailtal/Calibration_6.05/Gailtal_Parameterfit_5_11.csv", ',')
    # calibration2 = readdlm("Gailtal/Calibration_6.05/Gailtal_Parameterfit_5_12.csv", ',')
    # calibration3 = readdlm("Gailtal/Calibration_6.05/Gailtal_Parameterfit_5_13.csv", ',')
    #
    # all_calibrations = vcat(all_calibrations, calibration0)
    # all_calibrations = vcat(all_calibrations, calibration1)
    # all_calibrations = vcat(all_calibrations, calibration2)
    # all_calibrations = vcat(all_calibrations, calibration3)

    return all_calibrations[2:end, :]#, total_saved
end

# #----------------- COMBINE RESULTS OF ONE DEVICE-------------
# All_Calibrations_Laptop2 = combine_calibrations()
# writedlm("Gailtal/Calibration_6.05/Gailtal_Parameterfit_Laptop2.csv", All_Calibrations_Laptop2, ',')

# # -------------- COMBINE RESULTS OF ALL DEVICES -----------------
# all_calibrations = zeros((1,29))
# calibration1 = readdlm("Gailtal/Calibration_6.05/Gailtal_Parameterfit_MyLaptop.csv", ',')
# calibration2 = readdlm("Gailtal/Calibration_6.05/Gailtal_Parameterfit_Laptop2.csv", ',')
# calibration3 = readdlm("Gailtal/Calibration_6.05/Gailtal_Parameterfit_Desktop.csv", ',')
#
# all_calibrations = vcat(all_calibrations, calibration1)
# all_calibrations = vcat(all_calibrations, calibration2)
# all_calibrations = vcat(all_calibrations, calibration3)
# writedlm("Gailtal/Calibration_6.05/Gailtal_Parameterfit_All.csv", all_calibrations[2:end,:], ',')






calibration_best = calibration_statistics("Gailtal/Calibration_6.05/Gailtal_Parameterfit_All.csv", 10000)
# writedlm("Gailtal/Calibration_6.05/Gailtal_Parameterfit_best100.csv", calibration_best, ',')


# function EC_calibration(path_to_file)
#     calibration = readdlm(path_to_file, ',')
#     # sort the calibration according to the euclidean distance
#     calibration_sorted = sortslices(calibration, dims=1)
#     #number_best = 10
#     #calibration_best = calibration_sorted[1:number_best,:]
#     number_values = Float64[]
#     threshold_values = collect(0.35:0.005:0.40)
#     for threshold in threshold_values
#         all_values_below_threshold = length(findall(x -> x < threshold, calibration_sorted[:,1]))
#         append!(number_values, all_values_below_threshold)
#     end
#     return threshold_values, number_values
# end

# thresholds, numbers = EC_calibration("Gailtal/Calibration_4.05/Gailtal_Parameterfit_All.csv")
# scatter(thresholds, numbers, size=(1400,800))
# xlabel!("Euclidean Distance")
# ylabel!("Number of Calibration Runs given ED")
# savefig("compare_ED_Runs2.png")
