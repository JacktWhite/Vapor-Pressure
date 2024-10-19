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



%% 
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

% Constants (define b1 and b2 based on your data)
b1 = 1;  % Set to your actual b1 value
b2 = 0;  % Set to your actual b2 value

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
ln_p = ln_p(ln_p ~= 0);
inv_T = inv_T(inv_T ~= 0);
ln_p_err = ln_p_err(ln_p_err ~= 0);

% Plot ln(p) vs 1/T including one isotherm below (950°C)
figure;
errorbar(inv_T, ln_p, ln_p_err, '-o');  % Add error bars to the plot
xlabel('1/T (K^{-1})');
ylabel('ln(p)');
title('ln(p) vs 1/T with Error Bars (950°C to 1200°C)');
grid on;

% Highlight the linearized region (1000°C to 1200°C) in red
hold on;
plot(inv_T(2:end), ln_p(2:end), 'r-o');  % Highlight the linearized region
legend('950°C to 1200°C with Error Bars', 'Linearized 1000°C to 1200°C', 'Location', 'Best');
hold off;