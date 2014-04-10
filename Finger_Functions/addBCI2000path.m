olddir = pwd;
cd('C:\BCI2000')   % The absolute path has to be hardcoded somewhere, and here it is.  Watch out, in case this is (or becomes) incorrect 
%cd('~/Documents/BCI2000')
cd tools, cd matlab
bci2000path -AddToMatlabPath tools/matlab
bci2000path -AddToMatlabPath tools/mex
bci2000path -AddToSystemPath tools/cmdline   % required so that BCI2000CHAIN can call the command-line tools
cd(olddir) % change directory back to where we were before
clear olddir