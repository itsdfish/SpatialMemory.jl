"""
    Dot(; selected=false, target=false, col, row

Generates a dot object containing the following elements:

- `selected`: dot is selected if true
- `is_target`: target to be memorized if true 
- `row`: row index 
- `col`: col index 
"""
mutable struct Dot
    selected::Bool
    is_target::Bool
    row::Int
    col::Int
end

function Dot(; selected=false, target=false, col, row)
    return Dot(selected, target, row, col)
end

"""
    Game(;n_rows=8, n_cols=8, n_rounds=30, round=n_rounds, visible=true)

Generates a game object containing the following elements:

- `dots`: an array of dots representing the board
- `selected_dots`: an array of selected dots
- `n_rounds`: the number of rounds in a game 
- `round`: current round 
- `score`: the number of connected dots
- `visible`: display GUI if true
"""
mutable struct Game
    dots::Array{Dot,2}
    n_rounds::Int
    round::Int
    score::Float64
    visible::Bool
    grid_size::Int
    can_respond::Bool
    can_start::Bool
end

function Game(game; grid_size)
    (;n_rounds,round,score,visible,can_respond,can_start) = game
    return Game(;grid_size, n_rounds,round, score, visible, can_respond, can_start)
end

function Game(;
    grid_size = 2, 
    n_rounds = 30, 
    round = n_rounds, 
    visible = true, 
    can_respond = false, 
    can_start = true,
    score = 0.0,
    )
    dots = populate(grid_size)
    return Game(dots, n_rounds, round, score, visible, grid_size, can_respond, can_start)
end

Broadcast.broadcastable(x::Game) = Ref(x)

mutable struct GUI{G,S}
    gui::G
    style::S
end

function GUI(;width=700, height=600, game = Game())
    gui = GtkWindow("Memory", width, height)
    filename = joinpath(@__DIR__, "style.css")
    style = CssProviderLeaf(;filename)
    generate_gui!(game, gui, style)
    GUI(gui, style)
end
