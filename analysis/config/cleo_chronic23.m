ncschannels={};

%get info on whether pc or some other system (ie. chunky) to determine dir
pctype=computer;
ispc=strcmpi(pctype,'pcwin64');
homedir='Z:';
if ~ispc
    homedir=[filesep 'smbshare'];
end
graserver='inj-monkey';
fscvdir='cleo_fscv';

paths{1}=fullfile(homedir,graserver,'raw',fscvdir,'cleo_chronic23_4ch_05102017','1dr','cvtotxt',filesep);
paths{2}=fullfile(homedir,graserver,'raw','cleo','2017-05-10_11-38-57',filesep);