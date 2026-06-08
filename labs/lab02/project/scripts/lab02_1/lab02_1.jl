using DifferentialEquations
using Plots

default(fmt = :png)

script_name = "lab02_1_variant54"
output_dir = joinpath(pwd(), "plots", script_name)
mkpath(output_dir)

k = 17.7          # начальное расстояние между катером и лодкой, км
n = 3.8           # скорость катера в n раз больше скорости лодки
fi = 3*pi/4       # направление движения лодки

r0_1 = k / (n + 1)

r0_2 = k / (n - 1)

function f(r, p, theta)
    return r / sqrt(n^2 - 1)
end

tspan1 = (0.0, 2*pi)
prob1 = ODEProblem(f, r0_1, tspan1)
sol1 = solve(prob1, Tsit5(), saveat = 0.01)

tspan2 = (-pi, pi)
prob2 = ODEProblem(f, r0_2, tspan2)
sol2 = solve(prob2, Tsit5(), saveat = 0.01)

r_meet1 = sol1(fi)
r_meet2 = sol2(fi)

println("Вариант 54")
println("k = ", k, " км")
println("n = ", n)
println("sqrt(n^2 - 1) = ", round(sqrt(n^2 - 1), digits = 3))
println("Начальное расстояние для случая 1: r0 = ", round(r0_1, digits = 3), " км")
println("Начальное расстояние для случая 2: r0 = ", round(r0_2, digits = 3), " км")
println("Точка пересечения 1: r = ", round(r_meet1, digits = 3), " км, θ = ", round(fi, digits = 3))
println("Точка пересечения 2: r = ", round(r_meet2, digits = 3), " км, θ = ", round(fi, digits = 3))

plot_limit = ceil(maximum([maximum(sol1.u), maximum(sol2.u), r_meet1, r_meet2]) + 5)
theta_boat = [fi, fi]
r_boat = [0, plot_limit]

p1 = plot(sol1.t, sol1.u,
          proj = :polar,
          lims = (0, plot_limit),
          title = "Вариант 54: случай 1",
          label = "Катер",
          lw = 2)
plot!(p1, theta_boat, r_boat,
      label = "Лодка",
      linestyle = :dash,
      color = :red)
scatter!(p1, [fi], [r_meet1],
         label = "Пересечение",
         markersize = 4)

p2 = plot(sol2.t, sol2.u,
          proj = :polar,
          lims = (0, plot_limit),
          title = "Вариант 54: случай 2",
          label = "Катер",
          lw = 2)
plot!(p2, theta_boat, r_boat,
      label = "Лодка",
      linestyle = :dash,
      color = :red)
scatter!(p2, [fi], [r_meet2],
         label = "Пересечение",
         markersize = 4)

final_plot = plot(p1, p2, layout = (1, 2), size = (1000, 500))

savefig(final_plot, joinpath(output_dir, "pursuit_variant54.png"))
final_plot
