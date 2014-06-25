function setPathEnviro(username,subname)

switch username
    case 'Sumner'
        if ispc==1
            cd('C:\Users\Sumner\Desktop\FINGER-Enviro study')             
        else
            cd('/Users/sum/Desktop/Finger-Enviro study');
        end
    case 'Omar'
        cd('C:\Users\Omar\Desktop\FINGER-Enviro study')  
    case 'Camilo'
        cd('C:\Users\Camilo\Desktop\FINGER-Enviro study') 
    case 'Thuong'
        cd('C:\Users\Thuong\Documents\SPRING 2014\Research\Enviro_Study_Data');
end
addpath .; cd(subname);

end