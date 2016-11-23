%calls datToMat to parse data from BCI2000 Wadsworth BCI study
startDir = pwd;
try 
%     cd 'C:\Users\Sumner\Dropbox\UCI RESEARCH\FINGER\FINGER_wadsworth\Data'
    cd 'C:\Users\Sumner\Dropbox\UCI RESEARCH\FINGER\FINGER_wadsworth\DenniShare'
    data = datToMat(subname,runsExpected);
    cd(startDir)
catch me
    error('Could not find data set or could not load')
end

subname = 'Name';
runsExpected = 1;

data.force = double([data.state{1,1}.FRobotForceF1 ... 
                     data.state{1,1}.FRobotForceF2]);
data.forceEst = double([data.state{1,1}.FRobotForce1 ... 
                        data.state{1,1}.FRobotForce2]);   
data.forceNorm = data.force/norm(data.force,Inf);
data.forceEstNorm = data.forceEst/norm(data.forceEst,Inf);
                    
%% plot force traces
close all
sample = 1:size(data.force,1);
plot(sample,data.forceNorm(:,1),'b',sample,data.forceNorm(:,2),'y')
legend('index','middle','Location','Best'); 
