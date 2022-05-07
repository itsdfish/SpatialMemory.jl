
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