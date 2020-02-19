module ObjectiveFunctions
export nse
export lognse

# """
#     NSE(Qobserved, Qmodelled)
#
# Compute the Nash Sutclifee efficiency for a model using the observed discharge ('Qobserved')
# and the modelled discharge ('Qmodeled')
# """

function nse(Qobserved, Qmodelled)
    QobservedAverage = sum(Qobserved) / length(Qobserved) #float
    QobservedAverage = ones(length(Qobserved)) * QobservedAverage
    Nominator = sum((Qobserved-Qmodelled).^2)
    Denominator = sum((Qobserved - QobservedAverage).^2)
    NashSutcliffe = 1 - (Nominator / Denominator)
    return NashSutcliffe
end

# """
#     NSElog(Qobserved, Qmodelled)
#
# Compute the logarithmic Nash Sutclifee efficiency for a model using the observed discharge ('Qobserved')
# and the modelled discharge ('Qmodeled')
# """

function lognse(Qobserved, Qmodelled)
    QobservedAverage = sum(Qobserved) / length(Qobserved) #float
    QobservedAverage = ones(length(Qobserved)) * QobservedAverage # average as array
    Nominator = sum((log.(Qobserved)-log.(Qmodelled)).^2)
    Denominator = sum((log.(Qobserved) - log.(QobservedAverage)).^2)
    NashSutcliffelog = 1 - (Nominator / Denominator)
    return NashSutcliffelog
end
end
