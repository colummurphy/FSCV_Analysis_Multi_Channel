function extractsession(sessnum,varargin)
%script to run all functions to get compiled trial data lfp/da
%After running syncsigs to get "raw data" to make individual bigreward/smallreward/etc.
%folders
%assume patra recording
%05/31/2021, add spike extraction, only for whole file--use original marker
%timestamps,etc. also output interpolated data used for spike extraction in
%separate folder for temporary storage/validation
sessid=num2str(sessnum);
doreconvert=1;
doauto=1;
docompile=1;
argnum=1;
alltypes=1;
nlxsel=0;           %specify selective chs or get from chronic..config
nlxchsel=[];
chs=[1 2 3 4];
types={'big','small','targetbreak','fixbreak','fixedintervals'};      
numpcs=3;
nofscv=0;
getspikes=0;
while argnum<=length(varargin)
    switch varargin{argnum}
        case 'compile'
            %only run compiletrials
            doreconvert=0;
            doauto=0;
            docompile=1;
        case 'autocompile'
            %run auto and compile
            doauto=1;
            docompile=1;
            doreconvert=0;
        case 'types'
            %user provides trial types to process
            argnum=argnum+1;
            alltypes=0;
            types=varargin{argnum};       
        case 'fscvchs'
            argnum=argnum+1;    %user provides fscv chs selected
            chs=varargin{argnum};
        case 'nlxsel'
            %only reconvert specified nl channels, not reconverting da
            %again, specified as e.g. {'cl4-cl6','cl1-cl4'}
            argnum=argnum+1;
            nlxchsel=varargin{argnum};
        case 'numpcs'
            %# pcs to use in autotrialdir
            argnum=argnum+1;
            numpcs=varargin{argnum};
        case 'nofscv'
            nofscv=1;
        case 'getspikes'
            getspikes=1;
    end
    argnum=argnum+1;
end

%get dir with config files
pctype=computer;
ispc=strcmpi(pctype,'pcwin64');
%default on putamen pc in lab
configdir='A:\mit\injectrode\experiments\fscv\matlab\analysis\analysis\config\';
if ~ispc
    %chunky dir
    configdir=fullfile(filesep,'home','schwerdt','matlab','analysis','analysis','config',filesep);
end

d=dir(configdir);
cd(configdir);
filenames={d.name};
targfiles=strfind(filenames,['chronic' sessid 'chconfig']);
processfiles=find(~cellfun(@isempty,targfiles));
targconfigname=filenames{processfiles};
run([configdir targconfigname]);            %MUST BE RUN FIRST FOR SESSIONNUM
run([configdir 'patra_map_bipolar']);   %run patra_map_bipolar for ch settings
%run config file to get ncschannels & paths

targpath={};
if ~isempty(types)
    %set path names for different trial types folders
    for itype=1:length(types)
        name=types{itype};
        if strcmp(name,'big') || strcmp(name,'small')
            name=[name 'reward'];
        end
        targpath=setfield(targpath,types{itype},...
            fullfile(paths{1}, 'matlab',name,filesep));
    end
end

assignin('base','fcnStatus',targpath)   %store targpath in workspace

trialtypes=fieldnames(targpath);
numtypes=length(trialtypes);

%auto & compile trials
for ii=1:numtypes
    currpath=getfield(targpath,trialtypes{ii});
    disp(currpath)
    if ~isdir(currpath)
        %files/folder not created by sync sigs, skip
        disp(['folder not created, skipping : ' char(10) currpath]);
        continue
    end
    %reconvert directory
    if doreconvert
        disp(['reconvert ' trialtypes{ii}])
        if ~nofscv
            if ~nlxsel
                reconvertfscv(currpath,ncschannels,'map',csc_map,'split')
            else
                %only reconvert select nlx chs, no da
                    %already previously reconverted everything lese
                    %already ran syncsigs again (by default merges everything..
                    %so have to run all chs in this step)
                reconvertfscv(currpath,nlxchsel,'map',csc_map,'split','nlxchsel')
            end
        else
            reconvertfscv(currpath,ncschannels,'map',csc_map,'split','nofscv')
        end

    end
    pathauto=[currpath(1:end-1) '_pro' filesep];
    if doauto
        if strcmp(trialtypes{ii},'fixedintervals')
            %no autotrial for fixed intervals
            continue
        end 
        disp(['auto trial ' trialtypes{ii}])
        if ~nofscv
            autotrialdir(pathauto,'fscvchs',chs,'numpcs',numpcs)
        else
             autotrialdir(pathauto,'fscvchs',chs,'numpcs',numpcs,'nofscv')
        end
        
    end
    pathcomp=[pathauto 'analyzed' filesep];
    if docompile
        if strcmp(trialtypes{ii},'fixedintervals')
            %no autotrial for fixed intervals
            continue
        end 
        disp(['compile trials ' trialtypes{ii}])
        if ~nofscv
            compiletrialsdir(pathcomp)
        else
            compiletrialsdir(pathcomp,'nofscv')
        end
    end
end

end
