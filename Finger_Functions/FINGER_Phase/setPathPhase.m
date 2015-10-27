function setPathPhase(username,subname)

if nargin == 0
    username = 'LAB';
    disp('assuming username ''LAB''');
end

switch username
    case 'Sumner'
        if ispc==1
            cd('C:\Users\Sumner\Desktop\FINGER_phase')             
        else
            cd('/Users/sum/Desktop/FINGER_phase');
        end
    case 'LAB'
        cd('D:\FINGER_phase');           
    otherwise
        disp('Invalid username selected');
        error('Invalid username');
end
addpath(cd); 

if nargin==2
    cd(strcat(subname,'001'));
end

end