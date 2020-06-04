using DelimitedFiles
using DataFrames
using CSV
using Plots
using GLM

Glaciers_Pitztal_69 = readdlm("/home/sarah/Master/Thesis/Data/Glaciers/Austrian_Glacier_Inventory_Gl3/Glaciers_Pitztal_Gl_1.csv", ',', skipstart=0)
Glaciers_Pitztal_97 = readdlm("/home/sarah/Master/Thesis/Data/Glaciers/Austrian_Glacier_Inventory_Gl3/Glaciers_Pitztal_Gl_2.csv", ',', skipstart=0)
Glaciers_Pitztal_06 = readdlm("/home/sarah/Master/Thesis/Data/Glaciers/Austrian_Glacier_Inventory_Gl3/Glaciers_Pitztal_Gl_3.csv", ',', skipstart=0)

Glacier_ID_69 = Glaciers_Pitztal_69[2:end,2]
Glacier_ID_97 = Glaciers_Pitztal_97[2:end,2]
Glacier_ID_06 = Glaciers_Pitztal_06[2:end,2]


Glacier_Area_69 = Glaciers_Pitztal_69[2:end,end]
Glacier_Area_97 = Glaciers_Pitztal_97[2:end,end]
Glacier_Area_06 = Glaciers_Pitztal_06[2:end,end]

#----------- SEARCH FOR DIFFERENCES IN IDs ------------
# index_Glacier_97_both69_97 = Int64[]
# index_Glacier_97_both97_06 = Int64[]
# index_Glacier_06_both69_06 = Int64[]
# index_Glacier_06_both97_06 = Int64[]
# index_Glacier_69_both69_97 = Int64[]
# index_Glacier_69_both69_06 = Int64[]
#
# for i in 1:length(Glacier_ID_69)
#     #print(Glacier_ID_69[i], " ", Glacier_ID_97[i], "\n")
#     append!(index_Glacier_97_both69_97, findall(x-> x == Glacier_ID_69[i], Glacier_ID_97))
#     append!(index_Glacier_06_both69_06, findall(x-> x == Glacier_ID_69[i], Glacier_ID_06))
# end
#
# for i in 1:length(Glacier_ID_97)
#     #print(Glacier_ID_69[i], " ", Glacier_ID_97[i], "\n")
#     append!(index_Glacier_69_both69_97, findall(x-> x == Glacier_ID_97[i], Glacier_ID_69))
#     append!(index_Glacier_06_both97_06, findall(x-> x == Glacier_ID_97[i], Glacier_ID_06))
# end
#
# for i in 1:length(Glacier_ID_06)
#     #print(Glacier_ID_69[i], " ", Glacier_ID_97[i], "\n")
#     append!(index_Glacier_69_both69_06, findall(x-> x == Glacier_ID_06[i], Glacier_ID_69))
#     append!(index_Glacier_97_both97_06, findall(x-> x == Glacier_ID_06[i], Glacier_ID_97))
# end
#
# #Glacier_ID_69_notin97 = deleteat!(Glacier_ID_69, sort(index_Glacier_69_both69_97))
# Glacier_ID_69_notin06 = deleteat!(Glacier_ID_69, sort(index_Glacier_69_both69_06))
# #Glacier_ID_97_notin69 = deleteat!(Glacier_ID_97, sort(index_Glacier_97_both69_97))
# Glacier_ID_97_notin06 = deleteat!(Glacier_ID_97, sort(index_Glacier_97_both97_06))
# #Glacier_ID_06_notin69 = deleteat!(Glacier_ID_06, sort(index_Glacier_06_both69_06))
# Glacier_ID_06_notin97 = deleteat!(Glacier_ID_06, sort(index_Glacier_06_both97_06))


# delete those IDs that are not in all datasets
# -------------- DELETE IDs THAT ARE NOT IN ALL DATASETS ---------------
#irrelevant_glaciers = [2137, 2151, 2157, 2161, 7005, 7008, 7009, 7013, 7011, 7014,14001, 14002, 14004]

irrelevant_glaciers = [2137, 2142, 2161, 7014, 7009, 7008, 7005, 7017, 7011, 14002,  2156,14004, 14001]
sort!(irrelevant_glaciers)

index_69 = Int64[]
index_97 = Int64[]
index_06 = Int64[]

for ID in irrelevant_glaciers
    append!(index_69, findall(x->x == ID, Glacier_ID_69))
    append!(index_97, findall(x->x == ID, Glacier_ID_97))
    append!(index_06, findall(x->x == ID, Glacier_ID_06))
end

deleteat!(Glacier_ID_69, sort(index_69))
deleteat!(Glacier_ID_97, sort(index_97))
deleteat!(Glacier_ID_06, sort(index_06))



@assert isequal(Glacier_ID_06, Glacier_ID_69) == true
@assert isequal(Glacier_ID_97, Glacier_ID_69) == true
@assert isequal(Glacier_ID_06, Glacier_ID_97) == true

deleteat!(Glacier_Area_69, index_69)
deleteat!(Glacier_Area_97, index_97)
deleteat!(Glacier_Area_06, index_06)


Glacier_Areas = DataFrame(ID = Glacier_ID_69, Area_69 = Glacier_Area_69, Area_97 = Glacier_Area_97, Area_06 = Glacier_Area_06)
#
# df["ID"] =
# df[!] = Glacier_Area_69
# df[!] = Glacier_Area_97
# df[!] = Glacier_Area_06


#check which IDs occur in 1969 and 1997

Glacier_Areas_sorted = sort(Glacier_Areas, :Area_69, rev=true)

CSV.write("/home/sarah/Master/Thesis/Data/Glaciers/Austrian_Glacier_Inventory_Gl3/Glaciers_Pitztal_evolution.csv", Glacier_Areas_sorted)

Glaciers_Pitztal = readdlm("/home/sarah/Master/Thesis/Data/Glaciers/Austrian_Glacier_Inventory_Gl3/Glaciers_Pitztal_evolution.csv", ',')
plot()
for i in 1:10
    plot!([1969,1997,2006], Glaciers_Pitztal[1+i,2:end], legend=false)
end

savefig("/home/sarah/Master/Thesis/Data/Glaciers/Austrian_Glacier_Inventory_Gl3/largest10.png")

#linear regression

function linear_interpolation()
    Number_Glaciers = length(Glaciers_Pitztal[2:end,1])
    all_areas = zeros(29)
    lastyear = 1997
    firstyear = 1969
    yearsbetween = lastyear - firstyear
    for nr_glacier in 1: Number_Glaciers


        firstarea = Glaciers_Pitztal[1+ nr_glacier,2]
        lastarea = Glaciers_Pitztal[1+ nr_glacier,3]

        Einheitsvektor = (lastyear - firstyear , lastarea - firstarea)
        Einheitsvektor = Einheitsvektor ./ yearsbetween
        area = Float64[]
        append!(area, firstarea)
        for i in 1: yearsbetween
            append!(area, firstarea + Einheitsvektor[2]*i)
        end
        print("compare", lastarea, " ", area[end], "\n")
        @assert firstarea == area[1]
        @assert lastarea == round(area[end])
        all_areas = hcat(all_areas, area)
    end
    Areas_All_Glaciers = convert(Matrix, transpose(all_areas[:, 2:end]))
    return Areas_All_Glaciers, sum(Areas_All_Glaciers, dims= 1)[1:yearsbetween+1], all_areas
end

all_areas, sum_glaciers,all_areas_raw = linear_interpolation()
