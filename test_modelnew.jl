
push!(LOAD_PATH,".")
using DelimitedFiles
import ModelNew

forcing = readdlm("Forcing.txt")
randnr = readdlm("Parameters_rand.txt",',')

Precipitation = forcing[:,4]
Observed_Discharge = forcing[:,5]
Potential_Evaporation = forcing[:,6]

ParMinn = [0.,   0.2,  40.,    0.5,   0.001,   0.,     0.01,  .0001]
ParMaxn = [8.,    1.,  800.,   4.,    0.3,     10.,    0.1,   0.01]
#Si, Su,   Sf, Ss
Sin= [0.,  100.,  0.,  5.]
nmax=5000
A=zeros(nmax,10)
@time begin
for n in 1 : nmax
    Rnum= randnr[n,:]
    Par= Rnum .* (ParMaxn - ParMinn) + ParMinn # calculate the random parameter set
    #print("Par",Par)
    Obj = ModelNew.HBV(Par, Precipitation, Observed_Discharge, Potential_Evaporation, Sin) #call the model
    #print("obj",Obj[1])
    if Obj[1] > 0.6
        A[n,1:8] = Par
        A[n,9] = Obj[1]
        A[n,10] = Obj[2] #Store the water balance
    end
end
end
