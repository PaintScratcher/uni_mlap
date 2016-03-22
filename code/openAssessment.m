bncsvName = '../data/bnprinter.csv';
datacsvName = '../data/bnprinterdata.csv';

bncsv = csvread(bncsvName);
datacsv = csvread(datacsvName);

csvColumnIndex = 1;

for column = bncsv; % For each column in the csv (node in the DAG)
    % For each 1 in the column, we need the row number. Then we get that
    % column in the data csv?
    nodeData = datacsv(:,csvColumnIndex);
    for idx = 1:numel(column) % For each element in the column
        incoming_edge = column(idx);
        if incoming_edge == 1 % Check if we have a connection to that node
            nodeData = horzcat(nodeData,datacsv(:,idx)); % Gather that nodes variable data
        end
    end
    csvColumnIndex = csvColumnIndex + 1;
end
