% How to read input data tables (UNIVPM):
%
%- Column 1: timestamp [s]
%- Column 2: setpoint valve 1 (water pressure, water inlet) [bar]
%- Column 3: setpoint valve 2 (water level in tank, water outlet) [mm]
%- Column 4: setpoint valve 3 (pressure in tank, air outlet) [bar]
%- Column 5, 6, 7: PID constants for valve 1 [N/A]
%- Column 8, 9, 10: PID constants for valve 2 [N/A]
%- Column 11, 12, 13: PID constants for valve 3 [N/A]
%- Column 14: fake measure (if any) for sensor 1 (water pressure at inlet)[bar]
%- Column 15: fake measure (if any) for sensor 5 (pressure in tank)[bar]
%- Column 16: fake measure (if any) for sensor 6 (level in tank)[mm]
%- Column 17: fake measure (if any) for valve 1 opening (water pressure, water inlet) [%]
%- Column 18: fake measure (if any) for valve 2 opening (water level in tank, water outlet) [%]
%- Column 19: fake measure (if any) for valve 3 opening (pressure in tank, air outlet) [%]
%- Column 20: measure for sensor 1 (water pressure at inlet)[bar]
%- Column 21: measure for sensor 2 (water flow rate at inlet)[m3/h]
%- Column 22: measure for sensor 5 (pressure in tank)[bar]
%- Column 23: measure for sensor 6 (level in tank)[mm]
%- Column 24: measure for sensor 7 (air outlet flow rate) [m3/h]
%- Column 25: measure for valve 1 opening (water pressure, water inlet) [%]
%- Column 26: measure for valve 2 opening (water level in tank, water outlet) [%]
%- Column 27: measure for valve 3 opening (pressure in tank, air outlet) [%]
%- Column 28: calculated water inlet flow rate [m3/h]
%- Column 29: calculated water outlet flow rate [m3/h]
%- Column 30: calculated volume of water extracted [m3]
%- Column 31: plant startup + normal operations phase identifier [1 or 0]
%- Column 32: plant attack phase identifier [1 or 0]
%- Column 33: plant shutdown phase identifier (PID controllers off) [1 or 0]
%- Column 34: plant off phase identifier [1 or 0]
%- Column 35: plant restart phase identifier [1 or 0]
%
%%%%%%% IMPORT DATA FOR EXPERIMENTAL PHYSICAL PLANT (UNIVPM) %%%%%%%
%
function scenarioTable = importPhysicalPlantData(scenarioOption)
    % Get directory of current function
    script_dir = fileparts(mfilename('fullpath'));
    % Path to 'dataPhysicalPlant' folder (assumed one level up)
    folder_path = fullfile(script_dir, '..', 'dataPhysicalPlant');
    % Load the standard steady state data with headers
    standard = readtable(fullfile(folder_path, 'standardSteadyState.csv'), "VariableNamingRule", "preserve");
    % Load Scenario 1 CSV data with headers
    scenario1 = readtable(fullfile(folder_path, 'scenario1.csv'), "VariableNamingRule", "preserve");
    % Load Scenario 2 CSV data with headers
    scenario2 = readtable(fullfile(folder_path, 'scenario2.csv'), "VariableNamingRule", "preserve");
    % Choose the correct table based on scenarioOption
    switch scenarioOption
        case 0
            scenarioTable = standard;
        case 1
            scenarioTable = scenario1;
        case 2
            scenarioTable = scenario2;
        otherwise
            error('Invalid scenarioOption: must be 0 (standard), 1 (scenario1), or 2 (scenario2).');
    end
    % Display confirmation message
    disp(['Import for experimental physical plant data (scenario ' num2str(scenarioOption) ') completed.']);
end