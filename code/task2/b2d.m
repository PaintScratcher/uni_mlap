function y = b2d(x)
% Function to convert a binary array to a decimal number
% Adapted from http://www.mathworks.com/matlabcentral/fileexchange/26447-efficient-convertors-between-binary-and-decimal-numbers
z = 2.^(length(x)-1:-1:0);
y = sum(x.*z);