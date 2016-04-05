function [ columnIndex ] = constructCPTColumnIndex( variable, bncsv, configuration )
%CONSTRUCTCONFIGSTRING Construct a config string for CPT indexing based on
%the status of each variable and its parents
parents = find(bncsv(:,variable)); % Find the parents of the variable
if numel(parents) == 0 % Variable has no parents
    configString = '0'; % Create a config string such that the column index will be 1
else
    configString = '';
    for parent = 1:size(parents,1) % Get the current value of all parents to build a binary string to be used for CPT indexing
        parent = parents(parent);
        configString = strcat(configString, int2str(configuration(parent))); % Add the variable state to the config string
    end
end
columnIndex = bin2dec(configString) + 1; % Calculate the column for the CPT (+1 as the binary configs start at 0 and MATLAB indexes from 1)
end

