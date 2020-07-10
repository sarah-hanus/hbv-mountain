using HypothesisTests
p_value_45 = Float64[]
for i in 1:1400
    test = MannWhitneyUTest(Date_Past_85[1+((i-1)*30):30*i], Date_Future_85[1+((i-1)*30):30*i])
    p = pvalue(test; tail = :both)
    append!(p_value_45, p)
end
