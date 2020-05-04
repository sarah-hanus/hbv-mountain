using Random
function parameter_selection()
        # maximum parameter

        max_Interceptioncapacity_Grass = 2.0
        max_Interceptioncapacity_Rip = 3.0
        max_Ks = 0.1
        max_Kf = 3.0
        max_Soilstoaragecapacity_Grass = 250.0
        max_Soilstoaragecapacity_Rip = 200.0
        max_Soilstoaragecapacity_Bare = 50.0

        precission = 0.00001

        beta_Bare = rand(0.1:precission: 2.0)
        beta_Forest = rand(0.1: precission: 2.0)
        beta_Grass = rand(0.1: precission: 2.0)
        beta_Rip = rand(0.1: precission: 2.0)
        Ce = rand(0.4: precission :0.8)
        Drainagecapacity = 0.0
        Interceptioncapacity_Bare = 0.0
        Interceptioncapacity_Forest = rand(1.0:precission:3.0)
        # parameter constraint Interception interceptioncapacity grass and rip lower than Interceptioncapacity_Forest
        if Interceptioncapacity_Forest < max_Interceptioncapacity_Grass
                Interceptioncapacity_Grass = rand(0.0:precission:Interceptioncapacity_Forest)
        else
                Interceptioncapacity_Grass = rand(0.0:precission: max_Interceptioncapacity_Grass)
        end

        if Interceptioncapacity_Forest < max_Interceptioncapacity_Rip
                Interceptioncapacity_Rip = rand(0.0:precission:Interceptioncapacity_Forest)
        else
                Interceptioncapacity_Rip = rand(0.0:precission: max_Interceptioncapacity_Rip)
        end
        # parameter constraints on fast reservoir coefficients
        Kf_Rip = rand(0.5:precission:3.0)
        if Kf_Rip < max_Kf
                Kf = rand(0.1:precission:Kf_Rip)
        else
                Kf = rand(0.1:precission: max_Kf)
        end

        if Kf < max_Ks
                Ks = rand(0.001:precission * 0.1: Kf)
        else
                Ks = rand(0.001:precission * 0.1: max_Ks)
        end
        Meltfactor = rand(1.75:precission:6.0)
        Mm = rand(0.001:precission:1.0)
        Precipitation_Gradient = 0.0
        #Precipitation_Gradient = round(random_parameter(0, 0.0045), precission= 5)
        Ratio_Pref = rand(0.0:precission:1.0)
        # Parameter Constrain SOilstoragecapacity Forest >= Grass >= Rip/Bare
        Soilstoaragecapacity_Forest = rand(100.0:precission:500.0)
        if Soilstoaragecapacity_Forest < max_Soilstoaragecapacity_Grass
                Soilstoaragecapacity_Grass = rand(50.0:precission:Soilstoaragecapacity_Forest)
        else
                Soilstoaragecapacity_Grass = rand(50.0:precission: max_Soilstoaragecapacity_Grass)
        end

        if Soilstoaragecapacity_Grass < max_Soilstoaragecapacity_Rip
                Soilstoaragecapacity_Rip = rand(50.0:precission:Soilstoaragecapacity_Grass)
        else
                Soilstoaragecapacity_Rip = rand(50.0:precission: max_Soilstoaragecapacity_Rip)
        end

        if Soilstoaragecapacity_Grass < max_Soilstoaragecapacity_Bare
                Soilstoaragecapacity_Bare = rand(5.0:precission:Soilstoaragecapacity_Grass)
        else
                Soilstoaragecapacity_Bare = rand(50.0:precission: max_Soilstoaragecapacity_Bare)
        end

        Temp_Thresh = rand(-2.0:precission:2.0)
        Ratio_Riparian = rand(0.05:precission:0.5)
         # based on calculation of recession curve

        bare_parameters = Parameters(beta_Bare, Ce, 0, Interceptioncapacity_Bare, Kf, Meltfactor, Mm, Ratio_Pref, Soilstoaragecapacity_Bare, Temp_Thresh)
        forest_parameters = Parameters(beta_Forest, Ce, 0, Interceptioncapacity_Forest, Kf, Meltfactor, Mm, Ratio_Pref, Soilstoaragecapacity_Forest, Temp_Thresh)
        grass_parameters = Parameters(beta_Grass, Ce, 0, Interceptioncapacity_Grass, Kf, Meltfactor, Mm, Ratio_Pref, Soilstoaragecapacity_Grass, Temp_Thresh)
        rip_parameters = Parameters(beta_Rip, Ce, Drainagecapacity, Interceptioncapacity_Rip, Kf, Meltfactor, Mm, Ratio_Pref, Soilstoaragecapacity_Rip, Temp_Thresh)
        slow_parameters = Slow_Paramters(Ks, Ratio_Riparian)

        parameters_array = [beta_Bare, beta_Forest, beta_Grass, beta_Rip, Ce, Interceptioncapacity_Forest, Interceptioncapacity_Grass, Interceptioncapacity_Rip, Kf_Rip, Kf, Ks, Meltfactor, Mm, Ratio_Pref, Ratio_Riparian, Soilstoaragecapacity_Bare, Soilstoaragecapacity_Forest, Soilstoaragecapacity_Grass, Soilstoaragecapacity_Rip, Temp_Thresh]

        return [bare_parameters, forest_parameters, grass_parameters, rip_parameters, slow_parameters], parameters_array
end
