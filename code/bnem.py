from sys import argv
import csv

parentsList = {}

with open(argv[1]) as csvfile:
	reader = csv.reader(csvfile)
	for row in reader:
		for col, val in enumerate(row):
			if val == '1':
				if col in parentsList:
					parentsList[col].append(reader.line_num)
				else:
					parentsList[col] = [reader.line_num]

print parentsList
