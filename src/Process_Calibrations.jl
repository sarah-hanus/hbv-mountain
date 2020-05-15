# get values for 10 best parameter sets of each run
# get number of saved values
using DelimitedFiles
using Plots
using StatsPlots
using CSV
# pyplot()
# Plots.PyPlotBackend()


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
    names_obj = ["NSE", "NSElog", "VE", "NSE_FDC", "Reative_Error_AC_1day", "NSE_AC_90day", "NSE_Runoff", "Snow_Cover"]
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
    savefig("Gailtal/Calibration_8.05/objbestfit_"*string(number_best)*".png")
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
    savefig("Gailtal/Calibration_8.05/parametersbestfit1_"*string(number_best)*".png")
    plot(plots_par[13], plots_par[14], plots_par[15], plots_par[16], plots_par[17], plots_par[18], plots_par[19], plots_par[20], layout= (2,4), legend=false, size=(1400,1000))
    savefig("Gailtal/Calibration_8.05/parametersbestfit2_"*string(number_best)*".png")

    return calibration_best
end
#
function combine_calibrations()
    all_calibrations = Array{Float64,2}[]
    total_saved = 0
    all_calibrations = zeros((1,29))
    print(size(all_calibrations))
    for i in 0:4
        calibration1 = readdlm("Gailtal/Calibration_6.05/Jan_Laptop/Gailtal_Parameterfit_1_"*string(i)*".csv", ',')
        calibration2 = readdlm("Gailtal/Calibration_6.05/Jan_Laptop/Gailtal_Parameterfit_2_"*string(i)*".csv", ',')
        calibration3 = readdlm("Gailtal/Calibration_6.05/Jan_Laptop/Gailtal_Parameterfit_3_"*string(i)*".csv", ',')
        calibration4 = readdlm("Gailtal/Calibration_6.05/Desktop/Gailtal_Parameterfit_4_"*string(i)*".csv", ',')
        calibration5 = readdlm("Gailtal/Calibration_6.05/Desktop/Gailtal_Parameterfit_5_"*string(i)*".csv", ',')
        calibration6 = readdlm("Gailtal/Calibration_6.05/Desktop/Gailtal_Parameterfit_6_"*string(i)*".csv", ',')
        calibration7 = readdlm("Gailtal/Calibration_6.05/Desktop/Gailtal_Parameterfit_7_"*string(i)*".csv", ',')
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

function combine_calibrations2(path)
    all_calibrations = Array{Float64,2}[]
    total_saved = 0
    all_calibrations = zeros((1,29))
    print(size(all_calibrations))
    #files = readdir(path)
    files = filter(name -> endswith(name, ".csv"), readdir(path))
    for i in 1: length(files)
        print(files[i],"\n")
        calibration = readdlm(path*files[i], ',')
        # calibration2 = readdlm("Gailtal/Calibration_6.05/Jan_Laptop/Gailtal_Parameterfit_2_"*string(i)*".csv", ',')
        # calibration3 = readdlm("Gailtal/Calibration_6.05/Jan_Laptop/Gailtal_Parameterfit_3_"*string(i)*".csv", ',')
        # calibration4 = readdlm("Gailtal/Calibration_6.05/Desktop/Gailtal_Parameterfit_4_"*string(i)*".csv", ',')
        # calibration5 = readdlm("Gailtal/Calibration_6.05/Desktop/Gailtal_Parameterfit_5_"*string(i)*".csv", ',')
        # calibration6 = readdlm("Gailtal/Calibration_6.05/Desktop/Gailtal_Parameterfit_6_"*string(i)*".csv", ',')
        # calibration7 = readdlm("Gailtal/Calibration_6.05/Desktop/Gailtal_Parameterfit_7_"*string(i)*".csv", ',')
        #adds the new array to former array
        all_calibrations = vcat(all_calibrations, calibration)
        # all_calibrations = vcat(all_calibrations, calibration2)
        # all_calibrations = vcat(all_calibrations, calibration3)
        # all_calibrations = vcat(all_calibrations, calibration4)
        # all_calibrations = vcat(all_calibrations, calibration5)
        # all_calibrations = vcat(all_calibrations, calibration6)
        # all_calibrations = vcat(all_calibrations, calibration7)
        total_saved+= size(calibration)[1]
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

    return all_calibrations[2:end, :], total_saved
end

function projections_statistics(path_to_file)
    names_obj = ["NSE", "NSElog", "VE","NSE_FDC", "Reative_Error_AC_1day", "NSE_AC_90day", "NSE_Runoff", "Snow_Cover"]
    #Parameters = ["beta_Bare", "beta_Forest", "beta_Grass", "beta_Rip", "Ce", "Interceptioncapacity_Forest", "Interceptioncapacity_Grass", "Interceptioncapacity_Rip", "Kf_Rip", "Kf", "Ks", "Meltfactor", "Mm", "Ratio_Pref", "Ratio_Riparian", "Soilstoaragecapacity_Bare", "Soilstoaragecapacity_Forest", "Soilstoaragecapacity_Grass", "Soilstoaragecapacity_Rip", "Temp_Thresh"]
    #Objective_Functions = [max_NSE, max_NSElog, max_VE, max_NSE_FDC, max_Reative_Error_AC_1day, max_NSE_AC_90day, max_Relative_Error_Runoff, max_Snow_Cover]
    # get array with all calibtation data
    projections = readdlm(path_to_file, ',')
    number_best = size(projections)[1]
    runs = collect(1:number_best)
    print(size(projections))
    plots_obj = []
    for i in 1:8
        #scatter(ED_best, calibration_best[:,i+1], xlabel = "Euclidean Distance", ylabel= names_obj[i])
        # xlabel!("Euclidean Distance")
        # ylabel!(names_obj[i])
        #savefig(names_obj[i]*".png")
        push!(plots_obj, scatter(runs, projections[:,i+1], xlabel = "Runs", ylabel= names_obj[i]))
    end
    plot(plots_obj[1], plots_obj[2], plots_obj[3], plots_obj[4], plots_obj[5], plots_obj[6], plots_obj[7], plots_obj[8], layout= (2,4), legend = false, size=(1400,800))
    savefig("Gailtal/Projections/objbestfit_"*string(number_best)*".png")
end


function boxplot_projection(path)
    #path = "/home/sarah/Master/Thesis/Data/Projektionen/new_station_data_rcp45/rcp45/"
    # 14 different projections
    Name_Projections = readdir(path)
    # run the model for all projections using the best 100 parameter sets
    All_Obj_Functions = Array{Float64,2}[]
    for (i, name) in enumerate(Name_Projections)
            getData = readdlm(path*name*"/Gailtal/100_model_results_05_10.csv",',')
            push!(All_Obj_Functions, getData[:,1:9])
    end

    Calibration = readdlm("Gailtal/Calibration_8.05/Validation/Gailtal_Parameterfit_best100_validation.csv", ',')[:,1:9]

    names_obj = ["Euclidean Distance", "NSE", "NSElog", "VE","NSE_FDC", "Reative_Error_AC_1day", "NSE_AC_90day", "NSE_Runoff", "Snow_Cover"]
    #number = collect(1:size(All_Obj_Functions)[1])
    for obj in 1:size(names_obj)[1]
        plot()
        for i in 1:size(All_Obj_Functions)[1]
            boxplot!(["Proj " *string(i)],All_Obj_Functions[i][:,obj],leg = false)

        end
        #boxplot!(["Calibration"],Calibration[:,obj],leg = false)
        ylabel!(names_obj[obj])
        savefig("/home/sarah/Master/Thesis/Results/Projektionen/Validation_Period/"*names_obj[obj]*"rcp45.png")
    end
end


function plot_FDC(path)
    Name_Projections = readdir(path)
    All_Discharges = Array{Float64,2}[]
    for (i, name) in enumerate(Name_Projections)
            getDischarge = readdlm(path*name*"/Gailtal/100_model_results_85_05_discharge.csv",',')
            push!(All_Discharges, getDischarge)
    end
    #observed discharge

    Discharge = CSV.read("/home/sarah/HBVModel/Gailtal/Q-Tagesmittel-212670.csv", header= false, skipto=23, decimal=',', delim = ';', types=[String, Float64])
    Discharge = convert(Matrix, Discharge)
    startindex = findfirst(isequal("01.10.1985 00:00:00"), Discharge)
    endindex = findfirst(isequal("30.09.2005 00:00:00"), Discharge)
    Observed_Discharge = Array{Float64,1}[]
    push!(Observed_Discharge, Discharge[startindex[1]:endindex[1],2])
    #Observed_Discharge = Observed_Discharge[1]
    observed_FDC = flowdurationcurve(log.(Observed_Discharge[1]))
    plot()

    #print(size(All_Discharges[1][1,:]))
    for proj in 1:length(Name_Projections)
        NSE_FDC_observations = Float64[]
        for i in 1:size(All_Discharges[1])[1]
            modeled_FDC = flowdurationcurve(log.(All_Discharges[proj][i,:]))
            #plot!(modeled_FDC[2], modeled_FDC[1], color="black", legend=false, size=(1400,800))
            NSE_FDC = nse(observed_FDC[1], modeled_FDC[1])
            append!(NSE_FDC_observations, NSE_FDC)
        end
        # plot!(observed_FDC[2], observed_FDC[1], color="red", size=(1400,800))
        # title!(Name_Projections[proj])
        # xlabel!("Exceedance Probability")
        # ylabel!("Discharge [m3/s]")
        # savefig("/home/sarah/Master/Thesis/Results/Projektionen/FDC_"*Name_Projections[proj]*".png")
        boxplot!(NSE_FDC_observations, leg=false)
    end
    Modelled_Discharge_Observations = readdlm("Gailtal/Calibration_8.05/Discharges_best100.csv", '\t')
    #print(size(Modelled_Discharge_Observations)[1])
    NSE_FDC_observations = Float64[]
    for i in 1:size(Modelled_Discharge_Observations)[2]
        modeled_FDC = flowdurationcurve(log.(Modelled_Discharge_Observations[:,i]))
        #plot!(modeled_FDC[2], modeled_FDC[1], color="black", legend=false, size=(1400,800))
        NSE_FDC = nse(observed_FDC[1], modeled_FDC[1])
        append!(NSE_FDC_observations, NSE_FDC)
    end
    boxplot!(["obs"],NSE_FDC_observations, leg=false)
    # plot!(observed_FDC[2], observed_FDC[1], color="red")
    # title!("Observed Data")
    # xlabel!("Exceedance Probability")
    # ylabel!("Discharge [m3/s]")
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/FDC_Boxplot.png")
    plot()
    observed_FDC = flowdurationcurve((Observed_Discharge[1]))
    for proj in 1:length(Name_Projections)
        NSE_FDC_observations = Float64[]
        for i in 1:size(All_Discharges[1])[1]
            modeled_FDC = flowdurationcurve(All_Discharges[proj][i,:])
            #plot!(modeled_FDC[2], modeled_FDC[1], color="black", legend=false, size=(1400,800))
            NSE_FDC = lognse(observed_FDC[1], modeled_FDC[1])
            append!(NSE_FDC_observations, NSE_FDC)
        end
        # plot!(observed_FDC[2], observed_FDC[1], color="red", size=(1400,800))
        # title!(Name_Projections[proj])
        # xlabel!("Exceedance Probability")
        # ylabel!("Discharge [m3/s]")
        # savefig("/home/sarah/Master/Thesis/Results/Projektionen/FDC_"*Name_Projections[proj]*".png")
        boxplot!(NSE_FDC_observations, leg=false)
    end
    Modelled_Discharge_Observations = readdlm("Gailtal/Calibration_8.05/Discharges_best100.csv", '\t')
    #print(size(Modelled_Discharge_Observations)[1])
    NSE_FDC_observations = Float64[]
    for i in 1:size(Modelled_Discharge_Observations)[2]
        modeled_FDC = flowdurationcurve(Modelled_Discharge_Observations[:,i])
        #plot!(modeled_FDC[2], modeled_FDC[1], color="black", legend=false, size=(1400,800))
        NSE_FDC = lognse(observed_FDC[1], modeled_FDC[1])
        append!(NSE_FDC_observations, NSE_FDC)
    end
    boxplot!(["obs"],NSE_FDC_observations, leg=false)
    # plot!(observed_FDC[2], observed_FDC[1], color="red")
    # title!("Observed Data")
    # xlabel!("Exceedance Probability")
    # ylabel!("Discharge [m3/s]")
    savefig("/home/sarah/Master/Thesis/Results/Projektionen/FDC_old_Boxplot.png")

end

boxplot_projection("/home/sarah/Master/Thesis/Data/Projektionen/new_station_data_rcp45/rcp45/")
#Modelled_Discharge_Observations = plot_FDC("/home/sarah/Master/Thesis/Data/Projektionen/new_station_data_rcp45/rcp45/")




# #----------------- COMBINE RESULTS OF ONE DEVICE-------------
#All_Calibrations_Laptop, total_saved = combine_calibrations2("Gailtal/Calibration_8.05/Laptop_Jan/Gailtal_Parameterfit_10.5/")
#writedlm("Gailtal/Calibration_8.05/Gailtal_Parameterfit_Jan_Laptop3.csv", All_Calibrations_Laptop, ',')






# # -------------- COMBINE RESULTS OF ALL DEVICES -----------------
# all_calibrations = zeros((1,29))
# calibration1 = readdlm("Gailtal/Calibration_8.05/Gailtal_Parameterfit_All.csv", ',')
# calibration2 = readdlm("Gailtal/Calibration_8.05/Gailtal_Parameterfit_Prior_Calibration.csv", ',')
# # calibration3 = readdlm("Gailtal/Calibration_8.05/Gailtal_Parameterfit_Jan_Laptop3.csv", ',')
# print(size(calibration1), size(calibration2))
# all_calibrations = vcat(all_calibrations, calibration1)
# all_calibrations = vcat(all_calibrations, calibration2)
# all_calibrations = vcat(all_calibrations, calibration3)
#writedlm("Gailtal/Calibration_8.05/Gailtal_Parameterfit_All_new.csv", all_calibrations[2:end,:], ',')

#all_calibrations, total_saved = combine_calibrations2("Gailtal/Calibration_8.05/Run_10000_Best_Prior_Calibration/")
#writedlm("Gailtal/Calibration_8.05/Gailtal_Parameterfit_Prior_Calibration.csv", all_calibrations, ',')




#calibration_best = calibration_statistics("Gailtal/Calibration_8.05/Gailtal_Parameterfit_All_new.csv", 10000)
#writedlm("Gailtal/Calibration_8.05/Gailtal_Parameterfit_best10000.csv", calibration_best, ',')


function EC_calibration(path_to_file)
    calibration = readdlm(path_to_file, ',')
    # sort the calibration according to the euclidean distance
    calibration_sorted = sortslices(calibration, dims=1)
    #number_best = 10
    #calibration_best = calibration_sorted[1:number_best,:]
    number_values = Float64[]
    threshold_values = collect(0.15:0.001:0.185)
    for threshold in threshold_values
        all_values_below_threshold = length(findall(x -> x < threshold, calibration_sorted[:,1]))
        append!(number_values, all_values_below_threshold)
    end
    return threshold_values, number_values
end

# thresholds, numbers = EC_calibration("Gailtal/Calibration_8.05/Gailtal_Parameterfit_All.csv")
# scatter(thresholds, numbers/2286000, size=(1400,800))
# xlabel!("Euclidean Distance")
# ylabel!("Percent of Runs below the Euclidean Distance")
# savefig("Gailtal/Calibration_8.05/compare_ED3.png")


#projections_statistics("Gailtal/Projections/Gailtal_Parameterfit_best100_projection1.csv")
