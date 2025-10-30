% percentage_threshold: the threshold as a percentage of error over which the difference between signals is anomalous
% min_length: the minimum lenght of a segment of anomalous points to be considered anomalous segment (if 3, 3 subsequent anomalies already represent an anomalous segment)
function resilienceIndicator = areaUnderCurve(reference_table, scenario_table, percentage_threshold, min_length_ko, min_length_ok)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % By now standard is shorter than disrupted (10k timesteps only)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Ensure all timeseries have same length
    timelength = min(height(reference_table), height(scenario_table));
    reference_table = reference_table(1:timelength, :);
    scenario_table = scenario_table(1:timelength, :); 
    % Modify timeseries to compute resilience only where there is a change in performance
    % Run trimmingAnomaliesWithDTW for all signals (time will e excluded after)
    num_signals = width(reference_table);
    % Check if there are such column (for debugging only)
    if width(reference_table) ~= width(scenario_table)
        error('Time series do not have same number of columns to perform comparison.');
    end
    % Iterate over all columns to compare to modify the timeseries signals masking non-anomalous points (set to 0)
    for i = 2 : num_signals % Column 1 is time, it is excluded
        % Extract the i-th column from both tables to be used as inputs for trimmingAnomaliesWithDTW
        reference = reference_table{:, i};
        signal = scenario_table{:, i};
        % Run the anomaly masking function
        [masked_reference, masked_signal] = trimmingAnomaliesWithDTW(reference, signal, percentage_threshold, min_length_ko, min_length_ok);
        % Replace the original column with the masked output
        reference_table{:, i} = masked_reference;
        scenario_table{:, i} = masked_signal;
    end      
    % Extract time vector (time series shall have equal length, i.e.,timelength above)
    time = reference_table{:, 1};
    % Preallocate output vector
    resilienceIndicator = zeros(1, num_signals); % Column 1 will be 0 because it is time
    % Loop over each signal column
    for i = 2:(num_signals) % Column 1 is kept 0 because it is time
        signal1 = reference_table{:, i};
        signal2 = scenario_table{:, i};
        % Compute absolute difference and area under the curve
        diff = abs(signal1 - signal2);
        area_diff = trapz(time, diff);
        area_standard = trapz(time, signal1);
        % Compute the resilience indicator for the current signal
        resilienceIndicator(i) = (area_standard - area_diff) / area_standard;
    end
end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Old logic to highlight anomalous portions - substituted with DTW
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % diff_matrix = ts1{:, cols_to_compare} - ts2{:, cols_to_compare};
    % % Sum distances rows by rows
    % euclidean_dist = sqrt(sum(diff_matrix.^2, 2));
    % % Find region where distance exceeds threshold
    % idx = find(euclidean_dist > threshold);
    % if isempty(idx)
    %     warning('No portion of time series exceeds the given threshold. Returning NaNs.');
    %     resilienceIndicator = NaN(1, width(ts1) - 1);
    %     return;
    % end
    % % Determine start and end of the region
    % start_idx = min(idx);
    % end_idx = max(idx);
    % % Trim the time series to the selected region
    % ts1_trimmed = ts1(start_idx:end_idx, :);
    % ts2_trimmed = ts2(start_idx:end_idx, :);
    % % Extract time vector (time series have equal length)
    % time = ts1_trimmed{:, 1};
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%