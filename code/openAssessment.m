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

for column = bncsv; % For each column in the csv (node in the DAG)
    % For each 1 in the column, we have an edge from that node, so we
    % generate its CPT
    CPT{csvColumnIndex} = initialConditionalProbabilities;
    CPTIndex = 2; % Keep track of the Column in the CPT page we are storing data in
    numberOfParents = numel(find(column==1)); % Get the number of parents the node has
    binaryPermutations = dec2bin(0:2^numberOfParents-1); % Compute the binary permutations for this number
    for permutation = 1:size(binaryPermutations,1) % For each possibility
        permutation = binaryPermutations(permutation,:); 
        CPT{csvColumnIndex}(bin2dec(permutation)+1) = initialConditionalProbabilities; % Save a conditional probability in the CPT for that permutation
    end
    csvColumnIndex = csvColumnIndex + 1;
end

for row = 1:size(datacsv,1) % For each data point
    global configurations;
    configurations = [];
    split(datacsv(row,:)); % Recursively split the data point into multiple configurations, one for each possible value of each of the hidden variables
    for configuration = 1:size(configurations,1) % For each configuration
        for variable = 1:numel(configurations(configuration,:)) % For each variable in the config
           parents = find(bncsv(:,variable)); % Find the parents of the variable
           
        end
    end
end
