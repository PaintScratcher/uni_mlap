function [ configurations ] = split(row)
%SPLIT Recursively split an input row with hidden variables into valid
%configurations
    hiddenColIndex = find(isnan(row)); % Find the column number of each of the hidden variables
    global configurations;
    if numel(hiddenColIndex) == 0 % There are no hidden variables so we just return the row 
       configurations = row; 
    elseif numel(hiddenColIndex) == 1 % Base case, only one hidden variable left
      for binary = 0:1; % For each possible value of the variable
           row(hiddenColIndex(1)) = binary; % Set the hidden variable to a known
           configurations = [configurations; row]; % Store the final configuration
      end
    else % Not the base case, so we need to recurse deeper
        for binary = 0:1; % For each possible value of the variable
           row(hiddenColIndex(1)) = binary; % Set the hidden variable to a known
           split(row); % Recurse to the next hidden variable
        end
    end    
end