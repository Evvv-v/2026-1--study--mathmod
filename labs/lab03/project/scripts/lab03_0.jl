# ## Лабораторная работа №3. Модель боевых действий
# файл для общего задания из методички

using DifferentialEquations
using Plots

default(fmt = :png)

# ## Папка для сохранения графиков
# используем уже существующую папку plots в проекте
function find_plots_dir()
    starts = String[]
    push!(starts, pwd())
    push!(starts, dirname(pwd()))
    push!(starts, @__DIR__)
    push!(starts, dirname(@__DIR__))
    push!(starts, dirname(dirname(@__DIR__)))

    for root in unique(starts)
        candidate = joinpath(root, "plots")
        if isdir(candidate)
            return candidate
        end
    end

    error("не найдена существующая папка plots. запусти файл из каталога проекта lab03 или из папки scripts внутри проекта")
end

plots_dir = find_plots_dir()

# ## 1. Параметры модели
# параметры выбраны самостоятельно, как требуется в общем задании

x0 = 35000.0          # начальная численность армии X
y0 = 24000.0          # начальная численность армии Y
u0 = [x0, y0]
tspan = (0.0, 1.5)

# функции подкрепления
P(t) = sin(t) + 1.5
Q(t) = cos(t) + 1.2

# параметры для модели 1 - регулярные войска против регулярных
params_regular = (
    a = 0.35,      # потери армии X, не связанные с боем
    b = 0.75,      # эффективность армии Y против армии X
    c = 0.55,      # эффективность армии X против армии Y
    h = 0.45       # потери армии Y, не связанные с боем
)

# параметры для модели 2 - регулярные войска против партизан
# коэффициент c выбран меньше, потому что в модели есть произведение x(t)y(t)
params_mixed = (
    a = 0.25,
    b = 0.60,
    c = 0.00003,
    h = 0.20
)

# параметры для модели 3 - партизаны против партизан
# коэффициенты b и c тоже малы из-за произведения x(t)y(t)
params_partisan = (
    a = 0.15,
    b = 0.000025,
    c = 0.000035,
    h = 0.18
)

# ## 2. Определение систем уравнений

# модель 1: регулярные войска против регулярных
function combat_regular!(du, u, p, t)
    x, y = u
    a, b, c, h = p.a, p.b, p.c, p.h
    du[1] = -a * x - b * y + P(t)
    du[2] = -c * x - h * y + Q(t)
end

# модель 2: регулярные войска против партизанских отрядов
function combat_mixed!(du, u, p, t)
    x, y = u
    a, b, c, h = p.a, p.b, p.c, p.h
    du[1] = -a * x - b * y + P(t)
    du[2] = -c * x * y - h * y + Q(t)
end

# модель 3: партизанские отряды против партизанских отрядов
function combat_partisan!(du, u, p, t)
    x, y = u
    a, b, c, h = p.a, p.b, p.c, p.h
    du[1] = -a * x - b * x * y + P(t)
    du[2] = -h * y - c * x * y + Q(t)
end

# ## 3. Решение систем

prob_regular = ODEProblem(combat_regular!, u0, tspan, params_regular)
sol_regular = solve(prob_regular, Tsit5(), saveat=0.01)

prob_mixed = ODEProblem(combat_mixed!, u0, tspan, params_mixed)
sol_mixed = solve(prob_mixed, Rosenbrock23(), saveat=0.01)

prob_partisan = ODEProblem(combat_partisan!, u0, tspan, params_partisan)
sol_partisan = solve(prob_partisan, Rosenbrock23(), saveat=0.01)

# ## 4. Анализ победителя

function army_values(sol)
    t = sol.t
    x = [max(u[1], 0.0) for u in sol.u]
    y = [max(u[2], 0.0) for u in sol.u]
    return t, x, y
end

function winner_by_solution(sol; limit = 1.0)
    t, x, y = army_values(sol)

    ix = findfirst(v -> v <= limit, x)
    iy = findfirst(v -> v <= limit, y)

    tx = ix === nothing ? Inf : t[ix]
    ty = iy === nothing ? Inf : t[iy]

    if tx < ty
        return "побеждает армия Y", tx, ty
    elseif ty < tx
        return "побеждает армия X", tx, ty
    else
        if last(x) > last(y)
            return "по итоговой численности преимущество у армии X", tx, ty
        elseif last(y) > last(x)
            return "по итоговой численности преимущество у армии Y", tx, ty
        else
            return "силы сторон примерно равны", tx, ty
        end
    end
end

function print_result(model_name, sol)
    t, x, y = army_values(sol)
    result, tx, ty = winner_by_solution(sol)

    println("\n", model_name)
    println("итоговая численность X: ", round(last(x), digits=2))
    println("итоговая численность Y: ", round(last(y), digits=2))
    println("вывод: ", result)

    if isfinite(tx)
        println("армия X достигает нулевой численности примерно при t = ", round(tx, digits=3))
    end
    if isfinite(ty)
        println("армия Y достигает нулевой численности примерно при t = ", round(ty, digits=3))
    end
end

print_result("Модель 1: регулярные войска против регулярных", sol_regular)
print_result("Модель 2: регулярные войска против партизан", sol_mixed)
print_result("Модель 3: партизаны против партизан", sol_partisan)

# условия победы для упрощенных моделей без подкреплений и небоевых потерь
condition_regular = params_regular.c * x0^2 - params_regular.b * y0^2
condition_mixed = params_mixed.b / 2 * x0^2 - params_mixed.c * y0
condition_partisan = y0 - (params_partisan.c / params_partisan.b) * x0

println("\nУсловия победы для упрощенных моделей:")
println("модель 1: если c*x0^2 - b*y0^2 > 0, побеждает X; значение = ", round(condition_regular, digits=2))
println("модель 2: если (b/2)*x0^2 - c*y0 > 0, побеждает регулярная армия X; значение = ", round(condition_mixed, digits=2))
println("модель 3: если y0 - (c/b)*x0 < 0, побеждает X; значение = ", round(condition_partisan, digits=2))

# ## 5. Визуализация

function make_plot(sol, title_text)
    t, x, y = army_values(sol)
    p = plot(t, x,
        label = "Армия X",
        title = title_text,
        xlabel = "Время",
        ylabel = "Численность",
        lw = 2,
        legend = :topright)
    plot!(p, t, y, label = "Армия Y", lw = 2)
    return p
end

p1 = make_plot(sol_regular, "Модель 1: регулярные войска")
p2 = make_plot(sol_mixed, "Модель 2: регулярные и партизаны")
p3 = make_plot(sol_partisan, "Модель 3: партизаны")

final_plot = plot(p1, p2, p3, layout = (3, 1), size = (900, 1000))

savefig(p1, joinpath(plots_dir, "lab03_0_model1_regular.png"))
savefig(p2, joinpath(plots_dir, "lab03_0_model2_mixed.png"))
savefig(p3, joinpath(plots_dir, "lab03_0_model3_partisan.png"))
savefig(final_plot, joinpath(plots_dir, "lab03_0_all_models.png"))

final_plot
