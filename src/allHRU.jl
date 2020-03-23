function allHRU(bare::HRU_Input, forest::HRU_Input, grass::HRU_Input, rip::HRU_Input, Slowstorage, Ks, Ratio_Riparian)
    #bare rock HRU
    bare_out::HRU_Output = hillslopeHRU(bare)
    # forest HRU
    forest_out::HRU_Output = hillslopeHRU(forest)
    # Grassland HRU
    grass_out::HRU_Output = hillslopeHRU(grass)
    # riparian HRU
    rip_out::HRU_Output = riparianHRU(rip)

    Total_GWflow = bare_out.GWflow + forest_out.GWflow + grass_out.GWflow

    Riparian_Discharge, Slow_Discharge, Slowstorage = slowstorage(Total_GWflow, Slowstorage, Ks, Ratio_Riparian)
    #return all storage values, all evaporation values, Fast_Discharge and Slow_Discharge

    # calculate total discharge of the timestep
    Total_Discharge = bare_out.Fast_Discharge + forest_out.Fast_Discharge + grass_out.Fast_Discharge + rip_out.Fast_Discharge + Slow_Discharge


    return bare_out, forest_out, grass_out, rip_out, Riparian_Discharge, Total_Discharge, Slowstorage
end
