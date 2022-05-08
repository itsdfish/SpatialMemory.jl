using SafeTestsets

@safetestset "select_targets!" begin
    using SpatialMemory
    using SpatialMemory: select_targets!
    using Test

    game = Game(;grid_size = 10)
    select_targets!(game)
    n_targets = count(x -> x.is_target, game.dots)

    @test n_targets == 10

end

@safetestset "score_trial" begin
    using SpatialMemory
    using SpatialMemory: score_trial
    using Test

    game = Game(;grid_size = 3)
    
    game.dots[1,1].is_target = true 
    game.dots[1,1].selected = true

    game.dots[2,1].is_target = true
    game.dots[2,1].selected = false

    game.dots[3,1].is_target = true
    game.dots[3,1].selected = true

    game.dots[2,2].is_target = false
    game.dots[2,2].selected = true
    
    num = 1 - 1 + 1 - 1 + 5
    @test score_trial(game) ≈ (num / 9) atol = 1e-2

end