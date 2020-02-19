module Model
export Weigfun, HBV
using DSP
using ObjectiveFunctions
function Weigfun(Tlag)
    nmax = Int(ceil(Tlag))
    if nmax == 1
        Weights = float(1)
        return [Weights]
    else
        Weights = zeros(nmax)

        th = Tlag/2
        nh_float = floor(th)
        nh = Int(nh_float)
        #print("th",th,"nh", nh)

        for i in 1 : nh
            Weights[i] = (float(i)-0.5)/th
            #print("weights",Weights[i])
        end

        i = nh + 1
        Weights[i]=(1+(float(i)-1)/th)*(th-Int(floor(th)))/2+(1+(Tlag-float(i))/th)*(Int(floor(th))+1-th)/2
        #print("weights",Weights[i])
        for i in nh+2 : Int(floor(Tlag))
            Weights[i]=(Tlag-float(i)+.5)/th
            #print("weights",Weights[i])
        end


        if Tlag>Int(floor(Tlag))
            Weights[Int(floor(Tlag))+1]=(Tlag-Int(floor(Tlag)))^2/(2*th)
        end

        Weights=Weights/sum(Weights)
        return Weights
    end
end


function HBV(Parameters, forcing, Sin, hydrograph)         #giving each parameter to certain value
    Imax = Parameters[1]
    Ce=Parameters[2]
    Sumax=Parameters[3]
    beta=Parameters[4]
    Pmax=Parameters[5]
    Tlag=Parameters[6]
    Kf=Parameters[7]
    Ks=Parameters[8]

    #giving input of rain, discharge and evaporation
    Precipitation=forcing[:,1]
    Qo=forcing[:,2]
    Etp=forcing[:,3]


    tmax=length(Precipitation)
    Si=zeros(tmax) #storage interception
    Su=zeros(tmax) #stroage unsaturated zone
    Sf=zeros(tmax) #storage fast
    Ss=zeros(tmax) #storage GW
    Eidt=zeros(tmax) #interception evaporation
    Eadt=zeros(tmax) #soil evaporation
    Qtotdt=zeros(tmax)

    #set initial values
    Si[1]=Sin[1]
    Su[1]=Sin[2]
    Sf[1]=Sin[3]
    Ss[1]=Sin[4]

    dt=1


    for i in 1 : tmax
        Pdt=Precipitation[i]*dt
        Epdt=Etp[i]*dt
        # Interception Reservoir
        if Pdt > 0
            Si[i]=Si[i]+Pdt
            Pedt=max(0,Si[i] - Imax)
            Si[i]=Si[i] - Pedt #change in storage
            Eidt[i]= min(Si[i], Epdt)
            Si[i] = Si[i]-Eidt[i]
            #print("Eidt",Eidt[i], "Si", Si[i])
        else
            # Evaporation only when there is no rainfall
            Pedt=0
            Eidt[i]=min(Epdt,Si[i])
            Si[i]=Si[i]-Eidt[i]
        end

         if i<tmax
            Si[i+1]=Si[i] #transferred to new timestep
        end

            # Unsaturated Reservoir
        if Pedt>0
            rho=(Su[i]/Sumax)^beta
            Su[i]=Su[i]+(1-rho)*Pedt #flow into unsaturated zone
            Qufdt=rho*Pedt #flow into fast reservoir
        else
            Qufdt=0
        end
            # Transpiration
        Epdt=max(0,Epdt-Eidt[i]) #potential evporation remaining in soil
        Eadt[i]=Epdt*(Su[i]/(Sumax*Ce)) # couldn't it be overfull now?
        Eadt[i]=min(Eadt[i],Su[i])
        Su[i]=Su[i]-Eadt[i]
        # Percolation
        Qusdt=(Su[i]/Sumax)*Pmax*dt #flow into slow reservoir
        Su[i]=Su[i]- Qusdt #??
        if i<tmax
            Su[i+1]=Su[i]
        end
        # Fast Reservoir
        Sf[i]=Sf[i]+Qufdt
        Qfdt= dt*Kf*Sf[i]
        Sf[i]=Sf[i]-Qfdt
        if i<tmax
            Sf[i+1]=Sf[i]
        end

        # Slow Reservoir
        Ss[i]=Ss[i]+Qusdt
        Qsdt= dt*Ks*Ss[i]
        Ss[i]=Ss[i]-Qsdt
        #Ss[i]=Ss[i]-min(Qsdt,Ss[i]) # or this??
        if i<tmax
            Ss[i+1]=Ss[i]
        end
        Qtotdt[i]=Qsdt+Qfdt
    end
  # Check Water Balance
    #print(Si[end], Ss[end], Sf[end], Su[end])
    Send=Si[end]+Ss[end]+Sf[end]+Su[end]
    Sin=sum(Sin)
    #print("Si",Si[1:3],"Ss",Ss[1:3],"Sf",Sf[1:3],"Su",Su[1:3])
    #print("sin",Sin,"send", Send)
    Stot = Send-Sin
    #print("Sin", Sin,"Ei", sum(Eidt),"Ea", sum(Eadt),"Qtot", sum(Qtotdt))
    WB=sum(Precipitation)-sum(Eidt)-sum(Eadt)-sum(Qtotdt)-Stot

    # Offset Q
    Weigths=Weigfun(Tlag)
    Qm = conv(Qtotdt,Weigths)
    #print("weights",Weigths)
    #print("qm",Qm)

    Qm=Qm[1:tmax]
    NashSutcliffe = NSE(Qo, Qm)
    if hydrograph == true
    ## Plot
    # hour=1:tmax\
        plot(range(0,stop=length(Qo)),Qo)
        plot!(range(0,stop=length(Qm)),Qm)
    end

     return NashSutcliffe, WB
 end
end
