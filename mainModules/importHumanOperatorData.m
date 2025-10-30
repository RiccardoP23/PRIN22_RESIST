% How to read input data in workspace (UNIBO):
%
% - controlVolumes variables contains defined control volumes on each column.
% Then, rows 1 - 3 include origin's coordinates, row 4 - 6 include the
% control volume extension from origin's coordinate, and row 7 contains the
% the total time the operator spent within the control volume;
% - distance variables contains defined control volumes on each column. Then
%each row include the distance [mm] between the hips of the operator and
%the centroid of each control volume. Data in rows are collected each 1/30
%seconds;
% - temporalSequence variables contains defined control volumes on the first
%columns while the last column includes times measured in seconds. In rows,
% it is denoted in which control volume the operator is positioned
% (1 if in control volume, 0 if not) with the corresponding time of presence
% in the control volume indicated in the last column. The number of rows is
% proportional to the changes in control volumes the operator made: if each
% control volume has value 0 the operator is in a zone of the plant which has
% not been mapped with control volumes;
% - D means detection, R means recovery. They indicate the two phases in
% which the operator intervenes;
% - 1 refers to scenario 1 (water level), 2 refers to scenario 2
% (tank pressure);
% - T+number (e.g., T1, T2, T3) identifies the recording take for data collection;
% - CP (if present) means control panel and it identifies the subset of
% recordings in which the operator shut off the plant through the control
% panel. Detection data labeled with CP can be paired with recovery data
% labeled with CP, only because, otherwise, the ending position (for
% detection) of the operator will not match with the starting one (for recovery).
%
%%%%%%% IMPORT DATA FOR HUMAN OPERATOR (UNIBO) %%%%%%%
%
function importHumanOperatorData()
    % Get the directory where this function is located
    script_dir = fileparts(mfilename('fullpath'));
    % Navigate to the 'dataHumanOperator' folder (assumed one level up)
    folder_path = fullfile(script_dir, '..', 'dataHumanOperator');
    % Get all .mat (MATLAB Workspace) files in the 'dataHumanOperator' folder
    workspace_files = dir(fullfile(folder_path, '*.mat'));
    % Loop through each workspace file
    for i = 1:length(workspace_files)
        % Get the full path of the current file
        current_file = fullfile(folder_path, workspace_files(i).name);
        % Load specific variables from the .mat file
        vars = load(current_file, 'CV', 'distanze', 'sequenza_con_tempi');
        % Extract filename without extension to use in dynamic variable naming (~ ignores first and third outputs of fileparts function)
        [~, file_name, ~] = fileparts(workspace_files(i).name);
        % Assign variables dynamically into the base workspace
        assignin('base', ['controlVolumes_' file_name], vars.CV);
        assignin('base', ['distances_' file_name], vars.distanze);
        assignin('base', ['temporalSequence_' file_name], vars.sequenza_con_tempi);
    end
    % Display confirmation message
    disp('Import for human operator data completed.');
end