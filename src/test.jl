All_Numbers = Float64[]
precission = 0.00001
for i in 1:100000000
    number = rand(100.0:precission:500.0)
    append!(All_Numbers, number)
end

percentage = Float64[]
for i in 100:499
    z = findall(x -> x >= i && x <= (i + 1), All_Numbers)
    percent = length(z) / length(All_Numbers)
    push!(percentage, percent)
end
