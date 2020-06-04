using CSV
using Plots
using DelimitedFiles
using DataFrames

Glacier_Pitz = CSV.read("/home/sarah/Master/Thesis/Data/Glaciers/Austrian_Glacier_Inventory_Gl3/Glaciers_Pitztal_RGI_2003.csv")

id_number = Array{Union{Nothing, String}}(nothing, 45)

for i in 1:45
    name = Glacier_Pitz.RGIId[i]
    global id_number[i] = name[10:14]
end


for i in 1:1
    x = CSV.read("/home/sarah/Master/Thesis/Data/Glacier_Evolution_New/"*id_number[i] * "_area+volume_rcp45.csv", datarow=2, delim=',',  header= false)
    print(x)
end

# # for i in 1:53
# #     Glacier_Pitz = CSV.read("Glaciers_Pitztal.csv")
#
Glacier_Future_85 = zeros(45, 86)
#
for i in 1:45
    global Glacier_Future_85[i,:] =  convert(Matrix,CSV.read("/home/sarah/Master/Thesis/Data/Glacier_Evolution_New/"*id_number[i] * "_area+volume_rcp85.csv", datarow=2, delim=',',  header= false, footerskip=1))
    print(i)
end

Glacier_Dataframe = DataFrame(Glacier_Future_85)
CSV.write("/home/sarah/Master/Thesis/Data/Glaciers/Austrian_Glacier_Inventory_Gl3/Glacier_Pitztal_Future_rcp8.5.csv", Glacier_Dataframe)

# sums the total glacier coverage of the Pitztal of each year
Area_Glacier_year_85 = vec(sum(Glacier_Future_85, dims=1))

#to calculate the percentage of the total Pitztal catchments

Glacier_Percent_45 = Area_Glacier_year_45 / 166
Glacier_Percent_85 = Area_Glacier_year_85 / 166
Years = collect(2015:2100)
plot(Years,Glacier_Percent_45*100, label="RCP 4.5")
plot!(Years,Glacier_Percent_85*100, label="RCP 8.5")
xlabel!("Years from 2015")
ylabel!("Percentage of Catchment [%]")
savefig("/home/sarah/Master/Thesis/Data/Glaciers/Austrian_Glacier_Inventory_Gl3/Glaciers_Pitztal_Percent.png")

plot(Years,Area_Glacier_year_45, label="RCP 4.5")
plot!(Years,Area_Glacier_year_85, label="RCP 8.5")
xlabel!("Year")
ylabel!("Area of Glacier [km2]")
savefig("/home/sarah/Master/Thesis/Data/Glaciers/Austrian_Glacier_Inventory_Gl3/Glaciers_Pitztal.png")
