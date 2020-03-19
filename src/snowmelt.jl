function snowmelt(Meltfactor, Mm, ThresholdTemp, Temp)
    Melt = Meltfactor * Mm * ((Temp - ThresholdTemp)/Mm + log(1 + exp(-(Temp - ThresholdTemp)/Mm)))
    return Melt
end

Temp = collect(-5:0.2:5)
Melt = zeros(length(Temp))
Melt2 = zeros(length(Temp))
Melt3 = zeros(length(Temp))
Melt4 = zeros(length(Temp))
for i in 1:length(Temp)
    Melt[i] = snowmelt(1, 1, 0, Temp[i])
    Melt2[i] = snowmelt(1, 0.1, 0, Temp[i])
    Melt3[i] = snowmelt(1, 2, 0, Temp[i])
    Melt4[i] = snowmelt(1, 0.5, 0, Temp[i])
    #i = i + 1
end

using Plots
plot(Temp, [Melt, Melt2, Melt3, Melt4], label = ["Mm = 1" "Mm = 0.1" "Mm = 2" "Mm = 0.5"])
xlabel!("Temperature - Threshold Temperature")
ylabel!("Snow Melt [mm/d]")
title!("Day Degree Factor = 1 mm/d/K")
savefig("snowmelt1.png")
#print(snowmelt(2,1,0,-5))
#print(length(Temp))
