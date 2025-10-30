%This function is meant to append the shutdown phase to the attack phase minimizing gaps. Euclidean distance is employed.
%
function trimmedShutdown = findClosestShutdownStart(attack_block, shutdown_block)
    % Get the last row of attack_block (columns 20 to 30 only, which contain real sensors data + valves data + input and output flows data + total volume of water extreacted)
    last_attack_row = table2array(attack_block(end, 20:30));
    % Initialize min distance (very large value to ensure the first to be less) and index
    min_distance = 100000;
    closest_i = 1;
    % Loop through each row in shutdown_block
    for i = 1:height(shutdown_block)
        % Extract values of interest (columns 20 to 30 only, which contain real sensors data + valves data + input and output flows data + total volume of water extreacted)
        row = table2array(shutdown_block(i, 20:30));
        % Compute Euclidean distance to last_attack_row
        dist = norm(row - last_attack_row);
        % If this is the smallest distance, save index
        if dist < min_distance
            min_distance = dist;
            closest_i = i;
        end
    end
    % Return shutdown block starting from closest match
    trimmedShutdown = shutdown_block(closest_i:end, :);
end
