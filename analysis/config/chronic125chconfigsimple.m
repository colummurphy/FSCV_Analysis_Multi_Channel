sessionnum=125;

ncschannels={'p1-p3','p2-p3','pl2-p1','pl2-pl3','p1-pl3',...
    'cl1-cl4','cl4-cl5','cl1-cl5',...
    'eyex','eyed','lickx','pulse'};  

%get info on whether pc or some other system (ie. chunky) to determine dir
letterdrive='Z:';
fscvdir='patra_fscv';

%paths{1}='\Users\colum\Documents\MATLAB\data_MIT\patra_fscv\patra_chronic125_08102018\1dr\cvtotxt\matlab\smallreward_pro\'
paths{1}=fullfile('Users','colum','Documents','MATLAB','data_MIT',fscvdir,'patra_chronic125_08102018','1dr','cvtotxt',filesep);
%paths{2}=fullfile(homedir,graserver,'patra2','2018-07-25_11-06-05',filesep);