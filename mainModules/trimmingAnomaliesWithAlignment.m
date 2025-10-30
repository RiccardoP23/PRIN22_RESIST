% This function is meant to trim only the anomalous portions of two comparable signals performing DTW alignement at first
% Inputs:
% reference: the first time series(as an array) nb. the first timeseries is the reference (i.e., how things should go)
% signal_y: the second time series (as an array) nb. the two arrays shall be equal length
% percentage_threshold: the threshold as a percentage of error over which the difference between signals is anomalous
% min_length: the minimum lenght of a segment of anomalous points to be considered anomalous segment (if 3, 3 subsequent anomalies already represent an anomalous segment)
% Outputs:
% masked_reference: the portions of reference where signal is anomalous (non-anomalous points are set to 0)
% masked_signal: the portions of signal where signal is anomalous (non-anomalous points are set to 0)
%
function [masked_reference, masked_signal] = trimmingAnomaliesWithAlignment(reference, signal, percentage_threshold, min_length_ko, min_length_ok)
    % Align the signals using cross-correlation (time shift only)
    [aligned_reference, aligned_signal] = alignsignals(reference, signal);

    % Ensure they are the same length after alignment
    min_len = min(length(aligned_reference), length(aligned_signal));
    aligned_reference = aligned_reference(1:min_len);
    aligned_signal = aligned_signal(1:min_len);

    % figure
    % plot(aligned_signal)
    % hold on
    % plot(aligned_reference)

    % Compute point-wise MAPE (Mean Absolute Percentage Error)
    point_MAPE = 100 * abs((aligned_reference - aligned_signal) ./ aligned_reference);

    % Identify anomaly points based on threshold
    anomalous_points = point_MAPE > percentage_threshold;

    % Initialize variables for tracking anomaly segments
    anomaly_start = [];
    anomaly_end = [];
    i = 1;
    in_anomaly = false;
    ok_count = 0;

    while i <= length(anomalous_points)
        if ~in_anomaly
            % Look for the start of an anomaly segment
            if anomalous_points(i)
                % Check for min_length_ko consecutive anomalies
                j = i;
                count = 0;
                while j <= length(anomalous_points) && anomalous_points(j)
                    count = count + 1;
                    if count >= min_length_ko
                        % Start anomaly segment
                        in_anomaly = true;
                        anomaly_start = [anomaly_start; i];
                        i = j + 1;
                        ok_count = 0;
                        break;
                    end
                    j = j + 1;
                end
                if ~in_anomaly
                    i = j;  % Skip ahead
                end
            else
                i = i + 1;
            end
        else
            % Already in an anomaly segment
            if anomalous_points(i)
                ok_count = 0;
            else
                ok_count = ok_count + 1;
                if ok_count >= min_length_ok
                    anomaly_end = [anomaly_end; i - min_length_ok];
                    in_anomaly = false;
                    ok_count = 0;
                end
            end
            i = i + 1;
        end
    end

    % If we reach the end while still in an anomaly
    if in_anomaly
        anomaly_end = [anomaly_end; length(anomalous_points)];
    end

    % Create mask and apply it
    mask = false(length(aligned_signal), 1);
    for k = 1:length(anomaly_start)
        mask(anomaly_start(k):anomaly_end(k)) = true;
    end

    masked_reference = zeros(size(aligned_reference));
    masked_signal = zeros(size(aligned_signal));
    masked_reference(mask) = aligned_reference(mask);
    masked_signal(mask) = aligned_signal(mask);

    % Trim output to match original signal length
    max_time_length = length(reference);
    current_length = length(masked_reference);

    if current_length > max_time_length
        zero_indices = find(masked_reference == 0 & masked_signal == 0);
        to_remove = current_length - max_time_length;
        if length(zero_indices) >= to_remove
            remove_indices = zero_indices(1:to_remove);
            keep_mask = true(current_length, 1);
            keep_mask(remove_indices) = false;
            masked_reference = masked_reference(keep_mask);
            masked_signal = masked_signal(keep_mask);
        else
            warning('Not enough zero-values to reduce to original time length. Try changing threshold and/or min_length. Returning full output.');
        end
    end

    % Optional plot
    % figure;
    % plot(masked_signal, 'r');
    % hold on;
    % plot(masked_reference, 'b');
    % legend('Masked Signal', 'Masked Reference');
    % title('Anomalous Segments Highlighted');

end