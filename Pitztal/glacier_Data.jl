using CSV
using Plots
using DelimitedFiles
using DataFrames

Glacier_Catchment = CSV.read("/home/sarah/Master/Thesis/Data/Glaciers/Pitztal_Glacier_RGI.csv")
Nr_Glaciers = size(Glacier_Catchment.RGIId)[1]

id_number = Array{Union{Nothing, String}}(nothing, Nr_Glaciers)

for i in 1:Nr_Glaciers
    name = Glacier_Catchment.RGIId[i]
    global id_number[i] = name[10:14]
end

#
# for i in 1:10
#     x = CSV.read("/home/sarah/Master/Thesis/Data/Glacier_Evolution_New/"*id_number[i] * "_area+volume_rcp45.csv", datarow=2, delim=',',  header= false)
#     print(x)
# end
#
# # # for i in 1:53
# # #     Glacier_Pitz = CSV.read("Glaciers_Pitztal.csv")
# #
Glacier_Future_45 = zeros(Nr_Glaciers, 86)
# #
# for i in 1:Nr_Glaciers
#     global Glacier_Future_45[i,:] =  convert(Matrix,CSV.read("/home/sarah/Master/Thesis/Data/Glacier_Evolution_New/"*id_number[i] * "_area+volume_rcp45.csv", datarow=2, delim=',',  header= false, footerskip=1))
#     print(i)
# end
# # #
# Glacier_Dataframe = DataFrame(Glacier_Future_45)
#CSV.write("/home/sarah/Master/Thesis/Data/Glaciers/Glacier_Pitztal_Future_rcp4.5.csv", Glacier_Dataframe)

#sums the total glacier coverage of the Pitztal of each year
# Area_Glacier_year_85 = vec(sum(Glacier_Future_85, dims=1))
# Area_Glacier_year_45 = vec(sum(Glacier_Future_45, dims=1))
# #to calculate the percentage of the total Pitztal catchments
# Area_Defreggental = sum([20651736.0, 145191864.0]) / 1000000
#
# Glacier_Percent_45 = Area_Glacier_year_45 / Area_Defreggental
# Glacier_Percent_85 = Area_Glacier_year_85 / Area_Defreggental
# Years = collect(2015:2100)
# plot(Years,Glacier_Percent_45*100, label="RCP 4.5")
# plot!(Years,Glacier_Percent_85*100, label="RCP 8.5")
# xlabel!("Years from 2015")
# ylabel!("Percentage of Catchment [%]")
# savefig("/home/sarah/Master/Thesis/Results/Projektionen/Pitztal/Glaciers_Pitztal_Percent_new.png")
#
# plot(Years,Area_Glacier_year_45, label="RCP 4.5")
# plot!(Years,Area_Glacier_year_85, label="RCP 8.5")
# xlabel!("Year")
# ylabel!("Area of Glacier [km2]")
# savefig("/home/sarah/Master/Thesis/Results/Projektionen/Pitztal/Glaciers_Pitztal_new.png")


# make relative glacier evaolution
function relative_evolution(id_number, Nr_Glaciers)
    for i in 1:Nr_Glaciers
        Relative_Glacier =  convert(Matrix,CSV.read("/home/sarah/Master/Thesis/Data/Glacier_Evolution_New/"*id_number[i] * "_area+volume_rcp85.csv", datarow=2, delim=',',  header= false, footerskip=1))
        glacier_2015 = Relative_Glacier[1]
        Relative_Glacier = Relative_Glacier ./ glacier_2015
        println(Relative_Glacier[end-5:end])
        print(size(Relative_Glacier))
        writedlm("/home/sarah/Master/Thesis/Data/Glacier_Evolution_New/Relative_Evolution/"*id_number[i] * "_area_rcp85_relative.csv", Relative_Glacier, ',')
    end
end

#relative_evolution(id_number, Nr_Glaciers)


RGI_Pitztal_elevation = readdlm("/home/sarah/Master/Thesis/Data/Glaciers/Pitztal_Glaciers_Elevation_2015_scaled.csv", ',')[:,2:end]

function remove_glacier(id_number, Nr_Glaciers)

    for current_year_index in 1:86
        all_glaciers_area = zeros(7)
        println("year ", 2014+current_year_index)
        for i in 1:Nr_Glaciers
            current_id_number = parse(Int, id_number[i][3:end])
            #println(current_id_number)
            index_column = findfirst(x->x == current_id_number, RGI_Pitztal_elevation[1,:])
            Glacier_elevation = RGI_Pitztal_elevation[2:end,index_column]
            Glacier_Area = sum(Glacier_elevation)
            Relative_Glacier =  readdlm("/home/sarah/Master/Thesis/Data/Glacier_Evolution_New/Relative_Evolution/"*id_number[i] * "_area_rcp45_relative.csv", ',')
            #print(Relative_Glacier, size(Relative_Glacier))
            remove_from_glacier = Glacier_Area .* (1 .- Relative_Glacier[current_year_index])

            println("remove from glacier", remove_from_glacier)
            # println(Glacier_elevation)
            new_glacier_area = Float64[] #store the glacier are for all elevations of this glacier
            for (j, current_elevation) in enumerate(Glacier_elevation)
                if remove_from_glacier >= 0 # if area has to be removed from glacier
                    if remove_from_glacier - current_elevation > 0 # and there has to be more removed than ice at current elevation
                        current_new_glacier_area = 0 # than there will be no ice at current elevation
                        remove_from_glacier = remove_from_glacier - current_elevation # and ice that has to be removed from next elevation is total_to_remove - ice at current elevation
                    else                                                              # if less ice has to be removed than at current elevation
                        current_new_glacier_area = current_elevation - remove_from_glacier # then ice at elevation decreases by ice to remove
                        remove_from_glacier = 0 # ice to remove from next elevation is 0
                        #println("Case 2: ", current_elevation - remove_from_glacier)
                    end
                    #println("ice removed, new area:", current_new_glacier_area)
                else # if ice is added to the glacier
                    println("ice thickens: ", i)
                    if current_elevation == 0 # then it is added to the last elevation that already contains ice
                        current_new_glacier_area = 0
                    # elseif current_elevation != 0
                    #     current_new_glacier_area = current_elevation - remove_from_glacier
                    # end
                    elseif j != length(Glacier_elevation) && current_elevation != 0 && Glacier_elevation[j+1] == 0 # add to highest elevation zones
                        current_new_glacier_area = current_elevation - remove_from_glacier
                        remove_from_glacier = 0 # at the next elevation no ice has to be added /removed
                    elseif j == length(Glacier_elevation) && current_elevation != 0
                        current_new_glacier_area = current_elevation - remove_from_glacier
                        remove_from_glacier = 0 # at the next elevation no ice has to be added /removed
                    elseif current_elevation != 0 && Glacier_elevation[j+1] != 0
                        current_new_glacier_area = current_elevation
                    end
                end
                    append!(new_glacier_area, current_new_glacier_area)
                    println("areal change ", current_elevation, " ", current_new_glacier_area)
            end
            #println(new_glacier_area)
            all_glaciers_area = hcat(all_glaciers_area, new_glacier_area) # attach to array containing elevations of all glaciers
        end

        writedlm("/home/sarah/Master/Thesis/Data/Glacier_Evolution_New/Yearly_Evolution_Elevation_scaled/"*string(current_year_index+2014)* "_area_rcp45_highest.csv", all_glaciers_area[:,2:end], ',')
    end
end

#remove_glacier(id_number, Nr_Glaciers)
#
# glaciers_all_years = zeros(7)
# for current_year_index in 1:86
#     elevations_single_glacier_current_year = readdlm("/home/sarah/Master/Thesis/Data/Glacier_Evolution_New/Yearly_Evolution_Elevation_scaled/"*string(current_year_index+2014)* "_area_rcp45_highest.csv", ',')
#     elevations_total_glaciers_current_year = sum(elevations_single_glacier_current_year, dims = 2)
#     global glaciers_all_years = hcat(glaciers_all_years, elevations_total_glaciers_current_year)
# end
#
# sum_area_45 = sum(glaciers_all_years, dims=1)[2:end]
#
# writedlm("/home/sarah/Master/Thesis/Data/Glacier_Evolution_New/Yearly_Evolution_Elevation_scaled/2015_2100_area_rcp45_scaled_highest.csv", glaciers_all_years[:,2:end], ',')
# # # #
# Years = collect(2015:2100)
# plot(Years, sum_area_45./1000000, label="RCP 4.5")
# plot!(Years, sum_area_85./1000000, label="RCP 8.5")
# xlabel!("Years")
# ylabel!("Area in km²")
# savefig("/home/sarah/Master/Thesis/Results/Projektionen/Pitztal/Glaciers_Pitztal_future_elevations_scaled.png")
#
# #
Glaciers_85 = readdlm("/home/sarah/Master/Thesis/Data/Glacier_Evolution_New/Yearly_Evolution_Elevation_scaled/2015_2100_area_rcp85_scaled_highest.csv", ',')

Elevations = collect(2500:200:3700)
plot()
Area_2015 = Glaciers_85[:,1]./1000000
for (i, current_elevation) in enumerate(Elevations)
    plot!(Years, Glaciers_85[i,:]./1000000 / Area_2015[i] * 100, label=string(current_elevation), size=(1200,600))
end
title!("RCP 8.5 Evolution Glaciers Pitztal")
xlabel!("Years")
ylabel!("Percentage of Area of 2015")

savefig("/home/sarah/Master/Thesis/Results/Projektionen/Pitztal/Glaciers_Pitztal_rcp85_different_elevations_scaled_percen.png")
