bncsvName = '../data/bnprinter.csv';
datacsvName = '../data/bnprinterdata.csv';

bncsv = csvread(bncsvName);
datacsv = csvread(datacsvName);

initialConditionalProbabilities = 0.5; % Value for the initial probabilities
maxIterations = 4;

% Create our CPT Data structure, with a page for each node in the network
% The data for the current node is in column 1, with its parents data in
% subsequent columns
CPT = cell(1,size(bncsv,2));
% Initialise CPT's with initial conditional probabilities
for iteration = 0:maxIterations
    iteration = iteration + 1;
    csvColumnIndex = 1; % Keep track of what column in the csv we are reading
    
    for column = bncsv; % For each column in the csv (node in the DAG)
        % For each 1 in the column, we have an edge from that node, so we
        % generate its CPT
        
        parents = find(column==1);
        numberOfParents = numel(parents); % Get the number of parents the node has
        binaryPermutations = dec2bin(0:2^numberOfParents-1); % Compute the binary permutations for this number
        
        for permutation = 1:size(binaryPermutations,1) % For each possibility
            permutation = binaryPermutations(permutation,:);
            if iteration == 1
                CPT{csvColumnIndex}(1,bin2dec(permutation)+1) = initialConditionalProbabilities; % Save a conditional probability in the CPT for that permutation
            else
                CPT{csvColumnIndex}(1,bin2dec(permutation)+1) = CPT{csvColumnIndex}(2,bin2dec(permutation)+1) / CPT{csvColumnIndex}(3,bin2dec(permutation)+1);
            end
            CPT{csvColumnIndex}(2,bin2dec(permutation)+1) = 0; % Initialise a counter for 1's
            CPT{csvColumnIndex}(3,bin2dec(permutation)+1) = 0; % Initialise a counter for 0's
        end
        csvColumnIndex = csvColumnIndex + 1;
    end
    
    % E-Step
    newData = [];
    for row = 1:size(datacsv,1) % For each data point
        global configurations;
        configurations = [];
        numerators = [];
        split(datacsv(row,:)); % Recursively split the data point into multiple configurations, one for each possible value of each of the hidden variables
        for configuration = 1:size(configurations,1) % For each configuration
            numerators(:,configuration) = 1; % Array to store the numerator for each configuration Bayes Calculation
            for variable = 1:numel(configurations(configuration,:)) % For each variable in the config
                columnIndex = constructCPTColumnIndex(variable, bncsv, configurations(configuration,:));
                probability = CPT{variable}(1,columnIndex); % Get the probability from the CPT
                numerators(:,configuration) = numerators(:,configuration) * probability; % Calculate the current value for the Bayes calculation numerator
            end
        end
        denominator = sum(numerators,2); % Sum all the numerators to find the denominator
        configurationWeights = numerators / denominator; % Perform the Bayes calculation to find the configuration weights
        newData = [newData; configurations configurationWeights']; % Concatinate the configurations and their weights to generate a new dataset
    end
    
    % M-Step
    for dataPoint = 1:size(newData,1) % For each datapoint
        dataPoint = newData(dataPoint,:);
        for variable = 1:numel(dataPoint)-1
            variableValue = dataPoint(variable);
            columnIndex = constructCPTColumnIndex(variable, bncsv, dataPoint);
            if variableValue == 1
                CPT{variable}(2:3,columnIndex) = CPT{variable}(2:3,columnIndex) + dataPoint(end);
            else
                CPT{variable}(3,columnIndex) = CPT{variable}(3,columnIndex) + dataPoint(end);
            end
        end
    end
    
    % Print Results for this iteration
    fprintf('Iteration %d. P(1=1) = %f \n',iteration,CPT{1}(1))
end