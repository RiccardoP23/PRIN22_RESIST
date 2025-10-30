% Add the modules' directory to the MATLAB path
addpath('mainModules\');

% Set the scenario (0 = standard, 1 = attack on S6, 2 = attack on S5)
disruptiveScenario = 1;

% Choose the numer of simulations to run
numberOfSimulations = 500;

% Set the threshold for spotting anomalous behaviours (percentage)
threshold = 10;

% Set the threshold for spotting anomalous ranges (minimum number of subsequent anomalies)
min_length_ko = 50;
min_length_ok = 500;

% Load human operator data (MAT files)
importHumanOperatorData();
% Set human operator data takes parameter
Nd = 5;  % Number of detection takes with computer shutdown
Md = 3;  % Number of detection takes with button shutdown
Nr = 5;  % Number of recovery takes with computer shutdown
Mr = 3;  % Number of recovery takes with button shutdown

% Set human operator reaction time distribution parameter (distribution is assumed triangular, time is in seconds)

% Novice operator, scenario 1 (S6)
% minReactionTime = 60;
% modeReactionTime= 60*5;
% maxReactionTime = 60*10;

% Expert operator, scenario 1 (S6)
minReactionTime = 30;
modeReactionTime= 60*2;
maxReactionTime = 60*5;

% Novice operator, scenario 2 (S5)
% minReactionTime = 60*2;
% modeReactionTime= 60*3;
% maxReactionTime = 60*5;

% Expert operator, scenario 2 (S5)
% minReactionTime = 60*2;
% modeReactionTime= 60*2+30;
% maxReactionTime = 60*3;

% Load plant data (CSV files)
scenarioData = importPhysicalPlantData(disruptiveScenario);
standardData = importPhysicalPlantData(0);

% Run simulation loop and store outputs
% Preallocate cell array for storing results (array of tables)
finalTimeseriesList = cell(numberOfSimulations, 1);
disp('Starting simulations...')
for run = 1:numberOfSimulations
    fprintf('Performing simulation %d...\n', run)
    finalTimeseriesList{run} = runSimulation(disruptiveScenario, scenarioData, Nd, Md, Nr, Mr,minReactionTime, modeReactionTime, maxReactionTime);
end

% % Plot all simulation results
% for run = 1:numberOfSimulations
%     plotSimulation(finalTimeseriesList{run}, run);
% end

% Keep only time (column 1) and sensors S1, S2, S5, S6, S7, valves AV1 AV2 AV3, water input floweate, water output flowrate, total volume of water extracted (columns 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30) for resilience calculation
columnsToKeep = [1, 20, 21, 22, 23, 24,25, 26, 27, 28, 29, 30];
standardData_filtered = standardData(:,columnsToKeep);
% The scenario data are filtered within the resilience calculation cycle

% Compute resilience as area under the curve difference
resilienceList = cell(numberOfSimulations, 1);
disp('Computing resilience...')
for i = 1:numberOfSimulations
    current_ts = finalTimeseriesList{i};
    current_ts = current_ts(:,columnsToKeep);
    resilienceList{i} = areaUnderCurve(standardData_filtered, current_ts, threshold, min_length_ko, min_length_ok);
end
disp('Completed!')

% Create tri-dimensional plots
plotResilienceMetrics(finalTimeseriesList, resilienceList);

% Store results in CSV file
% Get current date and time
t = datetime('now');
% Format the timestamp to string
timestamp = datestr(t, 'yyyy-mm-dd_HH-MM');
% Build the filename with timestamp
filename = ['results_' timestamp '.csv'];
% Run store function
storeResilienceMetrics(finalTimeseriesList, resilienceList, filename)