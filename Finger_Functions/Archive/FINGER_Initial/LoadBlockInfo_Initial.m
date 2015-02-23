function bdata = LoadBlockInfo_Initial(subname,block_type_list)
%[desiredNote, desiredTime, actualNote, actualTime] = LoadHitTimes(filename)

 cd(strcat(subname,'001'));
 
 bdata_dir = dir(strcat(pwd,'/hittimes*.txt'));
 
 for j = 1:length(bdata_dir)
    hittime_files{j} = bdata_dir(j).name;
 end
 
 bdata.conds = [];
 for j = 1:length(hittime_files)
     
     [desiredNote, desiredTime, actualNote, actualTime] = textread(hittime_files{j},...
         '%f %f %f %f',40,'headerlines',1);
     
     bdata.blocks{j}.desiredNote = desiredNote';
     bdata.blocks{j}.desiredTime = desiredTime';
     bdata.blocks{j}.actualNote = actualNote';
     bdata.blocks{j}.actualTime = actualTime';
     
     bdata.blocks{j}.blockconds = block_type_list(j)*ones(1,length(desiredNote'));
     
     bdata.conds = [bdata.conds bdata.blocks{j}.blockconds];
     
     
     % Creates the inital robot setup note trial that does not exist
%      if cond == 1
%          BlockInfo{j}.conds = [2 BlockInfo{j}.conds];
%          BlockInfo{j}.desiredNote = [0 desiredNote]';
%          BlockInfo{j}.desiredTime = [0 desiredTime]';
%          BlockInfo{j}.actualNote = [0 actualNote]';
%          BlockInfo{j}.actualTime = [0 actualTime]';
%      end
 
 end
 
 cd ..
 
end

