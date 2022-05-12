module MemoryGame
    using SpatialMemory
    export julia_main

    function julia_main()::Cint
        gui = start()
        return 0
    end
end