using Pkg

function find_project_dir()
    candidates = [
        abspath(joinpath(@__DIR__, "..")),
        abspath(@__DIR__),
        abspath(joinpath(pwd(), "..")),
        abspath(pwd())
    ]
    for dir in candidates
        if isdir(joinpath(dir, "plots"))
            return dir
        end
    end
    error("Не найдена существующая папка plots. Запусти скрипт из каталога lab08/project/scripts или lab08/project")
end

project_dir = find_project_dir()
Pkg.activate(project_dir)

using DifferentialEquations
using Plots

gr()
default(fmt = :png, size = (850, 650), titlefont = font(10))
plots_dir = joinpath(project_dir, "plots")

p_cr = 47.0      # критическая стоимость продукта, тыс. ед.
tau1 = 33.0      # длительность производственного цикла фирмы 1
tau2 = 27.0      # длительность производственного цикла фирмы 2
p1 = 9.7         # себестоимость товара фирмы 1, тыс. ед.
p2 = 11.7        # себестоимость товара фирмы 2, тыс. ед.
N = 50.0         # число потребителей, тыс. ед.
q = 1.0          # максимальная потребность одного человека

M0 = [7.7, 9.7]
tspan = (0.0, 30.0)

const a1 = p_cr / (tau1^2 * p1^2 * N * q)
const a2 = p_cr / (tau2^2 * p2^2 * N * q)
const b = p_cr / (tau1^2 * tau2^2 * p1^2 * p2^2 * N * q)
const c1 = (p_cr - p1) / (tau1 * p1)
const c2 = (p_cr - p2) / (tau2 * p2)

extra_factor = 0.0004

function stationary_state()
    A = [a1 b; b a2]
    rhs = [c1, c2]
    return A \ rhs
end

M_star = stationary_state()

println("Стационарное состояние для случая 1, вариант 54:")
println("M1* = ", round(M_star[1], digits=4))
println("M2* = ", round(M_star[2], digits=4))

function competition_case1!(dM, M, p, theta)
    M1, M2 = M
    dM[1] = M1 - (b / c1) * M1 * M2 - (a1 / c1) * M1^2
    dM[2] = (c2 / c1) * M2 - (b / c1) * M1 * M2 - (a2 / c1) * M2^2
end

function competition_case2!(dM, M, p, theta)
    M1, M2 = M
    dM[1] = M1 - ((b / c1) + extra_factor) * M1 * M2 - (a1 / c1) * M1^2
    dM[2] = (c2 / c1) * M2 - (b / c1) * M1 * M2 - (a2 / c1) * M2^2
end

prob1 = ODEProblem(competition_case1!, M0, tspan)
sol1 = solve(prob1, Tsit5(), saveat = 0.01, reltol = 1e-8, abstol = 1e-8)

prob2 = ODEProblem(competition_case2!, M0, tspan)
sol2 = solve(prob2, Tsit5(), saveat = 0.01, reltol = 1e-8, abstol = 1e-8)

plt1 = plot(sol1, vars = (0, 1),
    label = "Фирма 1",
    lw = 2,
    title = "Вариант 54. Случай 1: рыночная конкуренция",
    xlabel = "Безразмерное время θ",
    ylabel = "Оборотные средства M")
plot!(plt1, sol1, vars = (0, 2), label = "Фирма 2", lw = 2)
hline!(plt1, [M_star[1]], linestyle = :dash, label = "M1* = $(round(M_star[1], digits=2))")
hline!(plt1, [M_star[2]], linestyle = :dash, label = "M2* = $(round(M_star[2], digits=2))")

plt2 = plot(sol2, vars = (0, 1),
    label = "Фирма 1",
    lw = 2,
    title = "Вариант 54. Случай 2: соц.-психологический фактор",
    xlabel = "Безразмерное время θ",
    ylabel = "Оборотные средства M")
plot!(plt2, sol2, vars = (0, 2), label = "Фирма 2", lw = 2)

final_plot = plot(plt1, plt2, layout = (2, 1), size = (850, 750))
display(final_plot)

save_path = joinpath(plots_dir, "lab08_variant54_competition.png")
savefig(final_plot, save_path)
println("График сохранен: ", save_path)
