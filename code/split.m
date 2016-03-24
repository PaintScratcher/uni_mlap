function [ configurations ] = split(row)
%SPLIT Recursively split an input row with hidden variables into valid
%configurations
    hiddenColIndex = find(isnan(row)); % Partition the variables into hidden and visible
    global configurations;
    if numel(hiddenColIndex) > 1
%         disp 'greater than 1'
        for binary = 0:1;
           row(hiddenColIndex(1)) = binary;
           split(row);
        end
    else
        disp 'base case'
        for binary = 0:1;
           row(hiddenColIndex(1)) = binary; 
           configurations = [configurations; row];
           configurations
        end
    end    
end

