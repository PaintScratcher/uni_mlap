function [ columnIndex ] = constructCPTColumnIndex( variable, bncsv, configuration )
%CONSTRUCTCONFIGSTRING Construct a config string for CPT indexing based on
%the status of each variable and its parents
parents = find(bncsv(:,variable)); % Find the parents of the variable
if numel(parents) == 0 % Variable has no parents
    columnIndex = 1;
else
    parentValues = configuration(parents);
    columnIndex = b2d(parentValues) + 1; % Calculate the column for the CPT (+1 as the binary configs start at 0 and MATLAB indexes from 1)
end
end