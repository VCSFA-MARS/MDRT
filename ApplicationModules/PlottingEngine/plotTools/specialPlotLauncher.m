%% specialPlotLauncher
function specialPlotLauncher

hs.fig = figure('NumberTitle',  'off', ...
            'ToolBar',          'none', ...
            'MenuBar',          'none');
        
        guiSize = [300 200];
        hs.fig.Position = [hs.fig.Position(1:2) guiSize];
        hs.fig.Resize = 'off'
        hs.fig.Name = 'MDRT Specialty Plot Launcher';
        hs.fig.NumberTitle = 'off';
        hs.fig.MenuBar = 'none';
        hs.fig.ToolBar = 'none';
        hs.fig.Tag = 'specialPlotLauncher';    

   
        
        
specialPlots = { ...
    [10  10  100 30], '414 GN2 PHS',    @buttonCallback, '' ; ...
    [10  50  100 30], 'RP1 System',     @buttonCallback, '' ; ...
    [10  90  100 30], 'LO2 System',     @buttonCallback, '' ; ...
    [10 130  100 30], 'TEL Cylinders',  @buttonCallback, '' ; ...
    }
        
        
for s = 1:size(specialPlots,1)
    
    uicontrol(  'Style',        'pushbutton', ...
                'Position',     specialPlots{s, 1},...                
                'String',       specialPlots{s, 2},...                
                'Callback',     specialPlots{s, 3});       
    
end



    function buttonCallback(hobj, ~)

        if find(ismember(specialPlots(:,2), hobj.String))
            switch hobj.String
                case '414 GN2 PHS'
                    plotGN2PHS;
                case 'RP1 System'
                    plotRP1valves;
                case 'LO2 System'
                    plotLO2valves;
                case 'TEL Cylinders'
                    plotTELcyl;
            end
        end
    end

end