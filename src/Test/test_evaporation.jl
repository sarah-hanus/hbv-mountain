using Test

@testset "evaporation" begin
    for i in 1:5000
        Ra = rand(10:0.1:40)
        Tmin= rand(0.1:0.1:20)
        Tmax = rand(Tmin:0.1:25)
        Kt = 0.17
        Evap = 0.0135 * Kt * ((Tmin + Tmax)/2 + 17.8) * (Tmax - Tmin)^0.5 * Ra

        @test round(epot_hargreaves(Tmin, Tmax, Kt, Ra), digits=12) == round(Evap, digits=12)
    end
end
