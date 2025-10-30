%This function trims the phases of plant's operations based upon the phase identifiers (1 if yes, 0 if no) stored in columns 31, 32, 33, 34, 35 (see importPhysicalPlantData.m for details)
%
function [normal, attack, shutdown, off, restart] = extractScenarioBlocks(dataTable)
    % Extract logical subsets of the scenario table
    normal   = dataTable(dataTable{:, 31} == 1, :);   % Normal operation
    attack   = dataTable(dataTable{:, 32} == 1, :);   % Attack phase, operator detection
    shutdown = dataTable(dataTable{:, 33} == 1, :);   % Shutdown phase, PID controllers off
    off      = dataTable(dataTable{:, 34} == 1, :);   % Plant off, operator recovery phase
    restart  = dataTable(dataTable{:, 35} == 1, :);   % Restart phase
end