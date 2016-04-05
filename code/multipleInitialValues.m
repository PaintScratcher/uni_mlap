bncsvName = '../data/bnprinter.csv';
datacsvName = '../data/bnprinterdata.csv';
initialProbabilities = [0.25 0.5 0.7];
% initialProbabilities = [0.5]; % Single run (for part 1)

for initialProbability = initialProbabilities 
   openAssessment(bncsvName, datacsvName, initialProbability)
end