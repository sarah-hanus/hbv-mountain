function faststorage(Faststorage, Overlandflow, Kf)
    # the fast storage increases with the overland flow
    Faststorage = Faststorage + Overlandflow
    # a part of the fast storage gets redirected into discharge depending on the reservoir constant (linear response)
    Fast_Discharge = Kf*Faststorage
    Faststorage = Faststorage-Fast_Discharge

    return Faststorage, Fast_Discharge
end
