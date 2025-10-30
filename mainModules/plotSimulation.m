% This script is meant to plot the timeseries. It plots S1 (column 20), S5 column (22), and S6 (column 23)
%
function plotSimulation(final_timeseries, run)
    % Extract relevant signals
    time = final_timeseries{:, 1};
    S1 = final_timeseries{:, 20};
    S5 = final_timeseries{:, 22};
    S6 = final_timeseries{:, 23};

    % Plot signals
    figure('Name', sprintf('Run %d - Simulation Results', run), 'NumberTitle', 'off');
    % Plot S1
    subplot(3, 1, 1);
    plot(time, S1, 'b', 'LineWidth', 1.5);
    title('Water pressure at inlet (S1)'); ylabel('Pressure [bar]'); grid on;
    % Plot S5
    subplot(3, 1, 2);
    plot(time, S5, 'r', 'LineWidth', 1.5);
    title('Water pressure in tank (S5)'); ylabel('Pressure [bar]'); grid on;
    % Plot S6
    subplot(3, 1, 3);
    plot(time, S6, 'g', 'LineWidth', 1.5);
    title('Water level in tank (S6)'); xlabel('Time [s]'); ylabel('Level [mm]'); grid on;
end