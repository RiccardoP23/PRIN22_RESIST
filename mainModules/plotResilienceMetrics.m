% This function is to plot in a tri dimensional space the resilience per sensor with respect to operator detection time and restoration time
% finalTimeSeriesList is the list of all simulations results
% resilienceList is the list of all computed values for resilience
%
function plotResilienceMetrics(finalTimeSeriesList, resilienceList)
    % Number of scenarios (assumed equal length of both lists)
    numScenarios = length(finalTimeSeriesList);
    % Initialize arrays to hold results
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
    % Loop over the tables
    for i = 1:numScenarios
        % From finalTimeSeriesList
        table1 = finalTimeSeriesList{i};
        detectionTime(i) = sum(table1{:, 32} ~= 0);
        restorationTime(i) = sum(table1{:, 34} ~= 0);
        % From resilienceList
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
    % Define plotting helper
    function plot3DMetric(x, y, z, metricName)
    figure;
    % Create scatter plot with color mapped to resilience values
    scatter3(x, y, z, 70, z, 'filled');
    % Axes labels
    xlabel('Detection Time');
    ylabel('Restoration Time');
    zlabel(['Resilience ' metricName]);
    title(['Resilience ' metricName ' vs Detection and Restoration Time']);
    grid on;
    % Green-to-red colormap (custom)
    nColors = 256;
    cmap = [linspace(1, 0, nColors)', linspace(0, 1, nColors)', zeros(nColors, 1)];
    colormap(cmap);
    % Color axis and colorbar
    clim([min(z) max(z)]);
    colorbar;
end
    % Create plots
    plot3DMetric(detectionTime, restorationTime, resilienceS1, '(Water inlet pressure)');
    plot3DMetric(detectionTime, restorationTime, resilienceS2, '(Water inlet flow rate)');
    plot3DMetric(detectionTime, restorationTime, resilienceS5, '(Tank pressure)');
    plot3DMetric(detectionTime, restorationTime, resilienceS6, '(Tank level)');
    plot3DMetric(detectionTime, restorationTime, resilienceS7, '(Air outlet flow rate)');
    plot3DMetric(detectionTime, restorationTime, resilienceAV1, '(Valve AV1 opening)');
    plot3DMetric(detectionTime, restorationTime, resilienceAV2, '(Valve AV2 opening)');
    plot3DMetric(detectionTime, restorationTime, resilienceAV3, '(Valve AV3 opening)');
    plot3DMetric(detectionTime, restorationTime, resilienceFlowIN, '(Inlet flow)');
    plot3DMetric(detectionTime, restorationTime, resilienceFlowOUT, '(Outlet flow)');
    plot3DMetric(detectionTime, restorationTime, resilienceVolumeOUT, '(Volume extracted)');
end
