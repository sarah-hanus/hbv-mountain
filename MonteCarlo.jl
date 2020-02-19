using DelimitedFiles
using DSP
push!(LOAD_PATH,".")
using Model
using ObjectiveFunctions
forcing = readdlm("Forcing.txt")
randnr = readdlm("Parameters_rand.txt",',')

forcing= forcing[:,4:6]
#      Imax Ce Sumax beta Pmax   Tlag   Kf  Ks
ParMinn = [0.,   0.2,  40.,    0.5,   0.001,   0.,     0.01,  .0001]
ParMaxn = [8.,    1.,  800.,   4.,    0.3,     10.,    0.1,   0.01]
#Si, Su,   Sf, Ss
Sin= [0.,  100.,  0.,  5.]
nmax=5000
B=zeros(nmax,10)
@time begin
for n in 1 : nmax
    Rnum= randnr[n,:]
    Par= Rnum .* (ParMaxn - ParMinn) + ParMinn # calculate the random parameter set
    #print("Par",Par)
    Obj = HBV(Par,forcing,Sin,false) #call the model
    #print("obj",Obj[1])
    if Obj[1] > 0.6
        B[n,1:8] = Par
        B[n,9] = Obj[1]
        B[n,10] = Obj[2] #Store the water balance
    end
end
end
##
#NumberBestParameters = count(n -> A[n,9] != 0, Array(1:5000)) # gets number of Best Parameters
# BestParameters = zeros(NumberBestParameters,10)
#print(NumberBestParameters)
# counter = 1
# for n in 1 : nmax
#     #i = 1
#     if A[n,9] != 0
#         BestParameters[counter,:] = A[n,:]
#         globalcounter += 1
#     end
# end
