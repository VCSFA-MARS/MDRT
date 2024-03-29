function TAMFDs = getTAMcontents(tamFolder)

if isempty(tamFolder)
    % Set a default folder for testing
    tamFolder = 'operations/2020-02-15_NG-13-Launch/NG13_Launch_server1/TAM/2020046_001840_1581725920/';
end

archiveBasePath = '/opt/archive/MARS-NAS/';

TAMdir = fullfile(archiveBasePath, tamFolder)
% TAMdir = '/opt/archive/MARS-NAS/operations/2020-02-15_NG-13-Launch/NG13_Launch_server1/TAM/2020046_001840_1581725920/';
Filebase = 'TAM';



%% Build command to be executed on retrieval server and execute via ssh

    % HistRetrieve    [-i|v|q] 
    %                 [-D] 
    %                 [-s[s]] 
    %                 [-p path] TAMdir
    %                 [-o output_file] 
    %                 [-b start_time] 
    %                 [-e end_time] 
    %                 [-f filebase] 'TAM'
    %                 parameter_file [parameter_file]



remoteCommand = ['HistRetrieve -ss -p ' TAMdir ' -f ' Filebase ]

[status,result] = system(['ssh -i id_rsa_mdrt fcsdev3 "' remoteCommand '"']);

disp('ssh command competed');

%% Pre-process
%   Some of the FD descriptions may have a pipe (|) character in them,
%   breaking the | delimited format. Damnit, CCT... You'd think they would
%   sanitize their strings for that... How does their code even work?
%
%   Find any lines that have too many | and use an outside->inside strategy
%   to keep the "real" ones and replace the bogus ones.
%
%   Example string: 
%   
%     1                                               2                                                                                           3*                     45    6 
%   Fd|LNSS Storage Tank Pressure Set Point Active Ind|Fusion determined Primary/Secondary Set Point  for LNSS Storage Tank Pressure {LNSS Tank [A|B] Pressure Set Point}||Meas|DISCRETE_TYPE

tempContents = textscan(result, '%s', 'HeaderLines', 4, 'Delimiter', '\n');
tempContents = tempContents{1};

for i = 1:length(tempContents)
	if length(strfind(tempContents{i}, '|')) > 5
        % Too many stupid | characters... wtf, CCT?
        % Guess what I'm gonna do? I might just skip the bloody thing.
       
        % Assume first 2 are correct (     Fd | FD   | ???? )
        % Assume last  3 are correct ( | unit | meas | type )
        
        ind = strfind(tempContents{i}, '|');
        
        ind(end - 2: end) = [];
        ind(1:2) = [];
        
        % Replace the offending characters
        for n = ind
            tempContents{i}(n) = '/';
        end
        
    else
        % Not checking for too few at this time.
    end
end



%% Create a table for use in retrieval generator

TAMcontents = textscan(sprintf('%s\n', tempContents{:}), ...
                        '%s %s %s %s %s %s',        ...
                        'delimiter',        '|',    ...
                        'headerlines',      6,      ...
                        'CollectOutput',    1);

                    
TAMFDs = table( TAMcontents{1}(:,2), ...
                TAMcontents{1}(:,3), ...
                TAMcontents{1}(:,4), ...
                TAMcontents{1}(:,5), ...
                TAMcontents{1}(:,6));
            
TAMFDs.Properties.VariableNames = {'FD', 'String', 'Unit', 'RetKind', 'Type'};
TAMFDs.Properties.RowNames = TAMFDs.FD;




