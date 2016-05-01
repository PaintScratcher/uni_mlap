function [ probability ] = getProbability( CPT, variable, variableValue, columnIndex )
%GETPROBABILITY Get the probability of a variable from the CPT
probability = CPT{variable}(1,columnIndex); % Retrieve the value for a variable being 1
if variableValue == 0 % If the variable is 0, we need to minus the probability from 1 to get the true value
    probability = 1 - probability;
end
end

