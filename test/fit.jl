using GrowthMaps, Rasters, ModelParameters, Unitful, Test, Plots
using Unitful: °C, K, hr, d, mol, cal
using GrowthMaps: rate, condition, conditionalrate
using Rasters.LookupArrays

#= This file just tests that the fitting routines run, not
that they work, which is difficult with Interact.jl. =#

p = Param(0.3; units=nothing, bounds=(0.0, 1.0))
ΔH_A = Param(2e4; units=u"cal*mol^-1", bounds=(2e3, 2e5))
ΔH_L = Param(-1e5; units=u"cal*mol^-1", bounds=(1e-6, 1e-4))
ΔH_H = Param(3e5; units=u"cal*mol^-1", bounds=(3e4, 3e6))
T_halfL = Param(250.0; units=u"K", bounds=(200, 300))
T_halfH = Param(300.0; units=u"K", bounds=(200, 300))
T_ref = K(25.0°C)
growth = Layer(:temp, K, SchoolfieldIntrinsicGrowth(p, ΔH_A, ΔH_L, T_halfL, ΔH_H, T_halfH, T_ref))
model = Model(growth)


obs = [(10.0°C, 0.0), (20.0°C, 0.2), (30.0°C, 0.1), (40.0°C, 0.0)]

@testset "Auto fit" begin
    fitted = fit!(model, obs)
end

@testset "Manual fit interface" begin
    data = (temp=0.0:1.0:45.0,)

    withunits(model, :bounds)
    interface = manualfit!(model, data; obs=obs);
end

# @testset "Map fit interface" begin
#     ## Set up series data
#     tempdata = Raster.(
#         [rand(0.0:40.0, 10, 10) for i in 1:5], Ref((X, Y)); 
#         name=:stress, missingval=-99.0
#     )
#     stacks = [RasterStack((temp=tempdata[i],)) for i in 1:length(tempdata)]
#     timedim = (Ti(Sampled((1:1:5)hr; span=Regular(1hr))),)
#     modelkwargs = (series=RasterSeries(stacks, timedim), tspan=1hr:1hr:5hr)
#     interface = mapfit!(model, modelkwargs; occurrence=[(1, 2), (9, 10)]);
# end
@testset "Map fit interface" begin
    # Generate random temperature data and convert each matrix to a Raster with dimensions.
    tempdata = [Raster(rand(0.0:40.0, 10, 10), dims=(X(), Y()), name=:temp, missingval=-99.0) for i in 1:5]
    
    # Create a RasterStack for each Raster in tempdata.
    stacks = [RasterStack(temp=tempdata[i]) for i in 1:length(tempdata)]
    
    # Define the time dimension as a regular sampled dimension.
    timedim = (Ti(Sampled((1:1:5)hr; span=Regular(1hr))),)
    
    # Create a RasterSeries from the stacks and timedim.
    series = RasterSeries(stacks, timedim)
    
    # Define model arguments for the fitting function.
    modelkwargs = (series=series, tspan=1hr:1hr:5hr)
    
    # Perform the model fitting with the specified occurrence positions.
    interface = mapfit!(model, modelkwargs; occurrence=[(1, 2), (9, 10)])
end


# To test interfaces manually
# using Blink
# w = Blink.Window()
# body!(w, interface)
