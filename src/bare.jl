# bare rock/sparsely vegetated HRU

# snow component
Melt_Total, Snowstorage = snow(Area_Glacier, Precipitation, Temp, Snowstorage, Meltfactor, Mm, Temp_Thresh)

#interception component
Effective_Precipitation, Interception_Evaporation, Interceptionstorage = interception(Potential_Evaporation, Precipitation, Temp, Interceptionstorage, Interception_Evaporation, Imax, Temp_Thresh)

#soil storage component
