function []= openAssessment( bncsvName, datacsvName, initialValues)

bncsv = csvread(bncsvName); % Read in the CSV files
datacsv = csvread(datacsvName);
initialValuescsv = csvread(initialValues);

iteration = 0; % Variable to keep count of the iteration we are on
totalLogLikelihood = 0; % Store the total log likelihood
% Create our CPT Data structure, with a page for each node in the network
% The data for the current node is in column 1, with its parents data in
% subsequent columns depending on their state
CPT = cell(1,size(bncsv,2));

while 1 % Loop until we reach convergence
    iteration = iteration + 1;
    csvColumnIndex = 1; % Keep track of what column in the csv we are reading
    
    for column = bncsv; % For each column in the csv (node in the DAG)
        % For each 1 in the column, we have an edge from that node, so we
        % generate its CPT
        
        parents = find(column==1); % Find the parents of the current variable
        numberOfParents = numel(parents); % Get the number of parents the node has
        binaryPermutations = dec2bin(0:2^numberOfParents-1); % Compute the binary permutations for this number
        
        for permutation = 1:size(binaryPermutations,1) % For each possibility
            permutation = binaryPermutations(permutation,:);
            if iteration == 1 % For the first iteration we initialise the probabilities with the initial value
                CPT{csvColumnIndex}(1,bin2dec(permutation)+1) = initialValuescsv(bin2dec(permutation)+1, csvColumnIndex); % Save a conditional probability in the CPT for that permutation
            else % This is not the first iteration so we need to calculate the probability using the counts from the previous M-Step
                probability = CPT{csvColumnIndex}(2,bin2dec(permutation)+1) / CPT{csvColumnIndex}(3,bin2dec(permutation)+1); % Number of times variable is 1 divided by number of times the parent condition occured
                if isnan(probability) % If we have divided by 0 and caused NaN, set the probability to 0 for nicer display
                    CPT{csvColumnIndex}(1,bin2dec(permutation)+1) = 0;
                else
                    CPT{csvColumnIndex}(1,bin2dec(permutation)+1) = probability;
                end
            end
            CPT{csvColumnIndex}(2,bin2dec(permutation)+1) = 0; % Initialise a counter for 1's (used in M step)
            CPT{csvColumnIndex}(3,bin2dec(permutation)+1) = 0; % Initialise a counter for 0's (used in M step)
        end
        csvColumnIndex = csvColumnIndex + 1; % Increment the column index so we can read the next column
    end
    
    % E-Step
    newData = []; % Data structure to store all the possible combinations and their weights
    for row = 1:size(datacsv,1) % For each data point
        global configurations; % Needs to be global so the recursion function can write to it
        configurations = [];
        numerators = []; % Store the top line of the bayes calculation
        split(datacsv(row,:)); % Recursively split the data point into multiple configurations, one for each possible value of each of the hidden variables
        for configuration = 1:size(configurations,1) % For each configuration
            numerators(:,configuration) = 1; % Array to store the numerator for each configuration Bayes Calculation
            for variable = 1:numel(configurations(configuration,:)) % For each variable in the config
                columnIndex = constructCPTColumnIndex(variable, bncsv, configurations(configuration,:)); % Construct the CPT column index for this configuration so we read from the correct place
                variableValue = configurations(configuration,variable); % Get the value of the current variable so we know if we need to minus the stored probability from 1 or not
                probability = getProbability(CPT, variable, variableValue, columnIndex); % Get the probability from the CPT
                probability = round(probability,10); % Round the probability to avoid floating point errors at a high number of iterations
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
        for variable = 1:numel(dataPoint)-1 % For each variable in the data point
            variableValue = dataPoint(variable); % Get the current status of the variable
            columnIndex = constructCPTColumnIndex(variable, bncsv, dataPoint); % Construct the CPT column index for this configuration so we write to the correct place
            if variableValue == 1 % If the variable is 1, we increment both the denominator and the numerator
                CPT{variable}(2:3,columnIndex) = CPT{variable}(2:3,columnIndex) + dataPoint(end);
            else % If the variable is 0, we only increment the denominator, indicating its parents status has occured
                CPT{variable}(3,columnIndex) = CPT{variable}(3,columnIndex) + dataPoint(end);
            end
        end
    end
    
    % Calculate log-likelihood for this iteration
    previousLogLikelihood = totalLogLikelihood; % Store the previous log-likelihood for use in detecting convergence
    totalLogLikelihood = 0; % Reset the current log-likelihood for this iteration
    for row = 1:size(datacsv,1) % For each data point
        global configurations;
        configurations = [];
        split(datacsv(row,:)); % Recursively split the data point into multiple configurations, one for each possible value of each of the hidden variables
        dataPointLikelihood = 0;
        for configuration = 1:size(configurations,1) % For each configuration
            configurationLikelihood = 1;
            for variable = 1:numel(configurations(configuration,:)) % For each variable in the config
                columnIndex = constructCPTColumnIndex(variable, bncsv, configurations(configuration,:));  % Construct the CPT column index for this configuration so we read from the correct place
                variableValue = configurations(configuration,variable);
                probability = getProbability(CPT, variable, variableValue, columnIndex); % Get the probability from the CPT
                configurationLikelihood = configurationLikelihood * probability; % The product of all the variable probabilities totals the likelihood for this configuration
            end
            dataPointLikelihood = dataPointLikelihood + configurationLikelihood; % Add all the configuration likelihoods's together to form the total LL for this datapoint
        end
        totalLogLikelihood = totalLogLikelihood + log(dataPointLikelihood); % Add all the log-likelihood for this datapoint to the total
    end
    
    % Print Results for this iteration
    fprintf('Iteration %d. Log-likelihood is currently: %f \n',iteration, totalLogLikelihood)
    
    % Detect Convergence
    if abs(totalLogLikelihood - previousLogLikelihood) < 0.0001 % If the difference between the current and previous LL is small enough, we have converged
        fprintf('Convergence in %d steps \n', iteration); % Print the number of iterations it took to converge
        for variable = 1:size(datacsv,2); % For each variable
            parents = find(bncsv(:,variable)); % Find its parents
            numberOfParents = numel(parents); % Get the number of parents the node has
            binaryPermutations = dec2bin(0:2^numberOfParents-1); % Compute the binary permutations for this number
            fprintf('Variable %d has these parents (%s\b\b)\n',variable -1,sprintf('%d, ', parents -1)) % Print the variable and its parents
            for permutation = 1:size(binaryPermutations,1) % For each possibility
                permutation = binaryPermutations(permutation,:);
                probability = CPT{variable}(1,bin2dec(permutation)+1);
                if numberOfParents == 0
                    fprintf('P(%d=1|() = %d \n',variable -1, probability) % Print the current variables probability
                else
                    fprintf('P(%d=1|(%s\b\b)) = %d \n',variable -1,sprintf('''%c'', ', permutation), probability) % Print the current variables probability for each parent state
                end
            end
            fprintf('\n')
        end
        break;
    end
end
end