function slowstorage(Slowstorage, Percolationflow, Ks)
    Slowstorage = Slowstorage + Percolationflow
    Slow_Discharge = Ks*Slowstorage
    Slowstorage = Slowstorage- Slow_Discharge
    #Ss[i]=Ss[i]-min(Qsdt,Ss[i]) # or this??

    return Slowstorage, Slow_Discharge
end
