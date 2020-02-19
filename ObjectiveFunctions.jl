module ObjectiveFunctions
export NSE
function NSE(Qobserved, Qmodelled)
    QobservedAverage = sum(Qobserved) / length(Qobserved) #float
    QobservedAverage = ones(length(Qobserved))*QobservedAverage
    Nominator = sum((Qobserved-Qmodelled).^2)
    Denominator = sum((Qobserved - QobservedAverage).^2)
    NashSutcliffe = 1 - (Nominator / Denominator)
    return NashSutcliffe
end
end
