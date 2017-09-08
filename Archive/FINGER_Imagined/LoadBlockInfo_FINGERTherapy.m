function bdata = LoadBlockInfo(subname,block_type_list)
%bdata = LoadBlockInfo(subname,block_type_list)

% 1 = imagery
% 2 = resting
% 3 = active

 if ispc == 1
    %cd E:\FINGER_data\FINGER_EEG_imagery_data\
    cd C:\Users\Sumner\Desktop\FINGER-EEG study\JOHG\Exam 1
 else
    cd ~/Documents/MATLAB/FINGER_data/FINGER_EEG_imagery_data/
 
 end
 
 %cd(strcat(subname,'002'));
 cd(strcat(subname,'\Exam 1'));
 
 if ispc == 1
    bdata_dir = dir(strcat(pwd,'\hittimes*.txt'));
 else
    bdata_dir = dir(strcat(pwd,'/hittimes*.txt'));
 end
 
 for j = 1:length(bdata_dir)
    hittime_files{j} = bdata_dir(j).name;
 end
 
 bdata.conds = [];
 bdata.deltaTime = [];
 bdata.condsEL = [];
 for j = 1:length(hittime_files)
     
     if ismember(block_type_list(j),[1 2])
        [desiredNote, desiredTime, actualNote, actualTime] = textread(hittime_files{j},...
            '%f %f %f %f',1,'headerlines',1);
        if block_type_list(j) == 1
            bdata.condsEL = [bdata.condsEL ones(1,40)];
        elseif block_type_list(j) == 2
            bdata.condsEL = [bdata.condsEL 2*ones(1,40)];
        end
        
     else
        [desiredNote, desiredTime, actualNote, actualTime] = textread(hittime_files{j},...
            '%f %f %f %f',40,'headerlines',1);
        
        bdata.deltaTime = [bdata.deltaTime; desiredTime - actualTime];
     end
     
     
     bdata.mediantime = median(bdata.deltaTime);
     
     for k = 1:length(desiredTime)
         if (desiredTime(k)-actualTime(k)) <= median(bdata.deltaTime);
             bdata.condsEL = [bdata.condsEL 3];
         elseif (desiredTime(k)-actualTime(k)) > median(bdata.deltaTime);
             bdata.condsEL = [bdata.condsEL 4];
         end
     end
     
     bdata.blocks{j}.desiredNote = desiredNote';
     bdata.blocks{j}.desiredTime = desiredTime';
     bdata.blocks{j}.actualNote = actualNote';
     bdata.blocks{j}.actualTime = actualTime';
     
     bdata.blocks{j}.blockconds = block_type_list(j)*ones(1,40);
     
     bdata.conds = [bdata.conds bdata.blocks{j}.blockconds];
 
 end
 
 bdata.deltaTime = bdata.deltaTime';

 save(strcat(subname,'_002_bdata'),'bdata');
 disp(strcat(subname,'_002_bdata.mat saved.'));
 
 cd ..
 cd ..
 
end

