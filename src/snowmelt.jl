function snowmelt(Meltfactor, Mm, ThresholdTemp, Temp)
    Melt = Meltfactor * Mm * ((Temp - ThresholdTemp)/Mm + log(1 + exp(-(Temp - ThresholdTemp)/Mm)))
    return Melt
end

Temp = collect(-5:0.2:5)
Melt = zeros(length(Temp))
Melt2 = zeros(length(Temp))
Melt3 = zeros(length(Temp))
Melt4 = zeros(length(Temp))
Melt_Simple = zeros(length(Temp))
Meltfactor = 3
for i in 1:length(Temp)
    Melt[i] = snowmelt(Meltfactor, 1, 0, Temp[i])
    Melt2[i] = snowmelt(Meltfactor, 0.1, 0, Temp[i])
    Melt3[i] = snowmelt(Meltfactor, 1.5, 0, Temp[i])
    Melt4[i] = snowmelt(Meltfactor, 0.5, 0, Temp[i])
    Melt_Simple[i] = Meltfactor * (Temp[i] - 0)
    #i = i + 1
end

using Plots
plot(Temp, [Melt, Melt2, Melt3, Melt4], label = ["Mm = 1" "Mm = 0.1" "Mm = 2" "Mm = 0.5"])
plot!(Temp, Melt_Simple, label="simple")
xlabel!("Temperature - Threshold Temperature")
ylabel!("Snow Melt [mm/d]")
title!("Day Degree Factor = 1 mm/d/K")
#savefig("snowmelt1.png")
#print(snowmelt(2,1,0,-5))
#print(length(Temp))

Soilstorage = [0,10,20,30,40,50,60,70,80,90,100]
Soilstoragecapacity = 100
Effective_Precipitation = 10
beta = 0.1
Q_Soil = zeros(length(Soilstorage))

for i in 1:length(Soilstorage)
    Ratio_Soil = 1 - (1 - (Soilstorage[i]/Soilstoragecapacity))^beta
    @assert Ratio_Soil <= 1 and >= 0
    Q_Soil[i] = min((1 - Ratio_Soil) * Effective_Precipitation, Soilstoragecapacity - Soilstorage[i])
end

plot(Soilstorage, Q_Soil)

beta = 3
Q_Soil = zeros(length(Soilstorage))

for i in 1:length(Soilstorage)
    Ratio_Soil = 1 - (1 - (Soilstorage[i]/Soilstoragecapacity))^beta
    @assert Ratio_Soil <= 1 and >= 0
    Q_Soil[i] = min((1 - Ratio_Soil) * Effective_Precipitation, Soilstoragecapacity - Soilstorage[i])
end

plot!(Soilstorage, Q_Soil)
