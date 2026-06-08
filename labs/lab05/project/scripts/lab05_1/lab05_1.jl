using DifferentialEquations
using Plots

gr()
default(fmt = :png, size = (900, 650), titlefont = font(10))

function find_plots_dir()
    candidates = [
        joinpath(pwd(), "plots"),
        joinpath(dirname(pwd()), "plots"),
        joinpath(dirname(dirname(pwd())), "plots")
    ]

    for path in candidates
        if isdir(path)
            return path
        end
    end

    error("Папка plots не найдена. Запусти скрипт из project или из project/scripts")
end

plots_dir = find_plots_dir()

a = 0.13
b = 0.041
c = 0.31
d = 0.042

u0 = [7.0, 20.0]     # начальные условия [хищники, жертвы]
tspan = (0.0, 100.0)

x_stationary = c / d # численность хищников в равновесии
y_stationary = a / b # численность жертв в равновесии

println("Стационарное состояние системы для варианта 54:")
println("x* = ", round(x_stationary, digits = 3), " - хищники")
println("y* = ", round(y_stationary, digits = 3), " - жертвы")

function lotka_volterra!(du, u, p, t)
    x, y = u
    du[1] = -a * x + b * x * y
    du[2] =  c * y - d * x * y
end

prob = ODEProblem(lotka_volterra!, u0, tspan)
sol = solve(prob, Tsit5(), saveat = 0.1)

p1 = plot(sol,
    title = "Динамика популяций (вариант 54)",
    xlabel = "Время t",
    ylabel = "Численность",
    label = ["Хищники x(t)" "Жертвы y(t)"],
    lw = 2)

p2 = plot(sol, vars = (2, 1),
    title = "Фазовый портрет (вариант 54)",
    xlabel = "Численность жертв y",
    ylabel = "Численность хищников x",
    label = "Траектория",
    lw = 2)

scatter!(p2,
    [y_stationary],
    [x_stationary],
    label = "Стац. точка A($(round(x_stationary, digits = 2)); $(round(y_stationary, digits = 2)))",
    markersize = 5)

layout = plot(p1, p2, layout = (2, 1))
display(layout)

savefig(layout, joinpath(plots_dir, "lab05_1_variant54_predator_prey.png"))
println("График сохранен в: ", joinpath(plots_dir, "lab05_1_variant54_predator_prey.png"))
