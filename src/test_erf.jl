using SpecialFunctions
x = collect(0:0.05:50)
plot()
for i in 0.05:0.01:0.5
      plot!(x, 12.1*erf.(i.*x), label=i)
end
xlabel!("Discharge [m³/s]")
ylabel!("Outtake [m³/s]")
savefig("eerrorfunctions.png")


plot()
for i in 0.01:0.001:0.08
      plot!(x, loss(x, i), label=i)
end
#ylims!((0,13))
#xlims!(0,20)
xlabel!("Discharge [m³/s]")
ylabel!("Outtake[m³/s]")
savefig("outtake_exp.png")

function loss(Discharge, loss_parameter)
      loss = loss_parameter .* Discharge.^2
      loss[loss.>12.1] .= 12.1
      return loss
end
