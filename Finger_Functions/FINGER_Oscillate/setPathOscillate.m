function setPathOscillate(username, subname)
% username as username (e.g. 'Sumner' or 'LAB')
% subname is 4 letter sub identifier as string (e.g. 'NORS')

switch username
    case 'Sumner'    
        cd('C:\Users\Sumner\Desktop\oscillateData'); 
    case 'LAB'
        cd('D:\Oscillate')
end

cd(subname);

end