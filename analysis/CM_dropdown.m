function CM_dropdown(app, appDesignColorFig, dopaminePlot)

global plotParam processed hgui parameters

    dropDownArray = app.getDropDownValues();
    dropDownLength = length(dropDownArray);

    channelsToDisplay = [];
    indexOfColorPlot = [];

    for i = 1 : dropDownLength

        channelValue = dropDownArray(i);

        if ~strcmp(channelValue, "X")
            channelsToDisplay = [channelsToDisplay, str2num(channelValue)];
            colorPlotIndex = [indexOfColorPlot, i];
        end
    end    

    plotParam.selch = channelsToDisplay;

    % send indexOfColorPlot to CM_compileloaded 

    [processed.Iread, processed.LFPread, processed.samplesNCS]=...
        loadall(hgui.PathName, hgui.FileName, parameters, plotParam.selch);

    CM_compileloaded(hgui, appDesignColorFig, dopaminePlot, indexOfColorPlot);

end

