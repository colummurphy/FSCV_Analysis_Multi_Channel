function setfscvgui(fh,numcolor)
%set up figure & individual plots
global plotParam parameters hgui
set(0,'CurrentFigure',fh);    %set figure handle to current figure
hfig={};
hpos={};
hgui.loadedcsc=plotParam.cscNames;
plotsize=plotParam.colorplotsize;
widen=plotParam.widen;
figpos=get(fh,'position');
numcolor=4;
hgui.hf=fh;
hgui.txtpad=25;
%set up plotting axes
for ifig=1:numcolor
    %subplots 1, 4, 7, 10 are color plots
    hgui.hfig{ifig}=subplot(5,3,(ifig-1)*3+1);     %1, 4, 7, 10
end
hgui.titletext=subplot(5,3,2);
hgui.itplot=subplot(5,3,13);
hgui.cv=subplot(5,3,3);         
hgui.closeup{1}=subplot(5,3,6);         
hgui.data=subplot(5,3,9);         
hgui.closeup{2}=subplot(5,3,12);        
hgui.closeup{3}=subplot(5,3,15);    
hgui.fftplot=subplot(5,3,5);       

for ifig=1:numcolor
    hpos{ifig}=getpixelposition(hgui.hfig{ifig});
end
hpostitle=getpixelposition(hgui.titletext);
hposit=getpixelposition(hgui.itplot);
hposcv=getpixelposition(hgui.cv);
hposdata=getpixelposition(hgui.data);

hposcloseup{1}=getpixelposition(hgui.closeup{1});
hposcloseup{2}=getpixelposition(hgui.closeup{2});
hposcloseup{3}=getpixelposition(hgui.closeup{3});

%resize color plots stretch
margins=25;
titlewidth=450; titleheight=10;
xoff=70;
yoff=8;
yinitialoff=20;
countb=0;

%color plots hgui.hfig{1:4}
for ifig=1:numcolor
    set(hgui.hfig{ifig}, 'Units','Pixels','Position',  ...
        [hpos{ifig}(1)-xoff hpos{ifig}(2)-yoff*(ifig-1)-yinitialoff ...
        plotsize(1) plotsize(2)]);
    hpos{ifig}=getpixelposition(hgui.hfig{ifig});
    if ~ismember(ifig,plotParam.selch)
        set(hgui.hfig{ifig},'ytick',[],'xtick',[],'visible','off')
    end
end

%pca vs time plot hgui.itplot
set(hgui.itplot, 'Units','Pixels','Position',  ...
    [hposit(1)-xoff hposit(2)-yoff*(numcolor)-yinitialoff ...
    plotsize(1) plotsize(2)]);
    
%cv plot hgui.cv
set(hgui.cv, 'Units','Pixels','Position',  ...
    [hposcv(1)-220 hposcv(2)+10 plotsize(1) plotsize(2)]);
pos6=getpixelposition(hgui.cv);

%text data plot hgui.data
set(hgui.data, 'Units','Pixels','Position',  ...
    [pos6(1)+200 pos6(2)-10 plotsize(1) plotsize(2)]);

%close up plots for lfp/eye/lick/phys around plotParam.zoomTS
%first one also used for spectrogram plotting
set(hgui.closeup{1}, 'Units','Pixels','Position',  ...
    [hposcloseup{1}(1)-40-widen/2 hposcloseup{1}(2)-160 plotsize(1) plotsize(2)]);
set(hgui.closeup{2}, 'Units','Pixels','Position',  ...
    [hposcloseup{2}(1)-40-widen/2 hposcloseup{2}(2)-30 plotsize(1) plotsize(2)]);
set(hgui.closeup{3}, 'Units','Pixels','Position',  ...
    [hposcloseup{3}(1)-40-widen/2 hposcloseup{3}(2)-55 plotsize(1) plotsize(2)]);

%title text
set(hgui.titletext,'Units','Pixels','Position',...
    [figpos(3)-titlewidth figpos(4)-titleheight titlewidth titleheight]);
set(hgui.titletext,'ytick',[],'xtick',[],'visible','off')

%set up buttons
hgui.menu = uicontrol('Style', 'popup',...
   'String', {'menu','load file','load settings',...
   'save settings','select nlx chs',...
   'fft scale',...
   'detect da unbias (current window)','detect da unbias (entire file)',...
   'get xcov da w/ lfp (current window)','get xcov da w/ lfp (entire file)',...
   'get da and xcov for directory','load detected da auto dir',...
   'save detected da','load bad ids','save bad ids','save trials to xcel'},...
   'Position', [10 figpos(4)-25 100 25],...
   'Callback', @menuselect);  
%check plots if in plotParam.selch
for ich=1:numcolor
    plotvalue=0;
    if ismember(ich,plotParam.selch)
        plotvalue=1;
    end
    hgui.check{ich} = uicontrol('Style', 'checkbox','value',plotvalue,... 
        'string',['ch' num2str(ich)],'Position', [hpos{ich}(1)-50 ...
        hpos{ich}(2)+plotsize(2)-15 15 15],...
        'foregroundcolor',plotParam.colorFSCV(ich,:),...
        'backgroundcolor',plotParam.colorFSCV(ich,:),...
        'callback',@checkbox);  
    
    chlab=['ch' num2str(ich)];
    if ~isempty(plotParam.sites)
        chlab=plotParam.sites{ich};
    end
    checktxt = uicontrol('Style', 'text','string',chlab,...
        'Position', [hpos{ich}(1)-85 hpos{ich}(2)+plotsize(2)-15 30 15],...
        'backgroundcolor',[1 1 1],...
        'foregroundcolor',plotParam.colorFSCV(ich,:));  
    
        
end
%text inputs (time periods to plot & color max scale)
textt = uicontrol('Style', 'text',...
   'String', 'start / end (s)',...
   'Position', [200 figpos(4)-30 100 25],...
   'BackgroundColor', [ 1 1 1]);  
hgui.tstart = uicontrol('Style', 'edit',...
   'String', num2str(round(plotParam.t_start/parameters.samplerate)),...
   'Position', [290 figpos(4)-25 40 25]);  
hgui.tend = uicontrol('Style', 'edit',...
   'String', num2str(round(plotParam.t_end/parameters.samplerate)),...
   'Position', [330 figpos(4)-25 40 25]);  
texttclose = uicontrol('Style', 'text',...
   'String', 'close up',...
   'Position', [375 figpos(4)-30 55 25],...
   'BackgroundColor', [ 1 1 1]);  
hgui.zoomts(1) = uicontrol('Style', 'edit',...
   'String', num2str(round(plotParam.zoomTS(1))),...
   'Position', [430 figpos(4)-25 40 25]);  
hgui.zoomts(2) = uicontrol('Style', 'edit',...
   'String', num2str(round(plotParam.zoomTS(2))),...
   'Position', [470 figpos(4)-25 40 25]);  

hgui.refresh=uicontrol('style','pushbutton','string','refresh',...
    'position',[620 figpos(4)-25 50 25],'callback',@refreshbutton);

textcm = uicontrol('Style', 'text',...
   'String', 'I max',...
   'Position', [520 figpos(4)-30 40 25],...
   'BackgroundColor', [ 1 1 1]);  
hgui.cmax = uicontrol('Style', 'edit',...
   'String', num2str(plotParam.cmax),...
   'Position', [560 figpos(4)-25 25 25]);  

%FFT text / options on close up axes
textfft = uicontrol('Style', 'text',...
   'String', 'fft ',...
   'Position', [figpos(3)-55 ...
   hposcloseup{1}(2)+plotsize(2) 35 25],...
   'BackgroundColor', [ 1 1 1]);
hgui.checkfft = uicontrol('Style', 'checkbox','value',plotParam.buttonm,... 
    'Position', [figpos(3)-25 ...
   hposcloseup{1}(2)+plotsize(2)+10 15 15], ...
   'backgroundcolor',[1 1 1]); 
blsub = uicontrol('Style', 'text',...
   'String', 'bl ',...
   'Position', [figpos(3)-55 ...
   hposcloseup{1}(2)+plotsize(2)+25 35 25],...
   'BackgroundColor', [ 1 1 1]);
hgui.blsub = uicontrol('Style', 'checkbox','value',plotParam.blsub,... 
    'Position', [figpos(3)-25 ...
   hposcloseup{1}(2)+plotsize(2)+35 15 15], ...
   'backgroundcolor',[1 1 1]); 
hgui.fftlimsdown = uicontrol('Style', 'edit',...
   'String', num2str(plotParam.fftclim(1)),...
   'Position', [figpos(3)-50 ...
   hposcloseup{1}(2)+plotsize(2)-120 40 25]);  
hgui.fftlimsup = uicontrol('Style', 'edit',...
   'String', num2str(plotParam.fftclim(2)),...
   'Position', [figpos(3)-50 ...
   hposcloseup{1}(2)+plotsize(2)-90 40 25]);  
%{
hgui.mcsc=uicontrol('Style', 'edit',...
   'String', plotParam.mcsc,...
   'Position', [figpos(3)-90 ...
   hposcloseup{1}(2)+plotsize(2)-20 80 25]);  
   %}
   if ~isempty(hgui.loadedcsc)
hgui.mcsc=hgui.loadedcsc{randi(length(hgui.loadedcsc),1,1)}; %plot random channel from those listed
   else
       hgui.mcsc='';
   end
hgui.dispch = uicontrol('Style', 'text',...
   'String', hgui.mcsc,...
   'Position', [figpos(3)-45 ...
   hposcloseup{1}(2)+65+plotsize(2) 35 25],...
   'BackgroundColor', [ 1 1 1]);
%set up menu for fft channel to plot
hgui.cscmenu = uicontrol('Style', 'popup',...
   'String', hgui.loadedcsc,...
   'Position', [figpos(3)-65 ...
   hposcloseup{1}(2)+plotsize(2)-25 60 25],...
   'Callback', @cscselect);  

%fft position
fftsize=[500 250];
set(hgui.fftplot,'units','pixels');
fftpos=get(hgui.fftplot,'position');
set(hgui.fftplot, 'Units','Pixels','Position',  ...
    [hposcloseup{1}(1)-40-widen/2 hposcloseup{1}(2)+5 fftsize(1) fftsize(2)]);
set(hgui.fftplot, 'visible','off', 'box','off','xtick',[],'ytick',[]);  %make invisble until prompted


%scales for lfp plots
textfilt=uicontrol('Style', 'text',...
   'String', 'bpf hz',...
   'Position', [hposcloseup{1}(1)-310 ...
   hposcloseup{1}(2)-340 55 25],...
   'BackgroundColor', [ 1 1 1]);
hgui.bpf(1) = uicontrol('Style', 'edit',...
   'String', num2str(plotParam.filtlfp(1)),...
   'Position', [hposcloseup{1}(1)-300 ...
   hposcloseup{1}(2)-360 30 25]);  
hgui.bpf(2) = uicontrol('Style', 'edit',...
   'String', num2str(plotParam.filtlfp(2)),...
   'Position', [hposcloseup{1}(1)-300 ...
   hposcloseup{1}(2)-390 30 25]);  
textlfpscale = uicontrol('Style', 'text',...
   'String', 'v^2',...
   'Position', [figpos(3)-55 ...
   hposcloseup{1}(2)-190 65 25],...
   'BackgroundColor', [ 1 1 1]);
hgui.powerscale(1) = uicontrol('Style', 'edit',...
   'String', num2str(plotParam.powerscale(1)),...
   'Position', [figpos(3)-50 ...
   hposcloseup{1}(2)-210 40 25]);  
hgui.powerscale(2) = uicontrol('Style', 'edit',...
   'String', num2str(plotParam.powerscale(2)),...
   'Position', [figpos(3)-50 ...
   hposcloseup{1}(2)-240 40 25]);  
textlfpscale = uicontrol('Style', 'text',...
   'String', 'v',...
   'Position', [figpos(3)-55 ...
   hposcloseup{1}(2)-20 65 25],...
   'BackgroundColor', [ 1 1 1]);
hgui.LFPscale(1) = uicontrol('Style', 'edit',...
   'String', num2str(plotParam.LFPscale(1)),...
   'Position', [figpos(3)-50 ...
   hposcloseup{1}(2)-40 40 25]);  
hgui.LFPscale(2) = uicontrol('Style', 'edit',...
   'String', num2str(plotParam.LFPscale(2)),...
   'Position', [figpos(3)-50 ...
   hposcloseup{1}(2)-70 40 25]);  
hposit=getpixelposition(hgui.itplot);

%plot bad ids
 hgui.badplot= uicontrol('Style', 'togglebutton','value',0,... 
        'string','m','Position', [hposit(1)-70 ...
        hposit(2)+plotsize(2)-25 25 25],...        
        'callback',@togglem);  
%erase detected peaks based on bad ids identified
 hgui.erase= uicontrol('Style', 'togglebutton','value',0,... 
        'string','E','Position', [hposit(1)-100 ...
        hposit(2)+plotsize(2)-25 25 25],...        
        'callback',@togglee);  
%scroll time windows
 hgui.lscroll= uicontrol('Style', 'pushbutton',... 
        'string','<<','Position', [hposit(1)-100 ...
        hposit(2) 25 25],...        
        'callback',@scroll); 
  hgui.rscroll= uicontrol('Style', 'pushbutton',... 
        'string','>>','Position', [hposit(1)-70 ...
        hposit(2) 25 25],...        
        'callback',@scroll); 
       
%text legend for lfp traces plotted
%updatelegends(hgui);
updatelegends;

%{
cscnames=plotParam.cscNames;
lfpid=plotParam.lfpid;
physid=plotParam.physid;
colortab=plotParam.colormaptab;
txtpad=30;
for ii=1:length(lfpid)
hgui.labelslfp{ii}= uicontrol('Style', 'text',...
   'String', cscnames{lfpid(ii)},'fontangle','italic',...
   'Position', [figpos(3)-60 ...
   hposcloseup{1}(2)-50-txtpad*(ii-1) 60 25],...
   'BackgroundColor', [ 1 1 1],'foregroundcolor',colortab(ii,:));
end
for ii=1:length(physid)
hgui.labelslfp{ii}= uicontrol('Style', 'text',...
   'String', cscnames{physid(ii)},'fontangle','italic',...
   'Position', [figpos(3)-60 ...
   hposcloseup{1}(2)-450-txtpad*(ii-1) 60 25],...
   'BackgroundColor', [ 1 1 1],'foregroundcolor',colortab(ii,:));
end
hgui.txtpad=txtpad;
%}
colormap(plotParam.map)


end
