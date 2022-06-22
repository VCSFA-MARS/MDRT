% TELForceComparisons plots cylinder forces and the delta for multiple
% missions.
%
%   Requires the following TEL FDs:
%         TELHS VXP1_FORCE_CYL_A Mon
%         TELHS VXP1_FORCE_CYL_B Mon
%         TELHS TEL_POS Mon
%
% Current version requires manually editing the dataSetPath array

dataSetPath = {
'/Users/nick/data/TEL_Historical/2022-02-18 - NG17 Lift 2/data';
'/Users/nick/data/TEL_Historical/2022-02-15 - NG17 Lift 1/data';
'/Users/nick/data/TEL_Historical/2021-08-07 - NG16 Lift 2/data';
'/Users/nick/data/TEL_Historical/2021-08-06 - NG16 Lift 1/data';
'/Users/nick/data/TEL_Historical/2021-02-19 - NG15 Lift 2/data';
'/Users/nick/data/TEL_Historical/2020-10-03 - NG14 Lift 2/data';
'/Users/nick/data/TEL_Historical/2020-09-26 - NG14 Lift 1/data';
'/Users/nick/data/TEL_Historical/2020-02-14 - NG13 Lift 3/data';
'/Users/nick/data/TEL_Historical/2020-02-09 - NG13 Lift 2/data';
};



markers = {'+', 'x', '^'};
markerInd = 0;

colors = {  [0      0       1   ];
            [0      0.5     0   ];
            [0.75   0       0.75];
            [0      0.75    0.75]; 
            [0.68   0.46    0   ];
         };
     
colorInd = 0;

     
subplotTitles = {'Cyl A', 'Cyl B', 'Force Delta'};
[hax, hfig, haxpair] = makeManyMDRTSubplots(subplotTitles, 'TELHS Cyl Force vs Position', ...
    'plotshigh',        3, ...
    'groupAxesBy',      3, ...
    'mdrtPairs',        true );



hold on;

% Loop through each data set:

oldSet = '';

for setnum = 1:numel(dataSetPath)

    load(fullfile(dataSetPath{setnum}, 'TELHS VXP1_FORCE_CYL_A Mon.mat'))
    forcea = fd.ts;

    load(fullfile(dataSetPath{setnum}, 'TELHS VXP1_FORCE_CYL_B Mon.mat'))
    forceb = fd.ts;

    load(fullfile(dataSetPath{setnum}, 'TELHS TEL_POS Mon.mat'))
    telpos = fd.ts;
    
    load(fullfile(dataSetPath{setnum}, 'metadata.mat'))
    
    %% New color for each mission, change marker for each lift
    newSet = regexp(metaData.operationName, 'NG[-]?\d*', 'match');
    if strcmpi(newSet, oldSet)
        % Same Launch/Mission
        markerInd = markerInd + 1;
    else
        % New Launch/Mission
        fprintf('Changed to mission %s, advancing color\n', newSet{1})
        colorInd = colorInd + 1;
        markerInd = 1;
    end
    
    if colorInd > length(colors)
        colorInd = 1;
    end
    
    if markerInd > length(markers)
        markerInd = 1;
    end

    %% Intersection - find points for comparison
    [~, posind,  forceinda] = intersect(telpos.Time, forcea.Time);
    [~, posindb, forceindb] = intersect(telpos.Time, forcea.Time);

    scatter(haxpair(1), telpos.Data(posind), forcea.Data(forceinda), ...
            markers{markerInd}, ...
            'markerEdgeColor',      colors{colorInd}, ...
            'displayname',          metaData.operationName);
        
   
    scatter(haxpair(2), telpos.Data(posindb), forceb.Data(forceindb), ...
            markers{markerInd}, ...
            'markerEdgeColor',      colors{colorInd}, ...
            'displayname',          metaData.operationName);
	
	
    scatter(haxpair(3), telpos.Data(posind), forceb.Data(forceindb) - forcea.Data(forceinda), ...
            markers{markerInd}, ...
            'markerEdgeColor',      colors{colorInd}, ...
            'displayname',          metaData.operationName);
        
    oldSet = newSet;

end


%% Update Axes Visual Properties

for axind = 1:numel(haxpair)
    legend(haxpair(axind), 'show')
    haxpair(axind).XTickLabelMode = 'auto';
    haxpair(axind).Title.String = subplotTitles{axind};
    haxpair(axind).XLabel.String = 'Position (in inches)';
    haxpair(axind).YLabel.String = 'Force (in lbf)';
end

linkaxes(haxpair, 'x')

