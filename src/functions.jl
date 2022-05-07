
click_dot!(game, dot, gui::Nothing) = click_dot!(game, dot)

function click_dot!(game, dot)
    can_respond(game) ? nothing : (return false)
    if dot.selected
        dot.selected = false
    else
        dot.selected = true
    end
    return true
end

function can_respond(game)
    return game.can_respond
end

populate(n_rows, n_cols) = [Dot(;row, col) for row in 1:n_rows, col in 1:n_cols]

game_over!(game) = game.round == 0

function compute_score!(game)
    game.score = score_trial(game)
end

function update_round!(game)
    game.round -= 1
end

click_submit!(game, gui::Nothing) = click_submit!(game)

function click_submit!(game)
    can_respond(game) ? nothing : return false
    game_over!(game) ? (return false) : nothing
    game.can_start = true
    game.can_respond = false
    update_round!(game)
    compute_score!(game)
    return true
end

function select_targets!(game)
    n = game.dims |> prod
    n_targets = game.dims[1]
    idx = sample(1:n, n_targets, replace=false)
    for i in idx 
        game.dots[i].is_target = true
    end
    return nothing
end

function score_trial(game)
    score = 0
    n = game.dims |> prod
    for dot in game.dots 
        score += dot.is_target == dot.selected ? 1 : -1
    end
    return round(score / n, digits = 2) 
end

# function score_trial(game)
#     n_hits = 0
#     n_false_alarms = 0
#     n_target = game.dims[1]
#     n_foil = prod(game.dims) - n_target
#     for dot in game.dots
#         if dot.is_target
#             n_hits += dot.selected ? 1 : 0
#         else
#             n_false_alarms += dot.selected ? 1 : 0
#         end
#     end
#     θhit = n_hits / n_target
#     θfa = n_false_alarms / n_foil
#     θhit = θhit == 1 ? (n_target - .01) / n_target : θhit
#     θhit = θhit == 0 ? .01 / n_target : θhit
#     θfa = θfa == 1 ? (n_foil - .01) / n_foil : θfa
#     θfa = θfa == 0 ? (.01 / n_foil) : θfa
#     println(θfa, " ", θhit)
#     d′ = invlogcdf(Normal(0, 1), log(θhit)) - invlogcdf(Normal(0, 1), log(θfa))
#     return d′
# end

function adapt_difficulty(game)
    (;score,) = game
    if score == 1
        n_rows,n_cols = game.dims = game.dims .+ 1
        return Game(game; n_cols, n_rows)
    elseif score ≥ .8
        n_rows,n_cols = game.dims
        return Game(game; n_cols, n_rows)
    end
    n_rows,n_cols = game.dims = game.dims .- 1
    n_rows = max(n_rows, 2)
    n_cols = max(n_cols, 2)
    return Game(game; n_cols, n_rows)
end

# function adapt_difficulty(game)
#     (;score,) = game
#     if score > 4
#         n_rows,n_cols = game.dims = game.dims .+ 1
#         return Game(game; n_cols, n_rows)
#     elseif score ≥ 3
#         n_rows,n_cols = game.dims
#         return Game(game; n_cols, n_rows)
#     end
#     n_rows,n_cols = game.dims = game.dims .- 1
#     n_rows = max(n_rows, 2)
#     n_cols = max(n_cols, 2)
#     return Game(game; n_cols, n_rows)
# end