module ModelNew
export HBV

using DSP
using ObjectiveFunctions
using ModelComponents
using Model

function HBV(Parameters, Precipitation, Observed_Discharge, Potential_Evaporation, Inital_Storage)
    #define Parameters
    Interceptionstoragecapacity = Parameters[1]
    Ce = Parameters[2]
    Soilstoragecapacity = Parameters[3]
    beta = Parameters[4]
    Percolationcapacity = Parameters[5]
    Tlag = Parameters[6]
    Kf = Parameters[7]
    Ks = Parameters[8]
    # define the maximum time
    tmax = length(Precipitation)

    # make arrays for each Model Component
    Interceptionstorage = zeros(tmax) #storage interception
    Soilstorage = zeros(tmax) #stroage unsaturated zone
    Faststorage = zeros(tmax) #storage fast
    Slowstorage = zeros(tmax) #storage GW
    Interception_Evaporation = zeros(tmax) #interception evaporation
    Soil_Evaporation = zeros(tmax) #soil evaporation
    Total_Discharge = zeros(tmax)

    # define inital storages
    Interceptionstorage[1] = Inital_Storage[1]
    Soilstorage[1] = Inital_Storage[2]
    Faststorage[1] = Inital_Storage[3]
    Slowstorage[1] = Inital_Storage[4]

    dt=1
    for i in 1 : tmax
    # define storage and evporation for that timestep
        Precipitation_dt = Precipitation[i] * dt
        Potential_Evaporation_dt = Potential_Evaporation[i] * dt
        Interceptionstorage_dt = Interceptionstorage[i]
        Soilstorage_dt = Soilstorage[i]
        Faststorage_dt = Faststorage[i]
        Slowstorage_dt = Slowstorage[i]
        Interception_Evaporation_dt = Interception_Evaporation[i]
        Soil_Evaporation_dt = Soil_Evaporation[i]

        # interception component
        Interceptionstorage_dt, Interception_Evaporation_dt, effective_Precipitation = interceptionstorage(Precipitation_dt, Potential_Evaporation_dt,
                                                                                    Interceptionstorage_dt, Interception_Evaporation_dt, Interceptionstoragecapacity)
        # unsaturated zone component
        Soilstorage_dt, Overlandflow, Percolationflow, Soil_Evaporation_dt = soilstorage(Soilstorage_dt, Potential_Evaporation_dt, Interception_Evaporation_dt, effective_Precipitation,
                                                                                    beta, Soilstoragecapacity, Ce, Percolationcapacity)
        # fast component
        Faststorage_dt, Fast_Discharge = faststorage(Faststorage_dt, Overlandflow, Kf)

        # slow component
        Slowstorage_dt, Slow_Discharge = slowstorage(Slowstorage_dt, Percolationflow, Ks)

        Interceptionstorage[i] = Interceptionstorage_dt
        Soilstorage[i] = Soilstorage_dt
        Faststorage[i] = Faststorage_dt
        Slowstorage[i] = Slowstorage_dt
        Interception_Evaporation[i] = Interception_Evaporation_dt
        Soil_Evaporation[i] = Soil_Evaporation_dt


        if i < tmax
            Interceptionstorage[i+1] = Interceptionstorage[i]
            Soilstorage[i+1] = Soilstorage[i]
            Faststorage[i+1] = Faststorage[i]
            Slowstorage[i+1] = Slowstorage[i]
        end

        Total_Discharge[i] = Fast_Discharge + Slow_Discharge
    end

    # Check Water Balance
      End_Storage = Interceptionstorage[end]+Soilstorage[end]+Faststorage[end]+Slowstorage[end]
      Inital_Storage = sum(Inital_Storage)
      #print("Si",Interceptionstorage[1:3],"Ss",Soilstorage[1:3],"Sf",Faststorage[1:3],"Su",Slowstorage[1:3])
      #print("sin",Sin,"send", Send)
      Total_Storage = End_Storage - Inital_Storage
      #print("Sin", Sin,"Ei", sum(Eidt),"Ea", sum(Eadt),"Qtot", sum(Qtotdt))
      Waterbalance = sum(Precipitation) - sum(Interception_Evaporation) - sum(Soil_Evaporation) - sum(Total_Discharge) - Total_Storage

      # Offset Q
      Weigths=Weigfun(Tlag)
      Modelled_Discharge = conv(Total_Discharge, Weigths)
      Modelled_Discharge = Modelled_Discharge[1:tmax]
      NashSutcliffe = NSE(Observed_Discharge, Modelled_Discharge)

      return NashSutcliffe, Waterbalance
  end
end

    #interceptionstorage(Precipitation[iterator], Etp, Si, Parameters[1], iterator)
