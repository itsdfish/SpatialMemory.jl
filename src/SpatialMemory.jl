module SpatialMemory
    using Gtk, Cairo, Gtk.ShortNames, StatsBase
    using Distributions
    export Dot, Game, GUI, start
    export click_dot!, click_submit!, can_select

    include("structs.jl")
    include("functions.jl")
    include("gui.jl")
end
