function setup_menu(gui, game)
    mb = GtkMenuBar(name="menu_bar")
    file = GtkMenuItem("_File")
    file_menu = GtkMenu(file, name="file_menu")
    new_game = GtkMenuItem("New Game", name="new_game")

    game = Game()
    signal_connect(x -> start_new_game!(x, gui, game), new_game, :activate)
    push!(file_menu, new_game)
    setup = GtkMenuItem("Setup", name="setup")

    signal_connect(x -> setup_game(x, game, gui), setup, :activate)
    push!(file_menu, setup)
    push!(mb, file)
    return mb
end

start_new_game!(x, gui, game) = start_new_game!(gui, game)

function start_new_game!(gui, game)
    remove_components!(gui)
    filename = joinpath(@__DIR__, "style.css")
    style = CssProviderLeaf(;filename)
    generate_gui!(game, gui, style)
end

function setup_game(x, game, gui)
    popup = GtkWindow("Setup")
    base_panel = GtkBox(:v)
    push!(popup, base_panel)
    grid = GtkGrid()
    grid_size_label = GtkLabel("Grid Size")
    # row_label = GtkLabel("Number of Rows")
    round_label = GtkLabel("Number of Rounds")
    grid_size_entry = GtkEntry(name="grid_size_value")
    # row_entry = GtkEntry(name="row_value")
    round_entry = GtkEntry(name="round_value")
    grid[1,1] = grid_size_label
    grid[2,1] = grid_size_entry
    grid[1,2] = round_label
    grid[2,2] = round_entry
    GAccessor.justify(grid_size_label, Gtk.GConstants.GtkJustification.LEFT)
    set_gtk_property!(grid, :column_spacing, 5)  # introduce a 15-pixel gap between columns
    set_gtk_property!(grid, :row_spacing, 5)
    set_gtk_property!(grid, :column_homogeneous, true)
    set_gtk_property!(grid, :row_homogeneous, true)
    push!(base_panel, grid)
    ok_button = GtkButton("OK")
    components = (;grid_size_entry, round_entry, popup)
    signal_connect(x -> modify_game(x, components, game, gui), ok_button, "clicked")
    cancel_button = GtkButton("Cancel")
    signal_connect(x -> close_window(x, popup), cancel_button, "clicked")
    hbox = GtkButtonBox(:h)
    set_gtk_property!(hbox, :expand, ok_button, true)
    set_gtk_property!(hbox, :spacing, 10)
    push!(base_panel, hbox)
    push!(hbox, cancel_button)
    push!(hbox, ok_button)
    showall(popup)
end

function modify_game(x, c, game, gui)
    str_grid_size = get_gtk_property(c.grid_size_entry, :text, String)
    str_rounds = get_gtk_property(c.round_entry, :text, String)

    # is_error,n_cols = parse_value(str_cols, "Columns")
    # is_error ? (return nothing) : nothing

    # is_error,n_rows = parse_value(str_rows, "Rows")
    # is_error ? (return nothing) : nothing

    is_error,grid_size = parse_value(str_grid_size, "Grid Size")
    is_error ? (return nothing) : nothing


    is_error,n_rounds = parse_value(str_rounds, "Rounds")
    is_error ? (return nothing) : nothing

    game = Game(; grid_size, n_rounds)
    start_new_game!(gui, game)
    close_window(c.popup)
    return nothing
end

function parse_value(value, label)
    number = 0
    try 
        number = parse(Int, value)
    catch
        error_popup("$label must be a number")
        return true,-1
    end
    if number < 1
        is_error = true
        error_popup("$label must be greater than 1")
        return true,-1
    end
    return false,number
end

function error_popup(error_message)
    error_window = GtkWindow("Error")
    base_panel = GtkBox(:v)
    set_gtk_property!(base_panel, :spacing, 20)
    message = GtkLabel(error_message)
    ok_button = GtkButton("OK")
    push!(error_window, base_panel)
    push!(base_panel, message)
    push!(base_panel, ok_button)
    signal_connect(x -> close_window(x, error_window), ok_button, "clicked")
    showall(error_window)
    return nothing
end

close_window(_, component) = close_window(component)

function close_window(component)
    hide(component)
end

generate_gui!(game, gui) = generate_gui!(game, gui.gui, gui.style)

function generate_gui!(game, gui, style)
    base_panel = GtkBox(:v, name="base_panel")
    menu_bar = setup_menu(gui, game)
    push!(base_panel, menu_bar)

    info_panel = GtkBox(:h, name="info_panel")
    sc = Gtk.GAccessor.style_context(info_panel)
    set_gtk_property!(info_panel, :spacing, 30)
    set_gtk_property!(info_panel, :halign, 3)
    push!(base_panel, info_panel)
    push!(sc, StyleProvider(style), 600)

    label = GtkLabel("Rounds ", name="rounds_label")
    sc = Gtk.GAccessor.style_context(label)
    push!(sc, StyleProvider(style), 600)
    push!(info_panel, label)

    round_count = GtkLabel(string(game.round), name="round_count")
    sc = Gtk.GAccessor.style_context(round_count)
    push!(sc, StyleProvider(style), 600)
    push!(info_panel, round_count)
    
    score_label = GtkLabel("Score", name="score_label")
    sc = Gtk.GAccessor.style_context(score_label)
    push!(sc, StyleProvider(style), 600)
    push!(info_panel, score_label)

    score_value = GtkLabel("0", name="score_value")
    sc = Gtk.GAccessor.style_context(score_value)
    push!(sc, StyleProvider(style), 600)
    push!(info_panel, score_value)

    g = GtkGrid(name="grid")
    push!(base_panel, g)
    
    control_grid = GtkGrid(name="control_grid")
    push!(base_panel, control_grid)

    start_button = GtkButton(name="start_button")
    start_label = GtkLabel("Start", name="start_label")
    push!(start_button, start_label)
    sc = Gtk.GAccessor.style_context(start_label)
    push!(sc, StyleProvider(style), 600)

    submit_button = GtkButton(name="submit_button")
    submit_label = GtkLabel("Submit", name="submit_label")
    push!(submit_button, submit_label)
    sc = Gtk.GAccessor.style_context(submit_label)
    push!(sc, StyleProvider(style), 600)

    control_grid[1,1] = start_button
    control_grid[2,1] = submit_button
    signal_connect(_ -> click_submit!(game, gui, style), submit_button, "clicked")
    signal_connect(_ -> click_start!(game, gui, style), start_button, "clicked")

    set_gtk_property!(control_grid, :column_spacing, 1)
    set_gtk_property!(control_grid, :row_spacing, 1)
    set_gtk_property!(control_grid, :column_homogeneous, true)
    set_gtk_property!(control_grid, :row_homogeneous, true)
    #set_gtk_property!(control_grid, :expand, true)

    n_rows,n_cols = size(game.dots)
    for r in 1:n_rows, c in 1:n_cols
        b = GtkButton("")
        dot = game.dots[r,c]
        g[c,r] = b
        signal_connect(x -> click_dot!(game, dot, gui, x, style), b, "clicked")
    end
    set_gtk_property!(g, :column_spacing, 5)
    set_gtk_property!(g, :row_spacing, 5)
    set_gtk_property!(g, :column_homogeneous, true)
    set_gtk_property!(g, :row_homogeneous, true)
    set_gtk_property!(g, :expand, true)
    
    push!(gui, base_panel)
    showall(gui)
end

get_button(gui::GUI, dot) = get_button(gui.gui, dot)
get_button(gui, dot) = gui[1][3][dot.col,dot.row]

function click_dot!(game, dot, gui::GUI)
    button = get_button(gui, dot)
    return click_dot!(game, dot, gui.gui, button, gui.style)
end

function click_dot!(game, dot, gui, button, style)
    !click_dot!(game, dot) ? (return false) : nothing
    if dot.selected
        change_color!(button, style, "target")
    else
        change_color!(button, style, "")
    end
    return true
end

function display_targets!(game, gui, style)
    cnt = 1
    for dot in game.dots 
        if dot.is_target
            button = get_button(gui, dot)
            change_color!(button, style, "target")
            cnt += 1
        end
    end
    return nothing
end

function remove_targets!(game, gui, style)
    for dot in game.dots 
        if dot.is_target
            button = get_button(gui, dot)
            change_color!(button, style, "")
        end
    end
    return nothing
end

function change_color!(button, style, color)
    label = button[1]
    sc = Gtk.GAccessor.style_context(label)
    push!(sc, StyleProvider(style), 600)
    set_gtk_property!(label, :name, color)
end

function make_all_grey!(gui, game, style)
    for (button,dot) in zip(gui[1][3],game.dots)
        change_color!(button, style, "")
    end
    return nothing
end

click_submit!(game, gui::GUI) = click_submit!(game, gui.gui, gui.style)

function click_submit!(game, gui, style)
    !click_submit!(game) ? (return false) : nothing
    update_score!(game, gui)
    update_round!(game, gui)
    display_feedback!(game, gui, style)
    return true
end

function display_feedback!(game, gui, style)
    for dot in game.dots
        button = get_button(gui, dot)
        if dot.is_target && dot.selected
            change_color!(button, style, "hit")
        elseif dot.is_target && !dot.selected
            change_color!(button, style, "miss")
        elseif !dot.is_target && dot.selected
            change_color!(button, style, "false_alarm")
        else
            change_color!(button, style, "")
        end
    end
    return nothing
end

function update_round!(game, gui)
    score = gui[1][2][2]
    set_gtk_property!(score, :label, string(game.round))
end 

function update_score!(game, gui)
    counter = gui[1][2][4]
    set_gtk_property!(counter, :label, string(game.score))
    return nothing
end

function remove_components!(gui)
    for g in gui
        delete!(gui, g)
    end
end

function start()
    game = Game()
    gui = GUI(;game)
    return gui
end

function click_start!(game, gui, style)
    game.can_start ? nothing : (return nothing)
    game.can_start = false
    if game.n_rounds != game.round
        game = adapt_difficulty(game)
        start_new_game!(gui, game)
    end
    select_targets!(game)
    display_targets!(game, gui, style)
    Timer(_ -> remove_targets!(game, gui, style), 3) 
    f(game) = game.can_respond = true
    Timer(_ -> f(game), 3) 
    return nothing
end