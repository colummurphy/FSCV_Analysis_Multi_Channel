function CM_updatePlots(app)

global plotParam processed hgui parameters

    channelsToDisplay = app.getChannelsToDisplay();
    plotParam.selch = channelsToDisplay;

    [processed.Iread, processed.LFPread, processed.samplesNCS]=...
        CM_loadall(app, hgui.PathName, hgui.FileName, parameters, plotParam.selch);

    % adapt code for t_start + t_end
    % t_start + t_end is recalculated in CM_loadall for 32 channels

    CM_compileloaded(hgui, app);

end