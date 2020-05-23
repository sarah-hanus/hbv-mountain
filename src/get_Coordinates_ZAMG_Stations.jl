# Coordinates = CSV.read("Palten/klistat_2016.txt", header = true, delim = '\t', ignorerepeated = true)
#
# #Laenge = Coordinates[2:end, 6]
# #Breite = Coordinates[2:end, 7]
#
# new_Laenge = zeros(1832)
# new_Breite = zeros(1832)
# new_ID = zeros(1832)
# for i in 2:1832
#     print(i)
#     new_Laenge[i] = parse(Float64, Coordinates[i,1][120:121]) + parse(Float64, Coordinates[i,1][122:123]) / 60 + parse(Float64, Coordinates[i,1][124:125]) / 3600
#     new_Breite[i] = parse(Float64, Coordinates[i,1][133:134]) + parse(Float64, Coordinates[i,1][135:136]) / 60 + parse(Float64, Coordinates[i,1][137:138]) / 3600
#     new_ID[i] = parse(Float64, Coordinates[i,1][5:15])
# end
# #CSV.write("Palten/coordinates.csv", Coordinates; delim=';')
#
# WeatherStations = DataFrame()
# WeatherStations["new_ID"] = new_ID[2:end]
# WeatherStations["Laenge"] = new_Laenge[2:end]
# WeatherStations["Breite"] = new_Breite[2:end]
#
# CSV.write("Palten/weatherstations.csv", WeatherStations; delim=';')
ID_Prec_Zones = [106120, 111815, 9900]
Skipto = [22, 22]
local_path = "/home/sarah/"
Precipitation = CSV.read(local_path*"HBVModel/Palten/N-Tagessummen-"*string(ID_Prec_Zones[2])*".csv", header= false, skipto=Skipto[1], missingstring = "L\xfccke", decimal=',', delim = ';')
Precipitation_Array = convert(Matrix, Precipitation)
startindex = findfirst(isequal("01.01."*string(startyear)*" 07:00:00   "), Precipitation_Array)
endindex = findfirst(isequal("31.12."*string(endyear)*" 07:00:00   "), Precipitation_Array)
Precipitation_Array = Precipitation_Array[startindex[1]:endindex[1],:]
Precipitation_Array[:,1] = Date.(Precipitation_Array[:,1], Dates.DateFormat("d.m.y H:M:S   "))
# find duplicates and remove them
df = DataFrame(Precipitation_Array)
print(size(df))
df = unique!(df)
print(size(df))
# drop missing values
df = dropmissing(df)
print(size(df))
