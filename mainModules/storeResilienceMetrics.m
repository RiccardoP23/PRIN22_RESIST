function storeResilienceMetrics(finalTimeSeriesList, resilienceList, outputFileName)
    % Number of scenarios
    numScenarios = length(finalTimeSeriesList);
    % Preallocate arrays
    detectionTime = zeros(numScenarios, 1);
    restorationTime = zeros(numScenarios, 1);
    resilienceS1 = zeros(numScenarios, 1);
    resilienceS2 = zeros(numScenarios, 1);
    resilienceS5 = zeros(numScenarios, 1);
    resilienceS6 = zeros(numScenarios, 1);
    resilienceS7 = zeros(numScenarios, 1);
    resilienceAV1 = zeros(numScenarios, 1);
    resilienceAV2 = zeros(numScenarios, 1);
    resilienceAV3 = zeros(numScenarios, 1);
    resilienceFlowIN = zeros(numScenarios, 1);
    resilienceFlowOUT = zeros(numScenarios, 1);
    resilienceVolumeOUT = zeros(numScenarios, 1);
    % Loop over scenarios
    for i = 1:numScenarios
        % Extract detection and restoration times
        table1 = finalTimeSeriesList{i};
        detectionTime(i) = sum(table1{:, 32} ~= 0);
        restorationTime(i) = sum(table1{:, 34} ~= 0);
        % Extract resilience metrics (double matrix)
        table2 = resilienceList{i};
        resilienceS1(i) = table2(1, 2);
        resilienceS2(i) = table2(1, 3);
        resilienceS5(i) = table2(1, 4);
        resilienceS6(i) = table2(1, 5);
        resilienceS7(i) = table2(1, 6);
        resilienceAV1(i) = table2(1, 7);
        resilienceAV2(i) = table2(1, 8);
        resilienceAV3(i) = table2(1, 9);
        resilienceFlowIN(i) = table2(1, 10);
        resilienceFlowOUT(i) = table2(1, 11);
        resilienceVolumeOUT(i) = table2(1, 12);
    end
    % Combine all into one matrix
    results = [detectionTime, restorationTime, resilienceS1, resilienceS2, resilienceS5, resilienceS6, resilienceS7, resilienceAV1, resilienceAV2, resilienceAV3, resilienceFlowIN, resilienceFlowOUT, resilienceVolumeOUT];
    % Create header
    headers = {'detectionTime', 'restorationTime', 'resilienceS1', 'resilienceS2', 'resilienceS5', 'resilienceS6', 'resilienceS7', 'resilienceAV1', 'resilienceAV2', 'resilienceAV3', 'resilienceFlowIN', 'resilienceFlowOUT', 'resilienceVolumeOUT' };
    % Convert to table
    resultsTable = array2table(results, 'VariableNames', headers);
    % Write to CSV
    writetable(resultsTable, outputFileName);
    fprintf('Results saved to %s\n', outputFileName);
end