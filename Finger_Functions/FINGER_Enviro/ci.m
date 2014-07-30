function [mu sig conf] = ci(data)

% This function calculates the mean, standard deviation and confidence
% intervals for a vector of data
% [mean,std,ci] = ci(data)

mu = mean(data);
sig = std(data);
%1.796 taken from alpha = 0.05 and d.o.f. = 11 (12 subs - 1 for mean calc)
%table here: http://3.bp.blogspot.com/_C6375WoyYP0/THVqQkJRqbI/AAAAAAAAASU/ML7g-OPPgug/s1600/Student-t-table.png
conf = 1.796*sig; 

end