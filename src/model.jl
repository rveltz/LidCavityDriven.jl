	function simulate_lid_driven_cavity(; Re, N, end_time, archi = CPU(), cfl = 0.1)
		topology = (Flat, Bounded, Bounded)
		domain = (y=(0, 1), z=(0, 1))
		grid = RegularRectilinearGrid(topology=topology, size=(N, N); domain...)

		v_bcs = VVelocityBoundaryConditions(grid,
			   top = ValueBoundaryCondition(1),
			bottom = ValueBoundaryCondition(0)
		)

		w_bcs = WVelocityBoundaryConditions(grid,
			north = ValueBoundaryCondition(0),
			south = ValueBoundaryCondition(0)
		)

		model = IncompressibleModel(
						   grid = grid,
					   buoyancy = nothing,
						tracers = nothing,
					   coriolis = nothing,
			boundary_conditions = (v=v_bcs, w=w_bcs),
						closure = IsotropicDiffusivity(ν=1/Re),
				   architecture = archi
		)

		u, v, w = model.velocities
		ζ = ComputedField(∂y(w) - ∂z(v))

		fields = (; v, w, ζ)
		global_attributes = Dict("Re" => Re)
		output_attributes = Dict("ζ" => Dict("longname" => "vorticity", "units" => "1/s"))
		field_output_writer =
			NetCDFOutputWriter(model, fields, filepath="lid_driven_cavity_Re$Re.nc", schedule=TimeInterval(0.1),
							   global_attributes=global_attributes, output_attributes=output_attributes)

		max_Δt = 0.25 * model.grid.Δy^2 * Re / 2  # Make sure not to violate diffusive CFL.
		wizard = TimeStepWizard(cfl=cfl, Δt=1e-6, max_change=1.1, max_Δt=max_Δt)

		cfl = AdvectiveCFL(wizard)
		dcfl = DiffusiveCFL(wizard)

		simulation = Simulation(model, Δt=wizard, stop_time=end_time, progress=print_progress,
								iteration_interval=20, parameters=(cfl=cfl, dcfl=dcfl))

		simulation.output_writers[:fields] = field_output_writer

		run!(simulation)

		return simulation
	end

function print_progress(simulation)
	model = simulation.model
	cfl, dcfl = simulation.parameters

	# Calculate simulation progress in %.
	progress = 100 * (model.clock.time / simulation.stop_time)

	# Find maximum velocities.
	vmax = maximum(abs, model.velocities.v)
	wmax = maximum(abs, model.velocities.w)

	i, t = model.clock.iteration, model.clock.time
	@info @sprintf("[%06.2f%%] i: %d, t: %.3f, U_max: (%.2e, %.2e), CFL: %.2e, dCFL: %.2e, next Δt: %.2e", progress, i, t, vmax, wmax, cfl(model), dcfl(model), simulation.Δt.Δt)

	return nothing
end
