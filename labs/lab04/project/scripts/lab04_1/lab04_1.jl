using DifferentialEquations
using Plots

gr()
default(fmt = :png, size = (900, 450))

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

w0 = 2.0                  # собственная частота
gamma_val = 0.4           # коэффициент затухания
u0 = [0.0, 1.0]           # начальные условия: x(0)=0, y(0)=1
tspan = (0.0, 15.0)
step = 0.05

function oscillator_with_damping!(du, u, p, t)
    x, y = u
    du[1] = y
    du[2] = -2 * gamma_val * y - w0^2 * x
end

prob = ODEProblem(oscillator_with_damping!, u0, tspan)
sol = solve(prob, Tsit5(), saveat=step)

p_solution = plot(sol,
    title="Решение: с затуханием",
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

save_to_existing_plots(result_plot, "lab04_1_with_damping.png")
