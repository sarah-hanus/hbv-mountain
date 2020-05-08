ID_Prec_Zones = [113589, 113597, 113670, 114538]



snow_cover = readdlm("Gailtal/snow_cover_fixed_113589.csv", ',')

i = 5
scatter(snow_cover[(i-1)*365:365*i, 8])
