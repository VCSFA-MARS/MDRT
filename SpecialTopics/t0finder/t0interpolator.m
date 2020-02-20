%% t0interpolator determines the T0 time and automatically updates the 
%  timeline.mat file (if it exists)



%% Historical T0 times calculated with this script

% 2019/107/20:46:06.958094    CDTime_Time_Text                                                                 BA  - CDT Text                  ---------------- -000:00:00:00.003.                  
% 2019/107/20:46:06.968070    CDTime_Time_Text                                                                 BA  - CDT Text                  ---------------- +000:00:00:00.006.                  

% 2019/306/13:59:46.995857  -8.320654000000000244E-03, 
% 2019/306/13:59:47.005857   1.680005999999999947E-03, 

% 2020/046/20:21:00.999877  -2.734400000000000112E-04
% 2020/046/20:21:01.009884   9.734404000000000320E-03

%% Manually update CDT variables from retrieval file
%
%  Retrieval for "CDTime_Time_Analog" for values between -1 and 1
%  Find timestamps on either side of 0 (goes from - to +) and add to the
%  variables below. Future version will pull this automatically from a
%  delim file.

UTC1=makeMatlabTimeVector({'2020/046/20:21:00.999877'},0,0)
UTC2=makeMatlabTimeVector({'2020/046/20:21:01.009884'},0,0)
CDT1= -2.734400000000000112E-04
CDT2=  9.734404000000000320E-03

t = linterp(0,CDT1,UTC1,CDT2,UTC2);

datestr(t, 'HH:MM:SS.FFF')

%% Automatic Update of timeline file

config = MDRTConfig.getInstance;
[pth, fldr, b] = fileparts(config.userWorkingPath);
questStr = ['Automatically update timeline file in ', fldr];

result = questdlg(questStr, 'Proceed with auto-update', 'Yes', 'No', 'No')

if strcmpi(result, 'No')
    % Halt execution.
    return
end

timelineFullFile = fullfile(config.workingDataPath, 'timeline.mat');

if ~exist(timelineFullFile)
    % Halt execution
    disp('Timeline file not found');
    return
    
    % If this fails, add the option to generate a timeline file
    % timeline = newTimelineStructure
    % Make sure it's getting saved to the correct location?
end

try
    temp = load(timelineFullFile);
    timeline = temp.timeline;
catch
	disp('Unable to load timeline variable from file');
    return
end
   

% Update timeline structure

    timeline.uset0      = true;
    timeline.t0.time    = t;
    timeline.t0.name    = 'T0';
    timeline.t0.utc     = true;

save(timelineFullFile, 'timeline', '-mat');

disp(['Timeline file updated with T0 = ', datestr(t, 'yyyy mmm dd HH:MM:SS.FFF')])

