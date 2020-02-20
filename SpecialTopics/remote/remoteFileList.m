% list files in user directory on remote server

% [status,result] = system('ssh -i id_rsa_mdrt ops1@fcsdev3 "ls" 2>/dev/null')


TAMdir = '/opt/archive/MARS-NAS/operations/2020-02-15_NG-13-Launch/NG13_Launch_server1/TAM/2020046_001840_1581725920/';
Filebase = 'TAM';


 
% HistRetrieve    [-i|v|q] 
%                 [-D] 
%                 [-s[s]] 
%                 [-p path] TAMdir
%                 [-o output_file] 
%                 [-b start_time] 
%                 [-e end_time] 
%                 [-f filebase] 'TAM'
%                 parameter_file [parameter_file]

remoteCommand = ['HistRetrieve -ss -p' TAMdir ' -f ' Filebase ];

[status,result] = system(['ssh -i id_rsa_mdrt ops1@fcsdev3 "' remoteCommand '"'])