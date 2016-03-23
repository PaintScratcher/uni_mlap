bncsvName = '../data/bnprinter.csv';
datacsvName = '../data/bnprinterdata.csv';

bncsv = csvread(bncsvName);
datacsv = csvread(datacsvName);

csvColumnIndex = 1; % Keep track of what column in the csv we are reading


% Create our CPT Data structure, with a page for each node in the network,
% each row is a data point and each column is a variable.
% The data for the current node is in column 1, with its parents data in
% subsequent columns
CPT = cell(1,size(bncsv,2));

for column = bncsv; % For each column in the csv (node in the DAG)
    % For each 1 in the column, we have an edge from that node, so we add
    % its data to our CPT
    CPT{csvColumnIndex} = datacsv(:,csvColumnIndex); % Add the observed data for this node to the CPT
    CPTIndex = 2; % Keep track of the Column in the CPT page we are storing data in
    for indx = 1:numel(column) % For each element in the column
        if column(indx) == 1 % Check if we have an incoming edge from that node
            CPT{csvColumnIndex} = [CPT{csvColumnIndex} datacsv(:,indx)];
            CPTIndex = CPTIndex +1;
        end
    end
    csvColumnIndex = csvColumnIndex + 1;   
    
end
