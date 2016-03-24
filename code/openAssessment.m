bncsvName = '../data/bnprinter.csv';
datacsvName = '../data/bnprinterdata.csv';

bncsv = csvread(bncsvName);
datacsv = csvread(datacsvName);

csvColumnIndex = 1; % Keep track of what column in the csv we are reading
initialConditionalProbabilities = 0.5;
laff = find(isnan(datacsv));

% Create our CPT Data structure, with a page for each node in the network,
% each row is a data point and each column is a variable.
% The data for the current node is in column 1, with its parents data in
% subsequent columns
CPT = cell(1,size(bncsv,2));

for column = bncsv; % For each column in the csv (node in the DAG)
    % For each 1 in the column, we have an edge from that node, so we add
    % its data to our CPT
    %CPT{csvColumnIndex} = datacsv(:,csvColumnIndex); % Add the observed data for this node to the CPT
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
    row = datacsv(row,:);
    global configurations;
    configurations = [];
    split(row);
%     hiddenColIndex = find(isnan(row)); % Partition the variables into hidden and visible
%     visibleColIndex = find(~isnan(row));
%     for variable = hiddenColIndex; % For each hidden variable
%         for binary = 0:1; % For each binary value it can be
%             row(variable) = binary;
%         end
%         
%     end
end
