module LidCavityDriven

	using Printf
	using Logging
	using Oceananigans
	import Oceananigans.CPU
	import Oceananigans.GPU

	Logging.global_logger(OceananigansLogger())

	include("model.jl")
	
	export CPU, GPU
	export simulate_lid_driven_cavity

end
