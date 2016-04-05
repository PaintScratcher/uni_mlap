function [ probability ] = getProbability( CPT, variable, variableValue, columnIndex )
%GETPROBABILITY Get the probability of a variable from the CPT
probability = CPT{variable}(1,columnIndex);
if variableValue == 0
    probability = 1 - probability;
end
end

