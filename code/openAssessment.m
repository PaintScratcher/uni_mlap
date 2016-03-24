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
    for indx = 1:numel(column) % For each element in the column
        if column(indx) == 1 % Check if we have an incoming edge from that node
           % CPT{csvColumnIndex} = [CPT{csvColumnIndex} datacsv(:,indx)];
           CPT{csvColumnIndex}(:,indx) = initialConditionalProbabilities; 
           CPTIndex = CPTIndex +1;
        end
    end
    csvColumnIndex = csvColumnIndex + 1;
end

for row = 1:size(datacsv,1) % For each data point
    global configurations;
    configurations = [];
    split(datacsv(row,:)); % Recursively split the data point into multiple configurations, one for each possible value of each of the hidden variables
end
