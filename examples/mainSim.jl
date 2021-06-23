using Revise
using LidCavityDriven
using Plots

# simulation of the flow
# Hopf bifurcation at Re=7508
sim = @time simulate_lid_driven_cavity(Re=8008,  N=256, end_time=1000, archi = GPU(), cfl = 0.2)

# plotting the result
# TODO use Makie to plot the vector field

using NCDatasets
ds = NCDataset(sim.output_writers[:fields].filepath, "r")

for (iter, t) in enumerate(ds["time"])
	t>150 && break
	if t>100
		contourf(ds[:w][1,:,:,iter]', title = "t=$(round(t,digits = 3))") |> display
	end
end

wa = [ ds[:w][1,60,60,iter] for (iter, t) in enumerate(ds["time"])]
va = [ ds[:v][1,60,60,iter] for (iter, t) in enumerate(ds["time"])]

plot(ds["time"], wa, xlim = (2000,2500))
