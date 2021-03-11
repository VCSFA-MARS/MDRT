
dataSets = ...
    {
        '/Users/nick/data/archive/2016-20-17 OA-5 LA1/data/';
        '/Users/nick/data/archive/2017-11-11 - OA-8 Scrub/data/';
        '/Users/nick/data/archive/2017-11-12 - OA-8 Launch/data/';
        '/Users/nick/data/archive/2018-05-20 - OA-9 Launch/data/';
        '/Users/nick/data/archive/2018-11-16 - NG-10 Launch/data/';
        '/Users/nick/data/archive/2019-04-16 - NG-11 Launch/data/';
        '/Users/nick/data/archive/2019-11-01 - NG-12/data/';
        '/Users/nick/data/archive/2020-02-09_NG-13/data/'
    };


valveList = ...
    {
        'DCVNO-2010';
        '2010 LO2 DCVNO-2010 Ball Valve Ctl Param.mat';
        '2010 LO2 DCVNO-2010 State.mat';
        'PCVNO-2013';
        '2013 LO2 PCVNO-2013 Globe Valve Cmd Param.mat';
        '2013 LO2 PCVNO-2013 Globe Valve Mon.mat';
        'PCVNO-2013';
        '2014 LO2 PCVNO-2014 Globe Valve Cmd Param.mat';
        '2014 LO2 PCVNO-2014 Globe Valve Mon.mat'
    };

temp = load(fullfile(dataSets{end},'timeline.mat'));
    timeline = temp.timeline;

temp = load(fullfile(dataSets{end},valveList{2}));
    fd = temp.fd;

oneHr  = 1/24;
oneMin = oneHr / 60;
oneSec = oneMin / 60;
    
candidates = find(diff(fd.ts.Data)<0);
candidates = candidates(timeline.t0.time - oneHr < candidates < timeline.t0.time + oneHr);




