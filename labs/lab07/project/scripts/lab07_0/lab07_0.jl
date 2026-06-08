using Pkg
Pkg.activate("../project")

using DifferentialEquations
using Plots

gr()
default(fmt = :png, size = (900, 600), titlefont = font(10))

output_dir = normpath(joinpath(@__DIR__, "..", "plots"))
if !isdir(output_dir)
    error("Папка plots не найдена: $(output_dir). Создайте ее в project или запустите скрипт из project/scripts")
end

N = 1200.0          # общее число потенциальных клиентов
n0 = 8.0            # число клиентов, знающих о салоне в начальный момент
u0 = [n0]
tspan = (0.0, 30.0)

function advertising_model!(du, u, p, t)
    alpha1, alpha2, N = p
    n = u[1]
    du[1] = (alpha1(t) + alpha2(t) * n) * (N - n)
end

alpha1_case1(t) = 0.07
alpha2_case1(t) = 0.00002
p_case1 = (alpha1_case1, alpha2_case1, N)
prob_case1 = ODEProblem(advertising_model!, u0, tspan, p_case1)
sol_case1 = solve(prob_case1, Tsit5(), saveat = 0.1)

alpha1_case2(t) = 0.00005
alpha2_case2(t) = 0.004
p_case2 = (alpha1_case2, alpha2_case2, N)
prob_case2 = ODEProblem(advertising_model!, u0, tspan, p_case2)
sol_case2 = solve(prob_case2, Rosenbrock23(), saveat = 0.001)

alpha1_case3(t) = 0.005 * t
alpha2_case3(t) = 0.002 * t
p_case3 = (alpha1_case3, alpha2_case3, N)
prob_case3 = ODEProblem(advertising_model!, u0, tspan, p_case3)
sol_case3 = solve(prob_case3, Rosenbrock23(), saveat = 0.001)

alpha1_paid(t) = 0.06
alpha2_paid(t) = 0.0
p_paid = (alpha1_paid, alpha2_paid, N)
prob_paid = ODEProblem(advertising_model!, u0, tspan, p_paid)
sol_paid = solve(prob_paid, Tsit5(), saveat = 0.1)

alpha1_word(t) = 0.0
alpha2_word(t) = 0.004
p_word = (alpha1_word, alpha2_word, N)
prob_word = ODEProblem(advertising_model!, u0, tspan, p_word)
sol_word = solve(prob_word, Rosenbrock23(), saveat = 0.001)

function growth_rate_case2(t)
    n = sol_case2(t)[1]
    return (alpha1_case2(t) + alpha2_case2(t) * n) * (N - n)
end

sample_t = collect(range(tspan[1], tspan[2], length = 20000))
speeds = [growth_rate_case2(t) for t in sample_t]
max_index = argmax(speeds)
t_max = sample_t[max_index]
n_max = sol_case2(t_max)[1]
max_speed = speeds[max_index]

println("Общее задание")
println("N = ", Int(N), ", n0 = ", Int(n0))
println("Для случая 2 максимальная скорость распространения рекламы достигается примерно при t = ", round(t_max, digits = 4))
println("В этот момент n(t) ≈ ", round(n_max, digits = 2), ", скорость ≈ ", round(max_speed, digits = 2))

p1 = plot(sol_case1,
    title = "Случай 1: платная реклама эффективнее",
    xlabel = "Время t", ylabel = "Число информированных n(t)",
    label = "n(t)", lw = 2, xlims = (0, 30), ylims = (0, N * 1.05))

p2 = plot(sol_case2,
    title = "Случай 2: сарафанное радио эффективнее",
    xlabel = "Время t", ylabel = "Число информированных n(t)",
    label = "n(t)", lw = 2, xlims = (0, 3), ylims = (0, N * 1.05))
vline!(p2, [t_max], label = "max скорость", linestyle = :dash)

p3 = plot(sol_case3,
    title = "Случай 3: коэффициенты зависят от времени",
    xlabel = "Время t", ylabel = "Число информированных n(t)",
    label = "n(t)", lw = 2, xlims = (0, 5), ylims = (0, N * 1.05))

layout_cases = plot(p1, p2, p3, layout = (3, 1), size = (900, 900))
display(layout_cases)
savefig(layout_cases, joinpath(output_dir, "lab07_general_cases.png"))

p4 = plot(sol_paid,
    title = "Только платная реклама",
    xlabel = "Время t", ylabel = "Число информированных n(t)",
    label = "n(t)", lw = 2, xlims = (0, 30), ylims = (0, N * 1.05))

p5 = plot(sol_word,
    title = "Только сарафанное радио",
    xlabel = "Время t", ylabel = "Число информированных n(t)",
    label = "n(t)", lw = 2, xlims = (0, 3), ylims = (0, N * 1.05))

p6 = plot(sol_paid, label = "только платная реклама", lw = 2,
    title = "Сравнение двух механизмов распространения",
    xlabel = "Время t", ylabel = "Число информированных n(t)",
    xlims = (0, 30), ylims = (0, N * 1.05))
plot!(p6, sol_word, label = "только сарафанное радио", lw = 2)

layout_compare = plot(p4, p5, p6, layout = (3, 1), size = (900, 900))
display(layout_compare)
savefig(layout_compare, joinpath(output_dir, "lab07_general_paid_vs_word.png"))
