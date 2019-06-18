
timelines = {
	'/Users/nick/data/archive/2019-04-16 - NG-11 Launch/data/timeline.mat';
	'/Users/nick/data/archive/2018-11-16 - NG-10 Launch/data/timeline.mat';
	'/Users/nick/data/archive/2018-05-20 - OA-9 Launch/data/timeline.mat';
	'/Users/nick/data/archive/2017-11-12 - OA-8 Launch/data/timeline.mat';
	'/Users/nick/data/archive/2016-20-17 OA-5 LA1/data/timeline.mat' ...
};

datafiles = {
	'/Users/nick/data/archive/2019-04-16 - NG-11 Launch/data/4901 Ghe PT-4901 Press Sensor Mon.mat';
	'/Users/nick/data/archive/2018-11-16 - NG-10 Launch/data/4901 Ghe PT-4901 Press Sensor Mon.mat';
	'/Users/nick/data/archive/2018-05-20 - OA-9 Launch/data/4901 Ghe PT-4901 Press Sensor Mon.mat';
	'/Users/nick/data/archive/2017-11-12 - OA-8 Launch/data/4901 Ghe PT-4901 Press Sensor Mon.mat';
	'/Users/nick/data/archive/2016-20-17 OA-5 LA1/data/4901 Ghe PT-4901 Press Sensor Mon.mat' ...
};

metafiles = {
	'/Users/nick/data/archive/2019-04-16 - NG-11 Launch/data/metadata.mat';
	'/Users/nick/data/archive/2018-11-16 - NG-10 Launch/data/metadata.mat';
	'/Users/nick/data/archive/2018-05-20 - OA-9 Launch/data/metadata.mat';
	'/Users/nick/data/archive/2017-11-12 - OA-8 Launch/data/metadata.mat';
	'/Users/nick/data/archive/2016-20-17 OA-5 LA1/data/metadata.mat'...
}; 


fig = makeMDRTPlotFigure;

colors = {      [0.0 0.0 0.9];
                [0.0 0.6 0.6];
                [0.5 0.0 0.5];
                [0.4 0.4 0.0];
                [0.3 0.3 0.3]...
             };
         
         
         
%	Page setup for landscape US Letter
        graphsInFigure = 1;
        graphsPlotGap = 0.05;
        GraphsPlotMargin = 0.06;
        numberOfSubplots = 1;
        
        legendFontSize = [8];
        
subPlotAxes = MDRTSubplot(numberOfSubplots,1,graphsPlotGap, ... 
                                GraphsPlotMargin,GraphsPlotMargin);
                            
    
            
        


load(timelines{1});

tf=timeline.t0.time;

for f = numel(timelines):-1:1
    load(timelines{f})
    load(datafiles{f})
    load(metafiles{f})
    
    deltaT = tf - timeline.t0.time;
    
    
    hold on;
    plot(fd.ts.Time + deltaT, fd.ts.Data, ...
            'Color',                colors{f}, ...
            'DisplayName',          metaData.operationName);
        
end

reviewPlotAllTimelineEvents(timeline)

dynamicDateTicks;
legend SHOW;

title('PT-4901 Data for A230 Launches - Drainback')
