module ObjectiveFunctions
export nse
export lognse
export einfach


function einfach(x)
    x + 1
end

function nse(Qobserved, Qmodelled)
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
end
