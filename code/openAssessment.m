bncsvName = '../data/bnprinter.csv';
datacsvName = '../data/bnprinterdata.csv';

bncsv = csvread(bncsvName);
datacsv = csvread(datacsvName);
csvColumnIndex = 1; % Keep track of what column in the csv we are reading
initialConditionalProbabilities = 0.5; % Value for the initial probabilities

% Create our CPT Data structure, with a page for each node in the network
% The data for the current node is in column 1, with its parents data in
% subsequent columns
CPT = cell(1,size(bncsv,2));

% Initialise CPT's with initial conditional probabilities
for column = bncsv; % For each column in the csv (node in the DAG)
    % For each 1 in the column, we have an edge from that node, so we
    % generate its CPT
    
    numberOfParents = numel(find(column==1)); % Get the number of parents the node has
    binaryPermutations = dec2bin(0:2^numberOfParents-1); % Compute the binary permutations for this number
    for permutation = 1:size(binaryPermutations,1) % For each possibility
        permutation = binaryPermutations(permutation,:);
        CPT{csvColumnIndex}(bin2dec(permutation)+1) = initialConditionalProbabilities; % Save a conditional probability in the CPT for that permutation
    end
    csvColumnIndex = csvColumnIndex + 1;
end

newData = [];

% E-Step
for row = 1:size(datacsv,1) % For each data point
    global configurations;
    configurations = [];
    numerators = [];
    split(datacsv(row,:)); % Recursively split the data point into multiple configurations, one for each possible value of each of the hidden variables
    for configuration = 1:size(configurations,1) % For each configuration
        numerators(:,configuration) = ones(size(configurations,1),1); % Array to store the numerator for each configuration Bayes Calculation
        for variable = 1:numel(configurations(configuration,:)) % For each variable in the config
            parents = find(bncsv(:,variable)); % Find the parents of the variable
            configString = '';
            if size(parents,1) == 0 % Variable has no parents
                configString = '0'; % Create a config string such that the column index will be 1
            else
                for parent = 1:size(parents,1) % Get the current value of all parents to build a binary string to be used for CPT indexing
                    configString = strcat(configString, int2str(configurations(configuration,parents(parent)))); % Add the variable state to the config string
                end
            end
            columnIndex = bin2dec(configString) + 1; % Calculate the column for the CPT (+1 as the binary configs start at 0 and MATLAB indexes from 1)
            probability = CPT{variable}(:,columnIndex); % Get the probability from the CPT
            numerators(:,configuration) = numerators(:,configuration) * probability; % Calculate the current value for the Bayes calculation numerator
        end
    end
    denominator = sum(numerators); % Sum all the numerators to find the denominator
    configurationWeights = numerators / denominator; % Perform the Bayes calculation to find the configuration weights
    newData = [newData; configurations configurationWeights]; % Concatinate the configurations and their weights to generate a new dataset
end
