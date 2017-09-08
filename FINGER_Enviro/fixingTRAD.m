%% Load in subject .mat data file
username = 'Sumner'; subname = 'TRAD';
setPathEnviro(username,subname);

%Read in .mat file
filename = celldir([subname '*.mat']);
for i = 1:2
    filename{i} = filename{i}(1:end-4);
    disp(['Loading ' filename{i} '...']);
    load(filename{i});
end

TRAD_20140421_0922_amff1 = TRAD_20140421_09221;
TRAD_20140421_0922_amff1Video_trigger = TRAD_20140421_09221Extension;
TRAD_20140421_0922_amff2 = TRAD_20140421_09222;
%TRAD_20140421_0922_amff2Video_trigger = TRAD_20140421_09222Extension;
%using video trigger from next song
TRAD_20140421_0922_amff2Video_trigger = TRAD_20140421_10161Video_trigger; 
TRAD_20140421_0922_amff3 = TRAD_20140421_10161;
TRAD_20140421_0922_amff3Video_trigger = TRAD_20140421_10161Video_trigger;
TRAD_20140421_0922_amff4 = TRAD_20140421_10162;
TRAD_20140421_0922_amff4Video_trigger = TRAD_20140421_10162Video_trigger;

save('TRAD 20140421 0922 a','Impedances_0',  'TRAD_20140421_0922_amff1',...
    'TRAD_20140421_0922_amff1Video_trigger', 'TRAD_20140421_0922_amff2',...
    'TRAD_20140421_0922_amff2Video_trigger', 'TRAD_20140421_0922_amff3',...
    'TRAD_20140421_0922_amff3Video_trigger', 'TRAD_20140421_0922_amff4',...
    'TRAD_20140421_0922_amff4Video_trigger', 'samplingRate');

TRAD_20140421_0922_bmff1 = TRAD_20140421_10163;
TRAD_20140421_0922_bmff1Video_trigger = TRAD_20140421_10163Video_trigger;
TRAD_20140421_0922_bmff2 = TRAD_20140421_10164;
TRAD_20140421_0922_bmff2Video_trigger = TRAD_20140421_10164Video_trigger;
TRAD_20140421_0922_bmff3 = TRAD_20140421_10165;
TRAD_20140421_0922_bmff3Video_trigger = TRAD_20140421_10165Video_trigger;

save('TRAD 20140421 0922 b', 'Impedances_0', 'TRAD_20140421_0922_bmff1',...
    'TRAD_20140421_0922_bmff1Video_trigger', 'TRAD_20140421_0922_bmff2',...
    'TRAD_20140421_0922_bmff2Video_trigger', 'TRAD_20140421_0922_bmff3',...
    'TRAD_20140421_0922_bmff3Video_trigger', 'samplingRate');