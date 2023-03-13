function []= CM_mouseclick(app, typeOfClick, plotPosOnFigure, clickPosOnPlot)

global plotParam processed hgui parameters

%{  
    Input Parameters: 
    typeOfClick     'normal' (left), 'alt' (right), 'extend' (center)
    plotPosOnFigure [left bottom width height] pixels 
    clickPosOnPlot  [x, y] pixels

    Function backgrounds the data with a left mouse click.
    The color plots are replotted.

    Function updates the CV + data with a right mouse click.
%}


% appDesColorFig = app.getColorPlots();

colorPlots = app.getColorPlots();
colorPlotIndices = app.getIndicesOfColorPlots();

appDesCvPlot = app.getCvPlot();
appDesDataTable = app.getDataTable(); 
appDesDopaminePlot = app.getDopaminePlot();



% if left click, clktype = 0, otherwise clktype = 1.
if strcmpi(typeOfClick,'normal')
    clktype=0;
else
    clktype=1;
end

 
% relative position mapped to data domain
% xsel = round ( xPosOnPlot / widthOfPlotInPixels * (601 - 1)
xsel = round( ( clickPosOnPlot(1) / plotPosOnFigure(3) )... 
                * (plotParam.t_end - plotParam.t_start) );

ysel = clickPosOnPlot(2);

% store click position + type in plotParam
plotParam.xsel=xsel;
plotParam.ysel = ysel;
plotParam.clktype = clktype;

% display x (0 - 600), y (pixels), clk (0 - 1) 
disp(['x: ' num2str(xsel) ' | y: ' num2str(ysel) ' | clk: ' num2str(clktype)])



% selch=[1 2 3 4]
selch=plotParam.selch;

% if left click, backgound data at xsel, 
if clktype==0
 
    % for each channel - 1 to 4 
    for ii=1:length(selch)

        % This function performs the backgounding of the data.
        % Each channel generates a different background vector and matrix.
        % There is one xsel value for all plots, they are all 
        % backgrounded at the same x point.
        % xsel value is acquired from plotParam.xsel in the refreshfscv function.
        
        [processed.Isub(selch(ii)).data, processed.BG(selch(ii)).data]=...
            refreshfscv(processed.Iread(selch(ii)).data(:,plotParam.t_start:plotParam.t_end),...
            plotParam); %based on updated xsel & tstart/tend range
              
        
        colorPlotIndex = colorPlotIndices(ii);
        colorPlot = colorPlots(colorPlotIndex);

        % Plot backgounded data (processed.Isub(selch(ii)).data)
        % CM_setguicolorplot( appDesColorFig(selch(ii)),...
        %                     processed.Isub(selch(ii)).data, ii );  

        CM_setguicolorplot(app, colorPlot, processed.Isub(selch(ii)).data, ii); 
    end



% Other type of mouse click, right OR both buttons
% get CV plot, plot dopamine and get noise data
else

    % clear CV and dopamine plots    
    cla(appDesCvPlot);    
    cla(appDesDopaminePlot);

    % for each channel, selected
    for ii=1:length(selch)

        % Get the CV for the channel using the backgrounded data.
        % A window of 3 CV's is selected at the x point.
        % The CV returned is averaged accross a window of 3 CVs.
        processed.cv{selch(ii)}=getcv(...
            processed.Isub(selch(ii)).data,...
            parameters,plotParam);
        
            
        % Plot cv data to appDesCvPlot
        CM_setguicv(appDesCvPlot, processed.cv{selch(ii)}, ...
                    parameters, plotParam.colorFSCV(selch(ii), :));  
        
        % calculate pcr for 4 channels
        if (app.getNumOfChannels() == 4)

            %check if already detected signals for plotting
            detected=[];
            
            % false
            if isfield(processed,'detected')    
              if ~isempty(processed.detected)
                if ii<=length(processed.detected)
                  if ~isempty(processed.detected{selch(ii)})
                    if isfield(processed.detected{selch(ii)},'maxTS')
                      detected=round((processed.detected{selch(ii)}.maxTS-...
                      processed.LFPread.LFPts(1)).*parameters.samplerate...
                      -plotParam.t_start+2);
                    end
                  end
                end
              end
            end
     

            % compute pca    
            hfwidth=[];
    
            if isfield(parameters,'hfwidth')
                hfwidth=parameters.hfwidth;
            end
            processed.Ipcr{selch(ii)} = ...
                getpct(processed.Iread(selch(ii)).rawdata(:,plotParam.t_start:plotParam.t_end),...
                processed.Isub(selch(ii)).data,...
                processed.BG(selch(ii)).data,parameters,selch(ii),...
                'removebgph','nanwidth',8,'glitchwidth',hfwidth);
      
            % plot pca computed concentrations of indicated window
            if isfield(processed,'detected')
                if ~isempty(processed.detected{selch(ii)}.maxTS)
                    CM_setguipct(appDesDopaminePlot, processed.Ipcr{selch(ii)},plotParam, ...
                    parameters,plotParam.colorFSCV((selch(ii)-4*(ceil(selch(ii)/4)-1)),:),...
                    'detected',round((processed.detected{selch(ii)}.maxTS-...
                    processed.LFPread.LFPts(1)).*parameters.samplerate...
                    -plotParam.t_start+2),'plotnum',ii);            
                else
                    CM_setguipct(appDesDopaminePlot, processed.Ipcr{selch(ii)},plotParam, parameters,...
                    plotParam.colorFSCV((selch(ii)-4*(ceil(selch(ii)/4)-1)),:),'plotnum',ii); 
                end
            else
                CM_setguipct(appDesDopaminePlot, processed.Ipcr{selch(ii)},plotParam, parameters,...
                    plotParam.colorFSCV((selch(ii)-4*(ceil(selch(ii)/4)-1)),:),'plotnum',ii); 
            end
        end        
    end

    
    % data table requires pca data
    if (app.getNumOfChannels() == 4)

        % Calculate data 
        processed.info=calcdata(processed.Iread, processed.Isub, processed.cv, selch);   
        
        % plot the data  
        CM_setguidata(appDesDataTable, processed.info, [parameters.Vrange parameters.Vrange_cathodal])      
    end

end

end