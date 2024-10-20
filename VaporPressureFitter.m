%% Vapor Pressure Fitter (Function Call)
clear; clc; close all;

% Load the three Excel files
file1 = 'file1.xlsx';
file2 = 'file2.xlsx';
file3 = 'file3.xlsx';

% Define Constants
b1 = 1;
b2 = 2;

% Define target isothermal temperatures and tolerance
target_temps = [800, 850, 900, 950, 1000, 1050]; % Range one lower of linearized line
tolerance = 5;  % Tolerance of ±5°C

% Read data from each file
data1 = readtable(file1);
data2 = readtable(file2);
data3 = readtable(file3);

% Extract temperature and dmdt columns from all three datasets
T1 = data1{:, 'Temperature_C'};
dmdt1 = data1{:, 'dmdt'};
T2 = data2{:, 'Temperature_C'};
dmdt2 = data2{:, 'dmdt'};
T3 = data3{:, 'Temperature_C'};
dmdt3 = data3{:, 'dmdt'};

% Initialize arrays for storing average dmdt, ln(p), and standard deviations
ln_p = zeros(length(target_temps), 1);
inv_T = zeros(length(target_temps), 1);  % for 1/T in Kelvin
ln_p_err = zeros(length(target_temps), 1);  % Standard deviation for ln(p)

% Loop through each target isothermal temperature
for i = 1:length(target_temps)
    temp = target_temps(i);
    
    % Find temperatures within the tolerance range for each dataset
    idx1 = find(abs(T1 - temp) <= tolerance);
    idx2 = find(abs(T2 - temp) <= tolerance);
    idx3 = find(abs(T3 - temp) <= tolerance);
    
    % Check if there is valid data within the tolerance range
    if isempty(idx1) || isempty(idx2) || isempty(idx3)
        continue;  % Skip this iteration if data is missing
    end
    
    % Collect all dmdt values within tolerance
    dmdt_values = [mean(dmdt1(idx1)), mean(dmdt2(idx2)), mean(dmdt3(idx3))];
    
    % Average the dmdt values within the tolerance range
    avg_dmdt = mean(dmdt_values);
    
    % Calculate ln(p) using the given equation
    ln_p(i) = b1 * log(avg_dmdt) + b2;
    
    % Calculate the standard deviation of ln(p) for error bars
    ln_p_err(i) = std(log(dmdt_values));
    
    % Convert temperature to Kelvin and calculate 1/T
    temp_K = temp + 273.15;
    inv_T(i) = 1 / temp_K;
end

% Filter out any zero entries (in case of missing data)
valid_idx = ln_p ~= 0;
ln_p = ln_p(valid_idx);
inv_T = inv_T(valid_idx);
ln_p_err = ln_p_err(valid_idx);

% Perform linear fit using polyfit for temperatures between ~+1°C to ~°C
linear_idx = inv_T >= 1/(target_temps(end)+273.15) & inv_T <= 1/(target_temps(2)+273.15);
p = polyfit(inv_T(linear_idx), ln_p(linear_idx), 1);  % First degree polynomial (linear)

% Generate fitted line for the linear range
fit_line = polyval(p, inv_T(linear_idx));

% Plot ln(p) vs 1/T including one isotherm below
figure;
errorbar(inv_T, ln_p, ln_p_err, '-o');  % Add error bars to the plot
xlabel('1/T (K^{-1})');
ylabel('ln(p)');
title('ln(p) vs 1/T with Linear Fit (850°C to 1050°C)'); % Change dependent on what I finalize
grid on;

% Highlight the linearized region (850°C to 1050°C) in red
hold on;
plot(inv_T(linear_idx), fit_line, 'r-', 'LineWidth', 2);  % Plot the fitted line
legend('850°C to 1050°C with Error Bars', 'Linearized Fit 900°C to 1050°C', 'Location', 'Best');
hold off;
