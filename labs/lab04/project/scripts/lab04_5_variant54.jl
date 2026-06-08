# ## Инициализация проекта
using DifferentialEquations
using Plots

gr()
default(fmt = :png, size = (900, 450))

# функция ищет уже существующую папку plots в lab04/project
# новые папки plots не создаются
function find_existing_plots_dir()
    current_dir = pwd()

    for _ in 1:6
        candidate = joinpath(current_dir, "plots")

        if isdir(candidate)
            return candidate
        end

        parent_dir = dirname(current_dir)

        if parent_dir == current_dir
            break
        end

        current_dir = parent_dir
    end

    error("Не найдена существующая папка plots. Запусти скрипт из папки project, scripts или notebooks внутри lab04/project")
end

plots_dir = find_existing_plots_dir()

function save_to_existing_plots(plot_object, file_name)
    output_path = joinpath(plots_dir, file_name)
    savefig(plot_object, output_path)
    println("График сохранен: ", output_path)
end

# ## Лабораторная работа №4
# ## Вариант 54
# ## Задача №3: осциллятор с затуханием и внешней силой
# Уравнение варианта: x'' + 24x' + 25x = 6sin(4t)
# Начальные условия: x(0)=0.9, y(0)=0.9
# Интервал: t ∈ [0; 48], шаг 0.05

# ## 1. Параметры модели
stiffness = 25.0          # коэффициент при x
damping = 24.0            # коэффициент при x'
u0 = [0.9, 0.9]
tspan = (0.0, 48.0)
step = 0.05

# внешняя сила
f_ext(t) = 6.0 * sin(4.0 * t)

# ## 2. Переход к системе первого порядка
# x' = y
# y' = 6sin(4t) - 24y - 25x
function variant54_with_force!(du, u, p, t)
    x, y = u
    du[1] = y
    du[2] = f_ext(t) - damping * y - stiffness * x
end

# ## 3. Решение системы
prob = ODEProblem(variant54_with_force!, u0, tspan)
sol = solve(prob, Tsit5(), saveat=step, abstol=1e-8, reltol=1e-8)

# ## 4. Построение решения и фазового портрета
p_solution = plot(sol,
    title="Вариант 54: с внешней силой",
    xlabel="t",
    ylabel="x(t), y(t)",
    label=["x(t)" "y(t)"],
    lw=2
)

p_phase = plot(sol,
    vars=(1, 2),
    title="Фазовый портрет",
    xlabel="x",
    ylabel="y = x'",
    label="траектория",
    lw=2
)

result_plot = plot(p_solution, p_phase, layout=(1, 2), size=(1000, 450))
display(result_plot)

# ## 5. Сохранение результата
save_to_existing_plots(result_plot, "lab04_5_variant54_with_force.png")
