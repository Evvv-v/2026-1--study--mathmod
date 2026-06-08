using Pkg
Pkg.activate("../project")

using DifferentialEquations
using Plots

gr()
default(fmt = :png, size = (900, 600), titlefont = font(10))

# лабораторная работа №7 - эффективность рекламы
# вариант 54

# папка plots уже должна существовать в project
output_dir = normpath(joinpath(@__DIR__, "..", "plots"))
if !isdir(output_dir)
    error("Папка plots не найдена: $(output_dir). Создайте ее в project или запустите скрипт из project/scripts")
end

# исходные данные варианта 54
N = 1403.0       # объем аудитории
n0 = 9.0         # в начальный момент о товаре знает 9 человек
u0 = [n0]
tspan = (0.0, 30.0)

# уравнения варианта 54:
# 1) dn/dt = (0.64 + 0.00004*n(t)) * (N - n(t))
# 2) dn/dt = (0.00007 + 0.7*n(t)) * (N - n(t))
# 3) dn/dt = (0.4*t + 0.3*sin(2t)*n(t)) * (N - n(t))

function ad_case1!(du, u, p, t)
    n = u[1]
    du[1] = (0.64 + 0.00004 * n) * (N - n)
end

function ad_case2!(du, u, p, t)
    n = u[1]
    du[1] = (0.00007 + 0.7 * n) * (N - n)
end

function ad_case3!(du, u, p, t)
    n = u[1]
    du[1] = (0.4 * t + 0.3 * sin(2 * t) * n) * (N - n)
end

# решение трех случаев
prob1 = ODEProblem(ad_case1!, u0, tspan)
sol1 = solve(prob1, Tsit5(), saveat = 0.1)

prob2 = ODEProblem(ad_case2!, u0, tspan)
sol2 = solve(prob2, Rosenbrock23(), saveat = 0.00001, abstol = 1e-8, reltol = 1e-8)

prob3 = ODEProblem(ad_case3!, u0, tspan)
sol3 = solve(prob3, Rosenbrock23(), saveat = 0.0001, abstol = 1e-8, reltol = 1e-8)

# поиск момента максимальной скорости распространения рекламы для случая 2
function growth_rate_case2(t)
    n = sol2(t)[1]
    return (0.00007 + 0.7 * n) * (N - n)
end

sample_t_case2 = collect(range(0.0, 0.05, length = 20000))
speeds_case2 = [growth_rate_case2(t) for t in sample_t_case2]
max_index_case2 = argmax(speeds_case2)
t_max_case2 = sample_t_case2[max_index_case2]
n_max_case2 = sol2(t_max_case2)[1]
max_speed_case2 = speeds_case2[max_index_case2]

println("Вариант 54")
println("N = ", Int(N), ", n0 = ", Int(n0))
println("Для случая 2 максимальная скорость распространения рекламы достигается примерно при t = ", round(t_max_case2, digits = 6))
println("В этот момент n(t) ≈ ", round(n_max_case2, digits = 2), ", скорость ≈ ", round(max_speed_case2, digits = 2))

# график 1
p1 = plot(sol1,
    title = "Вариант 54. Случай 1",
    xlabel = "Время t", ylabel = "Число информированных n(t)",
    label = "n(t)", lw = 2, xlims = (0, 15), ylims = (0, N * 1.05))

# график 2 с отметкой максимальной скорости
p2 = plot(sol2,
    title = "Вариант 54. Случай 2",
    xlabel = "Время t", ylabel = "Число информированных n(t)",
    label = "n(t)", lw = 2, xlims = (0, 0.02), ylims = (0, N * 1.05))
vline!(p2, [t_max_case2], label = "max скорость", linestyle = :dash)

# график 3
p3 = plot(sol3,
    title = "Вариант 54. Случай 3",
    xlabel = "Время t", ylabel = "Число информированных n(t)",
    label = "n(t)", lw = 2, xlims = (0, 0.2), ylims = (0, N * 1.05))

layout = plot(p1, p2, p3, layout = (3, 1), size = (900, 900))
display(layout)
savefig(layout, joinpath(output_dir, "lab07_variant54_results.png"))

# отдельный увеличенный график для случая 2, так как рост очень быстрый
p2_zoom = plot(sol2,
    title = "Вариант 54. Случай 2: момент максимальной скорости",
    xlabel = "Время t", ylabel = "Число информированных n(t)",
    label = "n(t)", lw = 2, xlims = (0, 0.02), ylims = (0, N * 1.05))
vline!(p2_zoom, [t_max_case2], label = "max скорость, t=$(round(t_max_case2, digits=6))", linestyle = :dash)
scatter!(p2_zoom, [t_max_case2], [n_max_case2], label = "n≈$(round(n_max_case2, digits=1))")
display(p2_zoom)
savefig(p2_zoom, joinpath(output_dir, "lab07_variant54_case2_max_speed.png"))
