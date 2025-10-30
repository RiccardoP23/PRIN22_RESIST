% This functions generate performance profiles running actual simulations.
% scenarioNumber refers to the scenario to consider (1 or 2)
% scenarioTable is the output of the import of plant data
% Nd is the number of takes for detection behaviours shutting down the plant in control room;
% Md is the number of takes for detection behaviours shutting down the plant with the button;
% Nr is the number of takes for recover behaviours shutting down the plant in control room;
% Md is the number of takes for recover behaviours shutting down the plant with the button;
%
function final_timeseries = runSimulation(scenarioNumber, scenarioTable, Nd, Md, Nr, Mr, minReactionTime, modeReactionTime, maxReactionTime)
    % Shuffle the random seed to ensure different results each run
    rng('shuffle');
    % Randomly choose a random number between 0 and 1, then return false (0) if < 0.5, and true (1) if > 0.5
    useNd = rand() > 0.5;
    %
    % 1. Randomly select the duration for trimming the attack phase base on operator data
    %
    % Initialize an array which will contain the total time the operator needs to detect the attack based on the choice of dataset (shutting down in control room or with button)
    sumAttack = zeros(1, useNd * Nd + ~useNd * Md);
    % Iterate over all available takes
    for i = 1:length(sumAttack)
        % Construct variable name based on scenario and take type
        if useNd
            varName = sprintf('temporalSequence_D%d_T%d', scenarioNumber, i);
        else
            varName = sprintf('temporalSequence_D%d_T%d_CP',scenarioNumber, i);
        end
        % Load data from base workspace
        mat = evalin('base', varName);
        % Sum duration of all operations (last column) and store in array
        sumAttack(i) = sum(mat(:, end));
    end
    % Randomly select a duration from the precomputed values
    durationAttack = sumAttack(randi(length(sumAttack)));
    % Add random reaction time to durationAttack
    reactionTimeDist = makedist('Triangular', 'A', minReactionTime, 'B', modeReactionTime, 'C', maxReactionTime);
    reactionTime = random(reactionTimeDist);
    durationAttack = durationAttack + reactionTime;
    %
    % 2. Randomly select the duration for trimming the plant off phase base on operator data
    %
    % Initialize an array which will contain the total time the operator needs to restart the plant based on the choice of dataset (shutting down in control room or with button)
    sumRecovery = zeros(1, useNd * Nr + ~useNd * Mr);
    % Iterate over all available takes
    for i = 1:length(sumRecovery)
        % Construct variable name based on scenario and take type
        if useNd
            varName = sprintf('temporalSequence_R%d_T%d', scenarioNumber, i);
        else
            varName = sprintf('temporalSequence_R%d_T%d_CP', scenarioNumber, i);
        end
        % Load data from base workspace
        mat = evalin('base', varName);
        % Sum duration of all operations (last column) and store in array
        sumRecovery(i) = sum(mat(:, end));
    end
    % Randomly select a duration from the precomputed values
    durationRecovery = sumRecovery(randi(length(sumRecovery)));
    % 
    % 3. Extract all phases in plant data
    %
    [normal, attack, shutdown, off, restart] = extractScenarioBlocks(scenarioTable);
    %
    % 4. Trim blocks based on precomputed durations
    %
    attack = attack(1:min(durationAttack, height(attack)), :);
    off    = off(1:min(durationRecovery, height(off)), :);
    % Align shutdown start to end of attack
    shutdown = findClosestShutdownStart(attack, shutdown);
    %
    % 5. Combine in a single timeseries
    % 
    final_timeseries = [normal; attack; shutdown; off; restart];
    % Reset time column to be sequential indices
    final_timeseries{:, 1} = (1:height(final_timeseries))';
end