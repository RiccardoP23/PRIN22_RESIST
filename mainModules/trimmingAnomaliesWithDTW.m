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
function [masked_reference, masked_signal] = trimmingAnomaliesWithDTW(reference, signal, percentage_threshold, min_length_ko, min_length_ok)
    % Perform DTW and get the warping path indices
    [~, ix, iy] = dtw(reference, signal,200); % The third field is the maximum warping distance, it cannot match points at more than 200 seconds away (S7 is more shifted...)
    % Align the signals using the warping path indices
    aligned_reference = reference(ix);  % Align reference according to ix
    aligned_signal = signal(iy);  % Align signal according to iy

    % figure
    % plot(aligned_signal)
    % hold on
    % plot(aligned_reference)

    % Compute the point-to-point difference between the aligned signals in percentage (punctual Mean Absolute Percentage Error MAPE)
    point_MAPE = 100*(abs((aligned_reference - aligned_signal)./aligned_reference));
    % Find the points where the MAPE exceeds the threshold
    anomalous_points = point_MAPE > percentage_threshold;
    % Find the indices of consecutive anomalous points
    anomaly_start = [];
    anomaly_end = [];
    i = 1;
    in_anomaly = false;
    ok_count = 0;
    while i <= length(anomalous_points)
        if ~in_anomaly
            % Look for the start of an anomaly segment
            if anomalous_points(i)
                % Check if this is the start of min_length_ko consecutive anomalies
                j = i;
                count = 0;
                while j <= length(anomalous_points) && anomalous_points(j)
                    count = count + 1;
                    if count >= min_length_ko
                        % Start anomaly segment
                        in_anomaly = true;
                        anomaly_start = [anomaly_start; i];  % Mark start
                        i = j + 1;
                        ok_count = 0;
                        break;
                    end
                    j = j + 1;
                end
                if ~in_anomaly
                    i = j;  % Move i forward even if segment didn’t qualify
                end
            else
                i = i + 1;
            end
        else
            % Inside an anomaly segment
            if anomalous_points(i)
                ok_count = 0;  % Reset OK counter if anomaly continues
            else
                ok_count = ok_count + 1;
                if ok_count >= min_length_ok
                    % Close anomaly segment
                    anomaly_end = [anomaly_end; i - min_length_ok];
                    in_anomaly = false;
                    ok_count = 0;
                end
            end
            i = i + 1;
        end
    end
    % Handle case where anomaly goes till the end
    if in_anomaly
        anomaly_end = [anomaly_end; length(anomalous_points)];
    end
    % Create a mask of the same size as the aligned signals, initialize to false (i.e., non-anomalous)
    mask = false(length(aligned_signal), 1);
    % Mark anomalous regions in the mask
    for k = 1:length(anomaly_start)
        mask(anomaly_start(k):anomaly_end(k)) = true;
    end
    % Apply the mask: keep anomalous points, set others to 0
    masked_reference = zeros(size(aligned_reference));
    masked_signal = zeros(size(aligned_signal));
    masked_reference(mask) = aligned_reference(mask);
    masked_signal(mask) = aligned_signal(mask);
    % Limit output to max_time_length by removing zeros. Aligning signals may shift the time axis. This ensures the proper time length by removing zeros which will have no importance in the areaUnderCurve calculation
    max_time_length = length(reference);
    current_length = length(masked_reference);
    if current_length > max_time_length
        % Find indices of zeros to potentially remove
        zero_indices = find(masked_reference == 0 & masked_signal == 0);
        % Number of samples to remove
        to_remove = current_length - max_time_length;
        if length(zero_indices) >= to_remove
            % Remove from the beginning of zero_indices
            remove_indices = zero_indices(1:to_remove);
            % Create a logical index for keeping values
            keep_mask = true(current_length, 1);
            keep_mask(remove_indices) = false;
            masked_reference = masked_reference(keep_mask);
            masked_signal = masked_signal(keep_mask);
        else
            warning('Not enough zero-values to reduce to original time length. Try changing threshold and/or min_length. Returning full output.');
        end
    end

    % figure;
    % plot(masked_signal, 'r');
    % hold on;
    % plot(masked_reference, 'b');
    % legend('Masked Signal', 'Masked Reference');
    % title('Anomalous Segments Highlighted');

end

    
% This code here returned trimmed timeseries, with non-anomalous points being completely cancelled
% 
%     % If there are anomalies keep the anomalous segments
%     if ~isempty(anomaly_start)
%         % Create a mask to keep only the anomalous segments
%         mask = false(length(aligned_signal_x), 1); 
%         % Mark the anomalous regions as true in the mask
%         for k = 1:length(anomaly_start)
%             mask(anomaly_start(k):anomaly_end(k)) = true;
%         end 
%         % Keep only the anomalous portions of the signals
%         kept_reference = aligned_signal_x(mask);
%         kept_signal = aligned_signal_y(mask);
%     else
%         % If no anomalies found return empty arrays
%         kept_reference = [];
%         kept_signal = [];
%     end
% end