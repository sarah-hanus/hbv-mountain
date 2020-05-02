All_Numbers = Int[]
for i in 1:100000000
    number = rand(1:10)
    append!(All_Numbers, number)
end

for i in 1:10
    z = findall(x -> x == i, All_Numbers)
    percent = length(z) / length(All_Numbers)
    print(percent, "\n")
end
