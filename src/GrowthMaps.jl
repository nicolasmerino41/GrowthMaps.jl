module GrowthMaps
__precompile__(false)
# Use the README as the module docs
@doc read(joinpath(dirname(@__DIR__), "README.md"), String) GrowthMaps

using ConstructionBase,
      Dates,
      Rasters,
      InteractModels,
      LsqFit,
      Plots,
      Reexport,
      Unitful

@reexport using ModelParameters

using Rasters.LookupArrays 
using Unitful: °C, K, R, Units
using Base: tail

export mapgrowth, fit, fit!, manualfit!, mapfit!

export RateModel

export GrowthModel, SchoolfieldIntrinsicGrowth

export StressModel, LowerStress, UpperStress

export Layer

include("models.jl")
include("framework.jl")
include("fit.jl")

end # module
