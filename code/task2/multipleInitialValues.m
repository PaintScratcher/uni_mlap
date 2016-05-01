% bncsvName = '../data/bnprinter.csv';
% datacsvName = '../data/bnprinterdata.csv';
bncsvName = '../data/bnprinterTask2.csv';
datacsvName = '../data/bnprinterdataTeST.csv';
initialProbabilities = [0.3];
% initialProbabilities = [0.5]; % Single run (for part 1)

for initialProbability = initialProbabilities 
   openAssessment(bncsvName, datacsvName)
end