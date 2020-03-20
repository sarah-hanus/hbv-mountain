using Test
@testset "slowstorage" begin
    for i in 1:5
        Ks = rand(0.0001:0.001:0.1)[1]
        Ratio_Rip = rand(0.001:0.01:0.8)[1]
        Storage = rand(0.1:0.01:20)[1]
        Percolation = rand(0:0.01:10)[1]
        Preferential = rand(0:0.01:10)[1]
        # test that output 0, if input 0
        @test slowstorage(0, 0, 0, Ks, Ratio_Rip) == (0, 0, 0)
        # test that storage decreases if no input
        Riparian_Discharge, Slow_Discharge, Slowstorage = slowstorage(0, 0, Storage, Ks, 0)
        @test round(Storage - Slowstorage, digits=12) == round(Slow_Discharge, digits=12)
        Riparian_Discharge, Slow_Discharge, Slowstorage = slowstorage(0, 0, Storage, 0, Ratio_Rip)
        @test round(Storage - Slowstorage, digits=12) == round(Riparian_Discharge, digits=12)
        # test that discharge should be the Ks-ratio of sum of storage and overlandflow
        Riparian_Discharge, Slow_Discharge, Slowstorage = slowstorage(Percolation, Preferential, Storage, Ks, Ratio_Rip)
        Inflow = Percolation + Preferential
        @test (Storage + Inflow) * Ks  == Slow_Discharge + Riparian_Discharge
        @test Storage + Inflow - Slow_Discharge + Riparian_Discharge == Slowstorage
        # test right behavior if storage = 0
        # Discharge, Faststorage = faststorage(Percolation, Preferential, 0, Ks, Ratio_Rip)
        # @test (Percolation + Preferential) * Ks * (1 - Ratio_Rip) == Slow_Discharge
        # @test (Percolation + Preferential) * Ks == Slow_Discharge + Riparian_Discharge
        # @test round(Slow_Discharge + Riparian_Discharge + Faststorage, digits=12) == round(Percolation + Preferential, digits=12)
    end
end
