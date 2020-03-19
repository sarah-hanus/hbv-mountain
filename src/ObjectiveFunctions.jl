function nse(Qobserved, Qmodelled)
    # input is array of modelled and observed data
    QobservedAverage = sum(Qobserved) / length(Qobserved) #float
    QobservedAverage = ones(length(Qobserved)) * QobservedAverage
    Nominator = sum((Qobserved-Qmodelled).^2)
    Denominator = sum((Qobserved - QobservedAverage).^2)
    NashSutcliffe = 1 - (Nominator / Denominator)
    return NashSutcliffe
end

function lognse(Qobserved, Qmodelled)
    QobservedAverage = sum(Qobserved) / length(Qobserved) #float
    QobservedAverage = ones(length(Qobserved)) * QobservedAverage # average as array
    Nominator = sum((log.(Qobserved)-log.(Qmodelled)).^2)
    Denominator = sum((log.(Qobserved) - log.(QobservedAverage)).^2)
    NashSutcliffelog = 1 - (Nominator / Denominator)
    return NashSutcliffelog
end

function volumetricefficiency(Qobserved, Qmodelled)
    Nominator = sum(abs.(Qmodelled - Qobserved))
    Denominator = sum(Qobserved)
    Ve = 1 - Nominator / Denominator
    return Ve
end

function flowdurationcurve(Q)
    # input as array, the discharge has to be sorted from largest to smallest and assigned value
    # check function with data of former exercises
    SortedQ = sort(Q, rev = true)
    Rank = collect(1 : length(Q))
    Exceedanceprobability = Rank ./ (SortedQ .+ 1)
    # exceedence probability should not be higher than 1???
    return SortedQ, Exceedanceprobability
end

export nse
export lognse
export volumetricefficiency
export flowdurationcurve
