using Pkg
cd(@__DIR__)
Pkg.activate("")
using Revise, SpatialMemory

gui = start()
wait(Condition())