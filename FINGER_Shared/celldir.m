function thecell = celldir(dirarg)
% function thecell = celldir(dirarg)
%
% Wrapper function for dir.m that outputs a cell array of filename
% strings that match the input argument. For instructions on how
% to use the input argument, see help dir.  Best used with
% wildcards to get all files for a single subject, condition, etc.
%
% ex: thecell=celldir('CH*.cnt');
%
% Cort Horton - 7/24/12

dirout=dir(dirarg);
for k=1:length(dirout)
    thecell{k}=dirout(k).name;
end
