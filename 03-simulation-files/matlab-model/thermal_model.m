% Thermal Model of Air-Cooled Drone Battery Pack
% Based on lumped parameter approach

clear; clc; close all;

%% Battery Parameters
battery_capacity = 5; % Ah
nominal_voltage = 22.2; % V
num_cells = 6;
cell_mass = 0.07; % kg per cell
specific_heat = 1200; % J/kg·K
thermal_mass = num_cells * cell_mass * specific_heat; % J/K

%% Flight Scenarios
scenarios = {'Hover', 'Cruise', 'Climb', 'Aggressive'};
current_draw = [30, 50, 80, 100]; % A
air_velocity = [2, 5, 8, 10]; % m/s
heat_generation = current_draw.^2 * 0.02; % I²R losses (R=0.02Ω)

%% Environmental Conditions
T_ambient = 25; % °C
convection_coeff_base = 10; % W/m²K (natural convection)
surface_area = 0.03; % m²

%% Simulation Time
time = 0:1:600; % 10 minutes simulation
T_initial = 25; % °C

%% Main Simulation Loop
T_battery = zeros(length(scenarios), length(time));

for s = 1:length(scenarios)
    T = T_initial * ones(size(time));
    
    % Forced convection coefficient (depends on air velocity)
    h_forced = convection_coeff_base + 5 * air_velocity(s); % empirical
    
    for t = 2:length(time)
        % Heat generation
        Q_gen = heat_generation(s);
        
        % Heat dissipation (convection)
        Q_diss = h_forced * surface_area * (T(t-1) - T_ambient);
        
        % Temperature change
        dT = (Q_gen - Q_diss) / thermal_mass;
        T(t) = T(t-1) + dT;
    end
    
    T_battery(s, :) = T;
end

%% Plot Results
figure('Position', [100, 100, 800, 500]);
plot(time/60, T_battery, 'LineWidth', 2);
xlabel('Time (minutes)');
ylabel('Battery Temperature (°C)');
title('Drone Battery Temperature Under Different Flight Conditions');
legend(scenarios, 'Location', 'best');
grid on;
ylim([20, 70]);

% Add safety threshold line
hold on;
yline(60, '--r', 'Safety Limit (60°C)', 'LineWidth', 1.5);

% Save results
saveas(gcf, '04-results/figures/temperature_comparison.png');

%% Export Data
for s = 1:length(scenarios)
    filename = sprintf('04-results/raw-data/%s_scenario.csv', scenarios{s});
    data = [time', T_battery(s,:)'];
    csvwrite(filename, data);
end

fprintf('Simulation complete! Results saved.\n');