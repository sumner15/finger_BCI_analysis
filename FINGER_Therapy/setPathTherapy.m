function setPathTherapy(username,subname)

if nargin == 0
    username = 'LAB';
    disp('assuming username ''LAB''');
end

switch username
    case 'Sumner'        
        if ispc==1                     
            cd('C:\Users\Sumner\Desktop\fingerTherapyData')
        else
            cd('/Users/sum/Desktop/fingerTherapyData');            
        end
    case 'Omar'
        cd('/Users/omarshanta/Desktop/fingerTherapyData');              
    case 'Camilo'
        cd('C:\Users\Camilo\Desktop\fingerTherapyData') 
    case 'Thuong'
        cd('C:\Users\Thuong\Desktop\fingerTherapyData');        
    case 'LAB'
        cd('D:\FINGER_therapy');    
    otherwise
        disp('Invalid username selected');
        error('Invalid username');
end
addpath(cd); 

if nargin==2
    cd(subname);   
end

end