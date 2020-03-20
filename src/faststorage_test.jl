using Test

@testset "faststorage" begin
    for i in 1:100
        Kf = rand(1)[1]
        Storage = rand(0.1:0.1:20)[1]
        Overland = rand(0:0.1:10)[1]
        # test that output 0, if input 0
        @test faststorage(0, 0, Kf) == (0,0)
        # test that storage decreases if no input
        Discharge, Faststorage = faststorage(0, Storage, Kf)
        @test round(Storage - Faststorage, digits=12) == round(Discharge, digits=12)
        # test that discharge should be the Kf-ratio of sum of storage and overlandflow
        Discharge, Faststorage = faststorage(Overland, Storage, Kf)
        @test (Storage + Overland) * Kf == Discharge
        @test Storage + Overland - (Storage + Overland) * Kf == Faststorage
        @test Storage + Overland - Discharge == Faststorage
        # test right behavior if storage = 0
        Discharge, Faststorage = faststorage(Overland, 0, Kf)
        @test Overland * Kf == Discharge
        @test round(Discharge + Faststorage, digits=12) == round(Overland, digits=12)
    end
end
