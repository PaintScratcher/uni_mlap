bncsvName = '../data/bnprinter.csv';
datacsvName = '../data/bnprinterdata.csv';

bncsv = csvread(bncsvName);
datacsv = csvread(datacsvName);

csvColumnIndex = 1; % Keep track of what column in the csv we are reading

for column = bncsv; % For each column in the csv (node in the DAG)
    % For each 1 in the column, we need the row number. Then we get that
    % column in the data csv?
    nodeData = datacsv(:,csvColumnIndex); % Data structure for storing the variable data we need
    % Iterate through the column and check for 1's, this indicates an edge
    % in the DAG and therefore the node associated with the 1 is a parent
    % of the node we are currently looking at. If a 1 is present we need to
    % get the associated nodes data for use
    for idx = 1:numel(column) % For each element in the column
        incoming_edge = column(idx); % Get the element
        if incoming_edge == 1 % Check if we have a connection to that node
            nodeData = horzcat(nodeData,datacsv(:,idx)); % Gather that nodes variable data
        end
    end
    csvColumnIndex = csvColumnIndex + 1;
    
    
    
end
