%chronic 179 channels
%fscv chs p5, pl3, cl6
sessionnum=179;

ncschannels={'pl1-p5','p1-p5','p2-p5','cl1-cl4','cl3-cl4','cl4-cl6','cl3-cl6',...
    'eyex','eyed','lickx','pulse'};   %chronic65/67

letterdrive='Z:';   %COPYHERE
fscvdir='patra_fscv'; %COPYHERE

paths{1}=fullfile(letterdrive,'data_MIT',fscvdir,'patra_chronic179_11052018','1dr','cvtotxt',filesep); %COPYHERE

